import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

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
    String? email,
    String? matrixUserId,
    FeedListType? defaultFeedListType,
    PostSortType? defaultPostSortType,
    bool? showNsfw,
    bool? showReadPosts,
    bool? showScores,
    bool? botAccount,
    bool? showBotAccounts,
    List<int>? discussionLanguages,
  }) async {
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

      final localUser = originalSiteResponse!.myUser!.localUserView.localUser.copyWith(
        email: email ?? originalSiteResponse.myUser!.localUserView.localUser.email,
        showReadPosts: showReadPosts ?? originalSiteResponse.myUser!.localUserView.localUser.showReadPosts,
        showScores: showScores ?? originalSiteResponse.myUser!.localUserView.localUser.showScores,
        showBotAccounts: showBotAccounts ?? originalSiteResponse.myUser!.localUserView.localUser.showBotAccounts,
        showNsfw: showNsfw ?? originalSiteResponse.myUser!.localUserView.localUser.showNsfw,
        defaultListingType: defaultFeedListType ?? originalSiteResponse.myUser!.localUserView.localUser.defaultListingType,
        defaultSortType: defaultPostSortType ?? originalSiteResponse.myUser!.localUserView.localUser.defaultSortType,
      );

      final updatedSiteResponse = originalSiteResponse.copyWith(
        myUser: originalSiteResponse.myUser!.copyWith(
          localUserView: originalSiteResponse.myUser!.localUserView.copyWith(
            person: originalSiteResponse.myUser!.localUserView.person.copyWith(
              botAccount: botAccount ?? originalSiteResponse.myUser!.localUserView.person.botAccount,
              bio: bio ?? originalSiteResponse.myUser!.localUserView.person.bio,
              displayName: displayName ?? originalSiteResponse.myUser!.localUserView.person.displayName,
              matrixUserId: matrixUserId ?? originalSiteResponse.myUser!.localUserView.person.matrixUserId,
            ),
            localUser: localUser,
          ),
          discussionLanguages: discussionLanguages ?? originalSiteResponse.myUser!.discussionLanguages,
        ),
      );

      emit(state.copyWith(status: AccountSettingsStatus.ready, siteResponse: updatedSiteResponse, errorMessage: '', errorReason: null));
      emit(state.copyWith(status: AccountSettingsStatus.updating, errorMessage: '', errorReason: null));

      await accountRepository.saveSettings(
        bio: bio,
        email: email,
        matrixUserId: matrixUserId,
        displayName: displayName,
        defaultFeedListType: defaultFeedListType,
        defaultPostSortType: defaultPostSortType,
        showNsfw: showNsfw,
        showReadPosts: showReadPosts,
        showScores: showScores,
        botAccount: botAccount,
        showBotAccounts: showBotAccounts,
        discussionLanguages: discussionLanguages,
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
