import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/error_message.dart';

class PostPage extends StatefulWidget {
  final PostViewMedia? postView;
  final int? postId;

  final VoidCallback onPostUpdated;

  const PostPage({super.key, this.postView, this.postId, required this.onPostUpdated});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = true;
  bool resetFailureMessage = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95) {
      if (hasScrolledToBottom == false) setState(() => hasScrolledToBottom = true);
    } else {
      if (hasScrolledToBottom == true) setState(() => hasScrolledToBottom = false);
    }
  }

  CommentSortType? sortType;
  IconData? sortTypeIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return BlocProvider<PostBloc>(
        create: (context) => PostBloc(),
        child: BlocConsumer<PostBloc, PostState>(
            listenWhen: (previousState, currentState) {
              if (previousState.sortType != currentState.sortType) {
                setState(() {
                  sortType = currentState.sortType;
                  sortTypeIcon = commentSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == currentState.sortType).icon;
                });
              }
              return true;
            },
            listener: (context, state) {},
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
                    listenWhen: (previous, current) {
                      if (previous.status != PostStatus.failure && current.status == PostStatus.failure) {
                        setState(() => resetFailureMessage = true);
                      }
                      return true;
                    },
                    listener: (context, state) {
                      if (state.status == PostStatus.success && widget.postView != null) {
                        // Update the community's post
                        context.read<CommunityBloc>().add(UpdatePostEvent(postViewMedia: state.postView!));
                      }
                    },
                    builder: (context, state) {
                      if (state.status == PostStatus.failure && resetFailureMessage == true) {
                        SnackBar snackBar = SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: theme.colorScheme.errorContainer,
                              ),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Text(state.errorMessage ?? 'No error message available', maxLines: 4),
                              )
                            ],
                          ),
                          backgroundColor: theme.colorScheme.onErrorContainer,
                          behavior: SnackBarBehavior.floating,
                        );

                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() => resetFailureMessage = false);
                        });
                      }
                      switch (state.status) {
                        case PostStatus.initial:
                          context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                          return const Center(child: CircularProgressIndicator());
                        case PostStatus.loading:
                          return const Center(child: CircularProgressIndicator());
                        case PostStatus.refreshing:
                        case PostStatus.success:
                        case PostStatus.failure:
                          if (state.postView != null) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                HapticFeedback.mediumImpact();
                                return context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                              },
                              child: PostPageSuccess(postView: state.postView!, comments: state.comments, scrollController: _scrollController, hasReachedCommentEnd: state.hasReachedCommentEnd),
                            );
                          }
                          return ErrorMessage(
                            message: state.errorMessage,
                            action: () {
                              context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                            },
                            actionText: 'Refresh Content',
                          );
                        case PostStatus.empty:
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
            }));
  }

//TODO: More or less duplicate from community_page.dart
  void showSortBottomSheet(BuildContext context, PostState state) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        title: 'Sort Options',
        onSelect: (selected) {
          setState(() {
            sortType = selected.payload;
            sortTypeIcon = selected.icon;
          });
          context.read<PostBloc>().add(
                  //shouldn't this be GetPostCommentsEvent?
                  GetPostEvent(
                postView: widget.postView,
                postId: widget.postId,
                sortType: sortType,
              ));
          //Navigator.of(context).pop();
        },
      ),
    );
  }
}
