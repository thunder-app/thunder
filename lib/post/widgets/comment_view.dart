import 'package:flutter/material.dart';
import 'package:lemmy/lemmy.dart';

class CommentSubview extends StatelessWidget {
  final List<CommentView> comments;

  const CommentSubview({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) const Divider(),
            Text(comments[index].comment.content),
            Divider(),
          ],
        );
      },
    );
  }
}
