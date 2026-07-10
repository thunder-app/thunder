import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/features/account/domain/utils/profile_community_utils.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/core/networking/networking.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

part 'profile_event.dart';
part 'profile_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Account account;

  InstanceRepository? instanceRepository;
  AccountRepository? accountRepository;
  UserRepository? userRepository;

  final InstanceRepository Function(Account) _instanceRepositoryFactory;
  final AccountRepository Function(Account) _accountRepositoryFactory;
  final UserRepository Function(Account) _userRepositoryFactory;
  final PlatformDetectionService _platformDetectionService;
  final LocalizationService _localizationService;

  ProfileBloc({
    required this.account,
    required InstanceRepository Function(Account) instanceRepositoryFactory,
    required AccountRepository Function(Account) accountRepositoryFactory,
    required UserRepository Function(Account) userRepositoryFactory,
    required PlatformDetectionService platformDetectionService,
    required LocalizationService localizationService,
  })  : _instanceRepositoryFactory = instanceRepositoryFactory,
        _accountRepositoryFactory = accountRepositoryFactory,
        _userRepositoryFactory = userRepositoryFactory,
        _platformDetectionService = platformDetectionService,
        _localizationService = localizationService,
        super(ProfileState(account: account)) {
    // This event should be triggered during the start of the app, or when there is a change in the active account
    on<InitializeAuth>(_initializeAuth, transformer: restartable());

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

    PlatformVersionCache().trySet(account.instance, platformInfo['version']?.toString());

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
      final ThunderUser user = response!.user;
      final List<ThunderCommunity> moderates = response.moderates;

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

      final favorites = await createFavoriteRepository().favorites(account.id);
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
