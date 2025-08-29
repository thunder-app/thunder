import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/fab_action.dart';
import 'package:thunder/src/shared/comment_sort_picker.dart';
import 'package:thunder/src/shared/error_message.dart';
import 'package:thunder/src/shared/gesture_fab.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/widgets/comment_navigator_fab.dart';
import 'package:thunder/src/shared/cross_posts.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/shared/widgets/text/selectable_text_modal.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';

/// A page that displays the post details and comments associated with a post.
class PostPage extends StatefulWidget {
  /// The initial [ThunderPost] that should be displayed in the page.
  /// When a post action is performed, the post bloc's [post] is updated.
  /// Additionally, the [onPostUpdated] function is called to update the post in the feed.
  final ThunderPost initialPost;

  /// Called whenever the post is updated. Used to update the post in the feed.
  final Function(ThunderPost post)? onPostUpdated;

  /// The ID of the comment that should be initially highlighted.
  final int? highlightedCommentId;

  /// The path of the comment that should be initially highlighted.
  final String? commentPath;

  const PostPage({
    super.key,
    required this.initialPost,
    this.onPostUpdated,
    this.highlightedCommentId,
    this.commentPath,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  /// Creates a [ScrollController] that can be used to control the scroll position of the page.
  final ScrollController scrollController = ScrollController();

  /// Creates a [ListController] that can be used to control the list of items in the page.
  final ListController listController = ListController();

  /// The key for the app bar
  final GlobalKey appBarKey = GlobalKey();

  /// The key for the "reached end" indicator
  final GlobalKey reachedEndKey = GlobalKey();

  /// Whether the post source should be displayed.
  bool viewSource = false;

  /// The active account that was selected when the page was opened
  Account? originalUser;

  /// Whether the user changed during the course of viewing the post
  bool userChanged = false;

  /// The height of the bottom spacer
  double? bottomSpacerHeight;

  /// Whether we have set the initial scroll offset.
  /// This needs to be done after building so the controller is attached
  bool hasSetInitialScroll = false;

  /// The ID of the comment that should be highlighted
  int? highlightedCommentId;

  /// The timer for calculating the bottom spacer height
  Timer? _calculateBottomSpacerTimer;

  @override
  void initState() {
    super.initState();

    highlightedCommentId = widget.highlightedCommentId;

    scrollController.addListener(() {
      // Fetches new comments when the user has scrolled past 70% list
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.7 && context.read<PostBloc>().state.status == PostStatus.success) {
        context.read<PostBloc>().add(const GetPostCommentsEvent());
      }

      context.read<PostBloc>().add(UpdateScrollPosition(scrollPosition: scrollController.position.pixels));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasSetInitialScroll) {
        hasSetInitialScroll = true;
        scrollController.jumpTo(context.read<PostBloc>().state.scrollPosition ?? 0.0);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    listController.dispose();
    _calculateBottomSpacerTimer?.cancel();
    super.dispose();
  }

  // The following logic helps us to set the size of the bottom spacer so that the user can scroll the last comment to the top of the viewport but no further.
  // This must be run some time after the layout has been rendered so we can measure everything.
  Future<void> _getBottomSpacerHeight() async {
    final deviceHeight = MediaQuery.sizeOf(context).height;

    // Get the height of the "reached end" indicator widget
    final reachedEndHeight = (reachedEndKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;

    // Get the height of the app bar
    final renderObject = appBarKey.currentContext?.findRenderObject() as RenderSliverFloatingPersistentHeader?;
    final appBarHeight = renderObject?.geometry!.maxPaintExtent;

    if (appBarHeight != null && reachedEndHeight != null) {
      // We will make the bottom spacer the size of the device height, minus the size of the app bar and the size of the "reached bottom" indicator.
      // This will allow the last comment to be scrolled to the top, with the "reached bottom" indicator and the spacer taking up the rest of the space.
      bottomSpacerHeight = deviceHeight - appBarHeight - reachedEndHeight;
      setState(() {});
    }
  }

  bool listenWhen(PostState previous, PostState current) {
    final l10n = GlobalContext.l10n;

    if (previous.status == PostStatus.loading && current.status == PostStatus.success && current.post != null && current.hasReachedCommentEnd) {
      // Check if the post's community is blocked by the user. If so, show a message.
      final blockedCommunities = context.read<ProfileBloc>().state.siteResponse?.myUser?.communityBlocks;
      final isCommunityBlocked = blockedCommunities?.any((c) => c.id == current.post?.community?.id) ?? false;

      if (isCommunityBlocked) showSnackbar(l10n.noVisibleComments);
    }

    return true;
  }

  void listener(BuildContext context, PostState state) {
    final l10n = GlobalContext.l10n;

    if (state.didScrollPositionChange) return;

    if (state.status == PostStatus.success && state.post != null) {
      if (!userChanged) widget.onPostUpdated?.call(state.post!);
      setState(() {});
    }

    if (state.status == PostStatus.failure) {
      showSnackbar(state.errorMessage ?? l10n.missingErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final thunderState = context.read<ThunderBloc>().state;

    originalUser ??= context.read<ProfileBloc>().state.account;

    if (bottomSpacerHeight == null) {
      if (_calculateBottomSpacerTimer != null) _calculateBottomSpacerTimer!.cancel();
      _calculateBottomSpacerTimer = Timer(Duration(milliseconds: 250), _getBottomSpacerHeight);
    }

    return BlocConsumer<PostBloc, PostState>(
      listenWhen: listenWhen,
      listener: listener,
      buildWhen: (previous, current) => !current.didScrollPositionChange,
      builder: (context, state) {
        if (state.status == PostStatus.initial) {
          // This is required because listener does not get called on initial build
          context.read<PostBloc>().add(
                GetPostEvent(
                  post: widget.initialPost,
                  selectedCommentPath: widget.commentPath,
                  highlightedCommentId: widget.highlightedCommentId,
                ),
              );
        }

        final post = state.post ?? widget.initialPost;

        // Check to see if there is a highlighted comment. If there is, check to see if it is visible.
        // If it is not visible, scroll to it.
        final highlightedCommentId = state.highlightedCommentId;
        final highlightedCommentIndex = state.comments.indexWhere((element) => element.comment!.id == highlightedCommentId);

        if (listController.isAttached && highlightedCommentIndex != -1) {
          final visibleRange = listController.visibleRange;

          if (visibleRange != null && (highlightedCommentIndex < (visibleRange.$1 + 3) || highlightedCommentIndex > (visibleRange.$2 - 3))) {
            listController.animateToItem(
              index: highlightedCommentIndex,
              scrollController: scrollController,
              alignment: 0,
              duration: (estimatedDistance) => const Duration(milliseconds: 250),
              curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
            );
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            if (this.highlightedCommentId != null) {
              // If we're viewing a specific comment thread, refresh with that context unless "View All Comments" is pressed
              context.read<PostBloc>().add(GetPostEvent(post: widget.initialPost, selectedCommentPath: widget.commentPath, highlightedCommentId: widget.highlightedCommentId));
            } else {
              context.read<PostBloc>().add(GetPostEvent(post: widget.initialPost));
            }
          },
          edgeOffset: MediaQuery.of(context).padding.top + APP_BAR_HEIGHT, // This offset is placed to allow the correct positioning of the refresh indicator
          child: Scaffold(
            floatingActionButton: _PostPageFAB(post: post, comments: state.comments, scrollController: scrollController, listController: listController),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            body: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: scrollController,
                    cacheExtent: 1000,
                    slivers: [
                      PostPageAppBar(
                        key: appBarKey,
                        viewSource: viewSource,
                        onViewSource: (value) => setState(() => viewSource = value),
                        onReset: () async => await scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized),
                        onCreateCrossPost: () {
                          createCrossPost(
                            context,
                            title: state.post?.name ?? '',
                            url: state.post?.url,
                            text: state.post?.body,
                            postUrl: state.post?.apId,
                          );
                        },
                        onSelectText: () {
                          showSelectableTextModal(
                            context,
                            title: state.post?.name ?? '',
                            text: state.post?.body ?? '',
                          );
                        },
                        onUserChanged: () => userChanged = true,
                        onPostChanged: (post) => context.read<PostBloc>().add(GetPostEvent(post: post)),
                        highlightedCommentId: this.highlightedCommentId,
                        commentPath: widget.commentPath,
                      ),
                      if (state.status == PostStatus.initial || state.status == PostStatus.loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.status == PostStatus.failure)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _PostPageError(
                            onRetry: () {
                              if (this.highlightedCommentId != null) {
                                // If we're viewing a specific comment thread, retry with that context unless "View All Comments" is pressed
                                context.read<PostBloc>().add(GetPostEvent(post: widget.initialPost, selectedCommentPath: widget.commentPath, highlightedCommentId: widget.highlightedCommentId));
                              } else {
                                context.read<PostBloc>().add(GetPostEvent(post: widget.initialPost));
                              }
                            },
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: PostBody(
                            post: state.post ?? widget.initialPost,
                            crossPosts: state.crossPosts,
                            viewSource: viewSource,
                            showCompactPostBody: widget.highlightedCommentId != null,
                          ),
                        ),
                        if (state.status != PostStatus.loading && this.highlightedCommentId != null)
                          SliverToBoxAdapter(
                            child: InkWell(
                              child: Container(
                                height: 60.0,
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor))),
                                child: Row(
                                  spacing: 4.0,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(l10n.viewAllComments, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                    Icon(Icons.arrow_right_alt_rounded),
                                  ],
                                ),
                              ),
                              onTap: () {
                                context.read<PostBloc>().add(const GetPostCommentsEvent(reset: true, commentParentId: null));
                                setState(() => this.highlightedCommentId = null);
                              },
                            ),
                          ),
                        SuperSliverList.builder(
                          itemCount: state.comments.length + 1,
                          listController: listController,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              // This is a placeholder widget to allow the comment scroller to work properly for the first comment
                              // Note: CommentNavigatorFab indexes will be shifted by 1 to account for the placeholder widget
                              return const SizedBox(height: 1);
                            }

                            CommentNode commentNode = state.comments[index - 1];
                            ThunderComment comment = commentNode.comment!;

                            final List<int> collapsedComments = context.read<PostBloc>().state.collapsedComments;

                            bool isCollapsed = collapsedComments.contains(comment.id);
                            bool isHidden = collapsedComments.any((int id) => comment.path.contains('$id') && id != comment.id);

                            return CommentCard(
                              comment: comment,
                              replyCount: commentNode.replies.length,
                              level: commentNode.depth,
                              collapsed: isCollapsed,
                              hidden: isHidden,
                              highlightedCommentId: state.highlightedCommentId,
                              onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.vote, value: voteType)),
                              onSaveAction: (int commentId, bool saved) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.save, value: saved)),
                              onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.delete, value: deleted)),
                              onReplyEditAction: (ThunderComment comment, bool isEdit) {
                                context.read<PostBloc>().add(CommentItemUpdatedEvent(comment: comment));
                              },
                              onCollapseCommentChange: (int commentId, bool collapsed) {
                                context.read<PostBloc>().add(UpdateCollapsedComment(commentId: commentId, collapsed: collapsed));
                                setState(() {});
                              },
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: state.hasReachedCommentEnd == true
                              ? Container(
                                  key: reachedEndKey,
                                  color: theme.dividerColor.withValues(alpha: 0.1),
                                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                                  child: ScalableText(
                                    state.comments.isEmpty ? l10n.noCommentsFound : l10n.endOfComments,
                                    fontScale: thunderState.metadataFontSizeScale,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                )
                              : Visibility(
                                  visible: state.status == PostStatus.success,
                                  child: Container(
                                    height: 100.0,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: const CircularProgressIndicator(),
                                  ),
                                ),
                        ),
                      ],
                      SliverToBoxAdapter(child: SizedBox(height: bottomSpacerHeight)),
                    ],
                  ),
                  if (thunderState.hideTopBarOnScroll)
                    Positioned(
                      child: Container(
                        height: MediaQuery.of(context).padding.top,
                        color: theme.colorScheme.surface,
                      ),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: thunderState.isFabOpen
                        ? Listener(
                            onPointerUp: (details) => context.read<ThunderBloc>().add(const OnFabToggle(false)),
                            child: Container(color: theme.colorScheme.surface.withValues(alpha: 0.95)),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The error widget for the post page.
class _PostPageError extends StatelessWidget {
  final Function() onRetry;

  const _PostPageError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Center(
      child: ErrorMessage(
        title: l10n.unableToLoadPost,
        message: l10n.internetOrInstanceIssues,
        actions: [
          (
            text: l10n.retry,
            action: onRetry,
            loading: false,
          ),
        ],
      ),
    );
  }
}

/// The FAB for the post page.
class _PostPageFAB extends StatefulWidget {
  /// The post information - used for various actions.
  final ThunderPost post;

  /// The list of comments - used for the comment navigator FAB.
  final List<CommentNode> comments;

  /// The list controller - used for the comment navigator FAB.
  final ListController listController;

  /// The scroll controller - used for the comment navigator FAB.
  final ScrollController scrollController;

  const _PostPageFAB({required this.post, required this.comments, required this.scrollController, required this.listController});

  @override
  State<_PostPageFAB> createState() => _PostPageFABState();
}

class _PostPageFABState extends State<_PostPageFAB> {
  @override
  void initState() {
    super.initState();
  }

  void showSortBottomSheet(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final account = context.read<ProfileBloc>().state.account;
    final commentSortType = context.read<PostBloc>().state.commentSortType;

    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        account: account,
        title: l10n.sortOptions,
        onSelect: (selected) async {
          await widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized);
          if (context.mounted) context.read<PostBloc>().add(GetPostCommentsEvent(commentSortType: selected.payload, reset: true));
        },
        previouslySelected: commentSortType,
      ),
    );
  }

  void replyToPost(BuildContext context, ThunderPost? post, {bool postLocked = false}) async {
    final l10n = GlobalContext.l10n;
    final isLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;

    if (postLocked) return showSnackbar(l10n.postLocked);
    if (!isLoggedIn) return showSnackbar(l10n.mustBeLoggedInComment);

    navigateToCreateCommentPage(
      context,
      post: post,
      onCommentSuccess: (comment, userChanged) {
        if (!userChanged) {
          context.read<PostBloc>().add(CommentItemUpdatedEvent(comment: comment));
        }
      },
    );
  }

  void startCommentSearch(BuildContext context) {
    PostFabAction.search.execute(
      override: () {
        final l10n = GlobalContext.l10n;
        final status = context.read<PostBloc>().state.status;

        if (status == PostStatus.searchInProgress) {
          context.read<PostBloc>().add(const EndCommentSearchEvent());
          return;
        }

        showInputDialog<String>(
          context: context,
          title: l10n.searchComments,
          inputLabel: l10n.searchTerm,
          onSubmitted: ({payload, value}) {
            Navigator.of(context).pop();
            Map<int, int> commentSearchResults = {};

            final commentNodes = context.read<PostBloc>().state.commentNodes;

            if (commentNodes != null) {
              final comments = CommentNode.flattenCommentTree(commentNodes);

              for (int index = 0; index < comments.length; index++) {
                final comment = comments[index];
                if (comment.comment?.content.contains(RegExp(value!, caseSensitive: false)) == true) {
                  commentSearchResults[index] = comment.comment!.id;
                }
              }
            }

            if (commentSearchResults.isEmpty) {
              showSnackbar(l10n.noResultsFound);
            } else {
              context.read<PostBloc>().add(StartCommentSearchEvent(commentSearchResults: commentSearchResults));
            }

            return Future.value(null);
          },
          getSuggestions: (_) => [],
          suggestionBuilder: (payload) => Container(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final thunderState = context.read<ThunderBloc>().state;
    final combineNavAndFab = thunderState.combineNavAndFab;
    final isFabSummoned = thunderState.isFabSummoned;
    final singlePressAction = thunderState.postFabSinglePressAction;
    final longPressAction = thunderState.postFabLongPressAction;

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final status = context.select<PostBloc, PostStatus>((bloc) => bloc.state.status);
    final highlightedCommentId = context.select<PostBloc, int?>((bloc) => bloc.state.highlightedCommentId);
    final selectedCommentPath = context.select<PostBloc, String?>((bloc) => bloc.state.selectedCommentPath);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (thunderState.enableCommentNavigation)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CommentNavigatorFab(
                  initialIndex: 0,
                  maxIndex: widget.listController.isAttached ? widget.listController.numberOfItems - 1 : 0,
                  scrollController: widget.scrollController,
                  listController: widget.listController,
                  comments: widget.comments,
                  statusBarHeight: thunderState.hideTopBarOnScroll ? statusBarHeight : 0,
                ),
              ),
            ),
          ),
        if (thunderState.enablePostsFab)
          Padding(
            padding: EdgeInsets.only(right: combineNavAndFab ? 0 : 16, bottom: combineNavAndFab ? 5 : 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isFabSummoned
                  ? GestureFab(
                      centered: combineNavAndFab,
                      distance: combineNavAndFab ? 45 : 60,
                      icon: Icon(
                        status == PostStatus.searchInProgress ? Icons.youtube_searched_for_rounded : singlePressAction.getIcon(postLocked: widget.post.locked),
                        semanticLabel: status == PostStatus.searchInProgress ? l10n.search : singlePressAction.getTitle(context, postLocked: widget.post.locked),
                        size: 35,
                      ),
                      onPressed: status == PostStatus.searchInProgress
                          ? () {
                              context.read<PostBloc>().add(const ContinueCommentSearchEvent());
                            }
                          : () => singlePressAction.execute(
                              context: context,
                              post: widget.post,
                              postId: widget.post.id,
                              highlightedCommentId: highlightedCommentId,
                              selectedCommentPath: selectedCommentPath,
                              override: singlePressAction == PostFabAction.backToTop
                                  ? () => {
                                        widget.listController.animateToItem(
                                          index: 0,
                                          scrollController: widget.scrollController,
                                          alignment: 0,
                                          duration: (estimatedDistance) => const Duration(milliseconds: 250),
                                          curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
                                        ),
                                      }
                                  : singlePressAction == PostFabAction.changeSort
                                      ? () => showSortBottomSheet(context)
                                      : singlePressAction == PostFabAction.replyToPost
                                          ? () => replyToPost(context, widget.post, postLocked: widget.post.locked)
                                          : singlePressAction == PostFabAction.search
                                              ? () => startCommentSearch(context)
                                              : null),
                      onLongPress: () => longPressAction.execute(
                          context: context,
                          post: widget.post,
                          postId: widget.post.id,
                          highlightedCommentId: highlightedCommentId,
                          selectedCommentPath: selectedCommentPath,
                          override: longPressAction == PostFabAction.backToTop
                              ? () => {
                                    widget.listController.animateToItem(
                                      index: 0,
                                      scrollController: widget.scrollController,
                                      alignment: 0,
                                      duration: (estimatedDistance) => const Duration(milliseconds: 250),
                                      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
                                    ),
                                  }
                              : longPressAction == PostFabAction.changeSort
                                  ? () => showSortBottomSheet(context)
                                  : longPressAction == PostFabAction.replyToPost
                                      ? () => replyToPost(context, widget.post, postLocked: widget.post.locked)
                                      : null),
                      children: [
                        if (thunderState.postFabEnableRefresh)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();

                              if (highlightedCommentId != null) {
                                // If we're viewing a specific comment thread, refresh with that context unless "View All Comments" is pressed
                                PostFabAction.refresh.execute(
                                  context: context,
                                  post: widget.post,
                                  postId: widget.post.id,
                                  highlightedCommentId: highlightedCommentId,
                                  selectedCommentPath: selectedCommentPath,
                                );
                              } else {
                                PostFabAction.refresh.execute(
                                  context: context,
                                  post: widget.post,
                                  postId: widget.post.id,
                                );
                              }
                            },
                            title: PostFabAction.refresh.getTitle(context),
                            icon: Icon(PostFabAction.refresh.getIcon()),
                          ),
                        if (thunderState.postFabEnableReplyToPost)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              PostFabAction.replyToPost.execute(
                                override: () => replyToPost(context, widget.post, postLocked: widget.post.locked),
                              );
                            },
                            title: PostFabAction.replyToPost.getTitle(context),
                            icon: Icon(widget.post.locked ? Icons.lock : PostFabAction.replyToPost.getIcon()),
                          ),
                        if (thunderState.enableChangeSort)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              PostFabAction.changeSort.execute(override: () => showSortBottomSheet(context));
                            },
                            title: PostFabAction.changeSort.getTitle(context),
                            icon: Icon(PostFabAction.changeSort.getIcon()),
                          ),
                        if (thunderState.enableBackToTop)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () {
                              PostFabAction.backToTop
                                  .execute(override: () => {widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized)});
                            },
                            title: PostFabAction.backToTop.getTitle(context),
                            icon: Icon(PostFabAction.backToTop.getIcon()),
                          ),
                        if (thunderState.postFabEnableSearch)
                          ActionButton(
                            centered: combineNavAndFab,
                            onPressed: () => startCommentSearch(context),
                            title: status == PostStatus.searchInProgress ? l10n.endSearch : PostFabAction.search.getTitle(context),
                            icon: Icon(status == PostStatus.searchInProgress ? Icons.search_off_rounded : PostFabAction.search.getIcon()),
                          ),
                      ],
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
