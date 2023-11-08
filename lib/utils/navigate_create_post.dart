import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
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
}) async {
  try {
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    AccountBloc accountBloc = context.read<AccountBloc>();
    final bool reduceAnimations = thunderBloc.state.reduceAnimations;
    Navigator.of(context).push(SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => FeedBloc(lemmyClient: LemmyClient.instance)),
            BlocProvider<ThunderBloc>.value(value: thunderBloc),
            BlocProvider<AccountBloc>.value(value: accountBloc),
          ],
          child: CreatePostPage(
            title: title,
            text: text,
            image: image,
            url: url,
            prePopulated: prePopulated,
            onUpdateDraft: (p) => {},
            communityId: null,
            onPostSuccess: (PostViewMedia postViewMedia) {
              try {
                context.read<FeedBloc>().add(FeedItemUpdatedEvent(postViewMedia: postViewMedia));
              } catch (e) {}
            },
          ),
        );
      },
    ));
  } catch (e) {
    if (context.mounted) showSnackbar(context, AppLocalizations.of(context)!.unexpectedError);
  }
}
