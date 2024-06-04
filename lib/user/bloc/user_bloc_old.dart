import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/post/utils/post.dart';

part 'user_event_old.dart';
part 'user_state_old.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required lemmyClient}) : super(const UserState()) {
    on<ResetUserEvent>(
      _resetUserEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserEvent>(
      _getUserEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VotePostEvent>(
      _votePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SavePostEvent>(
      _savePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VoteCommentEvent>(
      _voteCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SaveCommentEvent>(
      _saveCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserSavedEvent>(
      _getUserSavedEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<MarkUserPostAsReadEvent>(
      _markPostAsReadEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<BlockUserEvent>(
      _blockUserEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _resetUserEvent(ResetUserEvent event, emit) async {
    return emit(state.copyWith(status: UserStatus.initial));
  }

  Future<void> _getUserEvent(GetUserEvent event, emit) async {
    int attemptCount = 0;
    int limit = 30;

    try {
      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: UserStatus.loading));

            GetPersonDetailsResponse? fullPersonView;

            if (event.userId != null || event.username != null) {
              fullPersonView = await lemmy
                  .run(GetPersonDetails(
                personId: event.isAccountUser ? null : event.userId,
                username: event.username ?? (event.isAccountUser ? account?.username : null),
                auth: account?.jwt,
                sort: SortType.new_,
                limit: limit,
                page: 1,
              ))
                  .timeout(timeout, onTimeout: () {
                throw Exception('Error: Timeout when attempting to fetch user');
              });
            }

            List<PostViewMedia> posts = await parsePostViews(fullPersonView?.posts ?? []);

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView?.comments ?? [], flatten: true);

            return emit(
              state.copyWith(
                userId: event.userId,
                personView: fullPersonView?.personView,
                status: UserStatus.success,
                comments: commentTree,
                posts: posts,
                moderates: fullPersonView?.moderates,
                page: 2,
                hasReachedPostEnd: posts.length == fullPersonView?.personView.counts.postCount,
                hasReachedCommentEnd: posts.isEmpty && (fullPersonView?.comments.isEmpty ?? true),
                fullPersonView: fullPersonView,
              ),
            );
          }

          if (state.hasReachedCommentEnd && state.hasReachedPostEnd) {
            return emit(state.copyWith(status: UserStatus.success));
          }

          emit(state.copyWith(status: UserStatus.refreshing));

          GetPersonDetailsResponse? fullPersonView = await lemmy
              .run(GetPersonDetails(
            personId: state.userId,
            auth: account?.jwt,
            sort: SortType.new_,
            limit: limit,
            page: state.page,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch user');
          });

          List<PostViewMedia> posts = await parsePostViews(fullPersonView.posts);

          // Append the new posts
          List<PostViewMedia> postViewMedias = List.from(state.posts);
          postViewMedias.addAll(posts);

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView.comments, flatten: true);

          // Append the new comments
          List<CommentViewTree> commentViewTree = List.from(state.comments);
          commentViewTree.addAll(commentTree);

          return emit(state.copyWith(
            userId: state.userId,
            status: UserStatus.success,
            comments: commentViewTree,
            posts: postViewMedias,
            moderates: fullPersonView.moderates,
            page: state.page + 1,
            // It's possible that sometimes the instance you belong to might not have all the posts for a
            // user from a different instance. Lemmy's web view will simply just list what it has with no
            // indication that it's not complete. This is despite having the correct post count stat.
            // For this reason we are marking hasReachedPostEnd as true when what was fetched last is under the max limit.
            hasReachedPostEnd: postViewMedias.length == fullPersonView.personView.counts.postCount || posts.length < limit,
            hasReachedCommentEnd: posts.isEmpty && fullPersonView.comments.isEmpty,
            fullPersonView: fullPersonView,
          ));
        } catch (e) {
          attemptCount++;
        }
      }
    } catch (e) {
      emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _getUserSavedEvent(GetUserSavedEvent event, emit) async {
    int attemptCount = 0;
    int limit = 30;

    try {
      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: UserStatus.loading));

            GetPersonDetailsResponse? fullPersonView;

            if (event.userId != null) {
              fullPersonView = await lemmy
                  .run(GetPersonDetails(
                personId: event.isAccountUser ? null : event.userId,
                username: event.isAccountUser ? account?.username : null,
                auth: account?.jwt,
                sort: SortType.new_,
                limit: limit,
                page: 1,
                savedOnly: true,
              ))
                  .timeout(timeout, onTimeout: () {
                throw Exception('Error: Timeout when attempting to fetch user');
              });
            }

            List<PostViewMedia> posts = await parsePostViews(fullPersonView?.posts ?? []);

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView?.comments ?? [], flatten: true);

            return emit(
              state.copyWith(
                status: UserStatus.success,
                savedComments: commentTree,
                savedPosts: posts,
                savedContentPage: 2,
                hasReachedSavedPostEnd: posts.isEmpty || posts.length < limit,
                hasReachedSavedCommentEnd: commentTree.isEmpty || commentTree.length < limit,
              ),
            );
          }

          if (state.hasReachedSavedCommentEnd && state.hasReachedSavedPostEnd) {
            return emit(state.copyWith(status: UserStatus.success));
          }

          emit(state.copyWith(status: UserStatus.refreshing));

          GetPersonDetailsResponse? fullPersonView = await lemmy
              .run(GetPersonDetails(
            personId: state.userId,
            auth: account?.jwt,
            sort: SortType.new_,
            limit: limit,
            page: state.savedContentPage,
            savedOnly: true,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch user saved content');
          });

          List<PostViewMedia> posts = await parsePostViews(fullPersonView.posts);

          // Append the new posts
          List<PostViewMedia> postViewMedias = List.from(state.savedPosts);
          postViewMedias.addAll(posts);

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView.comments, flatten: true);

          // Append the new comments
          List<CommentViewTree> commentViewTree = List.from(state.savedComments);
          commentViewTree.addAll(commentTree);

          return emit(state.copyWith(
            status: UserStatus.success,
            savedComments: commentViewTree,
            savedPosts: postViewMedias,
            savedContentPage: state.savedContentPage + 1,
            hasReachedSavedPostEnd: posts.isEmpty || posts.length < limit,
            hasReachedSavedCommentEnd: commentTree.isEmpty || commentTree.length < limit,
          ));
        } catch (e) {
          attemptCount++;
        }
      }
    } catch (e) {
      emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      // Optimistically update the post
      PostViewMedia? postViewMedia = _getPost(event.postId);

      if (postViewMedia != null) {
        PostView originalPostView = postViewMedia.postView;
        PostView updatedPostView = optimisticallyVotePost(postViewMedia, event.score);
        _updatePosts(updatedPostView, event.postId);

        // Immediately set the status, and continue
        emit(state.copyWith(status: UserStatus.success));
        emit(state.copyWith(status: UserStatus.refreshing));

        PostView postView = await votePost(event.postId, event.score).timeout(timeout, onTimeout: () {
          _updatePosts(originalPostView, event.postId);
          throw Exception('Error: Timeout when attempting to vote post');
        });

        // Find the specific post to update
        _updatePosts(postView, event.postId);
      }

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e) {
      return emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _markPostAsReadEvent(MarkUserPostAsReadEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing, userId: state.userId));

      PostViewMedia? postViewMedia = _getPost(event.postId);
      PostView? postView = postViewMedia?.postView;

      bool success = await markPostAsRead(event.postId, event.read);

      if (postView != null && success) {
        postView = postView.copyWith(read: event.read);
        _updatePosts(postView, event.postId);
      }

      return emit(state.copyWith(status: UserStatus.success, userId: state.userId));
    } catch (e) {
      return emit(state.copyWith(
        status: UserStatus.failure,
        errorMessage: e.toString(),
        userId: state.userId,
      ));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      PostView postView = await savePost(event.postId, event.save);

      _updatePosts(postView, event.postId);

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e) {
      return emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _voteCommentEvent(VoteCommentEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      List<CommentViewTree> currentTrees = _getCommentTrees(event.commentId);
      List<CommentView?> originalCommentViews = currentTrees.map((currentTree) => currentTree.commentView).toList();
      if (currentTrees.isNotEmpty) {
        // Optimistically update the comment
        for (CommentViewTree currentTree in currentTrees) {
          currentTree.commentView = optimisticallyVoteComment(currentTree.commentView!, event.score);
        }

        // Immediately set the status, and continue
        emit(state.copyWith(status: UserStatus.success));
        emit(state.copyWith(status: UserStatus.refreshing));

        CommentView commentView = await voteComment(event.commentId, event.score).timeout(timeout, onTimeout: () {
          // Reset this on exception
          for (int i = 0; i < currentTrees.length; ++i) {
            currentTrees[i].commentView = originalCommentViews[i];
          }
          throw Exception('Error: Timeout when attempting to vote on comment');
        });

        for (CommentViewTree currentTree in currentTrees) {
          currentTree.commentView = commentView;
        }
      }

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e) {
      return emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _saveCommentEvent(SaveCommentEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      CommentView commentView = await saveComment(event.commentId, event.save).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting save a comment');
      });

      List<CommentViewTree> currentTrees = _getCommentTrees(event.commentId);
      for (CommentViewTree currentTree in currentTrees) {
        // Update the comment's information
        currentTree.commentView = commentView;
      }

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e) {
      emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  PostViewMedia? _getPost(int postId) {
    int postsIndex = state.posts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == postId);
    if (postsIndex >= 0) {
      return state.posts[postsIndex];
    }

    int savedPostsIndex = state.savedPosts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == postId);
    if (savedPostsIndex >= 0) {
      return state.savedPosts[savedPostsIndex];
    }

    return null;
  }

  void _updatePosts(PostView postView, int postId) {
    int postsIndex = state.posts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == postId);
    if (postsIndex >= 0) {
      state.posts[postsIndex].postView = postView;
    }

    int savedPostsIndex = state.savedPosts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == postId);
    if (savedPostsIndex >= 0) {
      state.savedPosts[savedPostsIndex].postView = postView;
    }
  }

  /// Returns [CommentViewTree]s for the given [commentId], searching both [state.comments] and [state.savedComments].
  List<CommentViewTree> _getCommentTrees(int commentId) {
    List<CommentViewTree> results = [];

    List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, commentId);
    if (commentIndexes.isNotEmpty) {
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      results.add(currentTree);
    }

    commentIndexes = findCommentIndexesFromCommentViewTree(state.savedComments, commentId);
    if (commentIndexes.isNotEmpty) {
      CommentViewTree currentTree = state.savedComments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      results.add(currentTree);
    }

    return results;
  }

  Future<void> _blockUserEvent(BlockUserEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing, userId: state.userId));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(
          state.copyWith(
            status: UserStatus.failedToBlock,
            errorMessage: 'You are not logged in. Cannot block user.',
            userId: state.userId,
          ),
        );
      }

      BlockPersonResponse blockedPerson = await lemmy.run(BlockPerson(
        auth: account!.jwt!,
        personId: event.personId,
        block: event.blocked,
      ));

      return emit(state.copyWith(
        status: UserStatus.success,
        personView: state.personView,
        blockedPerson: blockedPerson,
      ));
    } catch (e) {
      return emit(
        state.copyWith(
          status: UserStatus.failedToBlock,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString(),
          personView: state.personView,
        ),
      );
    }
  }
}
