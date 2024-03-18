part of 'report_bloc.dart';

enum ReportStatus { initial, fetching, success, failure }

final class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.reportFeedType = ReportFeedType.post,
    this.showResolved = false,
    this.postReports = const [],
    this.commentReports = const [],
    this.hasReachedPostReportsEnd = false,
    this.hasReachedCommentReportsEnd = false,
    this.currentPage = 1,
    this.message,
  });

  /// The status of the report feed
  final ReportStatus status;

  /// The type of report feed
  final ReportFeedType reportFeedType;

  /// Whether to show resolved reports
  final bool showResolved;

  /// The list of post reports
  final List<PostReportView> postReports;

  /// The list of comment reports
  final List<CommentReportView> commentReports;

  /// Determines if we have reached the end of the report post feed
  final bool hasReachedPostReportsEnd;

  /// Determines if we have reached the end of the report comment feed
  final bool hasReachedCommentReportsEnd;

  /// The current page of the feed
  final int currentPage;

  /// The message to display on failure
  final String? message;

  ReportState copyWith({
    ReportStatus? status,
    ReportFeedType? reportFeedType,
    bool? showResolved,
    List<PostReportView>? postReports,
    List<CommentReportView>? commentReports,
    bool? hasReachedPostReportsEnd,
    bool? hasReachedCommentReportsEnd,
    int? currentPage,
    String? message,
  }) {
    return ReportState(
      status: status ?? this.status,
      reportFeedType: reportFeedType ?? this.reportFeedType,
      showResolved: showResolved ?? this.showResolved,
      postReports: postReports ?? this.postReports,
      commentReports: commentReports ?? this.commentReports,
      hasReachedPostReportsEnd: hasReachedPostReportsEnd ?? this.hasReachedPostReportsEnd,
      hasReachedCommentReportsEnd: hasReachedCommentReportsEnd ?? this.hasReachedCommentReportsEnd,
      currentPage: currentPage ?? this.currentPage,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return '''ReportState { status: $status, postReports: ${postReports.length}, commentReports: ${commentReports.length}, hasReachedPostReportsEnd: $hasReachedPostReportsEnd, hasReachedCommentReportsEnd: $hasReachedCommentReportsEnd, currentPage: $currentPage, message: $message }''';
  }

  @override
  List<dynamic> get props => [status, reportFeedType, showResolved, postReports, commentReports, hasReachedPostReportsEnd, hasReachedCommentReportsEnd, currentPage, message];
}
