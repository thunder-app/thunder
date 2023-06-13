import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';

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
                  return const Center(child: CircularProgressIndicator());
                case PostStatus.refreshing:
                case PostStatus.success:
                  return PostPageSuccess(postView: state.postView!, comments: state.comments);
                case PostStatus.failure:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 100,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 32.0),
                          Text('Oops, something went wrong!', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8.0),
                          Text(
                            state.errorMessage ?? 'No error message available',
                            style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                          ),
                          const SizedBox(height: 32.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                            onPressed: () => {context.read<PostBloc>().add(GetPostEvent(id: postId))},
                            child: const Text('Refresh Post'),
                          ),
                        ],
                      ),
                    ),
                  );
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
