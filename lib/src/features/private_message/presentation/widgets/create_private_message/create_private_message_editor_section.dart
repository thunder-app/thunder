import 'package:flutter/material.dart';

import 'package:markdown_editor/markdown_editor.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

/// Displays the direct-message markdown editor or its rendered preview.
class CreatePrivateMessageEditorSection extends StatelessWidget {
  /// Creates an editor section with the same layout as post/comment compose pages.
  const CreatePrivateMessageEditorSection({super.key, required this.controller, required this.focusNode, required this.showPreview});

  /// Controls the message body input.
  final TextEditingController controller;

  /// Focus node used to restore keyboard focus after preview toggles.
  final FocusNode focusNode;

  /// Whether to show rendered markdown instead of the editor.
  final bool showPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return AnimatedCrossFade(
      firstChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: getBackgroundColor(context), borderRadius: const BorderRadius.all(Radius.circular(8.0))),
          child: CommonMarkdownBody(body: controller.text, isComment: true),
        ),
      ),
      secondChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: MarkdownTextInputField(
          controller: controller,
          focusNode: focusNode,
          label: l10n.message(0),
          minLines: 8,
          maxLines: null,
          textStyle: theme.textTheme.bodyLarge,
          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        ),
      ),
      crossFadeState: showPreview ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 120),
      excludeBottomFocus: false,
    );
  }
}
