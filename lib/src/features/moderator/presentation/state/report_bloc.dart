import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';

import 'package:thunder/src/features/moderator/moderator.dart';

part 'report_event.dart';
part 'report_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc({required this.account, required LocalizationService localizationService})
      : _localizationService = localizationService,
        super(const ReportState()) {
    /// Handles resetting the report feed to its initial state
    on<ResetReportEvent>(
      _onResetReportFeed,
      transformer: restartable(),
    );

    /// Handles fetching the report
    on<ReportFeedFetchedEvent>(
      _onReportFeedFetched,
      transformer: restartable(),
    );

    /// Handles actions on a given item within the feed
    on<ReportFeedItemActionedEvent>(
      _onReportFeedItemActioned,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles changing the filter type of the report feed
    on<ReportFeedChangeFilterTypeEvent>(
      _onReportFeedChangeFilterType,
      transformer: restartable(),
    );

    /// Handles clearing any messages from the state
    on<ReportFeedClearMessageEvent>(
      _onReportFeedClearMessage,
      transformer: throttleDroppable(Duration.zero),
    );
  }

  final Account account;
  final LocalizationService _localizationService;

  /// Handles clearing any messages from the state
  Future<void> _onReportFeedClearMessage(ReportFeedClearMessageEvent event, Emitter<ReportState> emit) async {
    emit(
      state.copyWith(
        status: state.status == ReportStatus.failure ? state.status : ReportStatus.success,
        message: null,
        errorReason: null,
      ),
    );
  }

  /// Resets the ReportState to its initial state
  Future<void> _onResetReportFeed(ResetReportEvent event, Emitter<ReportState> emit) async {
    emit(
      const ReportState(
        status: ReportStatus.initial,
        reportFeedType: ReportFeedType.post,
        showResolved: false,
        communityId: null,
        postReports: [],
        commentReports: [],
        hasReachedPostReportsEnd: false,
        hasReachedCommentReportsEnd: false,
        currentPage: 1,
        message: null,
        errorReason: null,
      ),
    );
  }

  /// Changes the current filter type of the report feed
  Future<void> _onReportFeedChangeFilterType(ReportFeedChangeFilterTypeEvent event, Emitter<ReportState> emit) async {
    add(ReportFeedFetchedEvent(
      reportFeedType: state.reportFeedType,
      showResolved: event.showResolved,
      communityId: event.communityId,
      reset: true,
    ));
  }

  /// Fetches the list of report events
  Future<void> _onReportFeedFetched(ReportFeedFetchedEvent event, Emitter<ReportState> emit) async {
    try {
      // Handle the initial fetch or reload of a feed
      if (event.reset) {
        if (state.status != ReportStatus.initial) add(ResetReportEvent());

        Map<String, dynamic> fetchReportsResult = await fetchReports(
          account: account,
          page: 1,
          unresolved: !event.showResolved,
          communityId: event.communityId,
          postId: null, // TODO: This is introduced in 0.19.4
          commentId: null, // TODO: This is introduced in 0.19.4
          reportFeedType: event.reportFeedType,
        );

        // Extract information from the response
        List<ThunderPostReport> postReportViews = fetchReportsResult['postReportViews'];
        List<ThunderCommentReport> commentReportViews = fetchReportsResult['commentReportViews'];
        bool hasReachedPostReportsEnd = fetchReportsResult['hasReachedPostReportsEnd'];
        bool hasReachedCommentReportsEnd = fetchReportsResult['hasReachedCommentReportsEnd'];
        int currentPage = fetchReportsResult['currentPage'];

        return emit(
          state.copyWith(
            status: ReportStatus.success,
            reportFeedType: event.reportFeedType,
            showResolved: event.showResolved,
            communityId: event.communityId,
            postReports: postReportViews,
            commentReports: commentReportViews,
            hasReachedPostReportsEnd: hasReachedPostReportsEnd,
            hasReachedCommentReportsEnd: hasReachedCommentReportsEnd,
            currentPage: currentPage,
            errorReason: null,
          ),
        );
      }

      if (shouldSkipPagination(
        isFetching: state.status == ReportStatus.fetching,
        hasReachedPostReportsEnd: state.hasReachedPostReportsEnd,
        hasReachedCommentReportsEnd: state.hasReachedCommentReportsEnd,
        isPostFeed: event.reportFeedType == ReportFeedType.post,
      )) {
        return;
      }

      // Handle fetching the next page of the feed
      emit(state.copyWith(status: ReportStatus.fetching));

      List<ThunderPostReport> postReportViews = List.from(state.postReports);
      List<ThunderCommentReport> commentReportViews = List.from(state.commentReports);

      Map<String, dynamic> fetchReportsResult = await fetchReports(
        account: account,
        page: state.currentPage,
        unresolved: !state.showResolved,
        communityId: state.communityId,
        postId: null, // TODO: This is introduced in 0.19.4
        commentId: null, // TODO: This is introduced in 0.19.4
        reportFeedType: state.reportFeedType,
      );

      // Extract information from the response
      List<ThunderPostReport> newPostReportViews = fetchReportsResult['postReportViews'];
      List<ThunderCommentReport> newCommentReportViews = fetchReportsResult['commentReportViews'];
      bool hasReachedPostReportsEnd = fetchReportsResult['hasReachedPostReportsEnd'];
      bool hasReachedCommentReportsEnd = fetchReportsResult['hasReachedCommentReportsEnd'];
      int currentPage = fetchReportsResult['currentPage'];

      postReportViews = appendPostReports(
        current: postReportViews,
        incoming: newPostReportViews,
      );
      commentReportViews = appendCommentReports(
        current: commentReportViews,
        incoming: newCommentReportViews,
      );

      return emit(
        state.copyWith(
          status: ReportStatus.success,
          reportFeedType: event.reportFeedType,
          postReports: postReportViews,
          commentReports: commentReportViews,
          hasReachedPostReportsEnd: hasReachedPostReportsEnd,
          hasReachedCommentReportsEnd: hasReachedCommentReportsEnd,
          currentPage: currentPage,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = e.toString();
      return emit(state.copyWith(
        status: ReportStatus.failure,
        message: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  /// Handles related actions on a given item within the feed
  Future<void> _onReportFeedItemActioned(ReportFeedItemActionedEvent event, Emitter<ReportState> emit) async {
    assert(!(event.postReportView == null && event.commentReportView == null));
    emit(state.copyWith(status: ReportStatus.fetching));

    switch (event.reportAction) {
      case ReportAction.resolvePost:
        final input = event.actionInput;
        if (input is! ResolveReportActionInput) {
          final message = _localizationService.l10n.unableToResolveReport;
          return emit(state.copyWith(
            status: ReportStatus.failure,
            message: message,
            errorReason: AppErrorReason.validation(message: message),
          ));
        }
        // Optimistically update the report
        int existingPostReportViewIndex = state.postReports.indexWhere((ThunderPostReport postReportView) => postReportView.id == event.postReportView!.id);
        if (existingPostReportViewIndex == -1) {
          final message = _localizationService.l10n.unableToResolveReport;
          return emit(state.copyWith(
            status: ReportStatus.failure,
            message: message,
            errorReason: AppErrorReason.actionFailed(message: message),
          ));
        }

        ThunderPostReport postReportView = state.postReports[existingPostReportViewIndex];
        final originalPostReports = List<ThunderPostReport>.from(state.postReports);
        final value = input.resolved;

        try {
          ThunderPostReport updatedPostReport = optimisticallyResolvePostReport(postReportView, value);
          final optimisticPostReports = replaceAt(
            source: state.postReports,
            index: existingPostReportViewIndex,
            value: updatedPostReport,
          );

          // Emit the state to update UI immediately
          emit(state.copyWith(status: ReportStatus.success, postReports: optimisticPostReports));
          emit(state.copyWith(status: ReportStatus.fetching, postReports: optimisticPostReports));

          bool success = await resolvePostReport(account, postReportView.id, value);
          if (success) {
            return emit(state.copyWith(
              status: ReportStatus.success,
              postReports: optimisticPostReports,
              errorReason: null,
            ));
          }

          final message = _localizationService.l10n.unableToResolveReport;
          return emit(state.copyWith(
            status: ReportStatus.failure,
            postReports: originalPostReports,
            message: message,
            errorReason: AppErrorReason.actionFailed(message: message),
          ));
        } catch (e) {
          final message = e.toString();
          emit(state.copyWith(
            status: ReportStatus.failure,
            postReports: originalPostReports,
            message: message,
            errorReason: AppErrorReason.unexpected(
              message: message,
              details: e.toString(),
            ),
          ));
        }
      case ReportAction.resolveComment:
        final input = event.actionInput;
        if (input is! ResolveReportActionInput) {
          final message = _localizationService.l10n.unableToResolveReport;
          return emit(state.copyWith(
            status: ReportStatus.failure,
            message: message,
            errorReason: AppErrorReason.validation(message: message),
          ));
        }
        // Optimistically update the report
        int existingCommentReportViewIndex = state.commentReports.indexWhere((ThunderCommentReport commentReportView) => commentReportView.id == event.commentReportView!.id);
        if (existingCommentReportViewIndex == -1) {
          final message = _localizationService.l10n.unableToResolveReport;
          return emit(state.copyWith(
            status: ReportStatus.failure,
            message: message,
            errorReason: AppErrorReason.actionFailed(message: message),
          ));
        }

        ThunderCommentReport commentReportView = state.commentReports[existingCommentReportViewIndex];
        ThunderCommentReport originalCommentReport = commentReportView;
        final originalCommentReports = List<ThunderCommentReport>.from(state.commentReports);
        final value = input.resolved;

        try {
          ThunderCommentReport updatedCommentReport = optimisticallyResolveCommentReport(commentReportView, value);
          final optimisticCommentReports = replaceAt(
            source: state.commentReports,
            index: existingCommentReportViewIndex,
            value: updatedCommentReport,
          );

          // Emit the state to update UI immediately
          emit(state.copyWith(status: ReportStatus.success, commentReports: optimisticCommentReports));
          emit(state.copyWith(status: ReportStatus.fetching, commentReports: optimisticCommentReports));

          bool success = await resolveCommentReport(account, originalCommentReport.id, value);
          if (success) {
            return emit(state.copyWith(
              status: ReportStatus.success,
              commentReports: optimisticCommentReports,
              errorReason: null,
            ));
          }

          final message = _localizationService.l10n.unableToResolveReport;
          return emit(
            state.copyWith(
              status: ReportStatus.failure,
              commentReports: originalCommentReports,
              message: message,
              errorReason: AppErrorReason.actionFailed(message: message),
            ),
          );
        } catch (e) {
          final message = e.toString();
          emit(state.copyWith(
            status: ReportStatus.failure,
            commentReports: originalCommentReports,
            message: message,
            errorReason: AppErrorReason.unexpected(
              message: message,
              details: e.toString(),
            ),
          ));
        }
    }
  }
}
