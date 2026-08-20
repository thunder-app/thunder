part of 'report_bloc.dart';

enum ReportStatus { initial, fetching, success, failure }

const _reportUnset = Object();

final class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.reportFeedType = ReportFeedType.post,
    this.showResolved = false,
    this.communityId,
    this.reports = const <ThunderReport>[],
    this.hasReachedReportsEnd = false,
    this.currentPage = 1,
    this.nextPage,
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

  /// The list of reports for the selected feed type.
  final List<ThunderReport> reports;

  /// Determines if we have reached the end of the report feed.
  final bool hasReachedReportsEnd;

  /// The current page of the feed
  final int currentPage;

  /// Cursor for the next page of reports.
  final String? nextPage;

  /// The message to display on failure
  final String? message;

  /// Typed reason for failures.
  final AppErrorReason? errorReason;

  ReportState copyWith({
    ReportStatus? status,
    ReportFeedType? reportFeedType,
    bool? showResolved,
    Object? communityId = _reportUnset,
    List<ThunderReport>? reports,
    bool? hasReachedReportsEnd,
    int? currentPage,
    Object? nextPage = _reportUnset,
    Object? message = _reportUnset,
    Object? errorReason = _reportUnset,
  }) {
    return ReportState(
      status: status ?? this.status,
      reportFeedType: reportFeedType ?? this.reportFeedType,
      showResolved: showResolved ?? this.showResolved,
      communityId: identical(communityId, _reportUnset) ? this.communityId : communityId as int?,
      reports: reports ?? this.reports,
      hasReachedReportsEnd: hasReachedReportsEnd ?? this.hasReachedReportsEnd,
      currentPage: currentPage ?? this.currentPage,
      nextPage: identical(nextPage, _reportUnset) ? this.nextPage : nextPage as String?,
      message: identical(message, _reportUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _reportUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  String toString() {
    return '''ReportState { status: $status, reports: ${reports.length}, hasReachedReportsEnd: $hasReachedReportsEnd, currentPage: $currentPage, nextPage: $nextPage, message: $message }''';
  }

  @override
  List<Object?> get props => [status, reportFeedType, showResolved, communityId, reports, hasReachedReportsEnd, currentPage, nextPage, message, errorReason];
}
