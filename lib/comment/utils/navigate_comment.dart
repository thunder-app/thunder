// Flutter imports
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

// Project imports
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/comment/view/create_comment_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/legacy_post_page.dart';
import 'package:thunder/shared/pages/loading_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

Future<void> navigateToComment(BuildContext context, CommentView commentView) async {
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  final ThunderState state = context.read<ThunderBloc>().state;
  final bool reduceAnimations = state.reduceAnimations;

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionWidth: 45,
    canSwipe: Platform.isIOS || state.enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true) || !state.enableFullScreenSwipeNavigationGesture,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: accountBloc),
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: thunderBloc),
        BlocProvider(create: (context) => PostBloc()),
      ],
      child: PostPage(
        selectedCommentId: commentView.comment.id,
        selectedCommentPath: commentView.comment.path,
        postId: commentView.post.id,
        onPostUpdated: (PostViewMedia postViewMedia) => {},
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<void> navigateToCreateCommentPage(
  BuildContext context, {
  PostViewMedia? postViewMedia,
  CommentView? commentView,
  CommentView? parentCommentView,
  Function(CommentView commentView, bool userChanged)? onCommentSuccess,
}) async {
  assert(!(postViewMedia == null && parentCommentView == null && commentView == null));
  assert(!(postViewMedia != null && (parentCommentView != null || commentView != null)));

  final l10n = AppLocalizations.of(context)!;

  try {
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    AccountBloc accountBloc = context.read<AccountBloc>();

    final bool reduceAnimations = thunderBloc.state.reduceAnimations;

    Navigator.of(context).push(SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (navigatorContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThunderBloc>.value(value: thunderBloc),
            BlocProvider<AccountBloc>.value(value: accountBloc),
          ],
          child: CreateCommentPage(
            postViewMedia: postViewMedia,
            commentView: commentView,
            parentCommentView: parentCommentView,
            onCommentSuccess: onCommentSuccess,
          ),
        );
      },
    ));
  } catch (e) {
    if (context.mounted) showSnackbar(l10n.unexpectedError);
  }
}
