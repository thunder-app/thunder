import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/comment/models/comment_node.dart';
import 'package:thunder/comment/widgets/comment_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/post_view.dart';

/// A page that displays the post details and comments associated with a post.
class PostPage extends StatefulWidget {
  /// The [PostViewMedia] that should be displayed in the page.
  final PostViewMedia postViewMedia;

  const PostPage({
    super.key,
    required this.postViewMedia,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  /// Creates a [ScrollController] that can be used to control the scroll position of the page.
  final ScrollController scrollController = ScrollController();

  /// Creates a [ListController] that can be used to control the list of items in the page.
  final ListController listController = ListController();

  /// Keeps track of which comments should be collapsed. When a comment is collapsed, its child comments are hidden.
  List<int> collapsedComments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state.status == PostStatus.initial) {
              // This is required because listener does not get called on initial build
              context.read<PostBloc>().add(GetPostEvent(postView: widget.postViewMedia));
            }

            List<CommentNode> flattenedComments = CommentNode.flattenCommentTree(state.commentNodes);

            return CustomScrollView(
              controller: scrollController,
              slivers: [
                const SliverAppBar(),
                SliverToBoxAdapter(
                  child: PostSubview(
                    useDisplayNames: false,
                    postViewMedia: widget.postViewMedia,
                    moderators: const [],
                    crossPosts: const [],
                    viewSource: false,
                  ),
                ),
                SuperSliverList.builder(
                  itemCount: flattenedComments.length,
                  listController: listController,
                  itemBuilder: (BuildContext context, int index) {
                    CommentNode commentNode = flattenedComments[index];
                    CommentView commentView = commentNode.commentView!;

                    bool isCollapsed = collapsedComments.contains(commentView.comment.id);
                    bool isHidden = collapsedComments.any((int id) => commentView.comment.path.contains('$id') && id != commentView.comment.id);

                    return CommentCard(
                      now: DateTime.now().toUtc(),
                      commentView: commentView,
                      replyCount: commentNode.replies.length,
                      level: commentNode.depth,
                      collapsed: isCollapsed,
                      hidden: isHidden,
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
