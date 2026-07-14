import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/domain/utils/comment_state_utils.dart';
import 'package:thunder/src/features/post/post.dart';

bool postCommentsChanged(PostState previous, PostState current) => previous.comments != current.comments || previous.collapsedComments != current.collapsedComments;

/// Sliver list that renders post comments with collapsed-thread visibility.
class PostCommentsSliver extends StatelessWidget {
  const PostCommentsSliver({super.key, required this.listController});

  /// Controller used by comment navigation FAB and highlighted-comment scrolling.
  final ListController listController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: postCommentsChanged,
      builder: (context, state) {
        final account = context.read<PostBloc>().account;
        final highlightedCommentId = context.select<PostNavigationCubit, int?>((cubit) => cubit.state.highlightedCommentId);
        final collapsedCommentIds = state.collapsedComments;
        final hiddenIds = hiddenCommentIds(
          comments: state.comments,
          collapsedCommentIds: collapsedCommentIds,
        );

        return SuperSliverList.builder(
          itemCount: state.comments.length + 1,
          listController: listController,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // The navigator FAB uses one-based comment indexes so the first
              // comment can still scroll cleanly to the top of the viewport.
              return const SizedBox(height: 1);
            }

            final commentNode = state.comments[index - 1];
            final comment = commentNode.comment;
            if (comment == null) return const SizedBox.shrink();

            return CommentCard(
              key: ValueKey(comment.id),
              account: account,
              comment: comment,
              onCommentUpdated: (comment) {
                context.read<PostBloc>().add(CommentItemUpdatedEvent(comment: comment));
                context.read<PostNavigationCubit>().setHighlightedCommentId(null);
              },
              onCommentInserted: (comment) {
                context.read<PostBloc>().add(CommentItemInsertedEvent(comment: comment));
                context.read<PostNavigationCubit>().setHighlightedCommentId(comment.id);
              },
              level: commentNode.depth,
              replies: commentNode.replies.length,
              collapsed: collapsedCommentIds.contains(comment.id),
              hidden: hiddenIds.contains(comment.id),
              highlight: comment.id == highlightedCommentId,
              onCollapse: (int commentId, bool collapsed) {
                context.read<PostBloc>().add(UpdateCollapsedComment(commentId: commentId, collapsed: collapsed));
              },
            );
          },
        );
      },
    );
  }
}
