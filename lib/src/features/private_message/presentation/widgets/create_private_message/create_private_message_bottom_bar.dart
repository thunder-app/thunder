import 'package:flutter/material.dart';

import 'package:markdown_editor/markdown_editor.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/private_message/presentation/state/create_private_message_cubit.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

/// Bottom markdown toolbar and submit controls for the direct-message composer.
class CreatePrivateMessageBottomBar extends StatelessWidget {
  /// Creates a bottom bar that mirrors the post/comment compose controls.
  const CreatePrivateMessageBottomBar({
    super.key,
    required this.account,
    required this.controller,
    required this.focusNode,
    required this.showPreview,
    required this.canSubmit,
    required this.status,
    required this.onTogglePreview,
    required this.onSubmit,
  });

  /// Account used for username and community markdown lookups.
  final Account account;

  /// Controls the message body input.
  final TextEditingController controller;

  /// Focus node for the message body input.
  final FocusNode focusNode;

  /// Whether the editor is currently showing markdown preview.
  final bool showPreview;

  /// Whether the current compose state can be submitted.
  final bool canSubmit;

  /// Current submission status.
  final CreatePrivateMessageStatus status;

  /// Toggles between source and preview mode.
  final VoidCallback onTogglePreview;

  /// Sends the direct message.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Row(
        children: [
          Expanded(
            child: IgnorePointer(
              ignoring: showPreview,
              child: MarkdownToolbar(
                controller: controller,
                focusNode: focusNode,
                actions: const [
                  MarkdownType.link,
                  MarkdownType.bold,
                  MarkdownType.italic,
                  MarkdownType.blockquote,
                  MarkdownType.strikethrough,
                  MarkdownType.title,
                  MarkdownType.list,
                  MarkdownType.separator,
                  MarkdownType.code,
                  MarkdownType.spoiler,
                  MarkdownType.username,
                  MarkdownType.community,
                ],
                customTapActions: {MarkdownType.username: () => _insertUserMention(context), MarkdownType.community: () => _insertCommunityMention(context)},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 4.0, right: 2.0),
            child: IconButton(
              onPressed: onTogglePreview,
              icon: Icon(showPreview ? Icons.visibility_off_rounded : Icons.visibility, color: theme.colorScheme.onSecondary, semanticLabel: l10n.postTogglePreview),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondaryContainer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 2.0, right: 8.0),
            child: SizedBox(
              width: 60,
              child: IconButton(
                onPressed: canSubmit ? onSubmit : null,
                icon: status == CreatePrivateMessageStatus.submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                    : Icon(Icons.send_rounded, color: theme.colorScheme.onSecondary, semanticLabel: l10n.send),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary, disabledBackgroundColor: getBackgroundColor(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _insertUserMention(BuildContext context) {
    final l10n = GlobalContext.l10n;

    showUserInputDialog(
      context,
      title: l10n.username,
      account: account,
      onUserSelected: (user) {
        controller.text = controller.text.replaceRange(controller.selection.end, controller.selection.end, '[@${user.name}@${fetchInstanceNameFromUrl(user.actorId)}](${user.actorId})');
      },
    );
  }

  void _insertCommunityMention(BuildContext context) {
    final l10n = GlobalContext.l10n;

    showCommunityInputDialog(
      context,
      title: l10n.community,
      account: account,
      onCommunitySelected: (community) {
        controller.text = controller.text.replaceRange(controller.selection.end, controller.selection.end, '!${community.name}@${fetchInstanceNameFromUrl(community.actorId)}');
      },
    );
  }
}
