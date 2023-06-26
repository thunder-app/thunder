import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';

class PostPageSuccess extends StatefulWidget {
  final PostViewMedia postView;
  final List<CommentViewTree> comments;

  final ScrollController scrollController;

  const PostPageSuccess({
    super.key,
    required this.postView,
    this.comments = const [],
    required this.scrollController,
  });

  @override
  State<PostPageSuccess> createState() => _PostPageSuccessState();
}

class _PostPageSuccessState extends State<PostPageSuccess> {
  @override
  void initState() {
    widget.scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent * 0.8) {
      context.read<PostBloc>().add(const GetPostCommentsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostSubview(postView: widget.postView),
          CommentSubview(comments: widget.comments),
        ],
      ),
    );
  }
}
