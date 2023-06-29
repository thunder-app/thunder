import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/comment.dart';
import 'package:thunder/utils/post.dart';

part 'account_event.dart';
part 'account_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 3);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<GetAccountContent>(
      _getAccountContent,
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
    on<GetAccountInformation>((event, emit) async {
      int attemptCount = 0;

      try {
        Account? account = await fetchActiveProfileAccount();

        while (attemptCount < 2) {
          try {
            LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

            if (account == null || account.jwt == null) {
              return emit(
                state.copyWith(
                  status: AccountStatus.success,
                  subsciptions: [],
                ),
              );
            }

            List<CommunityView> communityViews = await lemmy.run(
              ListCommunities(
                auth: account.jwt,
                type: PostListingType.subscribed,
                limit: 50, // Temporarily increasing this to address issue of missing subscriptions
              ),
            );

            // Sort subscriptions by their name
            communityViews.sort((CommunityView a, CommunityView b) => a.community.name.compareTo(b.community.name));

            FullPersonView fullPersonView = await lemmy.run(
              GetPersonDetails(
                auth: account.jwt,
                username: account.username,
                limit: 50,
              ),
            );

            List<PostViewMedia> posts = await parsePostViews(fullPersonView.posts);

            List<CommentViewTree> comments = buildCommentViewTree(fullPersonView.comments);

            return emit(
              state.copyWith(
                status: AccountStatus.success,
                subsciptions: communityViews,
                comments: comments,
                moderates: fullPersonView.moderates,
                personView: fullPersonView.personView,
                posts: posts,
              ),
            );
          } catch (e, s) {
            await Sentry.captureException(e, stackTrace: s);

            attemptCount += 1;
          }
        }
      } on DioException catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.message));
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
      }
    });
  }

  Future<void> _getAccountContent(GetAccountContent event, emit) async {
    int attemptCount = 0;
    int limit = 30;

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: AccountStatus.loading));

            FullPersonView? fullPersonView;

            if (account?.username != null) {
              fullPersonView = await lemmy
                  .run(GetPersonDetails(
                username: account!.username,
                auth: account.jwt,
                sort: SortType.hot,
                limit: limit,
                page: 1,
              ))
                  .timeout(timeout, onTimeout: () {
                throw Exception('Error: Timeout when attempting to fetch account details');
              });
            }

            List<PostViewMedia> posts = await parsePostViews(fullPersonView?.posts ?? []);

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView?.comments ?? []);

            return emit(
              state.copyWith(
                personView: fullPersonView?.personView,
                status: AccountStatus.success,
                comments: commentTree,
                posts: posts,
                page: 2,
                hasReachedPostEnd: posts.isEmpty || posts.length < limit,
                hasReachedCommentEnd: commentTree.isEmpty || commentTree.length < limit,
              ),
            );
          }

          if (state.hasReachedCommentEnd && state.hasReachedPostEnd) {
            return emit(state.copyWith(status: AccountStatus.success));
          }

          emit(state.copyWith(status: AccountStatus.refreshing));

          FullPersonView? fullPersonView = await lemmy
              .run(GetPersonDetails(
            username: account!.username,
            auth: account.jwt,
            sort: SortType.hot,
            limit: limit,
            page: state.page,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch account details');
          });

          List<PostViewMedia> posts = await parsePostViews(fullPersonView.posts ?? []);

          // Append the new posts
          List<PostViewMedia> postViewMedias = List.from(state.posts);
          postViewMedias.addAll(posts);

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView.comments ?? []);

          // Append the new comments
          List<CommentViewTree> commentViewTree = List.from(state.comments);
          commentViewTree.addAll(commentTree);

          return emit(state.copyWith(
            status: AccountStatus.success,
            comments: commentViewTree,
            posts: postViewMedias,
            page: state.page + 1,
            hasReachedPostEnd: posts.isEmpty || posts.length < limit,
            hasReachedCommentEnd: commentTree.isEmpty || commentTree.length < limit,
          ));
        } catch (e, s) {
          exception = e;
          attemptCount++;
          await Sentry.captureException(e, stackTrace: s);
        }
      }
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.message));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<AccountState> emit) async {
    try {
      emit(state.copyWith(status: AccountStatus.refreshing));

      PostView postView = await votePost(event.postId, event.score);

      // Find the specific post to update
      int existingPostViewIndex = state.posts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      state.posts[existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: AccountStatus.success));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<AccountState> emit) async {
    try {
      emit(state.copyWith(status: AccountStatus.refreshing));

      PostView postView = await savePost(event.postId, event.save);

      // Find the specific post to update
      int existingPostViewIndex = state.posts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      state.posts[existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: AccountStatus.success));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
    }
  }
}
