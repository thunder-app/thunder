import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/bloc/community_bloc_old.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc_old.dart';

class CommentsCardList extends StatefulWidget {
  final List<CommentViewTree>? commentViewTrees;
  final int? personId;
  final bool? hasReachedEnd;
  final bool isOwnComment;
  final bool disableActions;

  final VoidCallback onScrollEndReached;
  final Function(int, int)? onVoteAction;
  final Function(int, bool)? onSaveAction;
  final Function(int, bool)? onDeleteAction;
  final Function(int)? onReportAction;
  final Function(CommentView, bool)? onReplyEditAction;

  const CommentsCardList({
    super.key,
    this.commentViewTrees,
    this.hasReachedEnd,
    required this.personId,
    required this.onScrollEndReached,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onReportAction,
    required this.onReplyEditAction,
    required this.isOwnComment,
    required this.disableActions,
    this.onDeleteAction,
  });

  @override
  State<CommentsCardList> createState() => _CommentsCardListState();
}

class _CommentsCardListState extends State<CommentsCardList> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    // Check to see if the initial load did not load enough items to allow for scrolling to occur and fetches more items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;

      if (context.read<CommunityBloc>().state.hasReachedEnd == false && isScrollable == false) {
        widget.onScrollEndReached();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7) {
      widget.onScrollEndReached();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThunderBloc, ThunderState>(
      listenWhen: (previous, current) => (previous.status == ThunderStatus.refreshing && current.status == ThunderStatus.success),
      listener: (context, state) {},
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          if (widget.personId != null) {
            context.read<UserBloc>().add(GetUserEvent(userId: widget.personId, reset: true));
          } else {
            // context.read<CommunityBloc>().add(GetCommunityPostsEvent(
            //       reset: true,
            //       listingType: widget.communityId != null ? null : widget.listingType,
            //       communityId: widget.listingType != null ? null : widget.communityId,
            //       communityName: widget.listingType != null ? null : widget.communityName,
            //     ));
          }
        },
        child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.commentViewTrees?.length,
            itemBuilder: (context, index) {
              return CommentReference(
                comment: widget.commentViewTrees![index].commentView!,
                onVoteAction: widget.onVoteAction,
                onSaveAction: widget.onSaveAction,
                onDeleteAction: widget.onDeleteAction,
                onReportAction: widget.onReportAction,
                onReplyEditAction: widget.onReplyEditAction,
                isOwnComment: widget.isOwnComment,
              );
            }),
      ),
    );
  }
}
