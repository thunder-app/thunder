import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/enums/feed_type_subview.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/error_messages.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final LemmyClient lemmyClient;

  FeedBloc({required this.lemmyClient}) : super(const FeedState()) {
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

    /// Handles scrolling to top of the feed
    on<ScrollToTopEvent>(
      _onFeedScrollToTop,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles dismissing read posts from the feed
    on<FeedDismissReadEvent>(
      _onFeedDismissRead,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles dismissing posts from blocked users/communities
    on<FeedDismissBlockedEvent>(
      _onFeedDismissBlocked,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles dismissing posts that have been hidden by the user
    on<FeedDismissHiddenPostEvent>(
      _onFeedDismissHiddenPost,
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

  /// Handles dismissing read posts from the feed
  Future<void> _onFeedDismissRead(FeedDismissReadEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.success, dismissReadId: state.dismissReadId + 1));
  }

  /// Handles dismissing read posts from the feed
  Future<void> _onFeedDismissBlocked(FeedDismissBlockedEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.success, dismissBlockedUserId: event.userId, dismissBlockedCommunityId: event.communityId));
  }

  /// Handles dismissing read posts from the feed
  Future<void> _onFeedDismissHiddenPost(FeedDismissHiddenPostEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.success, dismissHiddenPostId: event.postId));
  }

  /// Handles scrolling to top of the feed
  Future<void> _onFeedScrollToTop(ScrollToTopEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.success, scrollId: state.scrollId + 1));
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
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          updatedPost = await votePost(post, event.value);
          state.posts[existingPostIndex] = updatedPost;

          emit(state.copyWith(status: FeedStatus.success));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.save:
        // Optimistically save the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallySavePost(post, event.value);
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          updatedPost = await savePost(post, event.value);
          state.posts[existingPostIndex] = updatedPost;

          emit(state.copyWith(status: FeedStatus.success));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
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
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          bool success = await markPostAsRead(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
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
            for (int i = 0; i < existingPostIndexes.length; i++) {
              ThunderPost updatedPost = optimisticallyReadPost(posts[i], event.value);
              state.posts[existingPostIndexes[i]] = updatedPost;
            }

            // Emit the state to update UI immediately
            emit(state.copyWith(status: FeedStatus.success));
            emit(state.copyWith(status: FeedStatus.fetching));

            List<int> failed = await markPostsAsRead(postIds, event.value);
            if (failed.isEmpty) return emit(state.copyWith(status: FeedStatus.success));

            // Restore the original post contents if not successful
            for (int i = 0; i < failed.length; i++) {
              state.posts[existingPostIndexes[failed[i]]] = originalPosts[failed[i]];
            }
            return emit(state.copyWith(status: FeedStatus.failure));
          } catch (e) {
            // Restore the original post contents
            // They will all be restored, but this is an unlikely scenario
            for (int i = 0; i < existingPostIndexes.length; i++) {
              state.posts[existingPostIndexes[i]] = originalPosts[i];
            }
            return emit(state.copyWith(status: FeedStatus.failure));
          }
        }
      case PostAction.hide:
        // Optimistically hide the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyHidePost(post, event.value);
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          bool success = await markPostAsHidden(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.delete:
        // Optimistically delete the post
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyDeletePost(post, event.value);
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          bool success = await deletePost(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.report:
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          await reportPost(post.id, event.value);
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
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          bool success = await lockPost(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.pinCommunity:
        // Optimistically pin the post to the community
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyPinPostToCommunity(post, event.value);
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          bool success = await pinPostToCommunity(post.id, event.value);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.remove:
        // Optimistically remove the post from the community
        int existingPostIndex = state.posts.indexWhere((ThunderPost post) => post.id == event.postId);
        final post = state.posts[existingPostIndex];

        try {
          ThunderPost updatedPost = optimisticallyRemovePost(post, event.value['remove']);
          state.posts[existingPostIndex] = updatedPost;

          // Emit the state to update UI immediately
          emit(state.copyWith(status: FeedStatus.success));
          emit(state.copyWith(status: FeedStatus.fetching));

          bool success = await removePost(post.id, event.value['remove'], event.value['reason']);
          if (success) return emit(state.copyWith(status: FeedStatus.success));

          // Restore the original post contents if not successful
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        } catch (e) {
          // Restore the original post contents
          state.posts[existingPostIndex] = post;
          return emit(state.copyWith(status: FeedStatus.failure));
        }
      case PostAction.pinInstance:
      case PostAction.purge:
        break;
    }
  }

  /// Handles updating a given item within the feed
  Future<void> _onFeedItemUpdated(FeedItemUpdatedEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.fetching));

    // TODO: Add support for updating comments (for user profile)
    for (final (index, post) in state.posts.indexed) {
      if (post.id == event.post.id) {
        state.posts[index] = event.post;
      }
    }

    emit(state.copyWith(status: FeedStatus.success, posts: state.posts));
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
        currentPage: 1,
        userId: state.userId,
        username: state.username,
        fullPersonView: state.fullPersonView,
      ));

      return;
    }

    emit(const FeedState(
      status: FeedStatus.initial,
      posts: <ThunderPost>[],
      comments: <ThunderComment>[],
      hasReachedPostsEnd: false,
      hasReachedCommentsEnd: false,
      feedType: FeedType.general,
      feedListType: null,
      postSortType: null,
      community: null,
      communityInstance: null,
      communityModerators: [],
      fullPersonView: null,
      communityId: null,
      communityName: null,
      userId: null,
      username: null,
      currentPage: 1,
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
    // Assert any requirements
    if (event.reset) assert(event.feedType != null);
    if (event.reset && event.feedType == FeedType.community) assert(!(event.communityId == null && event.communityName == null));
    if (event.reset && event.feedType == FeedType.user) assert(!(event.userId != null && event.username != null));
    if (event.reset && event.feedType == FeedType.general) assert(event.feedListType != null);

    // Handle the initial fetch or reload of a feed
    if (event.reset) {
      if (state.status != FeedStatus.initial) add(ResetFeedEvent(softReset: event.feedType == FeedType.account));

      ThunderCommunity? community;
      ThunderInstance? communityInstance;
      List<ThunderUser> communityModerators = [];

      GetPersonDetailsResponse? fullPersonView;

      switch (event.feedType) {
        case FeedType.community:
          // Fetch community information
          try {
            final result = await fetchCommunityInformation(id: event.communityId, name: event.communityName);
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
            final account = await fetchActiveProfile();
            LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

            fullPersonView = await lemmy.run(GetPersonDetails(
              auth: account.jwt,
              personId: event.userId,
              username: event.username,
            ));
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
        page: 1,
        feedListType: event.feedListType,
        postSortType: event.postSortType,
        communityId: event.communityId,
        communityName: event.communityName,
        userId: event.userId ?? fullPersonView?.personView.person.id,
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
      int currentPage = feedItemResult['currentPage'];

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
        fullPersonView: fullPersonView,
        communityId: event.communityId,
        communityName: event.communityName,
        userId: event.userId ?? fullPersonView?.personView.person.id,
        username: event.username,
        currentPage: currentPage,
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
      page: state.currentPage,
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
    int currentPage = feedItemResult['currentPage'];

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
      currentPage: currentPage,
    ));
  }

  /// This function is used to create a post. We can pass in a communityId directly to determine the community to post to.
  Future<void> _onCreatePost(CreatePostEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.fetching));

    try {
      PostView postView = await createPost(
        communityId: event.communityId,
        name: event.name,
        body: event.body,
        url: event.url,
        nsfw: event.nsfw,
      );

      // Parse the newly created post
      List<ThunderPost> formattedPost = await parsePosts([postView]);

      // Add the post to the state
      List<ThunderPost> updatedPosts = List.from(state.posts);
      updatedPosts.insert(0, formattedPost[0]);

      emit(state.copyWith(status: FeedStatus.success, posts: updatedPosts));
    } catch (e) {
      return emit(state.copyWith(status: FeedStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onPopulatePosts(PopulatePostsEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(posts: event.posts));
  }
}
