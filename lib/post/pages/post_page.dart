import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/error_message.dart';

class PostPage extends StatelessWidget {
  final PostViewMedia postView;

  const PostPage({super.key, required this.postView});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: isUserLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                PostBloc postBloc = context.read<PostBloc>();

                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  showDragHandle: true,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                      child: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: BlocProvider<PostBloc>.value(
                          value: postBloc,
                          child: CreateCommentModal(postView: postView),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Icon(
                Icons.reply_rounded,
                semanticLabel: 'Reply to Post',
              ),
            )
          : null,
      body: SafeArea(
        child: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state.status == PostStatus.success) {
              // Update the community's post
              int? postIdIndex = context.read<CommunityBloc>().state.postViews?.indexWhere((communityPostView) => communityPostView.post.id == postView.post.id);
              if (postIdIndex != null && state.postView != null) {
                context.read<CommunityBloc>().state.postViews![postIdIndex] = state.postView!;
              }
            }
          },
          builder: (context, state) {
            if (state.status == PostStatus.failure) {
              SnackBar snackBar = SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: theme.colorScheme.errorContainer,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(state.errorMessage ?? 'No error message available'),
                    )
                  ],
                ),
                backgroundColor: theme.colorScheme.onErrorContainer,
                behavior: SnackBarBehavior.floating,
              );
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
            }

            switch (state.status) {
              case PostStatus.initial:
                context.read<PostBloc>().add(GetPostEvent(postView: postView));
                return const Center(child: CircularProgressIndicator());
              case PostStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case PostStatus.refreshing:
              case PostStatus.success:
                if (state.postView != null) return PostPageSuccess(postView: state.postView!, comments: state.comments);
                return const Center(child: Text('Empty'));
              case PostStatus.empty:
                return const Center(child: Text('Empty'));
              case PostStatus.failure:
                return ErrorMessage(
                  message: state.errorMessage,
                  action: () => {context.read<PostBloc>().add(GetPostEvent(postView: postView))},
                  actionText: 'Refresh Content',
                );
            }
          },
        ),
      ),
    );
  }
}
