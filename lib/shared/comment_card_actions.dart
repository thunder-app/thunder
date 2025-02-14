import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/comment/widgets/comment_action_bottom_sheet.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class CommentCardActions extends StatelessWidget {
  final CommentView commentView;
  final bool isEdit;
  final double iconSize = 22;

  final Function(int, int) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;
  final Function(CommentView, bool) onReplyEditAction;
  final void Function() onViewSourceToggled;
  final bool viewSource;

  const CommentCardActions({
    super.key,
    required this.commentView,
    this.isEdit = false,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.onReplyEditAction,
    required this.onViewSourceToggled,
    required this.viewSource,
  });

  @override
  Widget build(BuildContext context) {
    final int voteType = commentView.myVote ?? 0;
    bool downvotesEnabled = context.read<AuthBloc>().state.downvotesEnabled;

    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 28,
              width: 44,
              child: IconButton(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    semanticLabel: 'Actions',
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    showCommentActionBottomModalSheet(
                      context,
                      commentView,
                      isShowingSource: viewSource,
                      onAction: ({commentAction, required commentView, communityAction, userAction, value}) {
                        if (commentAction != null) {
                          switch (commentAction) {
                            case CommentAction.vote:
                              onVoteAction(commentView.comment.id, value);
                              break;
                            case CommentAction.save:
                              onSaveAction(commentView.comment.id, value);
                              break;
                            case CommentAction.reply:
                              onReplyEditAction(commentView, false);
                              break;
                            case CommentAction.edit:
                              onReplyEditAction(commentView, true);
                              break;
                            case CommentAction.delete:
                              onDeleteAction(commentView.comment.id, value);
                              break;
                            case CommentAction.report:
                              context.read<PostBloc>().add(ReportCommentEvent(commentId: commentView.comment.id, message: value));
                              break;
                            case CommentAction.viewSource:
                              onViewSourceToggled();
                              break;
                            default:
                              break;
                          }
                        } else if (communityAction != null) {
                          // TODO - implement community actions
                        } else if (userAction != null) {}
                      },
                    );
                    HapticFeedback.mediumImpact();
                  }),
            ),
            SizedBox(
              height: 28,
              width: 44,
              child: IconButton(
                icon: Icon(isEdit ? Icons.edit_rounded : Icons.reply_rounded, semanticLabel: isEdit ? 'Edit' : 'Reply', size: iconSize),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onReplyEditAction(commentView, isEdit);
                },
              ),
            ),
            SizedBox(
              height: 28,
              width: 44,
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    semanticLabel: voteType == 1 ? 'Upvoted' : 'Upvote',
                    size: iconSize,
                  ),
                  color: voteType == 1 ? context.read<ThunderBloc>().state.upvoteColor.color : null,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onVoteAction(commentView.comment.id, voteType == 1 ? 0 : 1);
                  }),
            ),
            if (downvotesEnabled)
              SizedBox(
                height: 28,
                width: 44,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    semanticLabel: voteType == -1 ? 'Downvoted' : 'Downvote',
                    size: iconSize,
                  ),
                  color: voteType == -1 ? context.read<ThunderBloc>().state.downvoteColor.color : null,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onVoteAction(commentView.comment.id, voteType == -1 ? 0 : -1);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
