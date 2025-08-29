import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/nested_comment_indicator.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/conditional_parent_widget.dart';
import 'package:thunder/src/shared/reply_to_preview_actions.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';

/// A widget that displays the content of a comment
class CommentContent extends StatefulWidget {
  /// The comment to display
  final ThunderComment comment;

  /// Whether the user is logged in
  final bool isUserLoggedIn;

  /// Whether the comment is owned by the current user
  final bool isOwnComment;

  /// Whether the comment is hidden
  final bool isHidden;

  /// Whether to exclude semantics
  final bool excludeSemantics;

  /// Whether to disable actions
  final bool disableActions;

  /// The level of the comment
  final int level;

  /// Whether the comment is dragged
  final bool dragged;

  /// The function to call when a vote is made
  final Function(int commentId, int vote) onVoteAction;

  /// The function to call when a comment is replied to or edited
  final Function(ThunderComment, bool) onReplyEditAction;

  /// Whether to view the source of the comment
  final bool viewSource;

  /// The function to call when the view source is toggled
  final void Function() onViewSourceToggled;

  /// Whether the comment is selectable
  final bool selectable;

  /// Whether to show the reply editor buttons
  final bool showReplyEditorButtons;

  /// The function to call when the selection is changed
  final void Function(String? selection)? onSelectionChanged;

  const CommentContent({
    super.key,
    required this.comment,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onReplyEditAction,
    required this.isOwnComment,
    required this.isHidden,
    this.excludeSemantics = false,
    this.disableActions = false,
    required this.viewSource,
    required this.onViewSourceToggled,
    this.selectable = false,
    this.showReplyEditorButtons = false,
    this.onSelectionChanged,
    this.level = 0,
    this.dragged = false,
  });

  @override
  State<CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  final _selectableRegionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = cleanCommentContent(widget.comment);

    final collapseParentCommentOnGesture = context.select<ThunderBloc, bool>((bloc) => bloc.state.collapseParentCommentOnGesture);
    final showCommentButtonActions = context.select<ThunderBloc, bool>((bloc) => bloc.state.showCommentButtonActions);
    final nestedCommentIndicatorStyle = context.select<ThunderBloc, NestedCommentIndicatorStyle>((bloc) => bloc.state.nestedCommentIndicatorStyle);
    final nestedCommentIndicatorColor = context.select<ThunderBloc, NestedCommentIndicatorColor>((bloc) => bloc.state.nestedCommentIndicatorColor);
    final contentFontSizeScale = context.select<ThunderBloc, FontScale>((bloc) => bloc.state.contentFontSizeScale);

    return Container(
      decoration: widget.dragged ? null : CommentDepthIndicatorDecoration(context, level: widget.level, style: nestedCommentIndicatorStyle, scheme: nestedCommentIndicatorColor),
      child: ExcludeSemantics(
        excluding: widget.excludeSemantics,
        child: Container(
          padding: widget.level > 0 ? EdgeInsets.only(left: (nestedCommentIndicatorStyle == NestedCommentIndicatorStyle.thick ? widget.level + 1 : widget.level) * 4.0) : null,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubicEmphasized,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Divider(height: 1),
                CommentCardHeader(comment: widget.comment, hidden: widget.isHidden),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 130),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (Widget child, Animation<double> animation) => SizeTransition(sizeFactor: animation, child: SlideTransition(position: _offsetAnimation, child: child)),
                  child: (widget.isHidden && collapseParentCommentOnGesture)
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 0.0, right: 8.0, left: 8.0, bottom: (showCommentButtonActions && widget.isUserLoggedIn && !widget.disableActions) ? 0.0 : 8.0),
                              child: ConditionalParentWidget(
                                condition: widget.selectable,
                                parentBuilder: (child) {
                                  return SelectableRegion(
                                    focusNode: _selectableRegionFocusNode,
                                    // See comments on [SelectableTextModal] regarding the next two properties
                                    selectionControls: Platform.isIOS ? cupertinoTextSelectionHandleControls : materialTextSelectionHandleControls,
                                    contextMenuBuilder: (context, selectableRegionState) {
                                      return AdaptiveTextSelectionToolbar.buttonItems(
                                        buttonItems: selectableRegionState.contextMenuButtonItems,
                                        anchors: selectableRegionState.contextMenuAnchors,
                                      );
                                    },
                                    onSelectionChanged: (value) => widget.onSelectionChanged?.call(value?.plainText),
                                    child: child,
                                  );
                                },
                                child: widget.viewSource
                                    ? ScalableText(
                                        content,
                                        style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                                        fontScale: contentFontSizeScale,
                                      )
                                    : CommonMarkdownBody(body: content, isComment: true),
                              ),
                            ),
                            if (showCommentButtonActions && widget.isUserLoggedIn && !widget.disableActions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0, top: 6.0, right: 4.0),
                                child: CommentCardActions(
                                  comment: widget.comment,
                                  onVoteAction: (int commentId, int vote) => widget.onVoteAction(commentId, vote),
                                  isEdit: widget.isOwnComment,
                                  onReplyEditAction: widget.onReplyEditAction,
                                  onViewSourceToggled: widget.onViewSourceToggled,
                                  viewSource: widget.viewSource,
                                ),
                              ),
                          ],
                        ),
                ),
                if (widget.showReplyEditorButtons && widget.comment.content.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: ReplyToPreviewActions(
                      onViewSourceToggled: widget.onViewSourceToggled,
                      viewSource: widget.viewSource,
                      text: content,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
