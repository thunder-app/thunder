// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

// Project imports
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc;
import 'package:thunder/shared/comment_reference.dart';

/// A widget that can display a single comment entry for use within a list (e.g., search page, instance explorer)
class CommentListEntry extends StatelessWidget {
  final CommentView commentView;
  final Function(int, int)? onVoteAction;
  final Function(int, bool)? onSaveAction;

  const CommentListEntry({super.key, required this.commentView, this.onVoteAction, this.onSaveAction});

  @override
  Widget build(BuildContext context) {
    final bool isOwnComment = commentView.creator.id == context.read<AuthBloc>().state.account?.userId;

    return BlocProvider<post_bloc.PostBloc>(
      create: (BuildContext context) => post_bloc.PostBloc(),
      child: CommentReference(
        comment: commentView,
        onVoteAction: (int commentId, int voteType) => onVoteAction?.call(commentId, voteType),
        onSaveAction: (int commentId, bool save) => onSaveAction?.call(commentId, save),
        // Only swipe actions are supported here, and delete is not one of those, so no implementation
        onDeleteAction: (int commentId, bool deleted) {},
        // Only swipe actions are supported here, and report is not one of those, so no implementation
        onReportAction: (int commentId) {},
        onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(
          context,
          commentView: isEdit ? commentView : null,
          parentCommentView: isEdit ? null : commentView,
          onCommentSuccess: (commentView, userChanged) {
            if (!userChanged) {
              context.read<post_bloc.PostBloc>().add(post_bloc.UpdateCommentEvent(commentView: commentView, isEdit: isEdit));
            }
          },
        ),
        isOwnComment: isOwnComment,
        disableActions: true,
      ),
    );
  }
}
