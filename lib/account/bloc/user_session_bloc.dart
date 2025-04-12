import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/utils/profiles.dart';

import 'package:thunder/community/models/favourite.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'user_session_event.dart';
part 'user_session_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class UserSessionBloc extends Bloc<UserSessionEvent, UserSessionState> {
  UserSessionBloc() : super(const UserSessionState()) {
    on<RemoveAccount>((event, emit) async {
      emit(state.copyWith(status: UserSessionStatus.loading, isLoggedIn: false));

      await Account.deleteAccount(event.accountId);

      await Future.delayed(const Duration(seconds: 1), () {
        return emit(state.copyWith(status: UserSessionStatus.success, isLoggedIn: false));
      });
    });

    /// This event occurs whenever you switch to a different authenticated account
    on<SwitchAccount>((event, emit) async {
      emit(state.copyWith(status: UserSessionStatus.loading, isLoggedIn: false, reload: event.reload));

      Account? account = await Account.fetchAccount(event.accountId);
      if (account == null) return emit(state.copyWith(status: UserSessionStatus.success, account: null, isLoggedIn: false));

      // Set this account as the active account
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      prefs.setString('active_profile_id', event.accountId);

      // Check to see the instance settings (for checking if downvotes are enabled)
      LemmyClient.instance.changeBaseUrl(account.instance.replaceAll('https://', ''));
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account.jwt));
      bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes;

      return emit(state.copyWith(
        status: UserSessionStatus.success,
        account: account,
        isLoggedIn: true,
        downvotesEnabled: downvotesEnabled,
        getSiteResponse: getSiteResponse,
        reload: event.reload,
      ));
    });

    // This event should be triggered during the start of the app, or when there is a change in the active account
    on<CheckAuth>((event, emit) async {
      emit(state.copyWith(status: UserSessionStatus.loading, account: null, isLoggedIn: false));

      // Check to see what the current active account/profile is
      // The profile will match an account in the database (through the account's id)
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      String? activeProfileId = prefs.getString('active_profile_id');

      // If there is an existing jwt, remove it from the prefs
      String? jwt = prefs.getString('jwt');

      if (jwt != null) {
        prefs.remove('jwt');
        return emit(state.copyWith(status: UserSessionStatus.failure, account: null, isLoggedIn: false, errorMessage: 'You have been logged out. Please log in again!'));
      }

      if (activeProfileId == null) {
        return emit(state.copyWith(status: UserSessionStatus.success, account: null, isLoggedIn: false));
      }

      List<Account> accounts = await Account.accounts();

      if (accounts.isEmpty) {
        return emit(state.copyWith(status: UserSessionStatus.success, account: null, isLoggedIn: false));
      }

      Account? activeAccount = accounts.firstWhereOrNull((Account account) => account.id == activeProfileId);

      if (activeAccount == null) {
        return emit(state.copyWith(status: UserSessionStatus.success, account: null, isLoggedIn: false));
      }

      if (activeAccount.username != null && activeAccount.jwt != null) {
        // Set lemmy client to use the instance
        LemmyClient.instance.changeBaseUrl(activeAccount.instance.replaceAll('https://', ''));

        // Check to see the instance settings (for checking if downvotes are enabled)
        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

        bool downvotesEnabled = true;
        GetSiteResponse? getSiteResponse;
        try {
          getSiteResponse = await lemmy.run(GetSite(auth: activeAccount.jwt)).timeout(const Duration(seconds: 15));

          downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes;
        } catch (e) {
          return emit(state.copyWith(status: UserSessionStatus.failureCheckingInstance, errorMessage: getExceptionErrorMessage(e)));
        }

        return emit(state.copyWith(status: UserSessionStatus.success, account: activeAccount, isLoggedIn: true, downvotesEnabled: downvotesEnabled, getSiteResponse: getSiteResponse));
      }
    }, transformer: throttleDroppable(throttleDuration));

    /// This event should be triggered when the user logs in with a username/password
    on<LoginAttempt>((event, emit) async {
      LemmyClient lemmyClient = LemmyClient.instance;
      String originalBaseUrl = lemmyClient.lemmyApiV3.host;

      try {
        emit(state.copyWith(status: UserSessionStatus.loading, account: null, isLoggedIn: false));

        String instance = event.instance;
        if (instance.startsWith('https://')) instance = instance.replaceAll('https://', '');

        lemmyClient.changeBaseUrl(instance);
        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

        LoginResponse loginResponse = await lemmy.run(Login(
          usernameOrEmail: event.username,
          password: event.password,
          totp2faToken: event.totp,
        ));

        if (loginResponse.jwt == null) {
          return emit(state.copyWith(status: UserSessionStatus.failure, account: null, isLoggedIn: false));
        }

        GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: loginResponse.jwt));

        if (event.showContentWarning && getSiteResponse.siteView.site.contentWarning?.isNotEmpty == true) {
          return emit(state.copyWith(status: UserSessionStatus.contentWarning, contentWarning: getSiteResponse.siteView.site.contentWarning));
        }

        // Create a new account in the database
        Account? account = Account(
          id: '',
          username: getSiteResponse.myUser?.localUserView.person.name,
          jwt: loginResponse.jwt,
          instance: instance,
          userId: getSiteResponse.myUser?.localUserView.person.id,
          index: -1,
        );

        account = await Account.insertAccount(account);

        if (account == null) {
          return emit(state.copyWith(status: UserSessionStatus.failure, account: null, isLoggedIn: false));
        }

        // Set this account as the active account
        SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
        prefs.setString('active_profile_id', account.id);

        bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes;

        return emit(state.copyWith(status: UserSessionStatus.success, account: account, isLoggedIn: true, downvotesEnabled: downvotesEnabled, getSiteResponse: getSiteResponse));
      } on LemmyApiException catch (e) {
        return emit(state.copyWith(status: UserSessionStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString()));
      } catch (e) {
        try {
          // Restore the original baseUrl
          lemmyClient.changeBaseUrl(originalBaseUrl);
        } catch (e, s) {
          return emit(state.copyWith(status: UserSessionStatus.failure, account: null, isLoggedIn: false, errorMessage: s.toString()));
        }
        return emit(state.copyWith(status: UserSessionStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString()));
      }
    });

    on<CancelLoginAttempt>((event, emit) async {
      return emit(state.copyWith(status: UserSessionStatus.failure, errorMessage: AppLocalizations.of(GlobalContext.context)!.loginAttemptCanceled));
    });

    /// When we log out of all accounts, clear the instance information
    on<LogOutOfAllAccounts>((event, emit) async {
      emit(state.copyWith(status: UserSessionStatus.initial));
      final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      prefs.setString('active_profile_id', '');
      return emit(state.copyWith(status: UserSessionStatus.success, isLoggedIn: false, getSiteResponse: null));
    });

    /// When the given instance changes, re-fetch the instance information and preferences.
    on<InstanceChanged>((event, emit) async {
      // Copy everything from the state as is during loading
      emit(state.copyWith(status: UserSessionStatus.loading, isLoggedIn: state.isLoggedIn, account: state.account));

      // When the instance changes, update the fullSiteView
      LemmyClient.instance.changeBaseUrl(event.instance.replaceAll('https://', ''));
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      // Check to see if there is an active, non-anonymous account
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      String? activeProfileId = prefs.getString('active_profile_id');
      Account? account = (activeProfileId != null) ? await Account.fetchAccount(activeProfileId) : null;

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account?.jwt));
      bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes;

      return emit(
          state.copyWith(status: UserSessionStatus.success, account: account, isLoggedIn: activeProfileId?.isNotEmpty == true, downvotesEnabled: downvotesEnabled, getSiteResponse: getSiteResponse));
    });

    /// When any account setting synced with Lemmy is updated, re-fetch the instance information and preferences.
    on<LemmyAccountSettingUpdated>((event, emit) async {
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      // Check to see if there is an active, non-anonymous account
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      String? activeProfileId = prefs.getString('active_profile_id');
      Account? account = (activeProfileId != null) ? await Account.fetchAccount(activeProfileId) : null;

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account?.jwt));
      return emit(state.copyWith(
        status: UserSessionStatus.success,
        account: account,
        isLoggedIn: activeProfileId?.isNotEmpty == true,
        getSiteResponse: getSiteResponse,
        reload: false,
      ));
    });

    on<ResetAccountState>(_resetAccountState, transformer: restartable());
    on<RefreshAccountInformation>(_refreshAccountInformation, transformer: restartable());
    on<GetAccountInformation>(_getAccountInformation, transformer: restartable());
    on<GetAccountSubscriptions>(_getAccountSubscriptions, transformer: restartable());
    on<GetFavoritedCommunities>(_getFavoritedCommunities, transformer: restartable());
  }

  /// Resets the account state to its initial state.
  Future<void> _resetAccountState(ResetAccountState event, Emitter<UserSessionState> emit) async {
    return emit(state.copyWith(
      status: UserSessionStatus.success,
      subscriptions: [],
      favorites: [],
      moderates: [],
      user: null,
      error: null,
    ));
  }

  /// Refreshes the account information, subscriptions, and favorites.
  Future<void> _refreshAccountInformation(RefreshAccountInformation event, Emitter<UserSessionState> emit) async {
    await _getFavoritedCommunities(GetFavoritedCommunities(reload: event.reload), emit);
    await _getAccountInformation(GetAccountInformation(reload: event.reload), emit);
    await _getAccountSubscriptions(GetAccountSubscriptions(reload: event.reload), emit);
  }

  /// Fetches the current account's information, including the user's profile and moderated communities.
  Future<void> _getAccountInformation(GetAccountInformation event, Emitter<UserSessionState> emit) async {
    final account = await fetchActiveProfileAccount();
    if (account == null || account.jwt == null) return _resetAccountState(ResetAccountState(), emit);

    try {
      emit(state.copyWith(status: UserSessionStatus.loading, user: null, moderates: [], reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      final response = await lemmy.run(GetPersonDetails(username: account.username, auth: account.jwt, sort: SortType.new_, page: 1));
      final user = ThunderUser(response.personView.person, userView: response.personView);
      final moderates = response.moderates.map((cmv) => ThunderCommunity(cmv.community)).toList();

      // This eliminates an issue which has plagued me a lot which is that there's a race condition
      // with so many calls to GetAccountInformation, we can return success for the new and old account.
      if (user.id == account.userId) {
        return emit(state.copyWith(status: UserSessionStatus.success, user: user, moderates: moderates, reload: event.reload));
      } else {
        return emit(state.copyWith(status: UserSessionStatus.success, user: null, moderates: [], reload: event.reload));
      }
    } catch (e) {
      emit(state.copyWith(status: UserSessionStatus.failure, error: getExceptionErrorMessage(e), reload: event.reload));
    }
  }

  /// Fetches the current account's subscriptions.
  Future<void> _getAccountSubscriptions(GetAccountSubscriptions event, Emitter<UserSessionState> emit) async {
    final account = await fetchActiveProfileAccount();
    if (account == null || account.jwt == null) return _resetAccountState(ResetAccountState(), emit);

    try {
      emit(state.copyWith(status: UserSessionStatus.loading, reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      List<ThunderCommunity> subscriptions = [];

      int page = 1;
      bool hasFetchedAllSubscriptions = false;

      while (!hasFetchedAllSubscriptions) {
        final response = await lemmy.run(ListCommunities(auth: account.jwt, page: page, limit: 50, type: ListingType.subscribed));
        subscriptions.addAll(response.communities.map((cv) => ThunderCommunity(cv.community, communityView: cv)));

        page++;
        hasFetchedAllSubscriptions = response.communities.isEmpty;
      }

      // Sort subscriptions by their name
      subscriptions.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return emit(state.copyWith(status: UserSessionStatus.success, subscriptions: subscriptions, reload: event.reload));
    } catch (e) {
      emit(state.copyWith(status: UserSessionStatus.failure, error: getExceptionErrorMessage(e), reload: event.reload));
    }
  }

  /// Fetches the current account's favorited communities.
  Future<void> _getFavoritedCommunities(GetFavoritedCommunities event, Emitter<UserSessionState> emit) async {
    final account = await fetchActiveProfileAccount();
    if (account == null || account.jwt == null) return _resetAccountState(ResetAccountState(), emit);

    try {
      emit(state.copyWith(status: UserSessionStatus.loading, reload: event.reload));

      final favorites = await Favorite.favorites(account.id);
      final communities = state.subscriptions.where((community) => favorites.any((favorite) => favorite.communityId == community.id)).toList();

      return emit(state.copyWith(status: UserSessionStatus.success, favorites: communities, reload: event.reload));
    } catch (e) {
      emit(state.copyWith(status: UserSessionStatus.failure, error: getExceptionErrorMessage(e), reload: event.reload));
    }
  }
}
