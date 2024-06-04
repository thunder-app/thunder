import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/cubit/create_post_cubit.dart';
import 'package:thunder/post/utils/navigate_post.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/thunder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> navigateToCreatePostPage(
  BuildContext context, {
  String? title,
  String? text,
  File? image,
  String? url,
  bool? prePopulated,
  int? communityId,
  CommunityView? communityView,
}) async {
  try {
    final l10n = AppLocalizations.of(context)!;

    FeedBloc? feedBloc;
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    AccountBloc accountBloc = context.read<AccountBloc>();
    CreatePostCubit createPostCubit = CreatePostCubit();

    try {
      feedBloc = context.read<FeedBloc>();
    } catch (e) {
      // Don't need feed block if we're not opening post in the context of a feed.
    }

    final bool reduceAnimations = thunderBloc.state.reduceAnimations;

    await Navigator.of(context).push(SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (navigatorContext) {
        return MultiBlocProvider(
          providers: [
            feedBloc != null ? BlocProvider<FeedBloc>.value(value: feedBloc) : BlocProvider(create: (context) => FeedBloc(lemmyClient: LemmyClient.instance)),
            BlocProvider<ThunderBloc>.value(value: thunderBloc),
            BlocProvider<AccountBloc>.value(value: accountBloc),
            BlocProvider<CreatePostCubit>.value(value: createPostCubit),
          ],
          child: CreatePostPage(
            title: title,
            text: text,
            image: image,
            url: url,
            prePopulated: prePopulated,
            communityId: communityId,
            communityView: communityView,
            onPostSuccess: (PostViewMedia postViewMedia, bool userChanged) {
              if (!userChanged) {
                try {
                  showSnackbar(
                    l10n.postCreatedSuccessfully,
                    trailingIcon: Icons.remove_red_eye_rounded,
                    trailingAction: () {
                      navigateToPost(context, postViewMedia: postViewMedia);
                    },
                  );

                  context.read<FeedBloc>().add(FeedItemUpdatedEvent(postViewMedia: postViewMedia));
                } catch (e) {}
              }
            },
          ),
        );
      },
    ));
  } catch (e) {
    if (context.mounted) showSnackbar(AppLocalizations.of(context)!.unexpectedError);
  }
}
