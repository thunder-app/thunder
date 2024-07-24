import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/moderator/view/report_page.dart';

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
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  bool hasReachedPostReportsEnd = false;
  bool hasReachedCommentReportsEnd = false;

  List<PostReportView> postReportViews = [];
  List<CommentReportView> commentReportViews = [];

  int currentPage = page;

  // Guarantee that we fetch at least x post and comment reports (unless we reach the end of the feed)
  do {
    ListPostReportsResponse listPostReportsResponse =
        await lemmy.run(ListPostReports(
      auth: account?.jwt,
      page: currentPage,
      limit: limit,
      unresolvedOnly: unresolved,
      communityId: communityId,
      postId: postId,
    ));

    ListCommentReportsResponse listCommentReportsResponse =
        await lemmy.run(ListCommentReports(
      auth: account?.jwt,
      page: currentPage,
      limit: limit,
      unresolvedOnly: unresolved,
      communityId: communityId,
      commentId: commentId,
    ));

    postReportViews.addAll(listPostReportsResponse.postReports);
    commentReportViews.addAll(listCommentReportsResponse.commentReports);

    if (listPostReportsResponse.postReports.isEmpty)
      hasReachedPostReportsEnd = true;
    if (listCommentReportsResponse.commentReports.isEmpty)
      hasReachedCommentReportsEnd = true;
    currentPage++;
  } while (reportFeedType == ReportFeedType.post
      ? (!hasReachedPostReportsEnd && postReportViews.length < limit)
      : (!hasReachedCommentReportsEnd && commentReportViews.length < limit));

  return {
    'postReportViews': postReportViews,
    'commentReportViews': commentReportViews,
    'hasReachedPostReportsEnd': hasReachedPostReportsEnd,
    'hasReachedCommentReportsEnd': hasReachedCommentReportsEnd,
    'currentPage': currentPage
  };
}

// Optimistically resolves a post report. This changes the value of the post report locally, without sending the network request
PostReport optimisticallyResolvePostReport(
    PostReport postReport, bool resolved) {
  return postReport.copyWith(resolved: resolved);
}

/// Logic to resolve a post report
Future<bool> resolvePostReport(int postReportId, bool resolved) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  PostReportResponse postReportResponse = await lemmy.run(ResolvePostReport(
    reportId: postReportId,
    resolved: resolved,
    auth: account!.jwt!,
  ));

  return postReportResponse.postReportView.postReport.resolved == resolved;
}

// Optimistically resolves a comment report. This changes the value of the comment report locally, without sending the network request
CommentReport optimisticallyResolveCommentReport(
    CommentReport commentReport, bool resolved) {
  return commentReport.copyWith(resolved: resolved);
}

/// Logic to resolve a comment report
Future<bool> resolveCommentReport(int commentReportId, bool resolved) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  CommentReportResponse commentReportResponse =
      await lemmy.run(ResolveCommentReport(
    reportId: commentReportId,
    resolved: resolved,
    auth: account!.jwt!,
  ));

  return commentReportResponse.commentReportView.commentReport.resolved ==
      resolved;
}
