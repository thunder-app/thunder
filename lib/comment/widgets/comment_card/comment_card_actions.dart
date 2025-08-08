import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/post/post.dart';
import 'package:thunder/thunder/thunder.dart';
import 'package:thunder/utils/global_context.dart';

class CommentCardActions extends StatelessWidget {
  /// The comment to perform actions on
  final ThunderComment comment;

  /// Whether the comment has been edited
  final bool isEdit;

  /// Whether the source is being viewed
  final bool viewSource;

  final Function(int, int) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;
  final Function(ThunderComment, bool) onReplyEditAction;
  final void Function() onViewSourceToggled;

  const CommentCardActions({
    super.key,
    required this.comment,
    this.isEdit = false,
    required this.viewSource,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.onReplyEditAction,
    required this.onViewSourceToggled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final iconSize = 22.0;
    final voteType = comment.myVote ?? 0;

    final downvotesEnabled = context.select<ProfileBloc, bool>((bloc) => bloc.state.downvotesEnabled);
    final upvoteColor = context.select<ThunderBloc, Color>((bloc) => bloc.state.upvoteColor.color);
    final downvoteColor = context.select<ThunderBloc, Color>((bloc) => bloc.state.downvoteColor.color);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 28,
          width: 44,
          child: IconButton(
            icon: Icon(Icons.more_horiz_rounded, semanticLabel: l10n.actions, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              showCommentActionBottomModalSheet(
                context,
                comment,
                isShowingSource: viewSource,
                onAction: ({commentAction, communityAction, userAction, comment}) {
                  if (comment != null) context.read<PostBloc>().add(CommentItemUpdatedEvent(comment: comment));

                  switch (commentAction) {
                    case CommentAction.reply:
                      onReplyEditAction(comment!, false);
                      break;
                    case CommentAction.edit:
                      onReplyEditAction(comment!, true);
                      break;
                    case CommentAction.viewSource:
                      onViewSourceToggled();
                      break;
                    default:
                      break;
                  }

                  switch (communityAction) {
                    default:
                      break;
                  }

                  switch (userAction) {
                    default:
                      break;
                  }
                },
              );
              HapticFeedback.mediumImpact();
            },
          ),
        ),
        SizedBox(
          height: 28,
          width: 44,
          child: IconButton(
            icon: Icon(isEdit ? Icons.edit_rounded : Icons.reply_rounded, semanticLabel: isEdit ? l10n.edit : l10n.reply(1), size: iconSize),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onReplyEditAction(comment, isEdit);
            },
          ),
        ),
        SizedBox(
          height: 28,
          width: 44,
          child: IconButton(
              icon: Icon(
                Icons.arrow_upward,
                semanticLabel: voteType == 1 ? l10n.upvoted : l10n.upvote,
                size: iconSize,
              ),
              color: voteType == 1 ? upvoteColor : null,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                HapticFeedback.mediumImpact();
                onVoteAction(comment.id, voteType == 1 ? 0 : 1);
              }),
        ),
        if (downvotesEnabled)
          SizedBox(
            height: 28,
            width: 44,
            child: IconButton(
              icon: Icon(Icons.arrow_downward, semanticLabel: voteType == -1 ? l10n.downvoted : l10n.downvote, size: iconSize),
              color: voteType == -1 ? downvoteColor : null,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                HapticFeedback.mediumImpact();
                onVoteAction(comment.id, voteType == -1 ? 0 : -1);
              },
            ),
          ),
      ],
    );
  }
}
