import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';
import 'package:thunder/shared/media_view.dart';

class PostPageSuccess extends StatefulWidget {
  final Post post;
  final List<CommentViewTree> comments;

  const PostPageSuccess({super.key, required this.post, this.comments = const []});

  @override
  State<PostPageSuccess> createState() => _PostPageSuccessState();
}

class _PostPageSuccessState extends State<PostPageSuccess> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<PostBloc>().add(const GetPostCommentsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(widget.post.name, style: theme.textTheme.titleMedium),
                ),
                MediaView(post: widget.post),
                if (widget.post.body != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MarkdownBody(
                      data: widget.post.body!,
                      onTapLink: (text, url, title) => launchUrl(Uri.parse(url!)),
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: theme.textTheme.bodyMedium,
                        blockquoteDecoration: const BoxDecoration(
                          color: Colors.transparent,
                          border: Border(left: BorderSide(color: Colors.grey, width: 4)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          CommentSubview(comments: widget.comments),
        ],
      ),
    );
  }
}
