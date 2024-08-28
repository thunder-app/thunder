import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:thunder/account/models/account.dart';

import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/comment/models/comment_node.dart';
import 'package:thunder/comment/widgets/comment_card.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
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

  const PostPage({
    super.key,
    required this.initialPostViewMedia,
    this.onPostUpdated,
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

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      // Fetches new comments when the user has scrolled past 70% list
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.7 && context.read<PostBloc>().state.status == PostStatus.success) {
        context.read<PostBloc>().add(const GetPostCommentsEvent());
      }
    });

    // The following logic helps us to set the size of the bottom spacer so that the user can scroll the last comment to the top of the viewport but no further.
    // This must be run some time after the layout has been rendered so we can measure everything.
    // It also must be run after there is something to scroll, and the easiest way to do this is to do it in a scroll listener.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        if (bottomSpacerHeight == null) {
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final thunderState = context.read<ThunderBloc>().state;

    originalUser ??= context.read<AuthBloc>().state.account;

    return PopScope(
      onPopInvoked: (_) {
        if (context.mounted) {
          restoreUser(context, originalUser);
        }
      },
      child: Scaffold(
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
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: thunderState.hideTopBarOnScroll, // Don't apply to top of screen to allow for the status bar colour to extend
          bottom: false,
          child: BlocConsumer<PostBloc, PostState>(
            listener: (context, state) {
              if (state.status == PostStatus.success && state.postView != widget.initialPostViewMedia) {
                if (!userChanged) {
                  widget.onPostUpdated?.call(state.postView!);
                }
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state.status == PostStatus.initial) {
                // This is required because listener does not get called on initial build
                context.read<PostBloc>().add(GetPostEvent(postView: widget.initialPostViewMedia));
              }

              List<CommentNode> flattenedComments = CommentNode.flattenCommentTree(state.commentNodes);

              return CustomScrollView(
                controller: scrollController,
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
                  SliverToBoxAdapter(
                    child: PostSubview(
                      postViewMedia: state.postView ?? widget.initialPostViewMedia,
                      crossPosts: state.crossPosts,
                      viewSource: viewSource,
                    ),
                  ),
                  if (state.status == PostStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SuperSliverList.builder(
                      itemCount: flattenedComments.length,
                      listController: listController,
                      itemBuilder: (BuildContext context, int index) {
                        CommentNode commentNode = flattenedComments[index];
                        CommentView commentView = commentNode.commentView!;

                        bool isCollapsed = collapsedComments.contains(commentView.comment.id);
                        bool isHidden = collapsedComments.any((int id) => commentView.comment.path.contains('$id') && id != commentView.comment.id);

                        return CommentCard(
                          commentView: commentView,
                          replyCount: commentNode.replies.length,
                          level: commentNode.depth,
                          collapsed: isCollapsed,
                          hidden: isHidden,
                          onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.vote, value: voteType)),
                          onSaveAction: (int commentId, bool saved) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.save, value: saved)),
                          onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(CommentActionEvent(commentId: commentId, action: CommentAction.delete, value: deleted)),
                          onReplyEditAction: (CommentView commentView, bool isEdit) async => context.read<PostBloc>().add(CommentItemUpdatedEvent(commentView: commentView)),
                          onReportAction: (int commentId) => showReportCommentActionBottomSheet(context, commentId: commentId),
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
                            color: theme.dividerColor.withOpacity(0.1),
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
                  SliverToBoxAdapter(child: SizedBox(height: bottomSpacerHeight)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
