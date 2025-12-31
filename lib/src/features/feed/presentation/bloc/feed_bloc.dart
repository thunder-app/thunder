import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/error_messages.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  Account account;

  late PostRepository postRepository;
  late CommunityRepository communityRepository;
  late UserRepository userRepository;

  FeedBloc({required this.account}) : super(const FeedState()) {
    postRepository = PostRepositoryImpl(account: account);
    communityRepository = CommunityRepositoryImpl(account: account);
    userRepository = UserRepositoryImpl(account: account);

    /// Handles resetting the feed to its initial state
    on<ResetFeedEvent>(
      _onResetFeed,
      transformer: restartable(),
    );

    /// Handles fetching the feed
    on<FeedFetchedEvent>(
      _onFeedFetched,
      transformer: restartable(),
    );

    /// Handles changing the sort type of the feed
    on<FeedChangePostSortTypeEvent>(
      _onFeedChangePostSortType,
      transformer: restartable(),
    );

    /// Handles updating a given item within the feed
    on<FeedItemUpdatedEvent>(
      _onFeedItemUpdated,
      transformer: throttleDroppable(Duration.zero),
    );

    on<FeedCommunityUpdatedEvent>(
      _onFeedCommunityUpdated,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles actions on a given item within the feed
    on<FeedItemActionedEvent>(
      _onFeedItemActioned,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles clearing any messages from the state
    on<FeedClearMessageEvent>(
      _onFeedClearMessage,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles hiding posts from the feed
    on<FeedHidePostsFromViewEvent>(
      _onFeedHidePostsFromView,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles creating a new post
    on<CreatePostEvent>(
      _onCreatePost,
      transformer: throttleDroppable(Duration.zero),
    );

    on<PopulatePostsEvent>(
      _onPopulatePosts,
      transformer: throttleDroppable(Duration.zero),
    );
  }

  /// Handles hiding posts from the feed. This will remove any posts from the feed for the given post ids
  Future<void> _onFeedHidePostsFromView(FeedHidePostsFromViewEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.fetching));

    List<ThunderPost> posts = List.from(state.posts);
    posts.removeWhere((ThunderPost post) => event.postIds.contains(post.id));

    emit(state.copyWith(status: FeedStatus.success, posts: posts));
  }

  /// Handles clearing any messages from the state
  Future<void> _onFeedClearMessage(FeedClearMessageEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser ? state.status : FeedStatus.success, message: null));
  }

  /// Handles post related actions on a given item within the feed
  Future<void> _onFeedItemActioned(FeedItemActionedEvent event, Emitter<FeedState> emit) async {
    assert(!(event.post == null && event.postId == null && event.postIds == null));
    emit(state.copyWith(status: FeedStatus.fetching));

    switch (event.postAction) {
      case PostAction.vote:
        // Optimistically update the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyVotePost(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          updatedPost = await postRepository.vote(post, event.value);
          updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.save:
        // Optimistically save the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallySavePost(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          updatedPost = await postRepository.save(post, event.value);
          updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.read:
        // Optimistically read the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) return; // Unable to find the post

        final post = state.posts[existingPostIndex];

        // Give a slight delay to have the UI perform any navigation first
        await Future.delayed(const Duration(milliseconds: 250));

        try {
          ThunderPost updatedPost = optimisticallyReadPost(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.read(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.multiRead:
        List<int> eventPostIds = event.postIds ?? [];

        if (eventPostIds.isNotEmpty) {
          // Optimistically read the posts
          List<int> existingPostIndexes = [];
          List<int> postIds = [];
          List<ThunderPost> posts = [];
          List<ThunderPost> originalPosts = [];

          for (int i = 0; i < state.posts.length; i++) {
            if (eventPostIds.contains(state.posts[i].id)) {
              existingPostIndexes.add(i);
              postIds.add(state.posts[i].id);
              posts.add(state.posts[i]);
              originalPosts.add(state.posts[i]);
            }
          }

          try {
            List<ThunderPost> updatedPosts = List.from(state.posts);
            for (int i = 0; i < existingPostIndexes.length; i++) {
              ThunderPost updatedPost = optimisticallyReadPost(posts[i], event.value);
              updatedPosts[existingPostIndexes[i]] = updatedPost;
            }

            // Emit the state to update UI immediately
            emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

            List<int> failed = await postRepository.readMultiple(postIds, event.value);
            if (failed.isEmpty) return emit(state.copyWith(status: FeedStatus.success));

            // Restore the original post contents if not successful
            List<ThunderPost> restoredPosts = List.from(state.posts);
            for (int i = 0; i < failed.length; i++) {
              restoredPosts[existingPostIndexes[failed[i]]] = originalPosts[failed[i]];
            }
            return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
          } catch (e) {
            // Restore the original post contents
            // They will all be restored, but this is an unlikely scenario
            List<ThunderPost> restoredPosts = List.from(state.posts);
            for (int i = 0; i < existingPostIndexes.length; i++) {
              restoredPosts[existingPostIndexes[i]] = originalPosts[i];
            }
            return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
          }
        }
      case PostAction.hide:
        // Optimistically hide the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyHidePost(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.hide(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.delete:
        // Optimistically delete the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyDeletePost(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.delete(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.report:
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          await postRepository.report(post.id, event.value);
          return emit(state.copyWith(status: FeedStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.lock:
        // Optimistically lock the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyLockPost(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.lock(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.pinCommunity:
        // Optimistically pin the post to the community
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyPinPostToCommunity(post, event.value);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.pinCommunity(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.remove:
        // Optimistically remove the post from the community
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyRemovePost(post, event.value['remove']);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.remove(post.id, event.value['remove'], event.value['reason']);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.pinInstance:
      case PostAction.purge:
        break;
    }
  }

  /// Handles updating a given item within the feed
  Future<void> _onFeedItemUpdated(FeedItemUpdatedEvent event, Emitter<FeedState> emit) async {
    // TODO: Add support for updating comments (for user profile)
    List<ThunderPost> updatedPosts = List.from(state.posts);
    for (final (index, post) in state.posts.indexed) {
      if (post.id == event.post.id) {
        updatedPosts[index] = event.post;
      }
    }

    emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
  }

  /// Handles updating information about a community
  Future<void> _onFeedCommunityUpdated(FeedCommunityUpdatedEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.fetching));
    emit(state.copyWith(status: FeedStatus.success, community: event.community));
  }

  /// Resets the FeedState to its initial state
  Future<void> _onResetFeed(ResetFeedEvent event, Emitter<FeedState> emit) async {
    if (event.softReset && state.feedType == FeedType.account) {
      // This is only used when FeedType is set to account
      emit(FeedState(
        status: FeedStatus.fetching,
        feedType: FeedType.account,
        posts: const <ThunderPost>[],
        comments: const <ThunderComment>[],
        hasReachedPostsEnd: false,
        hasReachedCommentsEnd: false,
        cursor: null,
        userId: state.userId,
        username: state.username,
        user: state.user,
        userModerates: state.userModerates,
      ));

      return;
    }

    emit(FeedState(
      status: FeedStatus.initial,
      posts: <ThunderPost>[],
      comments: <ThunderComment>[],
      hasReachedPostsEnd: false,
      hasReachedCommentsEnd: false,
      feedType: FeedType.general,
      feedListType: state.feedListType,
      postSortType: state.postSortType,
      community: null,
      communityInstance: null,
      communityModerators: [],
      user: null,
      userModerates: [],
      communityId: null,
      communityName: null,
      userId: null,
      username: null,
      cursor: null,
    ));
  }

  /// Changes the current sort type of the feed, and refreshes the feed
  Future<void> _onFeedChangePostSortType(FeedChangePostSortTypeEvent event, Emitter<FeedState> emit) async {
    add(FeedFetchedEvent(
      feedType: state.feedType,
      feedListType: state.feedListType,
      postSortType: event.postSortType,
      communityId: state.communityId,
      communityName: state.communityName,
      userId: state.userId,
      username: state.username,
      reset: true,
      showHidden: state.showHidden,
    ));
  }

  /// Fetches the posts, community information, and user information for the feed
  Future<void> _onFeedFetched(FeedFetchedEvent event, Emitter<FeedState> emit) async {
    try {
      // Assert any requirements
      if (event.reset) assert(event.feedType != null);
      if (event.reset && event.feedType == FeedType.community) assert(!(event.communityId == null && event.communityName == null));
      if (event.reset && event.feedType == FeedType.user) assert(!(event.userId != null && event.username != null));
      if (event.reset && event.feedType == FeedType.general) assert(event.feedListType != null);

      // Handle the initial fetch or reload of a feed
      if (event.reset) {
        if (state.status != FeedStatus.initial) add(ResetFeedEvent(softReset: event.feedType == FeedType.account));

        ThunderCommunity? community;
        ThunderSite? communityInstance;
        List<ThunderUser> communityModerators = [];

        ThunderUser? user;
        List<ThunderCommunity> userModerates = [];

        switch (event.feedType) {
          case FeedType.community:
            // Fetch community information
            try {
              final result = await communityRepository.getCommunity(id: event.communityId, name: event.communityName);
              community = result['community'];
              communityInstance = result['instance'];
              communityModerators = result['moderators'];
            } catch (e) {
              // If we are given a community feed, but we can't load the community, that's a problem! Emit an error.
              return emit(state.copyWith(
                status: FeedStatus.failureLoadingCommunity,
                message: getExceptionErrorMessage(e, additionalInfo: event.communityName),
                feedType: event.feedType,
              ));
            }
            break;
          case FeedType.user:
          case FeedType.account:
            // Fetch user information
            try {
              final response = await userRepository.getUser(userId: event.userId, username: event.username);
              user = response!['user'];
              userModerates = response['moderates'];
            } catch (e) {
              // If we are given a user feed, but we can't load the user, that's a problem! Emit an error.
              return emit(state.copyWith(
                status: FeedStatus.failureLoadingUser,
                message: getExceptionErrorMessage(e, additionalInfo: event.username),
                feedType: event.feedType,
              ));
            }
            break;
          case FeedType.general:
            break;
          default:
            break;
        }

        Map<String, dynamic> feedItemResult = await fetchFeedItems(
          cursor: null,
          feedListType: event.feedListType,
          postSortType: event.postSortType,
          communityId: event.communityId,
          communityName: event.communityName,
          userId: event.userId ?? user?.id,
          username: event.username,
          feedTypeSubview: event.feedTypeSubview,
          showHidden: event.showHidden,
          showSaved: event.showSaved,
          notifyExcessiveApiCalls: () => emit(state.copyWith(excessivesApiCalls: true)),
        );

        // Extract information from the response
        List<ThunderPost> posts = feedItemResult['posts'];
        List<ThunderComment> comments = feedItemResult['comments'];
        bool hasReachedPostsEnd = feedItemResult['hasReachedPostsEnd'];
        bool hasReachedCommentsEnd = feedItemResult['hasReachedCommentsEnd'];
        String? cursor = feedItemResult['cursor'];

        return emit(state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          comments: comments,
          hasReachedPostsEnd: hasReachedPostsEnd,
          hasReachedCommentsEnd: hasReachedCommentsEnd,
          feedType: event.feedType,
          feedListType: event.feedListType,
          postSortType: event.postSortType,
          community: community,
          communityInstance: communityInstance,
          communityModerators: communityModerators,
          user: user,
          userModerates: userModerates,
          communityId: event.communityId,
          communityName: event.communityName,
          userId: event.userId ?? user?.id,
          username: event.username,
          cursor: cursor,
          showHidden: event.showHidden,
          showSaved: event.showSaved,
        ));
      }

      // If the feed is already being fetched but it is not a reset, then just wait
      if (state.status == FeedStatus.fetching) return;

      // Handle fetching the next page of the feed
      emit(state.copyWith(status: FeedStatus.fetching));

      List<ThunderPost> posts = List.from(state.posts);
      List<ThunderComment> comments = List.from(state.comments);

      Map<String, dynamic> feedItemResult = await fetchFeedItems(
        cursor: state.cursor,
        feedListType: state.feedListType,
        postSortType: state.postSortType,
        communityId: state.communityId,
        communityName: state.communityName,
        userId: state.userId,
        username: state.username,
        feedTypeSubview: event.feedTypeSubview,
        showHidden: state.showHidden,
        showSaved: state.showSaved,
      );

      // Extract information from the response
      List<ThunderPost> newPosts = feedItemResult['posts'];
      List<ThunderComment> newComments = feedItemResult['comments'];
      bool hasReachedPostsEnd = feedItemResult['hasReachedPostsEnd'];
      bool hasReachedCommentsEnd = feedItemResult['hasReachedCommentsEnd'];
      String? cursor = feedItemResult['cursor'];

      Set<int> newInsertedPostIds = Set.from(state.insertedPostIds);
      List<ThunderPost> filteredPosts = [];

      // Ensure we don't add existing posts to view
      for (ThunderPost post in newPosts) {
        int id = post.id;
        if (!newInsertedPostIds.contains(id)) {
          newInsertedPostIds.add(id);
          filteredPosts.add(post);
        }
      }

      posts.addAll(filteredPosts);
      comments.addAll(newComments);

      return emit(state.copyWith(
        status: FeedStatus.success,
        insertedPostIds: newInsertedPostIds.toList(),
        posts: posts,
        comments: comments,
        hasReachedPostsEnd: hasReachedPostsEnd,
        hasReachedCommentsEnd: hasReachedCommentsEnd,
        cursor: cursor,
      ));
    } catch (e) {
      debugPrint('Error fetching feed: $e');
      return emit(state.copyWith(status: FeedStatus.failure, message: e is LemmyApiException ? e.message : e.toString()));
    }
  }

  /// This function is used to create a post. We can pass in a communityId directly to determine the community to post to.
  Future<void> _onCreatePost(CreatePostEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.fetching));

    try {
      final post = await postRepository.create(
        communityId: event.communityId,
        name: event.name,
        body: event.body,
        url: event.url,
        nsfw: event.nsfw,
      );

      // Add the post to the state
      List<ThunderPost> updatedPosts = List.from(state.posts);
      updatedPosts.insert(0, post);

      emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
    } catch (e) {
      return emit(state.copyWith(status: FeedStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onPopulatePosts(PopulatePostsEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(posts: event.posts));
  }
}
