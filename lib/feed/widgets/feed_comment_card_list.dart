import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/comment_reference.dart';

/// Widget representing the list of comments on the feed. This is used when viewing a user's profile.
class FeedCommentCardList extends StatelessWidget {
  /// Whether or not the screen is in tablet mode. Determines the number of columns to display
  final bool tabletMode;

  /// The list of comments to display
  final List<CommentView> commentViews;

  const FeedCommentCardList({
    super.key,
    required this.commentViews,
    required this.tabletMode,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;

    return SliverMasonryGrid.count(
      crossAxisCount: tabletMode ? 2 : 1,
      crossAxisSpacing: 40,
      mainAxisSpacing: 0,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            CommentReference(
              comment: commentViews[index],
              onVoteAction: (int commentId, int voteType) => {
                // TODO: Implement action
              },
              onSaveAction: (int commentId, bool save) => {
                // TODO: Implement action
              },
              onDeleteAction: (int commentId, bool deleted) => {
                // TODO: Implement action
              },
              onReportAction: (int commentId) {
                // TODO: Implement action
              },
              onReplyEditAction: (CommentView commentView, bool isEdit) {
                // TODO: Implement action
              },
              isOwnComment: commentViews[index].comment.creatorId == state.account?.userId,
              disableActions: true,
            ),
            const FeedCardDivider(),
          ],
        );
      },
      childCount: commentViews.length,
    );
  }
}
