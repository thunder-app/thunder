import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Helper function which handles the logic of fetching post/comment reports
Future<ThunderPage<ThunderReport>> fetchReports({
  required Account account,
  int page = 1,
  String? cursor,
  int limit = 10,
  bool unresolved = false,
  int? communityId,
  int? postId,
  int? commentId,
  ReportFeedType reportFeedType = ReportFeedType.post,
}) async {
  final api = ApiClientFactory.create(account);
  final kind = switch (reportFeedType) {
    ReportFeedType.post => ReportKind.post,
    ReportFeedType.comment => ReportKind.comment,
  };

  if ((kind == ReportKind.post && !api.supportsPostReports) || (kind == ReportKind.comment && !api.supportsCommentReports)) {
    throw UnsupportedFeatureException('${kind.name} reports', platformName: api.platformName);
  }

  return await api.getReports(
    kind: kind,
    postId: postId,
    commentId: commentId,
    page: page,
    cursor: cursor,
    limit: limit,
    unresolved: unresolved,
    communityId: communityId,
  );
}

// Optimistically resolves a post report. This changes the value of the post report locally, without sending the network request
ThunderReport optimisticallyResolveReport(ThunderReport report, bool resolved) {
  return report.copyWith(resolved: resolved);
}

/// Logic to resolve a report
Future<bool> resolveReport(Account account, ThunderReport report, bool resolved) async {
  final response = await ApiClientFactory.create(account).resolveReport(reportId: report.id, kind: report.kind, resolved: resolved);

  return response.resolved == resolved;
}
