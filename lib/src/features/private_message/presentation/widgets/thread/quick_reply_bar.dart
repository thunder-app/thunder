import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';

/// Reply field for sending a short direct-messages.
class QuickReplyBar extends StatelessWidget {
  /// Creates a compact reply bar with a shortcut to the full editor.
  const QuickReplyBar({super.key, required this.controller, required this.canSend, required this.sending, required this.onOpenComposer, required this.onSend});

  /// Controls the quick reply text field.
  final TextEditingController controller;

  /// Whether the reply can be sent.
  final bool canSend;

  /// Whether a reply is currently being sent.
  final bool sending;

  /// Opens the full direct-message editor.
  final VoidCallback onOpenComposer;

  /// Sends the quick reply.
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderComposerBar(
      leading: IconButton(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        onPressed: onOpenComposer,
        icon: Icon(Icons.add_circle_outline_rounded, semanticLabel: l10n.message(0)),
      ),
      textField: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration.collapsed(hintText: l10n.message(0)),
        textInputAction: TextInputAction.newline,
      ),
      trailing: IconButton.filledTonal(
        onPressed: canSend ? onSend : null,
        icon: sending ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.send_rounded, semanticLabel: l10n.send, size: 22),
      ),
    );
  }
}
