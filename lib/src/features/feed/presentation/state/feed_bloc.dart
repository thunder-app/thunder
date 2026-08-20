import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/feed/domain/utils/feed_collection_utils.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/core/networking/networking.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

/// Coordinates feed fetching, pagination, and local feed item mutations.
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final Account account;

  final PostRepository postRepository;
  final CommunityRepository communityRepository;
  final UserRepository userRepository;

  FeedBloc({required this.account, required this.postRepository, required this.communityRepository, required this.userRepository}) : super(const FeedState()) {
    /// Handles resetting the feed to its initial state
    on<ResetFeedEvent>(_onResetFeed, transformer: restartable());

    /// Handles fetching the feed
    on<FeedFetchedEvent>(_onFeedFetched, transformer: restartable());

    /// Handles fetching the next page for the currently loaded feed.
    on<FeedPaginatedEvent>(_onFeedPaginated, transformer: droppable());

    /// Handles changing the sort type of the feed
    on<FeedChangePostSortTypeEvent>(_onFeedChangePostSortType, transformer: restartable());

    /// Handles updating a given item within the feed
    on<FeedItemUpdatedEvent>(_onFeedItemUpdated, transformer: throttleDroppable(Duration.zero));

    on<FeedCommunityUpdatedEvent>(_onFeedCommunityUpdated, transformer: throttleDroppable(Duration.zero));

    /// Handles actions on a given item within the feed
    on<FeedItemActionedEvent>(_onFeedItemActioned, transformer: throttleDroppable(Duration.zero));

    /// Handles clearing any messages from the state
    on<FeedClearMessageEvent>(_onFeedClearMessage, transformer: throttleDroppable(Duration.zero));

    /// Handles hiding posts from the feed
    on<FeedHidePostsFromViewEvent>(_onFeedHidePostsFromView, transformer: throttleDroppable(Duration.zero));

    /// Handles creating a new post
    on<CreatePostEvent>(_onCreatePost, transformer: throttleDroppable(Duration.zero));

    on<PopulatePostsEvent>(_onPopulatePosts, transformer: throttleDroppable(Duration.zero));
  }

  /// Handles hiding posts from the feed. This will remove any posts from the feed for the given post ids
  Future<void> _onFeedHidePostsFromView(FeedHidePostsFromViewEvent event, Emitter<FeedState> emit) async {
    if (event.postIds.isEmpty) return;

    final posts = hidePostsByIds(posts: state.posts, postIds: event.postIds.toSet());

    if (posts.length == state.posts.length) return;

    emit(state.copyWith(status: FeedStatus.success, posts: posts, errorReason: null));
  }

  /// Handles clearing any messages from the state
  Future<void> _onFeedClearMessage(FeedClearMessageEvent event, Emitter<FeedState> emit) async {
    emit(
      state.copyWith(status: state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser ? state.status : FeedStatus.success, message: null, errorReason: null),
    );
  }

  /// Handles post related actions on a given item within the feed
  Future<void> _onFeedItemActioned(FeedItemActionedEvent event, Emitter<FeedState> emit) async {
    assert(!(event.post == null && event.postId == null && event.postIds == null));

    switch (event.postAction) {
      case PostAction.vote:
        final input = event.actionInput;
        if (input is! VotePostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically update the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.score;

        try {
          ThunderPost updatedPost = optimisticallyVotePost(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          updatedPost = await postRepository.vote(post, value);
          updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.save:
        final input = event.actionInput;
        if (input is! SavePostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically save the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.save;

        try {
          ThunderPost updatedPost = optimisticallySavePost(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          updatedPost = await postRepository.save(post, value);
          updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.read:
        final input = event.actionInput;
        if (input is! ReadPostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically read the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) return; // Unable to find the post

        final post = state.posts[existingPostIndex];
        final value = input.read;

        // Give a slight delay to have the UI perform any navigation first
        await Future.delayed(const Duration(milliseconds: 250));

        try {
          ThunderPost updatedPost = optimisticallyReadPost(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.read(post.id, value);
          if (success) return;

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.multiRead:
        final input = event.actionInput;
        if (input is! MultiReadPostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        List<int> eventPostIds = event.postIds ?? [];
        final value = input.read;

        if (eventPostIds.isNotEmpty) {
          // Optimistically read the posts
          final collected = collectByIds(source: state.posts, ids: eventPostIds);
          List<int> existingPostIndexes = collected.indexes;
          List<int> postIds = collected.ids;
          List<ThunderPost> posts = collected.posts;
          List<ThunderPost> originalPosts = List<ThunderPost>.from(posts);

          try {
            List<ThunderPost> updatedPosts = List.from(state.posts);
            for (int i = 0; i < existingPostIndexes.length; i++) {
              ThunderPost updatedPost = optimisticallyReadPost(posts[i], value);
              updatedPosts[existingPostIndexes[i]] = updatedPost;
            }

            // Emit the state to update UI immediately
            emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

            List<int> failed = await postRepository.readMultiple(postIds, value);
            if (failed.isEmpty) {
              return;
            }

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
        final input = event.actionInput;
        if (input is! HidePostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically hide the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.hide;

        try {
          ThunderPost updatedPost = optimisticallyHidePost(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.hide(post.id, value);
          if (success) return;

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.delete:
        final input = event.actionInput;
        if (input is! DeletePostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically delete the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.delete;

        try {
          ThunderPost updatedPost = optimisticallyDeletePost(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.delete(post.id, value);
          if (success) return;

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.report:
        final input = event.actionInput;
        if (input is! ReportPostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.reason;

        try {
          await postRepository.report(post.id, value);
          return;
        } catch (e) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.lock:
        final input = event.actionInput;
        if (input is! LockPostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically lock the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.lock;

        try {
          ThunderPost updatedPost = optimisticallyLockPost(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.lock(post.id, value);
          if (success) return;

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.pinCommunity:
        final input = event.actionInput;
        if (input is! PinCommunityPostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically pin the post to the community
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final value = input.pin;

        try {
          ThunderPost updatedPost = optimisticallyPinPostToCommunity(post, value);
          List<ThunderPost> updatedPosts = replaceAt(source: state.posts, index: existingPostIndex, value: updatedPost);

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.pinCommunity(post.id, value);
          if (success) return;

          // Restore the original post contents if not successful
          List<ThunderPost> restoredPosts = replaceAt(source: state.posts, index: existingPostIndex, value: post);
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        } catch (e) {
          // Restore the original post contents
          List<ThunderPost> restoredPosts = List.from(state.posts);
          restoredPosts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure, posts: restoredPosts));
        }
      case PostAction.remove:
        final input = event.actionInput;
        if (input is! RemovePostInput) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        // Optimistically remove the post from the community
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        if (existingPostIndex == -1) {
          return emit(state.copyWith(status: FeedStatus.failure));
        }
        final post = state.posts[existingPostIndex];
        final remove = input.remove;
        final reason = input.reason;

        try {
          ThunderPost updatedPost = optimisticallyRemovePost(post, remove);
          List<ThunderPost> updatedPosts = List.from(state.posts);
          updatedPosts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));

          bool success = await postRepository.remove(post.id, remove, reason);
          if (success) return;

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
    List<ThunderPost> updatedPosts = List.from(state.posts);

    bool foundPost = false;

    for (final (index, post) in state.posts.indexed) {
      if (post.id == event.post.id) {
        final preserveMedia = event.post.media.isEmpty && post.media.isNotEmpty;
        final updatedPost = preserveMedia ? event.post.copyWith(media: post.media) : event.post;
        if (updatedPost == post) return;

        updatedPosts[index] = updatedPost;
        foundPost = true;
        break;
      }
    }

    if (!foundPost) return;

    emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
  }

  /// Handles updating information about a community
  Future<void> _onFeedCommunityUpdated(FeedCommunityUpdatedEvent event, Emitter<FeedState> emit) async {
    if (event.community == state.community) return;

    emit(state.copyWith(status: FeedStatus.success, community: event.community));
  }

  /// Resets the FeedState to its initial state
  Future<void> _onResetFeed(ResetFeedEvent event, Emitter<FeedState> emit) async {
    if (event.softReset && state.feedType == FeedType.account) {
      // This is only used when FeedType is set to account
      emit(
        FeedState(
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
        ),
      );

      return;
    }

    emit(
      FeedState(
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
      ),
    );
  }

  /// Changes the current sort type of the feed, and refreshes the feed
  Future<void> _onFeedChangePostSortType(FeedChangePostSortTypeEvent event, Emitter<FeedState> emit) async {
    add(
      FeedFetchedEvent(
        feedType: state.feedType,
        feedListType: state.feedListType,
        postSortType: event.postSortType,
        communityId: state.communityId,
        communityName: state.communityName,
        userId: state.userId,
        username: state.username,
        reset: true,
        showHidden: state.showHidden,
      ),
    );
  }

  /// Fetches the posts, community information, and user information for the feed
  Future<void> _onFeedFetched(FeedFetchedEvent event, Emitter<FeedState> emit) async {
    try {
      // Assert any requirements
      if (event.reset) assert(event.feedType != null);
      if (event.reset && event.feedType == FeedType.community) {
        assert(!(event.communityId == null && event.communityName == null));
      }
      if (event.reset && event.feedType == FeedType.user) {
        assert(!(event.userId != null && event.username != null));
      }
      if (event.reset && event.feedType == FeedType.general) {
        assert(event.feedListType != null);
      }

      // Handle the initial fetch or reload of a feed
      if (event.reset) {
        if (state.status != FeedStatus.initial) {
          add(ResetFeedEvent(softReset: event.feedType == FeedType.account));
        }

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
              community = result.community;
              communityInstance = result.site;
              communityModerators = result.moderators;
            } catch (e) {
              // If we are given a community feed, but we can't load the community, that's a problem! Emit an error.
              return emit(
                state.copyWith(
                  status: FeedStatus.failureLoadingCommunity,
                  message: getExceptionErrorMessage(e, additionalInfo: event.communityName),
                  feedType: event.feedType,
                  errorReason: AppErrorReason.unexpected(
                    message: getExceptionErrorMessage(e, additionalInfo: event.communityName),
                    details: e.toString(),
                  ),
                ),
              );
            }
            break;
          case FeedType.user:
          case FeedType.account:
            // Fetch user information
            try {
              final response = await userRepository.getUser(userId: event.userId, username: event.username);
              user = response?.user;
              userModerates = response?.moderates ?? [];
            } catch (e) {
              // If we are given a user feed, but we can't load the user, that's a problem! Emit an error.
              return emit(
                state.copyWith(
                  status: FeedStatus.failureLoadingUser,
                  message: getExceptionErrorMessage(e, additionalInfo: event.username),
                  feedType: event.feedType,
                  errorReason: AppErrorReason.unexpected(
                    message: getExceptionErrorMessage(e, additionalInfo: event.username),
                    details: e.toString(),
                  ),
                ),
              );
            }
            break;
          case FeedType.general:
            break;
          default:
            break;
        }

        FeedResult feedItemResult = await fetchFeedItems(
          postRepository: postRepository,
          userRepository: userRepository,
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
          notifyExcessiveApiCalls: () => emit(state.copyWith(excessiveApiCalls: true)),
        );

        // Extract information from the response
        List<ThunderPost> posts = feedItemResult.posts;
        List<ThunderComment> comments = feedItemResult.comments;
        bool hasReachedPostsEnd = feedItemResult.hasReachedPostsEnd;
        bool hasReachedCommentsEnd = feedItemResult.hasReachedCommentsEnd;
        String? cursor = feedItemResult.cursor;

        return emit(
          state.copyWith(
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
            errorReason: null,
          ),
        );
      }

      return await _fetchNextFeedPage(event.feedTypeSubview, emit);
    } catch (e) {
      debugPrint('Error fetching feed: $e');
      final message = getExceptionErrorMessage(e);
      return emit(
        state.copyWith(
          status: FeedStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  /// Fetches the next page for the current feed state.
  Future<void> _onFeedPaginated(FeedPaginatedEvent event, Emitter<FeedState> emit) async {
    try {
      return await _fetchNextFeedPage(event.feedTypeSubview, emit);
    } catch (e) {
      debugPrint('Error fetching feed page: $e');
      final message = getExceptionErrorMessage(e);
      return emit(
        state.copyWith(
          status: FeedStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  Future<void> _fetchNextFeedPage(FeedTypeSubview feedTypeSubview, Emitter<FeedState> emit) async {
    // If the feed is already being fetched, just wait for that request to finish.
    // If the cursor is null, then we are at the end of the feed.
    if (state.status == FeedStatus.fetching || state.cursor == null) return;

    emit(state.copyWith(status: FeedStatus.fetching));

    final posts = List<ThunderPost>.from(state.posts);
    final comments = List<ThunderComment>.from(state.comments);

    final feedItemResult = await fetchFeedItems(
      postRepository: postRepository,
      userRepository: userRepository,
      cursor: state.cursor,
      feedListType: state.feedListType,
      postSortType: state.postSortType,
      communityId: state.communityId,
      communityName: state.communityName,
      userId: state.userId,
      username: state.username,
      feedTypeSubview: feedTypeSubview,
      showHidden: state.showHidden,
      showSaved: state.showSaved,
    );

    final newInsertedPostIds = Set<int>.from(state.insertedPostIds);
    final filteredPosts = <ThunderPost>[];

    for (final post in feedItemResult.posts) {
      if (newInsertedPostIds.add(post.id)) {
        filteredPosts.add(post);
      }
    }

    posts.addAll(filteredPosts);
    comments.addAll(feedItemResult.comments);

    return emit(
      state.copyWith(
        status: FeedStatus.success,
        insertedPostIds: newInsertedPostIds.toList(),
        posts: posts,
        comments: comments,
        hasReachedPostsEnd: feedItemResult.hasReachedPostsEnd,
        hasReachedCommentsEnd: feedItemResult.hasReachedCommentsEnd,
        cursor: feedItemResult.cursor,
        errorReason: null,
      ),
    );
  }

  /// This function is used to create a post. We can pass in a communityId directly to determine the community to post to.
  Future<void> _onCreatePost(CreatePostEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.fetching));

    try {
      final post = await postRepository.create(communityId: event.communityId, name: event.name, body: event.body, url: event.url, nsfw: event.nsfw);

      // Add the post to the state
      List<ThunderPost> updatedPosts = List.from(state.posts);
      updatedPosts.insert(0, post);

      emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts, errorReason: null));
    } catch (e) {
      final message = e.toString();
      return emit(
        state.copyWith(
          status: FeedStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  Future<void> _onPopulatePosts(PopulatePostsEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(posts: event.posts));
  }
}
