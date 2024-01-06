import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class CommentSubview extends StatefulWidget {
  final List<CommentViewTree> comments;
  final int level;

  final Function(int, int) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;
  final Function(int) onReportAction;
  final Function(CommentView, bool) onReplyEditAction;

  final PostViewMedia? postViewMedia;
  final int? selectedCommentId;
  final String? selectedCommentPath;
  final int? newlyCreatedCommentId;
  final int? moddingCommentId;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  final bool hasReachedCommentEnd;
  final bool viewFullCommentsRefreshing;
  final DateTime now;

  final List<CommunityModeratorView>? moderators;
  final List<PostView>? crossPosts;

  const CommentSubview({
    super.key,
    required this.comments,
    this.level = 0,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.onReplyEditAction,
    required this.onReportAction,
    this.postViewMedia,
    this.selectedCommentId,
    this.selectedCommentPath,
    this.newlyCreatedCommentId,
    this.moddingCommentId,
    required this.itemScrollController,
    required this.itemPositionsListener,
    this.hasReachedCommentEnd = false,
    this.viewFullCommentsRefreshing = false,
    required this.now,
    required this.moderators,
    required this.crossPosts,
  });

  @override
  State<CommentSubview> createState() => _CommentSubviewState();
}

class _CommentSubviewState extends State<CommentSubview> with SingleTickerProviderStateMixin {
  Set collapsedCommentSet = {}; // Retains the collapsed state of any comments
  bool _animatingOut = false;
  bool _animatingIn = false;
  bool _removeViewFullCommentsButton = false;

  late final AnimationController _fullCommentsAnimation = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> _fullCommentsOffsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, 5),
  ).animate(CurvedAnimation(
    parent: _fullCommentsAnimation,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();
    _fullCommentsOffsetAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed && _animatingOut) {
        _animatingOut = false;
        _removeViewFullCommentsButton = true;
        context.read<PostBloc>().add(const GetPostCommentsEvent(commentParentId: null, viewAllCommentsRefresh: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    if (!widget.viewFullCommentsRefreshing && _removeViewFullCommentsButton) {
      _animatingIn = true;
      _fullCommentsAnimation.reverse();
    }

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.navigateCommentId > 0) {
          widget.itemScrollController.scrollTo(
            index: state.navigateCommentIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        } else if (state.newlyCreatedCommentId != null && state.comments.first.commentView?.comment.id == state.newlyCreatedCommentId) {
          // Only scroll for top level comments since you can comment from anywhere in the comment section.
          widget.itemScrollController.scrollTo(
            index: 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      },
      child: ScrollablePositionedList.builder(
        addSemanticIndexes: false,
        itemScrollController: widget.itemScrollController,
        itemPositionsListener: widget.itemPositionsListener,
        itemCount: getCommentsListLength(),
        itemBuilder: (context, index) {
          if (widget.postViewMedia != null && index == 0) {
            return PostSubview(
              selectedCommentId: widget.selectedCommentId,
              useDisplayNames: state.useDisplayNames,
              postViewMedia: widget.postViewMedia!,
              moderators: widget.moderators,
              crossPosts: widget.crossPosts,
            );
          }
          if (widget.hasReachedCommentEnd == false && widget.comments.isEmpty) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: const CircularProgressIndicator(),
                ),
              ],
            );
          } else {
            return SlideTransition(
              position: _fullCommentsOffsetAnimation,
              child: Column(
                children: [
                  if (widget.selectedCommentId != null && !_animatingIn && index != widget.comments.length + 1)
                    Center(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 15)),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    textStyle: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  onPressed: () {
                                    _animatingOut = true;
                                    _fullCommentsAnimation.forward();
                                  },
                                  child: Text(AppLocalizations.of(context)!.viewAllComments),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 15))
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                        ],
                      ),
                    ),
                  if (index != widget.comments.length + 1)
                    CommentCard(
                      now: widget.now,
                      selectCommentId: widget.selectedCommentId,
                      selectedCommentPath: widget.selectedCommentPath,
                      newlyCreatedCommentId: widget.newlyCreatedCommentId,
                      moddingCommentId: widget.moddingCommentId,
                      commentViewTree: widget.comments[index - 1],
                      collapsedCommentSet: collapsedCommentSet,
                      collapsed: collapsedCommentSet.contains(widget.comments[index - 1].commentView!.comment.id) || widget.level == 2,
                      onSaveAction: (int commentId, bool save) => widget.onSaveAction(commentId, save),
                      onVoteAction: (int commentId, int voteType) => widget.onVoteAction(commentId, voteType),
                      onCollapseCommentChange: (int commentId, bool collapsed) => onCollapseCommentChange(commentId, collapsed),
                      onDeleteAction: (int commentId, bool deleted) => widget.onDeleteAction(commentId, deleted),
                      onReportAction: (int commentId) => widget.onReportAction(commentId),
                      onReplyEditAction: (CommentView commentView, bool isEdit) => widget.onReplyEditAction(commentView, isEdit),
                      moderators: widget.moderators,
                    ),
                  if (index == widget.comments.length + 1) ...[
                    if (widget.hasReachedCommentEnd == true) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: theme.dividerColor.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: ScalableText(
                              widget.comments.isEmpty ? AppLocalizations.of(context)!.noComments : AppLocalizations.of(context)!.reachedTheBottom,
                              fontScale: state.metadataFontSizeScale,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(
                            height: 160,
                          )
                        ],
                      )
                    ] else ...[
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: const CircularProgressIndicator(),
                          ),
                        ],
                      )
                    ]
                  ]
                ],
              ),
            );
          }
        },
      ),
    );
  }

  int getCommentsListLength() {
    if (widget.comments.isEmpty && widget.hasReachedCommentEnd == false) {
      return 2; // Show post and loading indicator since no comments have been fetched yet
    }

    return widget.postViewMedia != null ? widget.comments.length + 2 : widget.comments.length + 1;
  }

  void onCollapseCommentChange(int commentId, bool collapsed) {
    if (collapsed == false && collapsedCommentSet.contains(commentId)) {
      setState(() => collapsedCommentSet.remove(commentId));
    } else if (collapsed == true && !collapsedCommentSet.contains(commentId)) {
      setState(() => collapsedCommentSet.add(commentId));
    }
  }
}
