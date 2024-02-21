import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class FeedCommentList extends StatelessWidget {
  final bool tabletMode;
  final List<int>? queuedForRemoval;
  final List<CommentView> commentViews;

  const FeedCommentList({
    super.key,
    required this.commentViews,
    required this.tabletMode,
    this.queuedForRemoval,
  });

  @override
  Widget build(BuildContext context) {
    final ThunderState thunderState = context.read<ThunderBloc>().state;
    final FeedState state = context.read<FeedBloc>().state;

    // Widget representing the list of comments on the feed (user)
    return SliverMasonryGrid.count(
      crossAxisCount: tabletMode ? 2 : 1,
      crossAxisSpacing: 40,
      mainAxisSpacing: 0,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedSwitcher(
          switchOutCurve: Curves.ease,
          duration: const Duration(milliseconds: 0),
          reverseDuration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: const Interval(0.5, 1.0)),
              ),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.2, 0), end: const Offset(0, 0)).animate(animation),
                child: SizeTransition(
                  sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.25),
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: queuedForRemoval?.contains(commentViews[index].comment.id) != true
              ? CommentReference(
                  comment: commentViews[index],
                  now: DateTime.now(),
                  onVoteAction: (int commentId, int voteType) => {},
                  onSaveAction: (int commentId, bool save) => {},
                  onDeleteAction: (int commentId, bool deleted) => {},
                  onReportAction: (int commentId) {},
                  onReplyEditAction: (CommentView commentView, bool isEdit) {},
                  isOwnComment: false,
                )
              : null,
        );
      },
      childCount: commentViews.length,
    );
  }
}
