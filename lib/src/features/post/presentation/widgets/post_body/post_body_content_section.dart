import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

/// Displays the expandable markdown or source body for a post.
class PostBodyContentSection extends StatelessWidget {
  const PostBodyContentSection({
    super.key,
    required this.controller,
    required this.post,
    required this.viewSource,
    required this.selectable,
    required this.showReplyEditorButtons,
    required this.hideNsfwPreviews,
    required this.contentFontSizeScale,
    required this.focusNode,
    required this.onExpand,
    this.onSelectionChanged,
  });

  /// Controller shared with the rest of the expandable post body.
  final ExpandableController controller;

  /// Post whose body should be rendered.
  final ThunderPost post;

  /// Whether to display the raw markdown source.
  final bool viewSource;

  /// Whether the body text should be selectable.
  final bool selectable;

  /// Whether reply-editor affordances are visible under this body.
  final bool showReplyEditorButtons;

  /// Whether NSFW markdown previews should be obscured.
  final bool hideNsfwPreviews;

  /// Font scale used by source text.
  final FontScale contentFontSizeScale;

  /// Focus node owned by the parent [PostBody].
  final FocusNode focusNode;

  /// Called when the collapsed preview expands the body.
  final VoidCallback onExpand;

  /// Called when selectable text changes.
  final void Function(String? selection)? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (post.body?.isNotEmpty != true) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Expandable(
      controller: controller,
      collapsed: PostBodyPreview(
        post: post,
        viewSource: viewSource,
        gradientBackgroundColor: showReplyEditorButtons ? getBackgroundColor(context) : null,
        onTap: onExpand,
      ),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: ThunderConditionalParent(
          condition: selectable,
          parentBuilder: (child) {
            return SelectableRegion(
              focusNode: focusNode,
              // See comments on [SelectableTextModal] regarding the next two properties.
              selectionControls: Platform.isIOS ? cupertinoTextSelectionHandleControls : materialTextSelectionHandleControls,
              contextMenuBuilder: (context, selectableRegionState) {
                return AdaptiveTextSelectionToolbar.buttonItems(
                  buttonItems: selectableRegionState.contextMenuButtonItems,
                  anchors: selectableRegionState.contextMenuAnchors,
                );
              },
              onSelectionChanged: (value) => onSelectionChanged?.call(value?.plainText),
              child: child,
            );
          },
          child: viewSource
              ? ThunderScalableText(
                  post.body ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  textScaleFactor: contentFontSizeScale.textScaleFactor,
                )
              : CommonMarkdownBody(body: post.body ?? '', nsfw: post.status.nsfw && hideNsfwPreviews),
        ),
      ),
    );
  }
}
