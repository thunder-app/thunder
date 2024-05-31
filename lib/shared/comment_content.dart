import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/conditional_parent_widget.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/shared/reply_to_preview_actions.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

import 'comment_card_actions.dart';
import 'comment_header.dart';

class CommentContent extends StatefulWidget {
  final CommentView comment;
  final bool isUserLoggedIn;
  final bool isOwnComment;
  final bool isHidden;
  final bool excludeSemantics;
  final bool disableActions;

  final Function(int, int) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;
  final Function(int) onReportAction;
  final Function(CommentView, bool) onReplyEditAction;

  final int? moddingCommentId;
  final bool viewSource;
  final void Function() onViewSourceToggled;
  final bool selectable;
  final bool showReplyEditorButtons;

  const CommentContent({
    super.key,
    required this.comment,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.onReplyEditAction,
    required this.onReportAction,
    required this.isOwnComment,
    required this.isHidden,
    this.moddingCommentId,
    this.excludeSemantics = false,
    this.disableActions = false,
    required this.viewSource,
    required this.onViewSourceToggled,
    this.selectable = false,
    this.showReplyEditorButtons = false,
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

  final FocusNode _selectableRegionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;
    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      excluding: widget.excludeSemantics,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommentHeader(
              moddingCommentId: widget.moddingCommentId ?? -1,
              comment: widget.comment,
              isOwnComment: widget.isOwnComment,
              isHidden: widget.isHidden,
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
                          padding: EdgeInsets.only(top: 0, right: 8.0, left: 8.0, bottom: (state.showCommentButtonActions && widget.isUserLoggedIn && !widget.disableActions) ? 0.0 : 8.0),
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
                                child: child,
                              );
                            },
                            child: widget.viewSource
                                ? ScalableText(
                                    cleanCommentContent(widget.comment.comment),
                                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                                    fontScale: state.contentFontSizeScale,
                                  )
                                : CommonMarkdownBody(
                                    body: cleanCommentContent(widget.comment.comment),
                                    isComment: true,
                                  ),
                          ),
                        ),
                        if (state.showCommentButtonActions && widget.isUserLoggedIn && !widget.disableActions)
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
                              onViewSourceToggled: widget.onViewSourceToggled,
                              viewSource: widget.viewSource,
                            ),
                          ),
                      ],
                    ),
            ),
            if (widget.showReplyEditorButtons && widget.comment.comment.content.isNotEmpty == true) ...[
              const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: ThunderDivider(sliver: false, padding: false),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: ReplyToPreviewActions(
                  onViewSourceToggled: widget.onViewSourceToggled,
                  viewSource: widget.viewSource,
                  text: cleanCommentContent(widget.comment.comment),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
