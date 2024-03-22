import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/moderator/enums/report_action.dart';
import 'package:thunder/moderator/utils/report.dart';
import 'package:thunder/moderator/view/report_page.dart';

part 'report_event.dart';
part 'report_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final LemmyClient lemmyClient;

  ReportBloc({required this.lemmyClient}) : super(const ReportState()) {
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

  /// Handles clearing any messages from the state
  Future<void> _onReportFeedClearMessage(ReportFeedClearMessageEvent event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: state.status == ReportStatus.failure ? state.status : ReportStatus.success, message: null));
  }

  /// Resets the ReportState to its initial state
  Future<void> _onResetReportFeed(ResetReportEvent event, Emitter<ReportState> emit) async {
    emit(const ReportState(
      status: ReportStatus.initial,
      postReports: [],
      commentReports: [],
      hasReachedPostReportsEnd: false,
      hasReachedCommentReportsEnd: false,
      currentPage: 1,
      message: null,
    ));
  }

  /// Changes the current filter type of the report feed
  Future<void> _onReportFeedChangeFilterType(ReportFeedChangeFilterTypeEvent event, Emitter<ReportState> emit) async {
    add(ReportFeedFetchedEvent(
      reportFeedType: event.reportFeedType,
      reset: true,
    ));
  }

  /// Fetches the list of report events
  Future<void> _onReportFeedFetched(ReportFeedFetchedEvent event, Emitter<ReportState> emit) async {
    // Handle the initial fetch or reload of a feed
    if (event.reset) {
      if (state.status != ReportStatus.initial) add(ResetReportEvent());

      Map<String, dynamic> fetchReportsResult = await fetchReports(
        page: 1,
        unresolved: !event.showResolved, // todo
        communityId: null, // todo
        postId: null, // todo
        commentId: null, // todo
        reportFeedType: event.reportFeedType,
      );

      // Extract information from the response
      List<PostReportView> postReportViews = fetchReportsResult['postReportViews'];
      List<CommentReportView> commentReportViews = fetchReportsResult['commentReportViews'];
      bool hasReachedPostReportsEnd = fetchReportsResult['hasReachedPostReportsEnd'];
      bool hasReachedCommentReportsEnd = fetchReportsResult['hasReachedCommentReportsEnd'];
      int currentPage = fetchReportsResult['currentPage'];

      return emit(
        state.copyWith(
          status: ReportStatus.success,
          reportFeedType: event.reportFeedType,
          showResolved: event.showResolved,
          postReports: postReportViews,
          commentReports: commentReportViews,
          hasReachedPostReportsEnd: hasReachedPostReportsEnd,
          hasReachedCommentReportsEnd: hasReachedCommentReportsEnd,
          currentPage: currentPage,
        ),
      );
    }

    // If the feed is already being fetched but it is not a reset, then just wait
    if (state.status == ReportStatus.fetching) return;
    if (state.hasReachedPostReportsEnd && event.reportFeedType == ReportFeedType.post) return;
    if (state.hasReachedCommentReportsEnd && event.reportFeedType == ReportFeedType.comment) return;

    // Handle fetching the next page of the feed
    emit(state.copyWith(status: ReportStatus.fetching));

    List<PostReportView> postReportViews = List.from(state.postReports);
    List<CommentReportView> commentReportViews = List.from(state.commentReports);

    Map<String, dynamic> fetchReportsResult = await fetchReports(
      page: state.currentPage,
      unresolved: !state.showResolved, // todo
      communityId: null, // todo
      postId: null, // todo
      commentId: null, // todo
      reportFeedType: state.reportFeedType,
    );

    // Extract information from the response
    List<PostReportView> newPostReportViews = fetchReportsResult['postReportViews'];
    List<CommentReportView> newCommentReportViews = fetchReportsResult['commentReportViews'];
    bool hasReachedPostReportsEnd = fetchReportsResult['hasReachedPostReportsEnd'];
    bool hasReachedCommentReportsEnd = fetchReportsResult['hasReachedCommentReportsEnd'];
    int currentPage = fetchReportsResult['currentPage'];

    postReportViews.addAll(newPostReportViews);
    commentReportViews.addAll(newCommentReportViews);

    return emit(
      state.copyWith(
        status: ReportStatus.success,
        reportFeedType: event.reportFeedType,
        postReports: postReportViews,
        commentReports: commentReportViews,
        hasReachedPostReportsEnd: hasReachedPostReportsEnd,
        hasReachedCommentReportsEnd: hasReachedCommentReportsEnd,
        currentPage: currentPage,
      ),
    );
  }

  /// Handles related actions on a given item within the feed
  Future<void> _onReportFeedItemActioned(ReportFeedItemActionedEvent event, Emitter<ReportState> emit) async {
    assert(!(event.postReportView == null && event.commentReportView == null));
    emit(state.copyWith(status: ReportStatus.fetching));

    switch (event.reportAction) {
      case ReportAction.resolvePost:
        // Optimistically update the report
        int existingPostReportViewIndex = state.postReports.indexWhere((PostReportView postReportView) => postReportView.postReport.id == event.postReportView!.postReport.id);

        PostReportView postReportView = state.postReports[existingPostReportViewIndex];
        PostReport originalPostReport = postReportView.postReport;

        try {
          PostReport updatedPostReport = optimisticallyResolvePostReport(postReportView.postReport, event.value);
          state.postReports[existingPostReportViewIndex] = postReportView.copyWith(postReport: updatedPostReport);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: ReportStatus.success));
          emit(state.copyWith(status: ReportStatus.fetching));

          bool success = await resolvePostReport(originalPostReport.id, event.value);
          if (success) return emit(state.copyWith(status: ReportStatus.success));

          return emit(state.copyWith(status: ReportStatus.failure, message: 'Failed to resolve report'));
        } catch (e) {
          // Restore the original post report contents
          state.postReports[existingPostReportViewIndex] = postReportView;
          emit(state.copyWith(status: ReportStatus.failure, message: e.toString()));
        }
      case ReportAction.resolveComment:
        // Optimistically update the report
        int existingCommentReportViewIndex = state.commentReports.indexWhere((CommentReportView commentReportView) => commentReportView.commentReport.id == event.commentReportView!.commentReport.id);

        CommentReportView commentReportView = state.commentReports[existingCommentReportViewIndex];
        CommentReport originalCommentReport = commentReportView.commentReport;

        try {
          CommentReport updatedCommentReport = optimisticallyResolveCommentReport(commentReportView.commentReport, event.value);
          state.commentReports[existingCommentReportViewIndex] = commentReportView.copyWith(commentReport: updatedCommentReport);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: ReportStatus.success));
          emit(state.copyWith(status: ReportStatus.fetching));

          bool success = await resolveCommentReport(originalCommentReport.id, event.value);
          if (success) return emit(state.copyWith(status: ReportStatus.success));

          return emit(state.copyWith(status: ReportStatus.failure, message: 'Failed to resolve report'));
        } catch (e) {
          // Restore the original comment report contents
          state.commentReports[existingCommentReportViewIndex] = commentReportView;
          emit(state.copyWith(status: ReportStatus.failure, message: e.toString()));
        }
    }
  }
}
