import 'package:thunder/src/foundation/primitives/primitives.dart';

bool shouldSkipPagination({
  required bool isFetching,
  required bool hasReachedPostReportsEnd,
  required bool hasReachedCommentReportsEnd,
  required bool isPostFeed,
}) {
  if (isFetching) {
    return true;
  }

  if (hasReachedPostReportsEnd && isPostFeed) {
    return true;
  }

  if (hasReachedCommentReportsEnd && !isPostFeed) {
    return true;
  }

  return false;
}

List<ThunderPostReport> appendPostReports({
  required List<ThunderPostReport> current,
  required List<ThunderPostReport> incoming,
}) {
  return [...current, ...incoming];
}

List<ThunderCommentReport> appendCommentReports({
  required List<ThunderCommentReport> current,
  required List<ThunderCommentReport> incoming,
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
