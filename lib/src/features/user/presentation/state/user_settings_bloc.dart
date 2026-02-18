import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/user/domain/utils/user_media_utils.dart';
import 'package:thunder/src/foundation/networking/networking.dart';

part 'user_settings_event.dart';
part 'user_settings_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  final Account account;

  final InstanceRepository instanceRepository;
  final SearchRepository searchRepository;
  final CommunityRepository communityRepository;
  final AccountRepository accountRepository;
  final UserRepository userRepository;
  final ActiveAccountProvider _activeAccountProvider;
  final LocalizationService _localizationService;

  UserSettingsBloc({
    required this.account,
    required this.instanceRepository,
    required this.searchRepository,
    required this.communityRepository,
    required this.accountRepository,
    required this.userRepository,
    required ActiveAccountProvider activeAccountProvider,
    required LocalizationService localizationService,
  })  : _activeAccountProvider = activeAccountProvider,
        _localizationService = localizationService,
        super(const UserSettingsState()) {
    on<ResetUserSettingsEvent>(
      _resetUserSettingsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserSettingsEvent>(
      _getUserSettingsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdateUserSettingsEvent>(
      _updateUserSettingsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserBlocksEvent>(
      _getUserBlocksEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnblockInstanceEvent>(
      _unblockInstanceEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnblockCommunityEvent>(
      _unblockCommunityEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnblockPersonEvent>(
      _unblockPersonEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ListMediaEvent>(
      _listMediaEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<DeleteMediaEvent>(
      _deleteMediaEvent,
      // Do not use any transformer, because a throttleDroppable will only process the first request and restartable will only process the last.
    );
    on<FindMediaUsagesEvent>(
      _findMediaUsagesEvent,
    );
  }

  Future<void> _resetUserSettingsEvent(ResetUserSettingsEvent event, emit) async {
    return emit(
      state.copyWith(
        status: UserSettingsStatus.initial,
        errorMessage: '',
        errorReason: null,
      ),
    );
  }

  Future<void> _getUserSettingsEvent(GetUserSettingsEvent event, emit) async {
    try {
      final l10n = _localizationService.l10n;
      final account = await _activeAccountProvider.getActiveAccount();
      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserSettingsStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      final getSiteResponse = await instanceRepository.info();

      return emit(
        state.copyWith(
          status: UserSettingsStatus.success,
          siteResponse: getSiteResponse,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _updateUserSettingsEvent(UpdateUserSettingsEvent event, emit) async {
    final originalGetSiteResponse = state.siteResponse;
    try {
      final l10n = _localizationService.l10n;
      final account = await _activeAccountProvider.getActiveAccount();
      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserSettingsStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      if (originalGetSiteResponse == null) {
        return emit(state.copyWith(
          status: UserSettingsStatus.failure,
          errorMessage: l10n.unexpectedError,
          errorReason: AppErrorReason.validation(
            message: l10n.unexpectedError,
          ),
        ));
      }

      // Optimistically update settings
      ThunderLocalUser localUser = state.siteResponse!.myUser!.localUserView.localUser.copyWith(
        email: event.email ?? state.siteResponse!.myUser!.localUserView.localUser.email,
        showReadPosts: event.showReadPosts ?? state.siteResponse!.myUser!.localUserView.localUser.showReadPosts,
        showScores: event.showScores ?? state.siteResponse!.myUser!.localUserView.localUser.showScores,
        showBotAccounts: event.showBotAccounts ?? state.siteResponse!.myUser!.localUserView.localUser.showBotAccounts,
        showNsfw: event.showNsfw ?? state.siteResponse!.myUser!.localUserView.localUser.showNsfw,
        defaultListingType: event.defaultFeedListType ?? state.siteResponse!.myUser!.localUserView.localUser.defaultListingType,
        defaultSortType: event.defaultPostSortType ?? state.siteResponse!.myUser!.localUserView.localUser.defaultSortType,
      );

      ThunderSiteResponse updatedGetSiteResponse = state.siteResponse!.copyWith(
        myUser: state.siteResponse!.myUser!.copyWith(
          localUserView: state.siteResponse!.myUser!.localUserView.copyWith(
            person: state.siteResponse!.myUser!.localUserView.person.copyWith(
              botAccount: event.botAccount ?? state.siteResponse!.myUser!.localUserView.person.botAccount,
              bio: event.bio ?? state.siteResponse!.myUser!.localUserView.person.bio,
              displayName: event.displayName ?? state.siteResponse!.myUser!.localUserView.person.displayName,
              matrixUserId: event.matrixUserId ?? state.siteResponse!.myUser!.localUserView.person.matrixUserId,
            ),
            localUser: localUser,
          ),
          discussionLanguages: event.discussionLanguages ?? state.siteResponse!.discussionLanguages,
        ),
      );

      emit(state.copyWith(
        status: UserSettingsStatus.success,
        siteResponse: updatedGetSiteResponse,
        errorReason: null,
      ));
      emit(state.copyWith(status: UserSettingsStatus.updating, errorReason: null));

      await accountRepository.saveSettings(
        bio: event.bio,
        email: event.email,
        matrixUserId: event.matrixUserId,
        displayName: event.displayName,
        defaultFeedListType: event.defaultFeedListType,
        defaultPostSortType: event.defaultPostSortType,
        showNsfw: event.showNsfw,
        showReadPosts: event.showReadPosts,
        showScores: event.showScores,
        botAccount: event.botAccount,
        showBotAccounts: event.showBotAccounts,
        discussionLanguages: event.discussionLanguages,
      );

      return emit(state.copyWith(status: UserSettingsStatus.success, errorReason: null));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        siteResponse: originalGetSiteResponse,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _getUserBlocksEvent(GetUserBlocksEvent event, emit) async {
    try {
      final l10n = _localizationService.l10n;
      final account = await _activeAccountProvider.getActiveAccount();
      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserSettingsStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      final getSiteResponse = await instanceRepository.info();

      final personBlocks = getSiteResponse.myUser!.personBlocks..sort((a, b) => a.name.compareTo(b.name));
      final communityBlocks = getSiteResponse.myUser!.communityBlocks..sort((a, b) => a.name.compareTo(b.name));
      final instanceBlocks = getSiteResponse.myUser!.instanceBlocks.map((instanceBlockView) => instanceBlockView.instance).toList()..sort((a, b) => a['domain'].compareTo(b['domain']));

      return emit(state.copyWith(
        status: (state.instanceBeingBlocked != 0 && instanceBlocks.any((instance) => instance['id'] == state.instanceBeingBlocked)) ? UserSettingsStatus.revert : UserSettingsStatus.success,
        personBlocks: personBlocks,
        communityBlocks: communityBlocks,
        instanceBlocks: instanceBlocks,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _unblockInstanceEvent(UnblockInstanceEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.blocking, instanceBeingBlocked: event.instanceId, personBeingBlocked: 0, communityBeingBlocked: 0));

    try {
      await instanceRepository.block(event.instanceId, !event.unblock);

      emit(state.copyWith(
        status: state.status,
        instanceBeingBlocked: event.instanceId,
        personBeingBlocked: 0,
        communityBeingBlocked: 0,
      ));

      return add(const GetUserBlocksEvent());
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _unblockCommunityEvent(UnblockCommunityEvent event, emit) async {
    try {
      final l10n = _localizationService.l10n;
      final account = await _activeAccountProvider.getActiveAccount();
      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserSettingsStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      emit(state.copyWith(status: UserSettingsStatus.blocking, communityBeingBlocked: event.communityId, personBeingBlocked: 0, instanceBeingBlocked: 0));

      final community = await communityRepository.block(event.communityId, !event.unblock);

      List<ThunderCommunity> updatedCommunityBlocks;
      if (event.unblock) {
        updatedCommunityBlocks = state.communityBlocks.where((community) => community.id != event.communityId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedCommunityBlocks = (state.communityBlocks + [community])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.successBlock : UserSettingsStatus.revert,
        communityBlocks: updatedCommunityBlocks,
        communityBeingBlocked: event.communityId,
        personBeingBlocked: 0,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _unblockPersonEvent(UnblockPersonEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.blocking, personBeingBlocked: event.personId, communityBeingBlocked: 0, instanceBeingBlocked: 0));

    try {
      final user = await userRepository.block(event.personId, !event.unblock);

      List<ThunderUser> updatedPersonBlocks;
      if (event.unblock) {
        updatedPersonBlocks = state.personBlocks.where((person) => person.id != event.personId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedPersonBlocks = (state.personBlocks + [user])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.successBlock : UserSettingsStatus.revert,
        personBlocks: updatedPersonBlocks,
        personBeingBlocked: event.personId,
        communityBeingBlocked: 0,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _listMediaEvent(ListMediaEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.listingMedia));

    try {
      int page = 1;
      final images = <Map<String, dynamic>>[];

      while (true) {
        final response = await accountRepository.media(page: page);
        if (response.isEmpty) break;

        images.addAll(response.images);
        page++;
      }

      return emit(state.copyWith(
        status: UserSettingsStatus.succeededListingMedia,
        images: images,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: UserSettingsStatus.failedListingMedia,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _deleteMediaEvent(DeleteMediaEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.deletingMedia));

    try {
      // Optimistically remove the media from the list
      final images = removeImageByAlias(
        images: state.images ?? const [],
        alias: event.id,
      );

      final l10n = _localizationService.l10n;
      final account = await _activeAccountProvider.getActiveAccount();
      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserSettingsStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      await accountRepository.deleteImage(file: event.id, token: event.deleteToken);

      return emit(state.copyWith(
        status: UserSettingsStatus.succeededListingMedia,
        images: images,
        errorReason: null,
      ));
    } catch (e) {
      final message = _localizationService.l10n.errorDeletingImage(getExceptionErrorMessage(e));
      return emit(
        state.copyWith(
          status: UserSettingsStatus.failedListingMedia,
          errorMessage: message,
          errorReason: AppErrorReason.actionFailed(
            message: message,
            details: e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _findMediaUsagesEvent(FindMediaUsagesEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.searchingMedia));

    try {
      final account = await _activeAccountProvider.getActiveAccount();
      String url = Uri.https(account.instance, 'pictrs/image/${event.id}').toString();

      final postsResponse = await searchRepository.search(query: url, type: MetaSearchType.posts);
      final postsByUrlResponse = await searchRepository.search(query: url, type: MetaSearchType.url);

      List<ThunderPost> posts = postsResponse.posts;
      List<ThunderPost> postsByUrl = postsByUrlResponse.posts;

      // De-dup posts found by body and URL
      posts = mergeUniquePosts(
        primary: posts,
        secondary: postsByUrl,
      );

      final response = await searchRepository.search(query: url, type: MetaSearchType.comments);
      final List<ThunderComment> comments = response.comments;

      return emit(state.copyWith(
        status: UserSettingsStatus.succeededSearchingMedia,
        imageSearchPosts: await parsePosts(posts),
        imageSearchComments: comments,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(
        state.copyWith(
          status: UserSettingsStatus.failedListingMedia,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(
            message: message,
            details: e.toString(),
          ),
        ),
      );
    }
  }
}
