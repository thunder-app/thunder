import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Optimistically resolves a post report. This changes the value of the report locally, without sending the network request.
ThunderReport optimisticallyResolveReport(ThunderReport report, bool resolved) {
  return report.copyWith(resolved: resolved);
}

bool shouldSkipPagination({
  required bool isFetching,
  required bool hasReachedReportsEnd,
}) {
  if (isFetching) {
    return true;
  }

  if (hasReachedReportsEnd) {
    return true;
  }

  return false;
}

List<ThunderReport> appendReports({
  required List<ThunderReport> current,
  required List<ThunderReport> incoming,
}) {
  return [...current, ...incoming];
}

List<T> replaceAt<T>({
  required List<T> source,
  required int index,
  required T value,
}) {
  final updated = List<T>.from(source);
  updated[index] = value;
  return updated;
}
