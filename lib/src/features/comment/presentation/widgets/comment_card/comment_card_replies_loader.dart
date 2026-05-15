import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';

/// Displays the "load replies" action for comments with additional children.
class CommentCardRepliesLoader extends StatelessWidget {
  const CommentCardRepliesLoader({super.key, required this.comment, required this.level, required this.replies, required this.collapsed, required this.hideReplyCount});

  /// Comment whose replies may be loaded.
  final ThunderComment comment;

  /// Nesting depth used for the additional-replies card.
  final int level;

  /// Number of currently loaded replies.
  final int replies;

  /// Whether the comment is collapsed.
  final bool collapsed;

  /// Whether the reply loader should be suppressed.
  final bool hideReplyCount;

  @override
  Widget build(BuildContext context) {
    if (replies != 0 || (comment.childCount ?? 0) <= 0 || hideReplyCount) {
      return const SizedBox.shrink();
    }

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 350),
      sizeCurve: Curves.easeInOutCubicEmphasized,
      firstChild: SizedBox(width: MediaQuery.sizeOf(context).width),
      secondChild: AdditionalCommentCard(
        depth: level,
        replies: comment.childCount!,
        onTap: () => context.read<PostBloc>().add(GetPostCommentRepliesEvent(commentParentId: comment.id)),
      ),
      crossFadeState: collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }
}
