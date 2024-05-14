import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:thunder/comment/enums/comment_action.dart';

import 'package:thunder/comment/models/comment_node.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/comment/widgets/comment_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/post/widgets/post_page_app_bar.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/text/selectable_text_modal.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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

  /// Whether the post source should be displayed.
  bool viewSource = false;

  /// Keeps track of which comments should be collapsed. When a comment is collapsed, its child comments are hidden.
  List<int> collapsedComments = [];

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;

    bool hideTopBarOnScroll = state.hideTopBarOnScroll;

    return Scaffold(
      body: SafeArea(
        top: hideTopBarOnScroll, // Don't apply to top of screen to allow for the status bar colour to extend
        bottom: false,
        child: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state.status == PostStatus.success && state.postView != widget.initialPostViewMedia) {
              widget.onPostUpdated?.call(state.postView!);
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
                ),
                SliverToBoxAdapter(
                  child: PostSubview(
                    useDisplayNames: false,
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
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}
