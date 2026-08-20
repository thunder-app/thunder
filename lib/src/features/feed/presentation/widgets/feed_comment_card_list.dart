import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_reference.dart';

/// Widget representing the list of comments on the feed. This is used when viewing a user's profile.
class FeedCommentCardList extends StatelessWidget {
  /// Whether or not the screen is in tablet mode. Determines the number of columns to display
  final bool tabletMode;

  /// The list of comments to display
  final List<ThunderComment> comments;

  const FeedCommentCardList({super.key, required this.comments, required this.tabletMode});

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: tabletMode ? 2 : 1,
      crossAxisSpacing: 40,
      mainAxisSpacing: 0,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            CommentReference(comment: comments[index]),
            const FeedCardDivider(),
          ],
        );
      },
      childCount: comments.length,
    );
  }
}
