import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc;
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

Widget buildCommentEntry(
  BuildContext context,
  CommentView commentView, {
  Function(int, int)? onVoteAction,
  Function(int, bool)? onSaveAction,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final bool isOwnComment = commentView.creator.id == context.read<AuthBloc>().state.account?.userId;

  return BlocProvider<post_bloc.PostBloc>(
    create: (BuildContext context) => post_bloc.PostBloc(),
    child: CommentReference(
      comment: commentView,
      now: DateTime.now().toUtc(),
      onVoteAction: (int commentId, int voteType) => onVoteAction?.call(commentId, voteType),
      onSaveAction: (int commentId, bool save) => onSaveAction?.call(commentId, save),
      // Only swipe actions are supported here, and delete is not one of those, so no implementation
      onDeleteAction: (int commentId, bool deleted) {},
      // Only swipe actions are supported here, and report is not one of those, so no implementation
      onReportAction: (int commentId) {},
      onReplyEditAction: (CommentView commentView, bool isEdit) async {
        ThunderBloc thunderBloc = context.read<ThunderBloc>();
        AccountBloc accountBloc = context.read<AccountBloc>();

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

        if (context.mounted) {
          Navigator.of(context)
              .push(
            SwipeablePageRoute(
              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
              canOnlySwipeFromEdge: true,
              backGestureDetectionWidth: 45,
              builder: (context) {
                return MultiBlocProvider(
                    providers: [
                      BlocProvider<ThunderBloc>.value(value: thunderBloc),
                      BlocProvider<AccountBloc>.value(value: accountBloc),
                    ],
                    child: CreateCommentPage(
                      commentView: commentView,
                      isEdit: isEdit,
                      parentCommentAuthor: commentView.creator.name,
                      previousDraftComment: previousDraftComment,
                      onUpdateDraft: (c) => newDraftComment = c,
                    ));
              },
            ),
          )
              .whenComplete(
            () async {
              timer.cancel();

              if (newDraftComment?.saveAsDraft == true && newDraftComment?.isNotEmpty == true && (!isEdit || commentView.comment.content != newDraftComment?.text)) {
                await Future.delayed(const Duration(milliseconds: 300));
                if (context.mounted) showSnackbar(l10n.commentSavedAsDraft);
                prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
              } else {
                prefs.remove(draftId);
              }
            },
          );
        }
      },
      isOwnComment: isOwnComment,
    ),
  );
}
