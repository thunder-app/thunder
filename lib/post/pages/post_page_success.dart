import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';
import 'package:thunder/shared/media_view.dart';

class PostPageSuccess extends StatefulWidget {
  final PostView postView;
  final List<CommentViewTree> comments;

  const PostPageSuccess({super.key, required this.postView, this.comments = const []});

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
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(widget.postView.post.name, style: theme.textTheme.titleMedium),
                ),
                Row(
                  children: [
                    Text(
                      widget.postView.community.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    Text(
                      ' · ${formatTimeToString(dateTime: widget.postView.post.published)} · ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    Text(
                      widget.postView.creator.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
                MediaView(post: widget.postView.post),
                if (widget.postView.post.body != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: MarkdownBody(
                      data: widget.postView.post.body!,
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
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<PostBloc>().add(VotePostEvent(
                              postId: widget.postView.post.id,
                              score: widget.postView.myVote == 1 ? 0 : 1,
                            ));
                      },
                      icon: const Icon(Icons.arrow_upward),
                      color: widget.postView.myVote == 1 ? Colors.orange : null,
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<PostBloc>().add(VotePostEvent(
                              postId: widget.postView.post.id,
                              score: widget.postView.myVote == -1 ? 0 : -1,
                            ));
                      },
                      icon: const Icon(Icons.arrow_downward),
                      color: widget.postView.myVote == -1 ? Colors.blue : null,
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<PostBloc>().add(SavePostEvent(
                              postId: widget.postView.post.id,
                              save: !widget.postView.saved,
                            ));
                      },
                      icon: Icon(widget.postView.saved ? Icons.star_rounded : Icons.star_border_rounded),
                      color: widget.postView.saved ? Colors.orange : null,
                    ),
                    // IconButton(
                    //   onPressed: null,
                    //   icon: Icon(
                    //     Icons.reply_rounded,
                    //   ),
                    // ),
                    // IconButton(
                    //   onPressed: null,
                    //   icon: Icon(
                    //     Icons.ios_share_rounded,
                    //   ),
                    // )
                  ],
                )
              ],
            ),
          ),
          CommentSubview(comments: widget.comments),
        ],
      ),
    );
  }
}
