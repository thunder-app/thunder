import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/comment/view/create_comment_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc;
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// A widget that can display a single comment entry for use within a list (e.g., search page, instance explorer)
class CommentListEntry extends StatelessWidget {
  final CommentView commentView;
  final Function(int, int)? onVoteAction;
  final Function(int, bool)? onSaveAction;

  const CommentListEntry({super.key, required this.commentView, this.onVoteAction, this.onSaveAction});

  @override
  Widget build(BuildContext context) {
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
        onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(context, commentView: commentView),
        isOwnComment: isOwnComment,
      ),
    );
  }
}
