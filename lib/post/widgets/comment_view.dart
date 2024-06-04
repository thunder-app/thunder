import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
  final ScrollController scrollController;
  final ListController listController;

  final bool hasReachedCommentEnd;
  final bool viewFullCommentsRefreshing;

  final List<PostView>? crossPosts;
  final bool viewSource;

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
    required this.scrollController,
    required this.listController,
    this.hasReachedCommentEnd = false,
    this.viewFullCommentsRefreshing = false,
    required this.crossPosts,
    required this.viewSource,
  });

  @override
  State<CommentSubview> createState() => _CommentSubviewState();
}

class _CommentSubviewState extends State<CommentSubview> with SingleTickerProviderStateMixin {
  Set collapsedCommentSet = {}; // Retains the collapsed state of any comments
  bool _animatingOut = false;
  bool _animatingIn = false;
  bool _removeViewFullCommentsButton = false;
  bool _scrolledToComment = false;
  double? _bottomSpacerHeight;
  final GlobalKey _listKey = GlobalKey();
  final GlobalKey _lastCommentKey = GlobalKey();
  final GlobalKey _reachedBottomKey = GlobalKey();

  late final AnimationController _fullCommentsAnimation = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> _fullCommentsOffsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, 15),
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

    // The following logic helps us to set the size of the bottom spacer so that the user can scroll the last comment
    // to the top of the viewport but no further.
    // This must be run some time after the layout has been rendered so we can measure everything.
    // It also must be run after there is something to scroll, and the easiest way to do this is to do it in a scroll listener.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.scrollController.addListener(() {
        if (_bottomSpacerHeight == null && _lastCommentKey.currentContext != null) {
          final double? lastCommentHeight = (_lastCommentKey.currentContext!.findRenderObject() as RenderBox?)?.size.height;
          final double? listHeight = (_listKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;
          final double? reachedBottomHeight = (_reachedBottomKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;

          if (lastCommentHeight != null && listHeight != null && reachedBottomHeight != null) {
            // We will make the bottom spacer the size of the list height, minus the size of the two other widgets.
            // This will allow the last comment to be scrolled to the top, with the "reached bottom" indicator and the spacer
            // taking up the rest of the space.
            _bottomSpacerHeight = max(160, listHeight - lastCommentHeight - reachedBottomHeight);
            setState(() {});
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_scrolledToComment && widget.selectedCommentId != null && widget.comments.isNotEmpty) {
      _scrolledToComment = true;
      // If we are looking at a comment context, scroll to the first comment.
      // The delay is purely for aesthetics and is not required for the logic to work.
      Future.delayed(const Duration(milliseconds: 250), () {
        widget.listController.animateToItem(
          index: 1,
          scrollController: widget.scrollController,
          alignment: 0,
          duration: (estimatedDistance) => const Duration(milliseconds: 250),
          curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
        );
      });
    }

    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    if (!widget.viewFullCommentsRefreshing && _removeViewFullCommentsButton) {
      _animatingIn = true;
      _fullCommentsAnimation.reverse();
    }

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.navigateCommentId > 0) {
          widget.listController.animateToItem(
            index: state.navigateCommentIndex,
            scrollController: widget.scrollController,
            alignment: 0,
            duration: (estimatedDistance) => const Duration(milliseconds: 250),
            curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
          );
        } else if (state.newlyCreatedCommentId != null && state.comments.first.commentView?.comment.id == state.newlyCreatedCommentId) {
          // Only scroll for top level comments since you can comment from anywhere in the comment section.
          widget.listController.animateToItem(
            index: 1,
            scrollController: widget.scrollController,
            alignment: 0,
            duration: (estimatedDistance) => const Duration(milliseconds: 250),
            curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
          );
        }
      },
      child: SuperListView.builder(
        key: _listKey,
        addSemanticIndexes: false,
        listController: widget.listController,
        controller: widget.scrollController,
        itemCount: getCommentsListLength(),
        itemBuilder: (context, index) {
          if (widget.postViewMedia != null && index == 0) {
            return Column(
              children: [
                PostSubview(
                  selectedCommentId: widget.selectedCommentId,
                  useDisplayNames: state.useDisplayNames,
                  postViewMedia: widget.postViewMedia!,
                  crossPosts: widget.crossPosts,
                  viewSource: widget.viewSource,
                ),
                if (widget.selectedCommentId != null && !_animatingIn && index <= widget.comments.length)
                  Center(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Padding(padding: EdgeInsets.only(left: 15)),
                            Expanded(
                              child: AnimatedOpacity(
                                opacity: _removeViewFullCommentsButton ? 0 : 1,
                                duration: const Duration(milliseconds: 500),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    textStyle: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() => _animatingOut = true);
                                    _fullCommentsAnimation.forward();
                                  },
                                  child: Text(AppLocalizations.of(context)!.viewAllComments),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(right: 15))
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                      ],
                    ),
                  ),
              ],
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
                  if (index <= widget.comments.length)
                    CommentCard(
                      key: index == widget.comments.length ? _lastCommentKey : null,
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
                    ),
                  if (index == widget.comments.length + 1) ...[
                    if (widget.hasReachedCommentEnd == true) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            key: _reachedBottomKey,
                            color: theme.dividerColor.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: ScalableText(
                              widget.comments.isEmpty ? AppLocalizations.of(context)!.noComments : AppLocalizations.of(context)!.reachedTheBottom,
                              fontScale: state.metadataFontSizeScale,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
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
                  ],
                  if (index == widget.comments.length + 2)
                    SizedBox(
                      // Initially give this spacer more room than it needs.
                      // When the user scrolls, we will set this to a more reasonable fixed height.
                      height: widget.hasReachedCommentEnd ? _bottomSpacerHeight ?? MediaQuery.of(context).size.height : 160,
                    ),
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

    return widget.postViewMedia != null ? widget.comments.length + 3 : widget.comments.length + 2;
  }

  void onCollapseCommentChange(int commentId, bool collapsed) {
    if (collapsed == false && collapsedCommentSet.contains(commentId)) {
      setState(() => collapsedCommentSet.remove(commentId));
    } else if (collapsed == true && !collapsedCommentSet.contains(commentId)) {
      setState(() => collapsedCommentSet.add(commentId));
    }
  }
}
