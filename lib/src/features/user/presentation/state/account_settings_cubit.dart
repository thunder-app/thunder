import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/networking/networking.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/localization_service.dart';

const _accountSettingsUnset = Object();

enum AccountSettingsStatus {
  initial,
  ready,
  updating,
  success,
  failure,
  notLoggedIn,
}

class AccountSettingsState extends Equatable {
  const AccountSettingsState({
    this.status = AccountSettingsStatus.initial,
    this.siteResponse,
    this.errorMessage = '',
    this.errorReason,
  });

  final AccountSettingsStatus status;
  final ThunderSiteResponse? siteResponse;
  final String? errorMessage;
  final AppErrorReason? errorReason;

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    Object? siteResponse = _accountSettingsUnset,
    Object? errorMessage = _accountSettingsUnset,
    Object? errorReason = _accountSettingsUnset,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      siteResponse: identical(siteResponse, _accountSettingsUnset) ? this.siteResponse : siteResponse as ThunderSiteResponse?,
      errorMessage: identical(errorMessage, _accountSettingsUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _accountSettingsUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, siteResponse, errorMessage, errorReason];
}

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  AccountSettingsCubit({required this.account, required this.accountRepository, required LocalizationService localizationService, ThunderSiteResponse? initialSiteResponse})
      : _localizationService = localizationService,
        super(
          account.anonymous
              ? AccountSettingsState(
                  status: AccountSettingsStatus.notLoggedIn,
                  errorMessage: localizationService.l10n.userNotLoggedIn,
                  errorReason: AppErrorReason.notLoggedIn(message: localizationService.l10n.userNotLoggedIn),
                )
              : AccountSettingsState(
                  status: initialSiteResponse == null ? AccountSettingsStatus.initial : AccountSettingsStatus.ready,
                  siteResponse: initialSiteResponse,
                ),
        );

  final Account account;
  final AccountRepository accountRepository;
  final LocalizationService _localizationService;

  void hydrateFromProfile(ThunderSiteResponse? siteResponse) {
    if (account.anonymous || siteResponse == null) return;

    emit(
      state.copyWith(
        status: AccountSettingsStatus.ready,
        siteResponse: siteResponse,
        errorMessage: '',
        errorReason: null,
      ),
    );
  }

  Future<void> updateSettings({
    String? displayName,
    String? bio,
    FeedListType? defaultFeedListType,
    PostSortType? defaultPostSortType,
    bool? showNsfw,
    bool? showNsfl,
    bool? showReadPosts,
    bool? showBotAccounts,
    List<int>? discussionLanguages,
  }) async {
    if (state.status == AccountSettingsStatus.updating) return;

    final originalSiteResponse = state.siteResponse;

    try {
      final l10n = _localizationService.l10n;

      if (account.anonymous) {
        return emit(state.copyWith(
          status: AccountSettingsStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      if (originalSiteResponse?.myUser == null) {
        return emit(state.copyWith(
          status: AccountSettingsStatus.failure,
          errorMessage: l10n.unexpectedError,
          errorReason: AppErrorReason.validation(message: l10n.unexpectedError),
        ));
      }

      final myUser = originalSiteResponse!.myUser!;

      final localUser = myUser.localUserView.localUser.copyWith(
        showNsfw: showNsfw ?? myUser.localUserView.localUser.showNsfw,
        showNsfl: showNsfl ?? myUser.localUserView.localUser.showNsfl,
        showReadPosts: showReadPosts ?? myUser.localUserView.localUser.showReadPosts,
        showBotAccounts: showBotAccounts ?? myUser.localUserView.localUser.showBotAccounts,
        defaultListingType: defaultFeedListType ?? myUser.localUserView.localUser.defaultListingType,
        defaultSortType: defaultPostSortType ?? myUser.localUserView.localUser.defaultSortType,
      );

      final updatedSiteResponse = originalSiteResponse.copyWith(
        myUser: myUser.copyWith(
          localUserView: myUser.localUserView.copyWith(
            person: myUser.localUserView.person.copyWith(
              bio: bio ?? myUser.localUserView.person.bio,
              displayName: displayName ?? myUser.localUserView.person.displayName,
            ),
            localUser: localUser,
          ),
          discussionLanguages: discussionLanguages ?? myUser.discussionLanguages,
        ),
      );

      emit(state.copyWith(
        status: AccountSettingsStatus.updating,
        siteResponse: updatedSiteResponse,
        errorMessage: '',
        errorReason: null,
      ));

      await accountRepository.saveSettings(
        AccountSettingsUpdate(
          displayName: displayName,
          bio: bio,
          defaultFeedListType: defaultFeedListType,
          defaultPostSortType: defaultPostSortType,
          showNsfw: showNsfw,
          showNsfl: showNsfl,
          showReadPosts: showReadPosts,
          showBotAccounts: showBotAccounts,
          discussionLanguages: discussionLanguages,
        ),
      );

      emit(state.copyWith(status: AccountSettingsStatus.success, errorMessage: '', errorReason: null));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        siteResponse: originalSiteResponse,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
      ));
    }
  }
}
