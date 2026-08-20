import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';

import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/core/services/localization_service.dart';

part 'report_event.dart';
part 'report_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc({required this.account, required this.reportRepository, required LocalizationService localizationService}) : _localizationService = localizationService, super(const ReportState()) {
    /// Handles resetting the report feed to its initial state
    on<ResetReportEvent>(_onResetReportFeed, transformer: restartable());

    /// Handles fetching the report
    on<ReportFeedFetchedEvent>(_onReportFeedFetched, transformer: restartable());

    /// Handles actions on a given item within the feed
    on<ReportFeedItemActionedEvent>(_onReportFeedItemActioned, transformer: throttleDroppable(Duration.zero));

    /// Handles changing the filter type of the report feed
    on<ReportFeedChangeFilterTypeEvent>(_onReportFeedChangeFilterType, transformer: restartable());

    /// Handles clearing any messages from the state
    on<ReportFeedClearMessageEvent>(_onReportFeedClearMessage, transformer: throttleDroppable(Duration.zero));
  }

  final Account account;
  final ReportRepository reportRepository;
  final LocalizationService _localizationService;

  /// Handles clearing any messages from the state
  Future<void> _onReportFeedClearMessage(ReportFeedClearMessageEvent event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: state.status == ReportStatus.failure ? state.status : ReportStatus.success, message: null, errorReason: null));
  }

  /// Resets the ReportState to its initial state
  Future<void> _onResetReportFeed(ResetReportEvent event, Emitter<ReportState> emit) async {
    emit(
      const ReportState(
        status: ReportStatus.initial,
        reportFeedType: ReportFeedType.post,
        showResolved: false,
        communityId: null,
        reports: [],
        hasReachedReportsEnd: false,
        currentPage: 1,
        nextPage: null,
        message: null,
        errorReason: null,
      ),
    );
  }

  /// Changes the current filter type of the report feed
  Future<void> _onReportFeedChangeFilterType(ReportFeedChangeFilterTypeEvent event, Emitter<ReportState> emit) async {
    add(ReportFeedFetchedEvent(reportFeedType: state.reportFeedType, showResolved: event.showResolved, communityId: event.communityId, reset: true));
  }

  /// Fetches the list of report events
  Future<void> _onReportFeedFetched(ReportFeedFetchedEvent event, Emitter<ReportState> emit) async {
    try {
      // Handle the initial fetch or reload of a feed
      if (event.reset) {
        if (state.status != ReportStatus.initial) add(ResetReportEvent());

        final response = await reportRepository.getReports(page: 1, unresolved: !event.showResolved, communityId: event.communityId, reportFeedType: event.reportFeedType);

        return emit(
          state.copyWith(
            status: ReportStatus.success,
            reportFeedType: event.reportFeedType,
            showResolved: event.showResolved,
            communityId: event.communityId,
            reports: response.items,
            hasReachedReportsEnd: response.nextPage == null && response.items.length < 10,
            currentPage: 2,
            nextPage: response.nextPage,
            errorReason: null,
          ),
        );
      }

      if (shouldSkipPagination(isFetching: state.status == ReportStatus.fetching, hasReachedReportsEnd: state.hasReachedReportsEnd)) {
        return;
      }

      // Handle fetching the next page of the feed
      emit(state.copyWith(status: ReportStatus.fetching));

      final response = await reportRepository.getReports(
        page: state.currentPage,
        cursor: state.nextPage,
        unresolved: !state.showResolved,
        communityId: state.communityId,
        reportFeedType: state.reportFeedType,
      );

      final reports = appendReports(current: state.reports, incoming: response.items);

      return emit(
        state.copyWith(
          status: ReportStatus.success,
          reportFeedType: event.reportFeedType,
          reports: reports,
          hasReachedReportsEnd: response.nextPage == null && response.items.length < 10,
          currentPage: state.currentPage + 1,
          nextPage: response.nextPage,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = e.toString();
      return emit(
        state.copyWith(
          status: ReportStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  /// Handles related actions on a given item within the feed
  Future<void> _onReportFeedItemActioned(ReportFeedItemActionedEvent event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.fetching));

    switch (event.reportAction) {
      case ReportAction.resolve:
        final input = event.actionInput;
        if (input is! ResolveReportActionInput) {
          final message = _localizationService.l10n.unableToResolveReport;
          return emit(
            state.copyWith(
              status: ReportStatus.failure,
              message: message,
              errorReason: AppErrorReason.validation(message: message),
            ),
          );
        }
        // Optimistically update the report
        final existingReportIndex = state.reports.indexWhere((report) => report.kind == event.report.kind && report.id == event.report.id);
        if (existingReportIndex == -1) {
          final message = _localizationService.l10n.unableToResolveReport;
          return emit(
            state.copyWith(
              status: ReportStatus.failure,
              message: message,
              errorReason: AppErrorReason.actionFailed(message: message),
            ),
          );
        }

        final report = state.reports[existingReportIndex];
        final originalReports = List<ThunderReport>.from(state.reports);
        final value = input.resolved;

        try {
          final updatedReport = optimisticallyResolveReport(report, value);
          final optimisticReports = replaceAt(source: state.reports, index: existingReportIndex, value: updatedReport);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: ReportStatus.success, reports: optimisticReports));
          emit(state.copyWith(status: ReportStatus.fetching, reports: optimisticReports));

          final success = await reportRepository.resolveReport(report, value);
          if (success) {
            return emit(state.copyWith(status: ReportStatus.success, reports: optimisticReports, errorReason: null));
          }

          final message = _localizationService.l10n.unableToResolveReport;
          return emit(
            state.copyWith(
              status: ReportStatus.failure,
              reports: originalReports,
              message: message,
              errorReason: AppErrorReason.actionFailed(message: message),
            ),
          );
        } catch (e) {
          final message = e.toString();
          emit(
            state.copyWith(
              status: ReportStatus.failure,
              reports: originalReports,
              message: message,
              errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
            ),
          );
        }
    }
  }
}
