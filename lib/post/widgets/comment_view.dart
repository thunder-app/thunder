import 'package:flutter/material.dart';

import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/core/models/comment_view_tree.dart';

class CommentSubview extends StatelessWidget {
  final List<CommentViewTree> comments;
  final int level;

  const CommentSubview({super.key, required this.comments, this.level = 0});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return CommentCard(commentViewTree: comments[index]);
      },
    );
  }
}
