import 'dart:async';

bool shouldSkipFetch({
  required bool currentlyLoading,
  required int page,
}) {
  return currentlyLoading && page != 1;
}

List<T> previousItemsForPage<T>({
  required int page,
  required List<T> currentItems,
}) {
  return page == 1 ? <T>[] : List<T>.from(currentItems);
}

bool hasReachedEnd({
  required int fetchedCount,
  required int pageLimit,
}) {
  return fetchedCount == 0 || fetchedCount < pageLimit;
}

Future<List<TResolved>> resolveInBatches<TSource, TResolved>({
  required List<TSource> source,
  required int batchSize,
  required Future<TResolved?> Function(TSource item) resolver,
  FutureOr<void> Function(List<TResolved> resolvedItems)? onBatchResolved,
}) async {
  final resolvedItems = <TResolved>[];

  for (var i = 0; i < source.length; i += batchSize) {
    final end = (i + batchSize < source.length) ? i + batchSize : source.length;
    final batch = source.sublist(i, end);
    final resolvedBatch = await Future.wait(batch.map(resolver));

    resolvedItems.addAll(resolvedBatch.whereType<TResolved>());

    if (onBatchResolved != null) {
      await onBatchResolved(List<TResolved>.from(resolvedItems));
    }
  }

  return resolvedItems;
}
