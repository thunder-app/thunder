import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:markdown_editor/markdown_editor.dart';
import 'package:thunder/src/features/feed/api.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

class CreatePostEditorSection extends StatelessWidget {
  const CreatePostEditorSection({super.key, required this.body, required this.controller, required this.focusNode, required this.showPreview, required this.nsfw});

  /// The current content of the post body.
  final String body;

  /// The controller for the body input field.
  final TextEditingController controller;

  /// The focus node for the body input field, used to manage keyboard focus and interactions.
  final FocusNode focusNode;

  /// Whether to show the Markdown preview or the editor input field.
  final bool showPreview;

  /// Whether the post is marked as NSFW, used to determine if NSFW content should be hidden in the preview.
  final bool nsfw;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    final hideNsfwPreviews = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.hideNsfwPreviews);

    return AnimatedCrossFade(
      firstChild: Container(
        margin: const EdgeInsets.only(top: 8.0),
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: getBackgroundColor(context), borderRadius: const BorderRadius.all(Radius.circular(8.0))),
        child: CommonMarkdownBody(body: body, isComment: true, nsfw: nsfw && hideNsfwPreviews),
      ),
      secondChild: MarkdownTextInputField(
        controller: controller,
        focusNode: focusNode,
        label: l10n.postBody,
        minLines: 8,
        maxLines: null,
        textStyle: theme.textTheme.bodyLarge,
        spellCheckConfiguration: SpellCheckConfiguration(spellCheckService: DefaultSpellCheckService()),
      ),
      crossFadeState: showPreview ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 120),
      excludeBottomFocus: false,
    );
  }
}
