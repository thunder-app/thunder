import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/features/account/domain/utils/profile_community_utils.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/networking/networking.dart';

part 'profile_event.dart';
part 'profile_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  Account account;

  InstanceRepository? instanceRepository;
  AccountRepository? accountRepository;
  UserRepository? userRepository;

  final InstanceRepository Function(Account) _instanceRepositoryFactory;
  final AccountRepository Function(Account) _accountRepositoryFactory;
  final UserRepository Function(Account) _userRepositoryFactory;
  final PlatformDetectionService _platformDetectionService;
  final ActiveAccountProvider _activeAccountProvider;
  final LocalizationService _localizationService;
  final PreferencesStore _preferencesStore;

  ProfileBloc({
    required this.account,
    required InstanceRepository Function(Account) instanceRepositoryFactory,
    required AccountRepository Function(Account) accountRepositoryFactory,
    required UserRepository Function(Account) userRepositoryFactory,
    required PlatformDetectionService platformDetectionService,
    required ActiveAccountProvider activeAccountProvider,
    required LocalizationService localizationService,
    required PreferencesStore preferencesStore,
  })  : _instanceRepositoryFactory = instanceRepositoryFactory,
        _accountRepositoryFactory = accountRepositoryFactory,
        _userRepositoryFactory = userRepositoryFactory,
        _platformDetectionService = platformDetectionService,
        _activeAccountProvider = activeAccountProvider,
        _localizationService = localizationService,
        _preferencesStore = preferencesStore,
        super(ProfileState(account: account)) {
    // This event should be triggered during the start of the app, or when there is a change in the active account
    on<InitializeAuth>(_initializeAuth, transformer: restartable());

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

  Future<void> _initializeAuth(InitializeAuth event, Emitter<ProfileState> emit) async {
    final platformInfo = await _platformDetectionService.detectPlatform(account.instance);
    if (platformInfo == null) {
      final message = _localizationService.l10n.unableToLoadInstance(account.instance);
      return emit(state.copyWith(
        status: ProfileStatus.failureCheckingInstance,
        error: () => message,
        errorReason: () => AppErrorReason.network(message: message),
      ));
    }

    PlatformVersionCache().set(account.instance, platformInfo['version'] ?? '');

    // Initialize the repositories with the current account
    instanceRepository = _instanceRepositoryFactory(account);
    accountRepository = _accountRepositoryFactory(account);
    userRepository = _userRepositoryFactory(account);

    // Check to see the instance settings (for checking if downvotes are enabled)
    bool downvotesEnabled = true;
    ThunderSiteResponse? siteResponse;

    try {
      siteResponse = await instanceRepository!.info().timeout(const Duration(seconds: 15));
      downvotesEnabled = siteResponse.site.enableDownvotes ?? true;
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: ProfileStatus.failureCheckingInstance,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
      ));
    }

    emit(
      state.copyWith(
        status: ProfileStatus.success,
        account: () => account,
        isLoggedIn: !account.anonymous,
        downvotesEnabled: downvotesEnabled,
        siteResponse: () => siteResponse!,
        moderates: [],
        subscriptions: [],
        favorites: [],
        error: () => null,
        errorReason: () => null,
      ),
    );

    // Do not use add(BlocEvent) here, as we want all these to happen sequentially.
    await _fetchProfileInformation(FetchProfileInformation(reload: false), emit);
    await _fetchProfileSettings(FetchProfileSettings(), emit);
    await _fetchProfileSubscriptions(FetchProfileSubscriptions(reload: false), emit);

    return;
  }

  Future<void> _addProfile(AddProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(
        status: ProfileStatus.loading,
        error: () => null,
        errorReason: () => null,
      ));

      final instanceUrl = event.instance.replaceAll('https://', '');

      // Detect the platform before attempting to log in
      final platformInfo = await _platformDetectionService.detectPlatform(instanceUrl) ?? {'platform': ThreadiversePlatform.lemmy};
      final platform = platformInfo['platform'];

      // Create a temporary Account to attempt to log in
      Account tempAccount = Account(id: '', index: -1, instance: instanceUrl, platform: platform);

      // Create a temporary account repository to use for the login
      final jwt = await _accountRepositoryFactory(tempAccount).login(username: event.username, password: event.password, totp: event.totp);
      if (jwt == null) {
        final message = _localizationService.l10n.unexpectedError;
        return emit(state.copyWith(
          status: ProfileStatus.failure,
          error: () => message,
          errorReason: () => AppErrorReason.actionFailed(message: message),
        ));
      }

      // Create a temporary instance repository to use for the site information
      tempAccount = Account(id: '', index: -1, jwt: jwt, instance: tempAccount.instance, platform: platform);
      final siteResponse = await _instanceRepositoryFactory(tempAccount).info();

      if (event.showContentWarning && siteResponse.site.contentWarning?.isNotEmpty == true) {
        return emit(state.copyWith(status: ProfileStatus.contentWarning, contentWarning: () => siteResponse.site.contentWarning!));
      }

      // Create a new account in the database
      Account? account = Account(
        id: '',
        username: siteResponse.myUser?.localUserView.person.name,
        jwt: jwt,
        instance: tempAccount.instance,
        userId: siteResponse.myUser?.localUserView.person.id,
        index: -1,
        platform: platform,
      );

      account = await Account.insertAccount(account);
      if (account == null) {
        final message = _localizationService.l10n.unexpectedError;
        return emit(state.copyWith(
          status: ProfileStatus.failure,
          error: () => message,
          errorReason: () => AppErrorReason.unexpected(message: message),
        ));
      }

      // Set this account as the active account
      this.account = account;
      await _preferencesStore.setString('active_profile_id', account.id);

      // Run the CheckAuth event to reset everything
      return await _initializeAuth(InitializeAuth(), emit);
    } catch (e) {
      debugPrint('Error adding profile: ${e.toString()}');
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: ProfileStatus.failure,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
      ));
    }
  }

  Future<void> _switchProfile(SwitchProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
      reload: event.reload,
      error: () => null,
      errorReason: () => null,
    ));

    Account? account = await Account.fetchAccount(event.accountId);

    if (account != null) {
      // Set this account as the active account
      await _preferencesStore.setString('active_profile_id', event.accountId);
    } else {
      // Account was not found - this indicates is an anonymous account. Find the corresponding account
      final anonymousAccounts = await Account.anonymousInstances();
      final anonymousAccount = anonymousAccounts.firstWhereOrNull((element) => element.instance == event.accountId);
      account = anonymousAccount;

      await _preferencesStore.remove('active_profile_id');
    }

    if (account == null) {
      final message = _localizationService.l10n.unexpectedError;
      return emit(state.copyWith(
        status: ProfileStatus.failure,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
      ));
    }

    this.account = account;
    add(InitializeAuth());
  }

  Future<void> _removeProfile(RemoveProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
      error: () => null,
      errorReason: () => null,
    ));

    final account = await _activeAccountProvider.getActiveAccount();
    await Account.deleteAccount(event.accountId);

    if (!account.anonymous && account.id == event.accountId) {
      // The removed profile is the currently active profile. Remove this.
      await _preferencesStore.remove('active_profile_id');
      add(InitializeAuth());
    } else if (account.anonymous && account.instance == event.accountId) {
      // The removed profile is the current anonymous profile.
      add(InitializeAuth());
    }

    return emit(state.copyWith(
      status: ProfileStatus.success,
      error: () => null,
      errorReason: () => null,
    ));
  }

  Future<void> _cancelLoginAttempt(CancelLoginAttempt event, Emitter<ProfileState> emit) async {
    final message = _localizationService.l10n.loginAttemptCanceled;
    return emit(state.copyWith(
      status: ProfileStatus.failure,
      error: () => message,
      errorReason: () => AppErrorReason.actionFailed(message: message),
    ));
  }

  /// Fetches the current profile's information, including the user's information and moderated communities.
  /// This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileInformation(FetchProfileInformation event, Emitter<ProfileState> emit) async {
    final account = await _activeAccountProvider.getActiveAccount();
    if (account.anonymous) {
      return emit(state.copyWith(
        status: ProfileStatus.success,
        reload: event.reload,
        user: null,
        subscriptions: [],
        favorites: [],
        moderates: [],
        error: () => null,
        errorReason: () => null,
      ));
    }

    try {
      emit(state.copyWith(
        status: ProfileStatus.loading,
        user: null,
        moderates: [],
        reload: event.reload,
        error: () => null,
        errorReason: () => null,
      ));

      final response = await userRepository!.getUser(username: account.username, sort: PostSortType.new_, page: 1);
      final ThunderUser user = response!['user'];
      final List<ThunderCommunity> moderates = response['moderates'];

      // This eliminates an issue which has plagued me a lot which is that there's a race condition
      // with so many calls to GetAccountInformation, we can return success for the new and old account.
      if (isSameUser(user: user, account: account)) {
        return emit(state.copyWith(
          status: ProfileStatus.success,
          user: () => user,
          moderates: moderates,
          reload: event.reload,
          error: () => null,
          errorReason: () => null,
        ));
      }

      return emit(state.copyWith(
        status: ProfileStatus.success,
        user: null,
        moderates: [],
        reload: event.reload,
        error: () => null,
        errorReason: () => null,
      ));
    } catch (e) {
      debugPrint('Error fetching profile information: ${e.toString()}');
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.failureCheckingInstance,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
        reload: event.reload,
      ));
    }
  }

  /// Fetches the current profile's account settings. This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileSettings(FetchProfileSettings event, Emitter<ProfileState> emit) async {
    final account = await _activeAccountProvider.getActiveAccount();
    if (account.anonymous) {
      return emit(state.copyWith(
        status: ProfileStatus.success,
        error: () => null,
        errorReason: () => null,
      ));
    }

    try {
      emit(state.copyWith(
        status: ProfileStatus.loading,
        error: () => null,
        errorReason: () => null,
      ));

      // Refresh the site information, which includes the user's settings
      final response = await instanceRepository!.info();

      return emit(state.copyWith(
        status: ProfileStatus.success,
        siteResponse: () => response,
        error: () => null,
        errorReason: () => null,
      ));
    } catch (e) {
      debugPrint('Error fetching profile settings: ${e.toString()}');
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.failureCheckingInstance,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
        reload: event.reload,
      ));
    }
  }

  /// Fetches the current profile's subscribed communities. This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileSubscriptions(FetchProfileSubscriptions event, Emitter<ProfileState> emit) async {
    final account = await _activeAccountProvider.getActiveAccount();
    if (account.anonymous) {
      return emit(state.copyWith(
        status: ProfileStatus.success,
        reload: event.reload,
        subscriptions: [],
        favorites: [],
        error: () => null,
        errorReason: () => null,
      ));
    }

    try {
      emit(state.copyWith(
        status: ProfileStatus.loading,
        reload: event.reload,
        error: () => null,
        errorReason: () => null,
      ));
      final subscriptions = await accountRepository!.subscriptions();
      emit(state.copyWith(
        status: ProfileStatus.success,
        reload: event.reload,
        subscriptions: subscriptions,
        error: () => null,
        errorReason: () => null,
      ));

      // Refresh the favourited communities as it might've changed.
      add(FetchProfileFavorites(reload: event.reload));
    } catch (e) {
      debugPrint('Error fetching profile subscriptions: ${e.toString()}');
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.failureCheckingInstance,
        reload: event.reload,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
      ));
    }
  }

  /// Fetches the current profile's favourited communities. This is only applicable for non-anonymous profiles.
  Future<void> _fetchProfileFavorites(FetchProfileFavorites event, Emitter<ProfileState> emit) async {
    final account = await _activeAccountProvider.getActiveAccount();
    if (account.anonymous) {
      return emit(state.copyWith(
        status: ProfileStatus.success,
        reload: event.reload,
        favorites: [],
        error: () => null,
        errorReason: () => null,
      ));
    }

    try {
      emit(state.copyWith(
        status: ProfileStatus.loading,
        reload: event.reload,
        error: () => null,
        errorReason: () => null,
      ));

      final favorites = await Favorite.favorites(account.id);
      final communities = filterFavorites(
        subscriptions: state.subscriptions,
        favorites: favorites,
      );

      return emit(state.copyWith(
        status: ProfileStatus.success,
        reload: event.reload,
        favorites: communities,
        error: () => null,
        errorReason: () => null,
      ));
    } catch (e) {
      debugPrint('Error fetching profile favorites: ${e.toString()}');
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.failureCheckingInstance,
        reload: event.reload,
        error: () => message,
        errorReason: () => AppErrorReason.unexpected(message: message),
      ));
    }
  }
}
