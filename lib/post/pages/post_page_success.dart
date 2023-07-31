import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';

class PostPageSuccess extends StatefulWidget {
  final PostViewMedia postView;
  final List<CommentViewTree> comments;
  final int? selectedCommentId;
  final String? selectedCommentPath;
  final int? moddingCommentId;

  final ScrollController scrollController;
  final bool hasReachedCommentEnd;

  final bool viewFullCommentsRefreshing;

  final FullCommunityView? community;

  const PostPageSuccess({
    super.key,
    required this.postView,
    this.comments = const [],
    required this.scrollController,
    this.hasReachedCommentEnd = false,
    this.selectedCommentId,
    this.selectedCommentPath,
    this.moddingCommentId,
    this.viewFullCommentsRefreshing = false,
    required this.community,
  });

  @override
  State<PostPageSuccess> createState() => _PostPageSuccessState();
}

class _PostPageSuccessState extends State<PostPageSuccess> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // We don't want to trigger comment fetch when looking at a comment context.
    // This also fixes a weird behavior that can happen when if the fetch triggers
    // right before you click view all comments. The fetch for all comments won't happen.
    if (widget.selectedCommentId != null) {
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
            now: DateTime.now().toUtc(),
            scrollController: widget.scrollController,
            postViewMedia: widget.postView,
            comments: widget.comments,
            hasReachedCommentEnd: widget.hasReachedCommentEnd,
            onVoteAction: (int commentId, VoteType voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
            onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
            onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
            community: widget.community,
          ),
        ),
      ],
    );
  }
}
