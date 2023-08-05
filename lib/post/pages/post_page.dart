import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/gesture_fab.dart';

class PostPage extends StatefulWidget {
  final PostViewMedia? postView;
  final int? postId;
  final String? selectedCommentPath;
  final int? selectedCommentId;

  final VoidCallback onPostUpdated;

  const PostPage({
    super.key,
    this.postView,
    this.postId,
    this.selectedCommentPath,
    this.selectedCommentId,
    required this.onPostUpdated,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _scrollController = ScrollController(initialScrollOffset: 0);
  bool hasScrolledToBottom = false;
  bool resetFailureMessage = true;
  bool _previousIsFabOpen = false;
  bool isFabOpen = false;
  bool _previousIsFabSummoned = true;
  bool isFabSummoned = true;
  bool enableFab = false;

  Offset? _currentHorizontalDragStartPosition;

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
  String? sortTypeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState thunderState = context.watch<ThunderBloc>().state;
    enableFab = thunderState.enablePostsFab;

    bool enableBackToTop = thunderState.postFabEnableBackToTop;
    bool enableChangeSort = thunderState.postFabEnableChangeSort;
    bool enableReplyToPost = thunderState.postFabEnableReplyToPost;

    var singlePressAction = thunderState.postFabSinglePressAction;
    var longPressAction = thunderState.postFabLongPressAction;

    if (thunderState.isFabOpen != _previousIsFabOpen) {
      isFabOpen = thunderState.isFabOpen;
      _previousIsFabOpen = isFabOpen;
    }

    if (thunderState.isFabSummoned != _previousIsFabSummoned) {
      isFabSummoned = thunderState.isFabSummoned;
      _previousIsFabSummoned = isFabSummoned;
    }

    return WillPopScope(
      onWillPop: () {
        if (context.read<ThunderBloc>().state.isFabOpen) {
          context.read<ThunderBloc>().add(const OnFabToggle(false));
        }
        return Future.value(true);
      },
      child: BlocProvider<PostBloc>(
        create: (context) => PostBloc(),
        child: BlocConsumer<PostBloc, PostState>(
          listenWhen: (previousState, currentState) {
            if (previousState.sortType != currentState.sortType) {
              setState(() {
                sortType = currentState.sortType;
                final sortTypeItem = commentSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == currentState.sortType);
                sortTypeIcon = sortTypeItem.icon;
                sortTypeLabel = sortTypeItem.label;
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
                    icon: Icon(
                      sortTypeIcon,
                      semanticLabel: AppLocalizations.of(context)!.sortBy,
                    ),
                    tooltip: sortTypeLabel,
                    onPressed: () => showSortBottomSheet(context, state),
                  ),
                ],
                centerTitle: false,
                toolbarHeight: 70.0,
              ),
              floatingActionButton: enableFab
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isFabSummoned
                          ? GestureFab(
                              distance: 60,
                              icon: Icon(
                                getFabActionIcon(singlePressAction, override: singlePressAction == LocalSettings.postFabEnableChangeSort.name ? sortTypeIcon : null),
                                semanticLabel: getFabActionTitle(singlePressAction),
                                size: 35,
                              ),
                              onPressed: () => executeFabAction(singlePressAction, state),
                              onLongPress: () => executeFabAction(longPressAction, state),
                              children: [
                                if (enableReplyToPost)
                                  ActionButton(
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      executeFabAction(LocalSettings.postFabEnableReplyToPost.name, state);
                                    },
                                    title: getFabActionTitle(LocalSettings.postFabEnableReplyToPost.name),
                                    icon: Icon(
                                      getFabActionIcon(LocalSettings.postFabEnableReplyToPost.name),
                                      semanticLabel: getFabActionTitle(LocalSettings.postFabEnableReplyToPost.name),
                                    ),
                                  ),
                                if (enableChangeSort)
                                  ActionButton(
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      executeFabAction(LocalSettings.postFabEnableChangeSort.name, state);
                                    },
                                    title: getFabActionTitle(LocalSettings.postFabEnableChangeSort.name),
                                    icon: Icon(
                                      getFabActionIcon(LocalSettings.postFabEnableChangeSort.name, override: sortTypeIcon),
                                      semanticLabel: getFabActionTitle(LocalSettings.postFabEnableChangeSort.name),
                                    ),
                                  ),
                                if (enableBackToTop)
                                  ActionButton(
                                    onPressed: () {
                                      executeFabAction(LocalSettings.postFabEnableBackToTop.name, state);
                                    },
                                    title: getFabActionTitle(LocalSettings.postFabEnableBackToTop.name),
                                    icon: Icon(
                                      getFabActionIcon(LocalSettings.postFabEnableBackToTop.name),
                                      semanticLabel: getFabActionTitle(LocalSettings.postFabEnableBackToTop.name),
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    )
                  : null,
              body: GestureDetector(
                onHorizontalDragStart: (details) {
                  _currentHorizontalDragStartPosition = details.globalPosition;
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0 && (_currentHorizontalDragStartPosition?.dx ?? 0) > 45) {
                    Navigator.of(context).pop();
                  }
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    SafeArea(
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
                                    child: Text(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage, maxLines: 4),
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
                              context
                                  .read<PostBloc>()
                                  .add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentPath: widget.selectedCommentPath, selectedCommentId: widget.selectedCommentId));
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
                                    return context.read<PostBloc>().add(
                                        GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
                                  },
                                  child: PostPageSuccess(
                                    postView: state.postView!,
                                    comments: state.comments,
                                    selectedCommentId: state.selectedCommentId,
                                    selectedCommentPath: state.selectedCommentPath,
                                    moddingCommentId: state.moddingCommentId,
                                    viewFullCommentsRefreshing: state.viewAllCommentsRefresh,
                                    scrollController: _scrollController,
                                    hasReachedCommentEnd: state.hasReachedCommentEnd,
                                    moderators: state.moderators,
                                  ),
                                );
                              }
                              return ErrorMessage(
                                message: state.errorMessage,
                                action: () {
                                  context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: null));
                                },
                                actionText: AppLocalizations.of(context)!.refreshContent,
                              );
                            case PostStatus.empty:
                              return ErrorMessage(
                                message: state.errorMessage,
                                action: () {
                                  context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                                },
                                actionText: AppLocalizations.of(context)!.refreshContent,
                              );
                          }
                        },
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isFabOpen
                          ? Listener(
                              onPointerUp: (details) {
                                context.read<ThunderBloc>().add(const OnFabToggle(false));
                              },
                              child: Container(
                                color: theme.colorScheme.background.withOpacity(0.85),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy < -5) {
                            context.read<ThunderBloc>().add(const OnFabSummonToggle(true));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

//TODO: More or less duplicate from community_page.dart
  void showSortBottomSheet(BuildContext context, PostState state) {
    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        title: AppLocalizations.of(context)!.sortOptions,
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

  void replyToPost() {
    PostBloc postBloc = context.read<PostBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<PostBloc>.value(value: postBloc),
                BlocProvider<ThunderBloc>.value(value: thunderBloc),
              ],
              child: CreateCommentModal(postView: widget.postView?.postView),
            ),
          ),
        );
      },
    );
  }

  IconData? getFabActionIcon(String name, {IconData? override}) {
    if (override != null) {
      return override;
    }

    if (name == 'open_fab') {
      return Icons.more_horiz_rounded;
    } else if (name == LocalSettings.postFabEnableBackToTop.name) {
      return Icons.arrow_upward;
    } else if (name == LocalSettings.postFabEnableChangeSort.name) {
      return Icons.sort_rounded;
    } else if (name == LocalSettings.postFabEnableReplyToPost.name) {
      return Icons.reply_rounded;
    }
    return null;
  }

  String? getFabActionTitle(String name) {
    if (name == 'open_fab') {
      return AppLocalizations.of(context)!.open;
    } else if (name == LocalSettings.postFabEnableBackToTop.name) {
      return AppLocalizations.of(context)!.backToTop;
    } else if (name == LocalSettings.postFabEnableChangeSort.name) {
      return AppLocalizations.of(context)!.changeSort;
    } else if (name == LocalSettings.postFabEnableReplyToPost.name) {
      return AppLocalizations.of(context)!.replyToPost;
    }
    return null;
  }

  void executeFabAction(String name, PostState state) {
    if (name == 'open_fab') {
      context.read<ThunderBloc>().add(const OnFabToggle(true));
    } else if (name == LocalSettings.postFabEnableBackToTop.name) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (name == LocalSettings.postFabEnableChangeSort.name) {
      showSortBottomSheet(context, state);
    } else if (name == LocalSettings.postFabEnableReplyToPost.name) {
      replyToPost();
    }
  }
}
