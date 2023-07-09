import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class CommentSubview extends StatefulWidget {
  final List<CommentViewTree> comments;
  final int level;

  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;

  final PostViewMedia? postViewMedia;
  final ScrollController? scrollController;

  final bool hasReachedCommentEnd;

  const CommentSubview({
    super.key,
    required this.comments,
    this.level = 0,
    required this.onVoteAction,
    required this.onSaveAction,
    this.postViewMedia,
    this.scrollController,
    this.hasReachedCommentEnd = false,
  });

  @override
  State<CommentSubview> createState() => _CommentSubviewState();
}

class _CommentSubviewState extends State<CommentSubview> {
  Set collapsedCommentSet = {}; // Retains the collapsed state of any comments

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    return ListView.builder(
      addSemanticIndexes: false,
      controller: widget.scrollController,
      itemCount: getCommentsListLength(),
      itemBuilder: (context, index) {
        if (widget.postViewMedia != null && index == 0) {
          return PostSubview(postViewMedia: widget.postViewMedia!);
        } else if (widget.hasReachedCommentEnd == false && widget.comments.isEmpty) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: const CircularProgressIndicator(),
              ),
            ],
          );
        } else if (index == widget.comments.length + 1) {
          if (widget.hasReachedCommentEnd == true) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: theme.dividerColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'Hmmm. It seems like you\'ve reached the bottom.',
                    textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: const CircularProgressIndicator(),
                ),
              ],
            );
          }
        } else {
          return CommentCard(
            commentViewTree: widget.comments[index - 1],
            collapsedCommentSet: collapsedCommentSet,
            collapsed: collapsedCommentSet.contains(widget.comments[index - 1].comment!.comment.id) || widget.level == 2,
            onSaveAction: (int commentId, bool save) => widget.onSaveAction(commentId, save),
            onVoteAction: (int commentId, VoteType voteType) => widget.onVoteAction(commentId, voteType),
            onCollapseCommentChange: (int commentId, bool collapsed) => onCollapseCommentChange(commentId, collapsed),
          );
        }
      },
    );
  }

  int getCommentsListLength() {
    if (widget.comments.isEmpty && widget.hasReachedCommentEnd == false) {
      return 2; // Show post and loading indicator since no comments have been fetched yet
    }

    return widget.postViewMedia != null ? widget.comments.length + 2 : widget.comments.length + 1;
  }

  void onCollapseCommentChange(int commentId, bool collapsed) {
    if (collapsed == false && collapsedCommentSet.contains(commentId)) {
      setState(() => collapsedCommentSet.remove(commentId));
    } else if (collapsed == true && !collapsedCommentSet.contains(commentId)) {
      setState(() => collapsedCommentSet.add(commentId));
    }

    print(collapsedCommentSet);
  }
}
