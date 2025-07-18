import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/repository/account_repository.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/community/repository/community_repository.dart';
import 'package:thunder/core/enums/meta_search_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/instance/repository/instance_repository.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/search/repository/search_repository.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/user/repository/user_repository.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'user_settings_event.dart';
part 'user_settings_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  Account account;

  late InstanceRepository instanceRepository;
  late SearchRepository searchRepository;
  late CommunityRepository communityRepository;
  late AccountRepository accountRepository;
  late UserRepository userRepository;

  UserSettingsBloc({required this.account}) : super(const UserSettingsState()) {
    instanceRepository = LemmyInstanceRepository(account: account);
    searchRepository = LemmySearchRepository(account: account);
    communityRepository = LemmyCommunityRepository(account: account);
    accountRepository = LemmyAccountRepository(account: account);
    userRepository = LemmyUserRepository(account: account);

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
    return emit(state.copyWith(status: UserSettingsStatus.initial));
  }

  Future<void> _getUserSettingsEvent(GetUserSettingsEvent event, emit) async {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    try {
      final getSiteResponse = await instanceRepository.getSiteInfo();

      return emit(
        state.copyWith(
          status: UserSettingsStatus.success,
          siteResponse: getSiteResponse,
        ),
      );
    } catch (e) {
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString(),
      ));
    }
  }

  Future<void> _updateUserSettingsEvent(UpdateUserSettingsEvent event, emit) async {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    ThunderSiteResponse? originalGetSiteResponse = state.siteResponse;
    if (originalGetSiteResponse == null) emit(state.copyWith(status: UserSettingsStatus.failure));

    try {
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

      emit(state.copyWith(status: UserSettingsStatus.success, siteResponse: updatedGetSiteResponse));
      emit(state.copyWith(status: UserSettingsStatus.updating));

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

      return emit(state.copyWith(status: UserSettingsStatus.success));
    } catch (e) {
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        siteResponse: originalGetSiteResponse,
        errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString(),
      ));
    }
  }

  Future<void> _getUserBlocksEvent(GetUserBlocksEvent event, emit) async {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    try {
      final getSiteResponse = await instanceRepository.getSiteInfo();

      final personBlocks = getSiteResponse.myUser!.personBlocks.map((personBlockView) => personBlockView.target).toList()..sort((a, b) => a.name.compareTo(b.name));
      final communityBlocks = getSiteResponse.myUser!.communityBlocks.map((communityBlockView) => communityBlockView.community).toList()..sort((a, b) => a.name.compareTo(b.name));
      final instanceBlocks = getSiteResponse.myUser!.instanceBlocks.map((instanceBlockView) => instanceBlockView.instance).toList()..sort((a, b) => a['domain'].compareTo(b['domain']));

      return emit(state.copyWith(
        status: (state.instanceBeingBlocked != 0 && (instanceBlocks.any((instance) => instance['id'] == state.instanceBeingBlocked) ?? false)) ? UserSettingsStatus.revert : UserSettingsStatus.success,
        personBlocks: personBlocks,
        communityBlocks: communityBlocks,
        instanceBlocks: instanceBlocks,
      ));
    } catch (e) {
      return emit(state.copyWith(status: UserSettingsStatus.failure, errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
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
      return emit(state.copyWith(
          status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _unblockCommunityEvent(UnblockCommunityEvent event, emit) async {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    emit(state.copyWith(status: UserSettingsStatus.blocking, communityBeingBlocked: event.communityId, personBeingBlocked: 0, instanceBeingBlocked: 0));

    try {
      final blockCommunityResponse = await communityRepository.block(event.communityId, !event.unblock);

      List<ThunderCommunity> updatedCommunityBlocks;
      if (event.unblock) {
        updatedCommunityBlocks = state.communityBlocks.where((community) => community.id != event.communityId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedCommunityBlocks = (state.communityBlocks + [ThunderCommunity.fromLemmyCommunityView(blockCommunityResponse.communityView.toJson())])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.successBlock : UserSettingsStatus.revert,
        communityBlocks: updatedCommunityBlocks,
        communityBeingBlocked: event.communityId,
        personBeingBlocked: 0,
      ));
    } catch (e) {
      return emit(state.copyWith(
          status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _unblockPersonEvent(UnblockPersonEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.blocking, personBeingBlocked: event.personId, communityBeingBlocked: 0, instanceBeingBlocked: 0));

    try {
      final response = await userRepository.block(event.personId, !event.unblock);

      List<ThunderUser> updatedPersonBlocks;
      if (event.unblock) {
        updatedPersonBlocks = state.personBlocks.where((person) => person.id != event.personId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedPersonBlocks = (state.personBlocks + [ThunderUser.fromLemmyUserView(response.personView.toJson())])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.successBlock : UserSettingsStatus.revert,
        personBlocks: updatedPersonBlocks,
        personBeingBlocked: event.personId,
        communityBeingBlocked: 0,
      ));
    } catch (e) {
      return emit(state.copyWith(
          status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _listMediaEvent(ListMediaEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.listingMedia));

    try {
      int page = 1;
      List<LocalImageView> images = [];
      List<LocalImageView>? lastResponse;

      while (lastResponse?.isEmpty != true) {
        final response = await accountRepository.media(page: page);
        images.addAll(lastResponse = response.images);
        ++page;
      }

      return emit(state.copyWith(status: UserSettingsStatus.succeededListingMedia, images: images));
    } catch (e) {
      return emit(state.copyWith(status: UserSettingsStatus.failedListingMedia, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> _deleteMediaEvent(DeleteMediaEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.deletingMedia));

    try {
      // Optimistically remove the media from the list
      state.images?.removeWhere((localImageView) => localImageView.localImage.pictrsAlias == event.id);

      final l10n = AppLocalizations.of(GlobalContext.context)!;
      final account = await fetchActiveProfile();
      if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

      await PictrsApi(account.instance).delete(PictrsUploadFile(deleteToken: event.deleteToken, file: event.id), account.jwt);

      return emit(state.copyWith(status: UserSettingsStatus.succeededListingMedia, images: state.images));
    } catch (e) {
      return emit(
        state.copyWith(
          status: UserSettingsStatus.failedListingMedia,
          errorMessage: AppLocalizations.of(GlobalContext.context)!.errorDeletingImage(getExceptionErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> _findMediaUsagesEvent(FindMediaUsagesEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.searchingMedia));

    try {
      final lemmy = LemmyApiV3(account.instance, debug: kDebugMode);
      String url = Uri.https(lemmy.host, 'pictrs/image/${event.id}').toString();

      List<PostView> posts = (await searchRepository.search(query: url, type: MetaSearchType.posts)).posts.toList();
      List<PostView> postsByUrl = (await searchRepository.search(query: url, type: MetaSearchType.url)).posts.toList();

      // De-dup posts found by body and URL
      posts.addAll(postsByUrl.where((postViewByUrl) => !posts.any((postView) => postView.post.id == postViewByUrl.post.id)));

      List<ThunderComment> comments = (await searchRepository.search(
        query: url,
        type: MetaSearchType.comments,
      ))
          .comments
          .map((cv) => ThunderComment.fromLemmyCommentView(cv.toJson()))
          .toList();

      return emit(state.copyWith(
        status: UserSettingsStatus.succeededSearchingMedia,
        imageSearchPosts: await parsePosts(posts),
        imageSearchComments: comments,
      ));
    } catch (e) {
      return emit(
        state.copyWith(
          status: UserSettingsStatus.failedListingMedia,
          errorMessage: getExceptionErrorMessage(e),
        ),
      );
    }
  }
}
