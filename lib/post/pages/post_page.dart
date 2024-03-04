import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page_success.dart';
import 'package:thunder/shared/comment_navigator_fab.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/gesture_fab.dart';

class PostPage extends StatefulWidget {
  final PostViewMedia? postView;
  final int? postId;
  final String? selectedCommentPath;
  final int? selectedCommentId;

  final Function(PostViewMedia) onPostUpdated;

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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool hasScrolledToBottom = false;
  bool resetFailureMessage = true;
  bool _previousIsFabOpen = false;
  bool isFabOpen = false;
  bool _previousIsFabSummoned = true;
  bool isFabSummoned = true;
  bool enableFab = false;
  bool enableCommentNavigation = true;
  bool combineNavAndFab = true;

  CommentSortType? sortType;
  IconData? sortTypeIcon;
  String? sortTypeLabel;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (context.read<ThunderBloc>().state.isFabOpen) {
      context.read<ThunderBloc>().add(const OnFabToggle(false));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState thunderState = context.watch<ThunderBloc>().state;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    enableFab = thunderState.enablePostsFab;

    bool enableBackToTop = thunderState.postFabEnableBackToTop;
    bool enableChangeSort = thunderState.postFabEnableChangeSort;
    bool enableReplyToPost = thunderState.postFabEnableReplyToPost;
    bool enableRefresh = thunderState.postFabEnableRefresh;
    bool enableSearch = thunderState.postFabEnableSearch;

    bool postLocked = widget.postView?.postView.post.locked == true;

    PostFabAction singlePressAction = thunderState.postFabSinglePressAction;
    PostFabAction longPressAction = thunderState.postFabLongPressAction;

    enableCommentNavigation = thunderState.enableCommentNavigation;
    combineNavAndFab = enableCommentNavigation && thunderState.combineNavAndFab;

    if (thunderState.isFabOpen != _previousIsFabOpen) {
      isFabOpen = thunderState.isFabOpen;
      _previousIsFabOpen = isFabOpen;
    }

    if (thunderState.isFabSummoned != _previousIsFabSummoned) {
      isFabSummoned = thunderState.isFabSummoned;
      _previousIsFabSummoned = isFabSummoned;
    }

    return BlocProvider<PostBloc>(
      create: (context) => PostBloc(),
      child: BlocConsumer<PostBloc, PostState>(
        listenWhen: (previousState, currentState) {
          if (previousState.sortType != currentState.sortType) {
            setState(() {
              sortType = currentState.sortType;
              final sortTypeItem = CommentSortPicker.getCommentSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.always)
                  .firstWhere((sortTypeItem) => sortTypeItem.payload == currentState.sortType);
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
              title: ListTile(
                title: Text(
                  sortTypeLabel?.isNotEmpty == true ? l10n.comments : '',
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Icon(sortTypeIcon, size: 13),
                    const SizedBox(width: 4),
                    Text(sortTypeLabel ?? ''),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
              flexibleSpace: Semantics(
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () {
                    if (context.read<ThunderBloc>().state.isFabOpen) {
                      context.read<ThunderBloc>().add(const OnFabToggle(false));
                    }
                  },
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  semanticLabel: l10n.back,
                ),
                onPressed: () {
                  if (context.read<ThunderBloc>().state.isFabOpen) {
                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                  }
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
                    onPressed: () {
                      if (context.read<ThunderBloc>().state.isFabOpen) {
                        context.read<ThunderBloc>().add(const OnFabToggle(false));
                      }
                      HapticFeedback.mediumImpact();
                      return context
                          .read<PostBloc>()
                          .add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
                    }),
                IconButton(
                  icon: Icon(
                    Icons.sort,
                    semanticLabel: l10n.sortBy,
                  ),
                  tooltip: l10n.sortBy,
                  onPressed: () {
                    if (context.read<ThunderBloc>().state.isFabOpen) {
                      context.read<ThunderBloc>().add(const OnFabToggle(false));
                    }
                    showSortBottomSheet(context, state);
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    ThunderPopupMenuItem(
                      onTap: () => createCrossPost(
                        context,
                        title: widget.postView?.postView.post.name ?? state.postView?.postView.post.name ?? '',
                        url: widget.postView?.postView.post.url ?? state.postView?.postView.post.url,
                        text: widget.postView?.postView.post.body ?? state.postView?.postView.post.body,
                        postUrl: widget.postView?.postView.post.apId ?? state.postView?.postView.post.apId,
                      ),
                      icon: Icons.repeat_rounded,
                      title: l10n.createNewCrossPost,
                    ),
                  ],
                ),
              ],
              centerTitle: false,
              toolbarHeight: 70.0,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Stack(
              alignment: Alignment.center,
              children: [
                if (enableCommentNavigation)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CommentNavigatorFab(
                          itemPositionsListener: _itemPositionsListener,
                        ),
                      ),
                    ),
                  ),
                if (enableFab)
                  Padding(
                    padding: EdgeInsets.only(
                      right: combineNavAndFab ? 0 : 16,
                      bottom: combineNavAndFab ? 5 : 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isFabSummoned
                          ? GestureFab(
                              centered: combineNavAndFab,
                              distance: combineNavAndFab ? 45 : 60,
                              icon: Icon(
                                state.status == PostStatus.searchInProgress ? Icons.youtube_searched_for_rounded : singlePressAction.getIcon(postLocked: postLocked),
                                semanticLabel: state.status == PostStatus.searchInProgress ? l10n.search : singlePressAction.getTitle(context, postLocked: postLocked),
                                size: 35,
                              ),
                              onPressed: state.status == PostStatus.searchInProgress
                                  ? () {
                                      context.read<PostBloc>().add(const ContinueCommentSearchEvent());
                                    }
                                  : () => singlePressAction.execute(
                                      context: context,
                                      postView: state.postView,
                                      postId: state.postId,
                                      selectedCommentId: state.selectedCommentId,
                                      selectedCommentPath: state.selectedCommentPath,
                                      override: singlePressAction == PostFabAction.backToTop
                                          ? () => {
                                                _itemScrollController.scrollTo(
                                                  index: 0,
                                                  duration: const Duration(milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                )
                                              }
                                          : singlePressAction == PostFabAction.changeSort
                                              ? () => showSortBottomSheet(context, state)
                                              : singlePressAction == PostFabAction.replyToPost
                                                  ? () => replyToPost(context, postViewMedia: state.postView!, postLocked: postLocked)
                                                  : null),
                              onLongPress: () => longPressAction.execute(
                                  context: context,
                                  postView: state.postView,
                                  postId: state.postId,
                                  selectedCommentId: state.selectedCommentId,
                                  selectedCommentPath: state.selectedCommentPath,
                                  override: longPressAction == PostFabAction.backToTop
                                      ? () => {
                                            _itemScrollController.scrollTo(
                                              index: 0,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            )
                                          }
                                      : longPressAction == PostFabAction.changeSort
                                          ? () => showSortBottomSheet(context, state)
                                          : longPressAction == PostFabAction.replyToPost
                                              ? () => replyToPost(context, postViewMedia: state.postView!, postLocked: postLocked)
                                              : null),
                              children: [
                                if (enableRefresh)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.refresh.execute(
                                        context: context,
                                        postView: state.postView,
                                        postId: state.postId,
                                        selectedCommentId: state.selectedCommentId,
                                        selectedCommentPath: state.selectedCommentPath,
                                      );
                                    },
                                    title: PostFabAction.refresh.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.refresh.getIcon(),
                                    ),
                                  ),
                                if (enableReplyToPost)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.replyToPost.execute(
                                        override: () => replyToPost(context, postViewMedia: state.postView!, postLocked: postLocked),
                                      );
                                    },
                                    title: PostFabAction.replyToPost.getTitle(context),
                                    icon: Icon(
                                      postLocked ? Icons.lock : PostFabAction.replyToPost.getIcon(),
                                    ),
                                  ),
                                if (enableChangeSort)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.changeSort.execute(
                                        override: () => showSortBottomSheet(context, state),
                                      );
                                    },
                                    title: PostFabAction.changeSort.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.changeSort.getIcon(),
                                    ),
                                  ),
                                if (enableBackToTop)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      PostFabAction.backToTop.execute(
                                          override: () => {
                                                _itemScrollController.scrollTo(
                                                  index: 0,
                                                  duration: const Duration(milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                )
                                              });
                                    },
                                    title: PostFabAction.backToTop.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.backToTop.getIcon(),
                                    ),
                                  ),
                                if (enableSearch)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      PostFabAction.search.execute(override: () {
                                        if (state.status == PostStatus.searchInProgress) {
                                          context.read<PostBloc>().add(const EndCommentSearchEvent());
                                        } else {
                                          showInputDialog<String>(
                                            context: context,
                                            title: l10n.searchComments,
                                            inputLabel: l10n.searchTerm,
                                            onSubmitted: ({payload, value}) {
                                              Navigator.of(context).pop();

                                              List<Comment> commentMatches = [];

                                              /// Recursive function which checks if any child of the given [commentViewTrees] contains the query
                                              void findMatches(List<CommentViewTree> commentViewTrees) {
                                                for (CommentViewTree commentViewTree in commentViewTrees) {
                                                  if (commentViewTree.commentView?.comment.content.contains(RegExp(value!, caseSensitive: false)) == true) {
                                                    commentMatches.add(commentViewTree.commentView!.comment);
                                                  }
                                                  findMatches(commentViewTree.replies);
                                                }
                                              }

                                              // Find all comments which contain the query
                                              findMatches(state.comments);

                                              if (commentMatches.isEmpty) {
                                                showSnackbar(l10n.noResultsFound);
                                              } else {
                                                context.read<PostBloc>().add(StartCommentSearchEvent(commentMatches: commentMatches));
                                              }

                                              return Future.value(null);
                                            },
                                            getSuggestions: (_) => Future.value(const Iterable<String>.empty()),
                                            suggestionBuilder: (payload) => Container(),
                                          );
                                        }
                                      });
                                    },
                                    title: state.status == PostStatus.searchInProgress ? l10n.endSearch : PostFabAction.search.getTitle(context),
                                    icon: Icon(
                                      state.status == PostStatus.searchInProgress ? Icons.search_off_rounded : PostFabAction.search.getIcon(),
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            body: Stack(
              alignment: Alignment.bottomRight,
              children: [
                SafeArea(
                  child: BlocConsumer<PostBloc, PostState>(
                    listenWhen: (previous, current) {
                      if ((previous.status != PostStatus.failure && current.status == PostStatus.failure) || (previous.errorMessage != current.errorMessage)) {
                        setState(() => resetFailureMessage = true);
                      }
                      return true;
                    },
                    listener: (context, state) {
                      if (state.status == PostStatus.success && widget.postView != null && state.postView != null) {
                        widget.onPostUpdated(state.postView!);
                      }
                    },
                    builder: (context, state) {
                      if (state.status == PostStatus.failure && resetFailureMessage == true) {
                        showSnackbar(
                          state.errorMessage ?? l10n.missingErrorMessage,
                          backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
                          leadingIcon: Icons.warning_rounded,
                          leadingIconColor: Theme.of(context).colorScheme.errorContainer,
                        );
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
                        case PostStatus.searchInProgress:
                          if (state.postView != null) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                HapticFeedback.mediumImpact();
                                return context
                                    .read<PostBloc>()
                                    .add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
                              },
                              child: PostPageSuccess(
                                postView: state.postView!,
                                comments: state.comments,
                                selectedCommentId: state.selectedCommentId,
                                selectedCommentPath: state.selectedCommentPath,
                                newlyCreatedCommentId: state.newlyCreatedCommentId,
                                moddingCommentId: state.moddingCommentId,
                                viewFullCommentsRefreshing: state.viewAllCommentsRefresh,
                                itemScrollController: _itemScrollController,
                                itemPositionsListener: _itemPositionsListener,
                                hasReachedCommentEnd: state.hasReachedCommentEnd,
                                moderators: state.moderators,
                                crossPosts: state.crossPosts,
                              ),
                            );
                          }
                          return ErrorMessage(
                            message: state.errorMessage,
                            action: () {
                              context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId, selectedCommentId: null));
                            },
                            actionText: l10n.refreshContent,
                          );
                        case PostStatus.empty:
                          return ErrorMessage(
                            message: state.errorMessage,
                            action: () {
                              context.read<PostBloc>().add(GetPostEvent(postView: widget.postView, postId: widget.postId));
                            },
                            actionText: l10n.refreshContent,
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
                            color: theme.colorScheme.background.withOpacity(0.95),
                          ),
                        )
                      : null,
                ),
                if (enableFab)
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
          );
        },
      ),
    );
  }

//TODO: More or less duplicate from community_page.dart
  void showSortBottomSheet(BuildContext context, PostState state) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        title: l10n.sortOptions,
        onSelect: (selected) {
          setState(() {
            sortType = selected.payload;
            sortTypeLabel = selected.label;
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
        previouslySelected: sortType,
      ),
    );
  }

  void replyToPost(BuildContext context, {required PostViewMedia postViewMedia, bool postLocked = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final authBloc = context.read<AuthBloc>();

    if (!authBloc.state.isLoggedIn) {
      return showSnackbar(l10n.mustBeLoggedInComment);
    }

    if (postLocked) {
      showSnackbar(l10n.postLocked);
      return;
    }

    navigateToCreateCommentPage(
      context,
      postViewMedia: postViewMedia,
      onCommentSuccess: (CommentView commentView) {
        context.read<PostBloc>().add(CommentUpdatedEvent(commentView: commentView));
      },
    );
  }
}
