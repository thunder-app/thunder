import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class CommentCardActions extends StatelessWidget {
  final CommentViewTree commentViewTree;
  final bool isEdit;

  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;

  const CommentCardActions({
    super.key,
    required this.commentViewTree,
    this.isEdit = false,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
  });

  final MaterialColor upVoteColor = Colors.orange;
  final MaterialColor downVoteColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final VoteType voteType = commentViewTree.commentView!.myVote ?? VoteType.none;

    return BlocBuilder<ThunderBloc, ThunderState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  semanticLabel: 'Actions',
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  showCommentActionBottomModalSheet(context, commentViewTree, onSaveAction, onDeleteAction);
                  HapticFeedback.mediumImpact();
                }),
            IconButton(
              icon: Icon(
                isEdit ? Icons.edit_rounded : Icons.reply_rounded,
                semanticLabel: 'Reply',
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                HapticFeedback.mediumImpact();
                PostBloc postBloc = context.read<PostBloc>();
                ThunderBloc thunderBloc = context.read<ThunderBloc>();

                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  showDragHandle: true,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                      child: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider<PostBloc>.value(value: postBloc),
                            BlocProvider<ThunderBloc>.value(value: thunderBloc),
                          ],
                          child: CreateCommentModal(commentView: commentViewTree, isEdit: isEdit),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            IconButton(
                icon: Icon(
                  Icons.arrow_upward,
                  semanticLabel: voteType == VoteType.up ? 'Upvoted' : 'Upvote',
                ),
                color: voteType == VoteType.up ? upVoteColor : null,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onVoteAction(commentViewTree.commentView!.comment.id, voteType == VoteType.up ? VoteType.none : VoteType.up);
                }),
            IconButton(
              icon: Icon(
                Icons.arrow_downward,
                semanticLabel: voteType == VoteType.down ? 'Downvoted' : 'Downvote',
              ),
              color: voteType == VoteType.down ? downVoteColor : null,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                HapticFeedback.mediumImpact();
                onVoteAction(commentViewTree.commentView!.comment.id, voteType == VoteType.down ? VoteType.none : VoteType.down);
              },
            ),
          ],
        );
      },
    );
  }
}
