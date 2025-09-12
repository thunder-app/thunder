import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/shared/error_message.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/features/post/post.dart';
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

  /// Whether the post source should be displayed.
  bool viewSource = false;

  /// The active account that was selected when the page was opened
  Account? originalUser;

  /// Whether the user changed during the course of viewing the post
  bool userChanged = false;

  /// Whether we have set the initial scroll offset.
  /// This needs to be done after building so the controller is attached
  bool hasSetInitialScroll = false;

  /// The ID of the comment that should be highlighted
  int? highlightedCommentId;

  /// The timer for detecting when scrolling has stopped
  Timer? _updateScrollPositionTimer;

  @override
  void initState() {
    super.initState();

    highlightedCommentId = widget.highlightedCommentId;

    scrollController.addListener(() {
      final state = context.read<PostBloc>().state;
      final isPastThreshold = scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.7;

      // Fetches new comments when the user has scrolled past 70% list
      if (isPastThreshold && state.status == PostStatus.success && !state.hasReachedCommentEnd) {
        context.read<PostBloc>().add(const GetPostCommentsEvent());
      }

      _updateScrollPosition();
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
    _updateScrollPositionTimer?.cancel();
    super.dispose();
  }

  /// Updates the scroll position in the bloc after scrolling has stopped
  void _updateScrollPosition() {
    _updateScrollPositionTimer?.cancel();

    _updateScrollPositionTimer = Timer(const Duration(milliseconds: 150), () {
      context.read<PostBloc>().add(UpdateScrollPosition(scrollPosition: scrollController.position.pixels));
    });
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

    final account = context.read<PostBloc>().account;

    originalUser ??= context.read<ProfileBloc>().state.account;

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
            floatingActionButton: PostPageFAB(post: post, comments: state.comments, scrollController: scrollController, listController: listController),
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
                        SliverList.list(
                          children: [
                            PostBody(
                              post: post,
                              crossPosts: state.crossPosts,
                              viewSource: viewSource,
                              showCompactPostBody: widget.highlightedCommentId != null,
                            ),
                            if (state.status != PostStatus.loading && this.highlightedCommentId != null)
                              InkWell(
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
                          ],
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

                            final commentNode = state.comments[index - 1];
                            final comment = commentNode.comment!;

                            final collapsedComments = context.read<PostBloc>().state.collapsedComments;

                            final isCollapsed = collapsedComments.contains(comment.id);
                            final isHidden = collapsedComments.any((int id) => comment.path.contains('$id') && id != comment.id);

                            return CommentCard(
                              key: ValueKey(comment.id),
                              account: account,
                              comment: comment,
                              onCommentUpdated: (comment) => context.read<PostBloc>().add(CommentItemUpdatedEvent(comment: comment)),
                              onCommentInserted: (comment) => context.read<PostBloc>().add(CommentItemInsertedEvent(comment: comment)),
                              level: commentNode.depth,
                              replies: commentNode.replies.length,
                              collapsed: isCollapsed,
                              hidden: isHidden,
                              highlight: comment.id == state.highlightedCommentId,
                              onCollapse: (int commentId, bool collapsed) {
                                context.read<PostBloc>().add(UpdateCollapsedComment(commentId: commentId, collapsed: collapsed));
                                setState(() {});
                              },
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: _PostPageFeedEnd(
                            key: ValueKey(widget.initialPost.apId),
                            appBarKey: appBarKey,
                            listController: listController,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (thunderState.hideTopBarOnScroll) Positioned(child: Container(height: MediaQuery.of(context).padding.top, color: theme.colorScheme.surface)),
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

/// Displays a widget when the user reaches the end of the comment list.
///
/// If there are additional comments to be loaded, a loading indicator is displayed.
/// Otherwise, a message is displayed saying that no comments were found.
class _PostPageFeedEnd extends StatefulWidget {
  /// The key for the app bar
  final GlobalKey appBarKey;

  /// The list controller
  final ListController listController;

  const _PostPageFeedEnd({super.key, required this.appBarKey, required this.listController});

  @override
  State<_PostPageFeedEnd> createState() => _PostPageFeedEndState();
}

class _PostPageFeedEndState extends State<_PostPageFeedEnd> {
  /// The key for the "reached end" indicator
  final GlobalKey reachedEndKey = GlobalKey();

  /// The height of the bottom spacer
  double? bottomSpacerHeight;

  /// The timer for calculating the bottom spacer height
  Timer? _calculateBottomSpacerTimer;

  // The following logic helps us to set the size of the bottom spacer so that the user can scroll the last comment to the top of the viewport but no further.
  // This must be run some time after the layout has been rendered so we can measure everything.
  Future<void> _getBottomSpacerHeight() async {
    final deviceHeight = MediaQuery.sizeOf(context).height;

    // Get the height of the "reached end" indicator widget
    final reachedEndHeight = (reachedEndKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;

    // Get the height of the app bar
    final renderObject = widget.appBarKey.currentContext?.findRenderObject() as RenderSliverFloatingPersistentHeader?;
    final appBarHeight = renderObject?.geometry!.maxPaintExtent;

    if (appBarHeight != null && reachedEndHeight != null) {
      // We will make the bottom spacer the size of the device height, minus the size of the app bar and the size of the "reached bottom" indicator.
      // This will allow the last comment to be scrolled to the top, with the "reached bottom" indicator and the spacer taking up the rest of the space.
      bottomSpacerHeight = deviceHeight - appBarHeight - reachedEndHeight;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _calculateBottomSpacerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    if (widget.listController.isAttached && widget.listController.visibleRange != null && widget.listController.visibleRange!.$2 <= max(widget.listController.numberOfItems - 10, 0)) {
      return SizedBox(height: height);
    }

    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final comments = context.select<PostBloc, List<CommentNode>>((bloc) => bloc.state.comments);
    final hasReachedCommentEnd = context.select<PostBloc, bool>((bloc) => bloc.state.hasReachedCommentEnd);
    final metadataFontSizeScale = context.select<ThunderBloc, FontScale>((bloc) => bloc.state.metadataFontSizeScale);

    if (bottomSpacerHeight == null) {
      if (_calculateBottomSpacerTimer != null) _calculateBottomSpacerTimer!.cancel();
      _calculateBottomSpacerTimer = Timer(Duration(milliseconds: 250), _getBottomSpacerHeight);
    }

    Widget child = Container(
      height: 100.0,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const CircularProgressIndicator(),
    );

    if (hasReachedCommentEnd == true) {
      child = Container(
        key: reachedEndKey,
        color: theme.dividerColor.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: ScalableText(
          comments.isEmpty ? l10n.noCommentsFound : l10n.endOfComments,
          fontScale: metadataFontSizeScale,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: bottomSpacerHeight ?? height),
      child: child,
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
