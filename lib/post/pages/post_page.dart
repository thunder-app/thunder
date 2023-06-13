import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';

class PostPage extends StatelessWidget {
  final int postId;

  const PostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
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
                  return const Center(child: CircularProgressIndicator());
                case PostStatus.refreshing:
                case PostStatus.success:
                  return PostPageSuccess(postView: state.postView!, comments: state.comments);
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
