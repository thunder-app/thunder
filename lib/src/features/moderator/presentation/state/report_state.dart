part of 'report_bloc.dart';

enum ReportStatus { initial, fetching, success, failure }

const _reportUnset = Object();

final class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.reportFeedType = ReportFeedType.post,
    this.showResolved = false,
    this.communityId,
    this.postReports = const <ThunderPostReport>[],
    this.commentReports = const [],
    this.hasReachedPostReportsEnd = false,
    this.hasReachedCommentReportsEnd = false,
    this.currentPage = 1,
    this.message,
    this.errorReason,
  });

  /// The status of the report feed
  final ReportStatus status;

  /// The type of report feed
  final ReportFeedType reportFeedType;

  /// Whether to show resolved reports
  final bool showResolved;

  /// The id of the community
  final int? communityId;

  /// The list of post reports
  final List<ThunderPostReport> postReports;

  /// The list of comment reports
  final List<ThunderCommentReport> commentReports;

  /// Determines if we have reached the end of the report post feed
  final bool hasReachedPostReportsEnd;

  /// Determines if we have reached the end of the report comment feed
  final bool hasReachedCommentReportsEnd;

  /// The current page of the feed
  final int currentPage;

  /// The message to display on failure
  final String? message;

  /// Typed reason for failures.
  final AppErrorReason? errorReason;

  ReportState copyWith({
    ReportStatus? status,
    ReportFeedType? reportFeedType,
    bool? showResolved,
    Object? communityId = _reportUnset,
    List<ThunderPostReport>? postReports,
    List<ThunderCommentReport>? commentReports,
    bool? hasReachedPostReportsEnd,
    bool? hasReachedCommentReportsEnd,
    int? currentPage,
    Object? message = _reportUnset,
    Object? errorReason = _reportUnset,
  }) {
    return ReportState(
      status: status ?? this.status,
      reportFeedType: reportFeedType ?? this.reportFeedType,
      showResolved: showResolved ?? this.showResolved,
      communityId: identical(communityId, _reportUnset) ? this.communityId : communityId as int?,
      postReports: postReports ?? this.postReports,
      commentReports: commentReports ?? this.commentReports,
      hasReachedPostReportsEnd: hasReachedPostReportsEnd ?? this.hasReachedPostReportsEnd,
      hasReachedCommentReportsEnd: hasReachedCommentReportsEnd ?? this.hasReachedCommentReportsEnd,
      currentPage: currentPage ?? this.currentPage,
      message: identical(message, _reportUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _reportUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  String toString() {
    return '''ReportState { status: $status, postReports: ${postReports.length}, commentReports: ${commentReports.length}, hasReachedPostReportsEnd: $hasReachedPostReportsEnd, hasReachedCommentReportsEnd: $hasReachedCommentReportsEnd, currentPage: $currentPage, message: $message }''';
  }

  @override
  List<Object?> get props => [
        status,
        reportFeedType,
        showResolved,
        communityId,
        postReports,
        commentReports,
        hasReachedPostReportsEnd,
        hasReachedCommentReportsEnd,
        currentPage,
        message,
        errorReason,
      ];
}
