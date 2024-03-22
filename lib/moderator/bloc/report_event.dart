part of 'report_bloc.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

/// Event for resetting the report feed
final class ResetReportEvent extends ReportEvent {}

/// Event for fetching the report feed
final class ReportFeedFetchedEvent extends ReportEvent {
  /// The type of report feed
  final ReportFeedType reportFeedType;

  /// Boolean which indicates whether or not to show resolved reports
  final bool showResolved;

  /// The community id to filter the report feed on
  final int? communityId;

  /// Boolean which indicates whether or not to reset the feed
  final bool reset;

  const ReportFeedFetchedEvent({
    this.reportFeedType = ReportFeedType.post,
    this.showResolved = false,
    this.communityId,
    this.reset = false,
  });
}

/// Event for changing the filter type of the report feed
final class ReportFeedChangeFilterTypeEvent extends ReportEvent {
  /// Boolean which indicates whether or not to show resolved reports
  final bool showResolved;

  /// The community id to filter the report feed on
  final int? communityId;

  const ReportFeedChangeFilterTypeEvent({this.showResolved = false, this.communityId});
}

final class ReportFeedItemActionedEvent extends ReportEvent {
  /// This is the original PostReportView to perform the action upon. Only one of [postReportView] or [commentReportView] should be set
  final PostReportView? postReportView;

  /// This is the original CommentReportView to perform the action upon. Only one of [postReportView] or [commentReportView] should be set
  final CommentReportView? commentReportView;

  /// This indicates the relevant action to perform on the post/comment report
  final ReportAction reportAction;

  /// This indicates the value to assign the action to. It is of type dynamic to allow for any type
  /// TODO: Change the dynamic type to the correct type(s) if possible
  final dynamic value;

  const ReportFeedItemActionedEvent({this.postReportView, this.commentReportView, required this.reportAction, this.value});
}

/// Event for clearing the report feed snackbar message
final class ReportFeedClearMessageEvent extends ReportEvent {}
