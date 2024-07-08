// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

// Project imports
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/post/widgets/comment_view.dart';

class PostPageSuccess extends StatefulWidget {
  final PostViewMedia postView;
  final List<CommentViewTree> comments;
  final int? selectedCommentId;
  final String? selectedCommentPath;
  final int? newlyCreatedCommentId;
  final int? moddingCommentId;

  final ScrollController scrollController;
  final ListController listController;
  final bool hasReachedCommentEnd;

  final bool viewFullCommentsRefreshing;

  final List<PostView>? crossPosts;
  final bool viewSource;

  const PostPageSuccess({
    super.key,
    required this.postView,
    this.comments = const [],
    required this.scrollController,
    required this.listController,
    this.hasReachedCommentEnd = false,
    this.selectedCommentId,
    this.selectedCommentPath,
    this.newlyCreatedCommentId,
    this.moddingCommentId,
    this.viewFullCommentsRefreshing = false,
    required this.crossPosts,
    required this.viewSource,
  });

  @override
  State<PostPageSuccess> createState() => _PostPageSuccessState();
}

class _PostPageSuccessState extends State<PostPageSuccess> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.scrollController.addListener(_onScroll));
  }

  void _onScroll() {
    // We don't want to trigger comment fetch when looking at a comment context.
    // This also fixes a weird behavior that can happen when if the fetch triggers
    // right before you click view all comments. The fetch for all comments won't happen.
    if (widget.selectedCommentId != null || widget.hasReachedCommentEnd) {
      return;
    }
    if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent * 0.6) {
      context.read<PostBloc>().add(const GetPostCommentsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CommentSubview(
            viewFullCommentsRefreshing: widget.viewFullCommentsRefreshing,
            moddingCommentId: widget.moddingCommentId,
            selectedCommentId: widget.selectedCommentId,
            selectedCommentPath: widget.selectedCommentPath,
            newlyCreatedCommentId: widget.newlyCreatedCommentId,
            scrollController: widget.scrollController,
            listController: widget.listController,
            postViewMedia: widget.postView,
            comments: widget.comments,
            hasReachedCommentEnd: widget.hasReachedCommentEnd,
            onVoteAction: (int commentId, int voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
            onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
            onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
            onReportAction: (int commentId) {
              showReportCommentActionBottomSheet(
                context,
                commentId: commentId,
              );
            },
            onReplyEditAction: (CommentView commentView, bool isEdit) async => navigateToCreateCommentPage(
              context,
              commentView: isEdit ? commentView : null,
              parentCommentView: isEdit ? null : commentView,
              onCommentSuccess: (commentView, userChanged) {
                if (!userChanged) {
                  context.read<PostBloc>().add(UpdateCommentEvent(commentView: commentView, isEdit: isEdit));
                }
              },
            ),
            crossPosts: widget.crossPosts,
            viewSource: widget.viewSource,
          ),
        ),
      ],
    );
  }
}
