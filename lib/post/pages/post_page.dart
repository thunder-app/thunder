import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';
import 'package:thunder/shared/media_view.dart';

class PostPage extends StatelessWidget {
  final int postId;

  const PostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => PostBloc(),
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              switch (state.status) {
                case PostStatus.initial:
                  context.read<PostBloc>().add(GetPostEvent(id: postId));
                  return const Center(child: CircularProgressIndicator());
                case PostStatus.loading:
                case PostStatus.refreshing:
                  return const Center(child: CircularProgressIndicator());
                case PostStatus.success:
                  Post? post = state.postView?.post;
                  if (post == null) return const Center(child: CircularProgressIndicator());

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(post.name, style: theme.textTheme.titleMedium),
                              ),
                              MediaView(post: post),
                              if (post.body != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(post.body!),
                                ),
                            ],
                          ),
                        ),
                        CommentSubview(comments: state.comments),
                      ],
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
