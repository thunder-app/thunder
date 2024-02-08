import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/swipe_action.dart';

import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void triggerCommentAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, int) onVoteAction,
  required Function(int, bool) onSaveAction,
  required int voteType,
  bool? saved,
  required CommentView commentView,
  int? selectedCommentId,
  String? selectedCommentPath,
}) async {
  switch (swipeAction) {
    case SwipeAction.upvote:
      onVoteAction(commentView.comment.id, voteType == 1 ? 0 : 1);
      return;
    case SwipeAction.downvote:
      bool downvotesEnabled = context.read<AuthBloc>().state.downvotesEnabled;

      if (downvotesEnabled == false) {
        showSnackbar(AppLocalizations.of(context)!.downvotesDisabled);
        return;
      }
      onVoteAction(commentView.comment.id, voteType == -1 ? 0 : -1);
      return;
    case SwipeAction.reply:
    case SwipeAction.edit:
      PostBloc postBloc = context.read<PostBloc>();
      ThunderBloc thunderBloc = context.read<ThunderBloc>();
      AccountBloc accountBloc = context.read<AccountBloc>();

      InboxBloc? inboxBloc;

      try {
        inboxBloc = context.read<InboxBloc>();
      } catch (e) {}

      final ThunderState state = context.read<ThunderBloc>().state;
      final bool reduceAnimations = state.reduceAnimations;

      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      DraftComment? newDraftComment;
      DraftComment? previousDraftComment;
      String draftId = '${LocalSettings.draftsCache.name}-${commentView.comment.id}';
      String? draftCommentJson = prefs.getString(draftId);
      if (draftCommentJson != null) {
        previousDraftComment = DraftComment.fromJson(jsonDecode(draftCommentJson));
      }
      Timer timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
        if (newDraftComment?.isNotEmpty == true) {
          prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
        }
      });

      Navigator.of(context)
          .push(
        SwipeablePageRoute(
          transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
          canOnlySwipeFromEdge: true,
          backGestureDetectionWidth: 45,
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<PostBloc>.value(value: postBloc),
                BlocProvider<ThunderBloc>.value(value: thunderBloc),
                BlocProvider<AccountBloc>.value(value: accountBloc),
                if (inboxBloc != null) BlocProvider<InboxBloc>.value(value: inboxBloc),
              ],
              child: CreateCommentPage(
                commentView: commentView,
                comment: commentView.comment,
                isEdit: swipeAction == SwipeAction.edit,
                selectedCommentId: selectedCommentId,
                selectedCommentPath: selectedCommentPath,
                previousDraftComment: previousDraftComment,
                onUpdateDraft: (c) => newDraftComment = c,
              ),
            );
          },
        ),
      )
          .whenComplete(() async {
        timer.cancel();

        if (newDraftComment?.saveAsDraft == true && newDraftComment?.isNotEmpty == true && (swipeAction != SwipeAction.edit || commentView.comment.content != newDraftComment?.text)) {
          await Future.delayed(const Duration(milliseconds: 300));
          showSnackbar(AppLocalizations.of(context)!.commentSavedAsDraft);
          prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
        } else {
          prefs.remove(draftId);
        }
      });

      break;
    case SwipeAction.save:
      onSaveAction(commentView.comment.id, !(saved ?? false));
      break;
    default:
      break;
  }
}

DismissDirection determineCommentSwipeDirection(bool isUserLoggedIn, ThunderState state) {
  if (!isUserLoggedIn) return DismissDirection.none;

  if (state.enableCommentGestures == false) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (state.leftPrimaryCommentGesture == SwipeAction.none &&
      state.leftSecondaryCommentGesture == SwipeAction.none &&
      state.rightPrimaryCommentGesture == SwipeAction.none &&
      state.rightSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.none;
  }

  // If there is at least 1 action on either side, then allow swiping from both sides
  if ((state.leftPrimaryCommentGesture != SwipeAction.none || state.leftSecondaryCommentGesture != SwipeAction.none) &&
      (state.rightPrimaryCommentGesture != SwipeAction.none || state.rightSecondaryCommentGesture != SwipeAction.none)) {
    return DismissDirection.horizontal;
  }

  // If there is no action on left side, disable left side swiping
  if (state.leftPrimaryCommentGesture == SwipeAction.none && state.leftSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.endToStart;
  }

  // If there is no action on the right side, disable right side swiping
  if (state.rightPrimaryCommentGesture == SwipeAction.none && state.rightSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.startToEnd;
  }

  return DismissDirection.none;
}
