import 'package:flutter/material.dart';
import 'package:lemmy/lemmy.dart';
import 'package:thunder/community/widgets/post_card.dart';

class PostCardList extends StatelessWidget {
  final List<PostView>? postViews;

  const PostCardList({super.key, this.postViews});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: postViews?.length ?? 0,
      itemBuilder: (context, index) {
        return PostCard(postView: postViews![index]);
      },
    );
  }
}
