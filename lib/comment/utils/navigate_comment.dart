import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/comment/view/create_comment_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

Future<void> navigateToComment(BuildContext context, CommentView commentView) async {
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  final ThunderState state = context.read<ThunderBloc>().state;
  final bool reduceAnimations = state.reduceAnimations;

  // To to specific post for now, in the future, will be best to scroll to the position of the comment
  await Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      backGestureDetectionWidth: 45,
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
    ),
  );
}

Future<void> navigateToCreateCommentPage(
  BuildContext context, {
  PostViewMedia? postViewMedia,
  CommentView? commentView,
  CommentView? parentCommentView,
  Function(CommentView commentView)? onCommentSuccess,
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
            onCommentSuccess: (CommentView commentView) {
              onCommentSuccess?.call(commentView);
            },
          ),
        );
      },
    ));
  } catch (e) {
    if (context.mounted) showSnackbar(l10n.unexpectedError);
  }
}
