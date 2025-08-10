// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/features/post/presentation/bloc/post_bloc.dart' as post_bloc;
import 'package:thunder/src/shared/comment_reference.dart';

/// A widget that can display a single comment entry for use within a list (e.g., search page, instance explorer)
class CommentListEntry extends StatelessWidget {
  final ThunderComment comment;
  final Function(int, int)? onVoteAction;
  final Function(int, bool)? onSaveAction;

  const CommentListEntry({super.key, required this.comment, this.onVoteAction, this.onSaveAction});

  @override
  Widget build(BuildContext context) {
    assert(comment.creator != null, 'Comment must have a creator');
    final bool isOwnComment = comment.creator!.id == context.read<ProfileBloc>().state.account.userId;
    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return BlocProvider<post_bloc.PostBloc>(
      create: (BuildContext context) => post_bloc.PostBloc(account: account),
      child: CommentReference(
        comment: comment,
        onVoteAction: (int commentId, int voteType) => onVoteAction?.call(commentId, voteType),
        onSaveAction: (int commentId, bool save) => onSaveAction?.call(commentId, save),
        // Only swipe actions are supported here, and delete is not one of those, so no implementation
        onDeleteAction: (int commentId, bool deleted) {},
        // Only swipe actions are supported here, and report is not one of those, so no implementation
        onReportAction: (int commentId) {},
        onReplyEditAction: (ThunderComment comment, bool isEdit) async => navigateToCreateCommentPage(
          context,
          comment: isEdit ? comment : null,
          parentComment: isEdit ? null : comment,
          onCommentSuccess: (comment, userChanged) {
            if (!userChanged) {
              context.read<post_bloc.PostBloc>().add(post_bloc.CommentItemUpdatedEvent(comment: comment));
            }
          },
        ),
        isOwnComment: isOwnComment,
        disableActions: true,
      ),
    );
  }
}
