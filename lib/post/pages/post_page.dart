import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/comment/models/comment_node.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/gesture_fab.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/comment/widgets/comment_card.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/post_page_app_bar.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/shared/comment_navigator_fab.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/shared/text/selectable_text_modal.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/utils/restore_user.dart';

/// A page that displays the post details and comments associated with a post.
class PostPage extends StatefulWidget {
  /// The initial [PostViewMedia] that should be displayed in the page.
  /// When a post action is performed, the post bloc's [postView] is updated.
  /// Additionally, the [onPostUpdated] function is called to update the post in the feed.
  final PostViewMedia initialPostViewMedia;

  /// Called whenever the post is updated. Used to update the post in the feed.
  final Function(PostViewMedia)? onPostUpdated;

  /// The ID of the comment that should be initially highlighted.
  final int? highlightedCommentId;

  /// The path of the comment that should be initially highlighted.
  final String? commentPath;

  const PostPage({
    super.key,
    required this.initialPostViewMedia,
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

  /// Keeps track of which comments should be collapsed. When a comment is collapsed, its child comments are hidden.
  List<int> collapsedComments = [];

  /// The active account that was selected when the page was opened
  Account? originalUser;

  /// Whether the user changed during the course of viewing the post
  bool userChanged = false;

  /// The height of the bottom spacer
  double? bottomSpacerHeight;

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
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    listController.dispose();
    _calculateBottomSpacerTimer?.cancel();
    super.dispose();
  }

  void showSortBottomSheet(BuildContext context, PostState state) {
    final l10n = AppLocalizations.of(context)!;

    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => CommentSortPicker(
        title: l10n.sortOptions,
        onSelect: (selected) async {
          await scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized);
          if (context.mounted) context.read<PostBloc>().add(GetPostCommentsEvent(sortType: selected.payload, reset: true));
        },
        previouslySelected: state.sortType,
        minimumVersion: LemmyClient.instance.version,
      ),
    );
  }

  void replyToPost(BuildContext context, PostViewMedia? postViewMedia, {bool postLocked = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<AuthBloc>().state;

    if (postLocked) return showSnackbar(l10n.postLocked);
    if (!state.isLoggedIn) return showSnackbar(l10n.mustBeLoggedInComment);

    navigateToCreateCommentPage(
      context,
      postViewMedia: postViewMedia,
      onCommentSuccess: (commentView, userChanged) {
        if (!userChanged) {
          context.read<PostBloc>().add(CommentItemUpdatedEvent(commentView: commentView));
        }
      },
    );
  }

  void startCommentSearch(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<PostBloc>().state;

    PostFabAction.search.execute(
      override: () {
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
            getSuggestions: (_) => [],
            suggestionBuilder: (payload) => Container(),
          );
        }
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final thunderState = context.read<ThunderBloc>().state;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    originalUser ??= context.read<AuthBloc>().state.account;

    if (bottomSpacerHeight == null) {
      if (_calculateBottomSpacerTimer != null) _calculateBottomSpacerTimer!.cancel();
      _calculateBottomSpacerTimer = Timer(Duration(milliseconds: 250), _getBottomSpacerHeight);
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (context.mounted) {
          restoreUser(context, originalUser);
        }
      },
      child: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state.status == PostStatus.success && state.postView != widget.initialPostViewMedia && state.postView != null) {
            if (!userChanged) {
              widget.onPostUpdated?.call(state.postView!);
            }
            setState(() {});
          }
        },
        builder: (context, state) {
          if (state.status == PostStatus.initial) {
            // This is required because listener does not get called on initial build
            context.read<PostBloc>().add(
                  GetPostEvent(
                    postView: widget.initialPostViewMedia,
                    selectedCommentPath: widget.commentPath,
                    selectedCommentId: widget.highlightedCommentId,
                  ),
                );
          }

          List<CommentNode> flattenedComments = CommentNode.flattenCommentTree(state.commentNodes);

          final combineNavAndFab = thunderState.combineNavAndFab;
          final isFabSummoned = thunderState.isFabSummoned;

          final singlePressAction = thunderState.postFabSinglePressAction;
          final longPressAction = thunderState.postFabLongPressAction;

          final post = state.postView?.postView.post ?? widget.initialPostViewMedia.postView.post;

          // Check to see if there is a highlighted comment. If there is, check to see if it is visible.
          // If it is not visible, scroll to it.
          final highlightedCommentId = state.newlyCreatedCommentId;
          final highlightedCommentIndex = flattenedComments.indexWhere((element) => element.commentView!.comment.id == highlightedCommentId);

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

          return Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: CommentNavigatorFab(
                        initialIndex: 0,
                        maxIndex: listController.isAttached ? listController.numberOfItems - 1 : 0,
                        scrollController: scrollController,
                        listController: listController,
                        comments: flattenedComments,
                        statusBarHeight: thunderState.hideTopBarOnScroll ? statusBarHeight : 0,
                      ),
                    ),
                  ),
                ),
                if (thunderState.enablePostsFab)
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
                                state.status == PostStatus.searchInProgress ? Icons.youtube_searched_for_rounded : singlePressAction.getIcon(postLocked: post.locked),
                                semanticLabel: state.status == PostStatus.searchInProgress ? l10n.search : singlePressAction.getTitle(context, postLocked: post.locked),
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
                                                listController.animateToItem(
                                                  index: 0,
                                                  scrollController: scrollController,
                                                  alignment: 0,
                                                  duration: (estimatedDistance) => const Duration(milliseconds: 250),
                                                  curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
                                                ),
                                              }
                                          : singlePressAction == PostFabAction.changeSort
                                              ? () => showSortBottomSheet(context, state)
                                              : singlePressAction == PostFabAction.replyToPost
                                                  ? () => replyToPost(context, widget.initialPostViewMedia, postLocked: post.locked)
                                                  : singlePressAction == PostFabAction.search
                                                      ? () => startCommentSearch(context)
                                                      : null),
                              onLongPress: () => longPressAction.execute(
                                  context: context,
                                  postView: state.postView,
                                  postId: state.postId,
                                  selectedCommentId: state.selectedCommentId,
                                  selectedCommentPath: state.selectedCommentPath,
                                  override: longPressAction == PostFabAction.backToTop
                                      ? () => {
                                            listController.animateToItem(
                                              index: 0,
                                              scrollController: scrollController,
                                              alignment: 0,
                                              duration: (estimatedDistance) => const Duration(milliseconds: 250),
                                              curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
                                            ),
                                          }
                                      : longPressAction == PostFabAction.changeSort
                                          ? () => showSortBottomSheet(context, state)
                                          : longPressAction == PostFabAction.replyToPost
                                              ? () => replyToPost(context, widget.initialPostViewMedia, postLocked: post.locked)
                                              : null),
                              children: [
                                if (thunderState.postFabEnableRefresh)
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
                                if (thunderState.postFabEnableReplyToPost)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact();
                                      PostFabAction.replyToPost.execute(
                                        override: () => replyToPost(context, widget.initialPostViewMedia, postLocked: post.locked),
                                      );
                                    },
                                    title: PostFabAction.replyToPost.getTitle(context),
                                    icon: Icon(post.locked ? Icons.lock : PostFabAction.replyToPost.getIcon()),
                                  ),
                                if (thunderState.enableChangeSort)
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
                                if (thunderState.enableBackToTop)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () {
                                      PostFabAction.backToTop
                                          .execute(override: () => {scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized)});
                                    },
                                    title: PostFabAction.backToTop.getTitle(context),
                                    icon: Icon(
                                      PostFabAction.backToTop.getIcon(),
                                    ),
                                  ),
                                if (thunderState.postFabEnableSearch)
                                  ActionButton(
                                    centered: combineNavAndFab,
                                    onPressed: () => startCommentSearch(context),
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
                            title: state.postView?.postView.post.name ?? '',
                            url: state.postView?.postView.post.url,
                            text: state.postView?.postView.post.body,
                            postUrl: state.postView?.postView.post.apId,
                          );
                        },
                        onSelectText: () {
                          showSelectableTextModal(
                            context,
                            title: state.postView?.postView.post.name ?? '',
                            text: state.postView?.postView.post.body ?? '',
                          );
                        },
                        onUserChanged: () => userChanged = true,
                        onPostChanged: (newPostViewMedia) => context.read<PostBloc>().add(GetPostEvent(postView: newPostViewMedia)),
                      ),
                      if (state.status == PostStatus.loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: PostSubview(
                            postViewMedia: state.postView ?? widget.initialPostViewMedia,
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
                                context.read<PostBloc>().add(const GetPostCommentsEvent(reset: true, commentParentId: null, viewAllCommentsRefresh: true));
                                setState(() => this.highlightedCommentId = null);
                              },
                            ),
                          ),
                        SuperSliverList.builder(
                          itemCount: flattenedComments.length + 1,
                          listController: listController,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              // This is a placeholder widget to allow the comment scroller to work properly for the first comment
                              // Note: CommentNavigatorFab indexes will be shifted by 1 to account for the placeholder widget
                              return const SizedBox(height: 1);
                            }

                            CommentNode commentNode = flattenedComments[index - 1];
                            CommentView commentView = commentNode.commentView!;

                            bool isCollapsed = collapsedComments.contains(commentView.comment.id);
                            bool isHidden = collapsedComments.any((int id) => commentView.comment.path.contains('$id') && id != commentView.comment.id);

                            return CommentCard(
                              commentView: commentView,
                              replyCount: commentNode.replies.length,
                              level: commentNode.depth,
                              collapsed: isCollapsed,
                              hidden: isHidden,
                              newlyCreatedCommentId: state.newlyCreatedCommentId ?? this.highlightedCommentId,
                              onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.vote, value: voteType)),
                              onSaveAction: (int commentId, bool saved) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.save, value: saved)),
                              onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.delete, value: deleted)),
                              onReplyEditAction: (CommentView commentView, bool isEdit) {
                                context.read<PostBloc>().add(CommentItemUpdatedEvent(commentView: commentView));
                              },
                              onCollapseCommentChange: (int commentId, bool collapsed) {
                                if (collapsed) {
                                  collapsedComments.add(commentId);
                                } else {
                                  collapsedComments.remove(commentId);
                                }

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
                                    flattenedComments.isEmpty ? l10n.noCommentsFound : l10n.endOfComments,
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
          );
        },
      ),
    );
  }
}
