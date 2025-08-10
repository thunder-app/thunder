import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/models/thunder_post_report.dart';
import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/features/post/post.dart';

/// Helper function which handles the logic of fetching post/comment reports
Future<Map<String, dynamic>> fetchReports({
  int page = 1,
  int limit = 10,
  bool unresolved = false,
  int? communityId,
  int? postId,
  int? commentId,
  ReportFeedType reportFeedType = ReportFeedType.post,
}) async {
  final account = await fetchActiveProfile();

  bool hasReachedPostReportsEnd = false;
  bool hasReachedCommentReportsEnd = false;

  List<ThunderPostReport> postReportViews = [];
  List<CommentReportView> commentReportViews = [];

  int currentPage = page;

  // Guarantee that we fetch at least x post and comment reports (unless we reach the end of the feed)
  do {
    final listPostReportsResponse = await PostRepositoryImpl(account: account).getPostReports(
      postId: postId,
      page: currentPage,
      limit: limit,
      unresolved: unresolved,
      communityId: communityId,
    );

    final listCommentReportsResponse = await CommentRepositoryImpl(account: account).getCommentReports(
      commentId: commentId,
      page: currentPage,
      limit: limit,
      unresolved: unresolved,
      communityId: communityId,
    );

    postReportViews.addAll(listPostReportsResponse.postReports.map((postReport) => ThunderPostReport.fromLemmyPostReportView(postReport.toJson())));
    commentReportViews.addAll(listCommentReportsResponse.commentReports);

    if (listPostReportsResponse.postReports.isEmpty) hasReachedPostReportsEnd = true;
    if (listCommentReportsResponse.commentReports.isEmpty) hasReachedCommentReportsEnd = true;
    currentPage++;
  } while (reportFeedType == ReportFeedType.post ? (!hasReachedPostReportsEnd && postReportViews.length < limit) : (!hasReachedCommentReportsEnd && commentReportViews.length < limit));

  return {
    'postReportViews': postReportViews,
    'commentReportViews': commentReportViews,
    'hasReachedPostReportsEnd': hasReachedPostReportsEnd,
    'hasReachedCommentReportsEnd': hasReachedCommentReportsEnd,
    'currentPage': currentPage
  };
}

// Optimistically resolves a post report. This changes the value of the post report locally, without sending the network request
ThunderPostReport optimisticallyResolvePostReport(ThunderPostReport postReport, bool resolved) {
  return postReport.copyWith(resolved: resolved);
}

/// Logic to resolve a post report
Future<bool> resolvePostReport(int postReportId, bool resolved) async {
  final account = await fetchActiveProfile();
  final postReportResponse = await PostRepositoryImpl(account: account).resolvePostReport(postReportId, resolved);

  return postReportResponse.postReportView.postReport.resolved == resolved;
}

// Optimistically resolves a comment report. This changes the value of the comment report locally, without sending the network request
CommentReport optimisticallyResolveCommentReport(CommentReport commentReport, bool resolved) {
  return commentReport.copyWith(resolved: resolved);
}

/// Logic to resolve a comment report
Future<bool> resolveCommentReport(int commentReportId, bool resolved) async {
  final account = await fetchActiveProfile();
  final commentReportResponse = await CommentRepositoryImpl(account: account).resolveCommentReport(commentReportId, resolved);

  return commentReportResponse.commentReportView.commentReport.resolved == resolved;
}
