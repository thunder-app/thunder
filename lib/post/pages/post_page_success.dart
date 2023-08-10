import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_view.dart';

import '../../thunder/bloc/thunder_bloc.dart';
import '../widgets/create_comment_modal.dart';

class PostPageSuccess extends StatefulWidget {
  final PostViewMedia postView;
  final List<CommentViewTree> comments;
  final int? selectedCommentId;
  final String? selectedCommentPath;
  final int? moddingCommentId;

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final bool hasReachedCommentEnd;

  final bool viewFullCommentsRefreshing;

  final List<CommunityModeratorView>? moderators;

  const PostPageSuccess({
    super.key,
    required this.postView,
    this.comments = const [],
    required this.itemScrollController,
    required this.itemPositionsListener,
    this.hasReachedCommentEnd = false,
    this.selectedCommentId,
    this.selectedCommentPath,
    this.moddingCommentId,
    this.viewFullCommentsRefreshing = false,
    required this.moderators,
  });

  @override
  State<PostPageSuccess> createState() => _PostPageSuccessState();
}

class _PostPageSuccessState extends State<PostPageSuccess> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.itemScrollController.primaryScrollController?.addListener(_onScroll));
  }

  void _onScroll() {
    // We don't want to trigger comment fetch when looking at a comment context.
    // This also fixes a weird behavior that can happen when if the fetch triggers
    // right before you click view all comments. The fetch for all comments won't happen.
    if (widget.selectedCommentId != null || widget.hasReachedCommentEnd) {
      return;
    }
    if ((widget.itemScrollController.primaryScrollController?.position.pixels ?? 0) >= (widget.itemScrollController.primaryScrollController?.position.maxScrollExtent ?? 0) * 0.6) {
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
            itemScrollController: widget.itemScrollController,
            itemPositionsListener: widget.itemPositionsListener,
            postViewMedia: widget.postView,
            comments: widget.comments,
            hasReachedCommentEnd: widget.hasReachedCommentEnd,
            onVoteAction: (int commentId, VoteType voteType) => context.read<PostBloc>().add(VoteCommentEvent(commentId: commentId, score: voteType)),
            onSaveAction: (int commentId, bool save) => context.read<PostBloc>().add(SaveCommentEvent(commentId: commentId, save: save)),
            onDeleteAction: (int commentId, bool deleted) => context.read<PostBloc>().add(DeleteCommentEvent(deleted: deleted, commentId: commentId)),
            onReplyEditAction: (CommentView commentView, bool isEdit) {
              HapticFeedback.mediumImpact();
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
                        child: CreateCommentModal(commentView: commentView, isEdit: isEdit),
                      ),
                    ),
                  );
                },
              );
            },
            moderators: widget.moderators,
          ),
        ),
      ],
    );
  }
}
