import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/SortTypes.dart';

class PostPage extends StatefulWidget {
  final PostViewMedia? postView;
  final int? postId;

  const PostPage({super.key, this.postView, this.postId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = false;

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95) {
      setState(() {
        hasScrolledToBottom = true;
      });
    } else {
      setState(() {
        hasScrolledToBottom = false;
      });
    }
  }

  SortType? sortType;
  IconData? sortTypeIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return BlocProvider<PostBloc>(
      create: (context)=>PostBloc(),
      child: BlocConsumer<PostBloc,PostState>(
        listenWhen: (previousState, currentState) {
          if (previousState.sortType != currentState.sortType) {
            setState(() {
              sortType = currentState.sortType;
              sortTypeIcon = CommentSortTypes.items
                  .firstWhere((sortTypeItem) =>
                      sortTypeItem.sortType == currentState.sortType)
                  .icon;
            });
          }
          return true;
        },
        listener: (context, state) {

        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(sortTypeIcon, semanticLabel: 'Sort By'),
                  onPressed: () => showSortBottomSheet(context, state),
                ),
              ],
              centerTitle: false,
              toolbarHeight: 70.0,
            ),
            floatingActionButton: (isUserLoggedIn && hasScrolledToBottom == false)
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
                          child: CreateCommentModal(postView: widget.postView?.postView),
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
                  // if (state.status == PostStatus.success && widget.postView != null) {
                  //   // Update the community's post
                  //   int? postIdIndex = context.read<CommunityBloc>().state.postViews?.indexWhere((communityPostView) => communityPostView.postView.post.id == widget.postView?.postView.post.id);
                  //   if (postIdIndex != null && state.postView != null) {
                  //     context.read<CommunityBloc>().state.postViews![postIdIndex] = state.postView!;
                  //   }
                  // }
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
                      context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                      return const Center(child: CircularProgressIndicator());
                    case PostStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case PostStatus.refreshing:
                    case PostStatus.success:
                      if (state.postView != null) return PostPageSuccess(postView: state.postView!, comments: state.comments, scrollController: _scrollController);
                      return const Center(child: Text('Empty'));
                    case PostStatus.empty:
                      return const Center(child: Text('Empty'));
                    case PostStatus.failure:
                      return ErrorMessage(
                        message: state.errorMessage,
                        action: () {
                          context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                        },
                        actionText: 'Refresh Content',
                      );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  //TODO: More or less duplicate from community_page.dart
  void showSortBottomSheet(BuildContext context, PostState state) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort Options',
                    style: theme.textTheme.titleLarge!.copyWith(),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: CommentSortTypes.items.length,
                itemBuilder: (BuildContext itemBuilderContext, int index) {
                  return ListTile(
                    title: Text(
                      CommentSortTypes.items[index].label,
                      style: theme.textTheme.bodyMedium,
                    ),
                    leading: Icon(CommentSortTypes.items[index].icon),
                    onTap: () {
                      setState(() {
                        sortType = CommentSortTypes.items[index].sortType;
                        sortTypeIcon = CommentSortTypes.items[index].icon;
                      });

                      context.read<PostBloc>().add(
                        //shouldn't this be GetPostCommentsEvent?
                        GetPostEvent(
                            postView: widget.postView,
                            postId: widget.postId,
                            sortType: sortType
                        )
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
