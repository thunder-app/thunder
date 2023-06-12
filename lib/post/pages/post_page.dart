import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy/lemmy.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class PostPage extends StatelessWidget {
  final int postId;

  const PostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: SafeArea(
        child: BlocProvider(
          create: (context) => PostBloc(),
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              switch (state.status) {
                case PostStatus.initial:
                  context.read<PostBloc>().add(GetPostEvent(id: postId));
                  // context.read<PostBloc>().add(GetPostCommentsEvent(postId: postId));
                  return const Center(child: CircularProgressIndicator());
                case PostStatus.loading:
                case PostStatus.refreshing:
                  return const Center(child: CircularProgressIndicator());
                case PostStatus.success:
                  Post? post = state.postView?.post;

                  if (post == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MediaView(post: post),
                          Text(
                            post.name,
                            style: theme.textTheme.titleMedium,
                            softWrap: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.postView!.community.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                                          color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconText(
                                            text: formatNumberToK(state.postView!.counts.upvotes),
                                            icon: Icon(
                                              Icons.arrow_upward,
                                              size: 18.0,
                                              color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                            ),
                                            padding: 2.0,
                                          ),
                                          const SizedBox(width: 12.0),
                                          IconText(
                                            icon: Icon(
                                              Icons.chat,
                                              size: 17.0,
                                              color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                            ),
                                            text: formatNumberToK(state.postView!.counts.comments),
                                            padding: 5.0,
                                          ),
                                          const SizedBox(width: 10.0),
                                          IconText(
                                            icon: Icon(
                                              Icons.history_rounded,
                                              size: 19.0,
                                              color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                            ),
                                            text: formatTimeToString(dateTime: post.published),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.arrow_upward),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.arrow_downward),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.bookmark),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CommentSubview(comments: state.comments),
                        ],
                      ),
                    ),
                  );
                case PostStatus.failure:
                  return const Center(child: Text('Something went wrong'));
                case PostStatus.empty:
                  return const Center(child: Text('Empty'));
              }
            },
          ),
        ),
      ),
    );
  }
}
