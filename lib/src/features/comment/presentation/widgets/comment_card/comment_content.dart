import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays the content of a comment.
class CommentContent extends StatefulWidget {
  /// The account
  final Account account;

  /// The comment to display
  final ThunderComment comment;

  /// Whether the comment is hidden
  final bool hidden;

  /// Whether to exclude semantics
  final bool excludeSemantics;

  /// The level of the comment
  final int level;

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
    required this.account,
    required this.comment,
    required this.hidden,
    this.excludeSemantics = false,
    required this.viewSource,
    required this.onViewSourceToggled,
    this.selectable = false,
    this.showReplyEditorButtons = false,
    this.onSelectionChanged,
    this.level = 0,
  });

  @override
  State<CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);

  late final _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0.0)).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

  final _selectableRegionFocusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _selectableRegionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = cleanCommentContent(widget.comment);

    final collapseParentCommentOnGesture = context.select<CommentPreferencesCubit, bool>((cubit) => cubit.state.collapseParentCommentOnGesture);
    final nestedCommentIndicatorStyle = context.select<CommentPreferencesCubit, NestedCommentIndicatorStyle>((cubit) => cubit.state.nestedCommentIndicatorStyle);
    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale);

    return ExcludeSemantics(
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
              CommentCardHeader(account: widget.account, comment: widget.comment, hidden: widget.hidden),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 130),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) => SizeTransition(
                  sizeFactor: animation,
                  child: SlideTransition(position: _offsetAnimation, child: child),
                ),
                child: (widget.hidden && collapseParentCommentOnGesture)
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 0.0, right: 8.0, left: 8.0, bottom: 8.0),
                            child: ThunderConditionalParent(
                              condition: widget.selectable,
                              parentBuilder: (child) {
                                return SelectableRegion(
                                  focusNode: _selectableRegionFocusNode,
                                  // See comments on [SelectableTextModal] regarding the next two properties
                                  selectionControls: Platform.isIOS ? cupertinoTextSelectionHandleControls : materialTextSelectionHandleControls,
                                  contextMenuBuilder: (context, selectableRegionState) {
                                    return AdaptiveTextSelectionToolbar.buttonItems(buttonItems: selectableRegionState.contextMenuButtonItems, anchors: selectableRegionState.contextMenuAnchors);
                                  },
                                  onSelectionChanged: (value) => widget.onSelectionChanged?.call(value?.plainText),
                                  child: child,
                                );
                              },
                              child: widget.viewSource
                                  ? ThunderScalableText(
                                      content,
                                      style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                                      textScaleFactor: contentFontSizeScale.textScaleFactor,
                                    )
                                  : CommonMarkdownBody(body: content, isComment: true),
                            ),
                          ),
                        ],
                      ),
              ),
              if (widget.showReplyEditorButtons && widget.comment.content.isNotEmpty == true)
                ThunderPreviewActionRow(
                  viewSource: widget.viewSource,
                  onViewSourceToggled: widget.onViewSourceToggled,
                  text: content,
                  viewSourceLabel: GlobalContext.l10n.viewSource,
                  viewOriginalLabel: GlobalContext.l10n.viewOriginal,
                  copyLabel: GlobalContext.l10n.copyText,
                  copiedMessage: GlobalContext.l10n.copiedToClipboard,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
