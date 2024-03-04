import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

import 'comment_card_actions.dart';
import 'comment_header.dart';

class CommentContent extends StatefulWidget {
  final CommentView comment;
  final DateTime now;
  final bool isUserLoggedIn;
  final bool isOwnComment;
  final bool isHidden;
  final bool excludeSemantics;
  final bool showActionBar;

  final Function(int, int) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;
  final Function(int) onReportAction;
  final Function(CommentView, bool) onReplyEditAction;

  final int? moddingCommentId;
  final List<CommunityModeratorView>? moderators;

  const CommentContent({
    super.key,
    required this.comment,
    required this.now,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.onReplyEditAction,
    required this.onReportAction,
    required this.isOwnComment,
    required this.isHidden,
    this.moddingCommentId,
    this.moderators,
    this.excludeSemantics = false,
    this.showActionBar = true,
  });

  @override
  State<CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for comment collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;
    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

    return ExcludeSemantics(
      excluding: widget.excludeSemantics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CommentHeader(
            moddingCommentId: widget.moddingCommentId ?? -1,
            comment: widget.comment,
            now: widget.now,
            isOwnComment: widget.isOwnComment,
            isHidden: widget.isHidden,
            moderators: widget.moderators ?? [],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 130),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: child,
                ),
              );
            },
            child: (widget.isHidden && collapseParentCommentOnGesture)
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 0, right: 8.0, left: 8.0, bottom: (state.showCommentButtonActions && widget.isUserLoggedIn) ? 0.0 : 8.0),
                        child: CommonMarkdownBody(body: widget.comment.comment.content, isComment: true),
                      ),
                      if (state.showCommentButtonActions && widget.isUserLoggedIn && widget.showActionBar)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, top: 6, right: 4.0),
                          child: CommentCardActions(
                            commentView: widget.comment,
                            onVoteAction: (int commentId, int vote) => widget.onVoteAction(commentId, vote),
                            isEdit: widget.isOwnComment,
                            onSaveAction: widget.onSaveAction,
                            onDeleteAction: widget.onDeleteAction,
                            onReplyEditAction: widget.onReplyEditAction,
                            onReportAction: widget.onReportAction,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
