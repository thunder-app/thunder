import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lemmy_api_client/v3.dart';
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

part 'profile_event.dart';
part 'profile_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    // This event should be triggered during the start of the app, or when there is a change in the active account
    on<InitializeAuth>(_initializeAuth, transformer: throttleDroppable(throttleDuration));

    /// This event should be triggered whenever the user removes a profile
    /// This could be either a log out event, or a removal of a profile
    on<RemoveProfile>(_removeProfile);

    /// This event occurs whenever you switch to a different profile
    on<SwitchProfile>(_switchProfile);

    /// This event should be triggered whenever the user adds a profile.
    /// This could be addition of a anonymous or non-anonymous account.
    on<AddProfile>(_addProfile);

    /// This event handles fetching a given profile's information.
    /// For non-anonymous accounts, this includes user information, subscriptions, and favourites.
    /// For anonymous accounts, this will not do anything.
    on<FetchProfileInformation>(_fetchProfileInformation, transformer: restartable());

    /// This event should be triggered when the user cancels a login attempt
    on<CancelLoginAttempt>(_cancelLoginAttempt);

    /// When any account setting synced with Lemmy is updated, re-fetch the instance information and preferences.
    on<FetchProfileSettings>(_fetchProfileSettings);

    /// Fetches the current profile's subscribed communities. This is only applicable for non-anonymous profiles.
    on<FetchProfileSubscriptions>(_fetchProfileSubscriptions, transformer: restartable());

    /// Fetches the current profile's favourited communities. This is only applicable for non-anonymous profiles.
    on<FetchProfileFavorites>(_fetchProfileFavorites, transformer: restartable());
  }

  /// Resets the entire state the the initial state.
  Future<void> _resetState(emit) async {
    return emit(ProfileState());
  }

  Future<void> _initializeAuth(InitializeAuth event, Emitter<ProfileState> emit) async {
    _resetState(emit);

    // Check to see what the current active profile is.
    final account = await fetchActiveProfile();

    // Set lemmy client to use the instance
    LemmyClient.instance.changeBaseUrl(account.instance.replaceAll('https://', ''));

    // Check to see the instance settings (for checking if downvotes are enabled)
    final lemmy = LemmyClient.instance.lemmyApiV3;

    bool downvotesEnabled = true;
    GetSiteResponse? getSiteResponse;

    try {
      getSiteResponse = await lemmy.run(GetSite(auth: account.jwt)).timeout(const Duration(seconds: 15));

      downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes;
    } catch (e) {
      return emit(state.copyWith(status: ProfileStatus.failureCheckingInstance, error: () => getExceptionErrorMessage(e)));
    }

    emit(
      state.copyWith(
        status: ProfileStatus.success,
        account: account.anonymous ? null : () => account,
        isLoggedIn: !account.anonymous,
        downvotesEnabled: downvotesEnabled,
        getSiteResponse: () => getSiteResponse!,
      ),
    );

    // Do not use add(BlocEvent) here, as we want all these to happen sequentially.
    await _fetchProfileInformation(FetchProfileInformation(reload: false), emit);
    await _fetchProfileSettings(FetchProfileSettings(), emit);
    await _fetchProfileSubscriptions(FetchProfileSubscriptions(reload: false), emit);

    return;
  }

  Future<void> _addProfile(AddProfile event, Emitter<ProfileState> emit) async {
    final originalBaseUrl = LemmyClient.instance.lemmyApiV3.host;

    try {
      emit(state.copyWith(status: ProfileStatus.loading));

      String instance = event.instance.replaceAll('https://', '');
      LemmyClient.instance.changeBaseUrl(instance);

      final lemmy = LemmyClient.instance.lemmyApiV3;

      final response = await lemmy.run(Login(
        usernameOrEmail: event.username,
        password: event.password,
        totp2faToken: event.totp,
      ));

      if (response.jwt == null) return emit(state.copyWith(status: ProfileStatus.failure));

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: response.jwt));

      if (event.showContentWarning && getSiteResponse.siteView.site.contentWarning?.isNotEmpty == true) {
        return emit(state.copyWith(status: ProfileStatus.contentWarning, contentWarning: () => getSiteResponse.siteView.site.contentWarning!));
      }

      // Create a new account in the database
      Account? account = Account(
        id: '',
        username: getSiteResponse.myUser?.localUserView.person.name,
        jwt: response.jwt,
        instance: instance,
        userId: getSiteResponse.myUser?.localUserView.person.id,
        index: -1,
      );

      account = await Account.insertAccount(account);
      if (account == null) return emit(state.copyWith(status: ProfileStatus.failure));

      // Set this account as the active account
      final prefs = (await UserPreferences.instance).sharedPreferences;
      prefs.setString('active_profile_id', account.id);

      // Run the CheckAuth event to reset everything
      return await _initializeAuth(InitializeAuth(), emit);
    } on LemmyApiException catch (e) {
      return emit(state.copyWith(status: ProfileStatus.failure, error: () => e.toString()));
    } catch (e) {
      try {
        LemmyClient.instance.changeBaseUrl(originalBaseUrl);
      } catch (e, s) {
        return emit(state.copyWith(status: ProfileStatus.failure, error: () => s.toString()));
      }

      return emit(state.copyWith(status: ProfileStatus.failure, error: () => e.toString()));
    }
  }

  Future<void> _switchProfile(SwitchProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading, reload: event.reload));

    Account? account = await Account.fetchAccount(event.accountId);
    final prefs = (await UserPreferences.instance).sharedPreferences;

    if (account != null) {
      // Set this account as the active account
      prefs.setString('active_profile_id', event.accountId);
    } else {
      // Account was not found - this indicates is an anonymous account. Find the corresponding account
      final anonymousAccounts = await Account.anonymousInstances();
      final anonymousAccount = anonymousAccounts.firstWhereOrNull((element) => element.instance == event.accountId);
      account = anonymousAccount;

      await prefs.remove('active_profile_id');
    }

    if (account == null) {
      return emit(state.copyWith(status: ProfileStatus.failure, error: () => AppLocalizations.of(GlobalContext.context)!.unexpectedError));
    }

    add(InitializeAuth());
  }

  Future<void> _removeProfile(RemoveProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final prefs = (await UserPreferences.instance).sharedPreferences;

    final account = await fetchActiveProfile();
    await Account.deleteAccount(event.accountId);

    if (!account.anonymous && account.id == event.accountId) {
      // The removed profile is the currently active profile. Remove this.
      prefs.remove('active_profile_id');
      add(InitializeAuth());
    } else if (account.anonymous && account.instance == event.accountId) {
      // The removed profile is the current anonymous profile.
      add(InitializeAuth());
    }

    // Check to see if the removed profile is the current profile. If so, we need to switch to an anonymous profile.

    return emit(state.copyWith(status: ProfileStatus.success));
  }

  Future<void> _cancelLoginAttempt(CancelLoginAttempt event, Emitter<ProfileState> emit) async {
    return emit(state.copyWith(status: ProfileStatus.failure, error: () => AppLocalizations.of(GlobalContext.context)!.loginAttemptCanceled));
  }

  /// Fetches the current profile's information, including the user's information and moderated communities.
  /// This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileInformation(FetchProfileInformation event, Emitter<ProfileState> emit) async {
    final account = await fetchActiveProfile();

    if (account.anonymous) {
      return emit(
        state.copyWith(
          status: ProfileStatus.success,
          reload: event.reload,
          user: null,
          subscriptions: [],
          favorites: [],
          moderates: [],
        ),
      );
    }

    try {
      emit(state.copyWith(status: ProfileStatus.loading, user: null, moderates: [], reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      final response = await lemmy.run(GetPersonDetails(username: account.username, auth: account.jwt, sort: SortType.new_, page: 1));
      final user = ThunderUser(response.personView.person, userView: response.personView);
      final moderates = response.moderates.map((cmv) => ThunderCommunity(cmv.community)).toList();

      // This eliminates an issue which has plagued me a lot which is that there's a race condition
      // with so many calls to GetAccountInformation, we can return success for the new and old account.
      if (user.id == account.userId) {
        return emit(state.copyWith(status: ProfileStatus.success, user: () => user, moderates: moderates, reload: event.reload));
      } else {
        return emit(state.copyWith(status: ProfileStatus.success, user: null, moderates: [], reload: event.reload));
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: () => getExceptionErrorMessage(e), reload: event.reload));
    }
  }

  /// Fetches the current profile's account settings. This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileSettings(FetchProfileSettings event, Emitter<ProfileState> emit) async {
    final account = await fetchActiveProfile();
    if (account.anonymous) return emit(state.copyWith(status: ProfileStatus.success));

    try {
      emit(state.copyWith(status: ProfileStatus.loading));

      // Refresh the site information, which includes the user's settings
      final lemmy = LemmyClient.instance.lemmyApiV3;
      final response = await lemmy.run(GetSite(auth: account.jwt));

      return emit(state.copyWith(status: ProfileStatus.success, getSiteResponse: () => response));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: () => getExceptionErrorMessage(e), reload: event.reload));
    }
  }

  /// Fetches the current profile's subscribed communities. This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileSubscriptions(FetchProfileSubscriptions event, Emitter<ProfileState> emit) async {
    final account = await fetchActiveProfile();
    if (account.anonymous) return emit(state.copyWith(status: ProfileStatus.success, reload: event.reload, subscriptions: [], favorites: []));

    try {
      emit(state.copyWith(status: ProfileStatus.loading, reload: event.reload));

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
      emit(state.copyWith(status: ProfileStatus.success, reload: event.reload, subscriptions: subscriptions));

      // Refresh the favourited communities as it might've changed.
      add(FetchProfileFavorites(reload: event.reload));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, reload: event.reload, error: () => getExceptionErrorMessage(e)));
    }
  }

  /// Fetches the current profile's favourited communities. This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileFavorites(FetchProfileFavorites event, Emitter<ProfileState> emit) async {
    final account = await fetchActiveProfile();
    if (account.anonymous) return emit(state.copyWith(status: ProfileStatus.success, reload: event.reload, favorites: []));

    try {
      emit(state.copyWith(status: ProfileStatus.loading, reload: event.reload));

      final favorites = await Favorite.favorites(account.id);
      final communities = state.subscriptions.where((community) => favorites.any((favorite) => favorite.communityId == community.id)).toList();

      return emit(state.copyWith(status: ProfileStatus.success, reload: event.reload, favorites: communities));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, reload: event.reload, error: () => getExceptionErrorMessage(e)));
    }
  }
}
