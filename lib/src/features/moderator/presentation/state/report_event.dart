part of 'report_bloc.dart';

sealed class ReportActionInput extends Equatable {
  const ReportActionInput();

  @override
  List<Object?> get props => [];
}

final class ResolveReportActionInput extends ReportActionInput {
  const ResolveReportActionInput(this.resolved);

  final bool resolved;

  @override
  List<Object?> get props => [resolved];
}

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
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

  @override
  List<Object?> get props => [reportFeedType, showResolved, communityId, reset];
}

/// Event for changing the filter type of the report feed
final class ReportFeedChangeFilterTypeEvent extends ReportEvent {
  /// Boolean which indicates whether or not to show resolved reports
  final bool showResolved;

  /// The community id to filter the report feed on
  final int? communityId;

  const ReportFeedChangeFilterTypeEvent({this.showResolved = false, this.communityId});

  @override
  List<Object?> get props => [showResolved, communityId];
}

final class ReportFeedItemActionedEvent extends ReportEvent {
  /// The report to perform the action upon.
  final ThunderReport report;

  /// This indicates the relevant action to perform on the post/comment report
  final ReportAction reportAction;

  /// Typed payload to apply for the selected [reportAction].
  final ReportActionInput? actionInput;

  const ReportFeedItemActionedEvent({
    required this.report,
    required this.reportAction,
    this.actionInput,
  });

  @override
  List<Object?> get props => [report, reportAction, actionInput];
}

/// Event for clearing the report feed snackbar message
final class ReportFeedClearMessageEvent extends ReportEvent {}
