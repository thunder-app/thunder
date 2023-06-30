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
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
      }
    });
  }
}
