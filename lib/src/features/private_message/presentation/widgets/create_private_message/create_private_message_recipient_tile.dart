import 'package:flutter/material.dart';

import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/core/config/global_context.dart';

/// A compact selector row for choosing the recipient of a direct message.
class CreatePrivateMessageRecipientTile extends StatelessWidget {
  /// Creates a recipient selector matching the app's account selector style.
  const CreatePrivateMessageRecipientTile({
    super.key,
    required this.recipient,
    required this.onTap,
  });

  /// The selected recipient, or null when the user still needs to choose one.
  final ThunderUser? recipient;

  /// Opens recipient selection.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final recipient = this.recipient;

    return Transform.translate(
      offset: const Offset(-8.0, 0),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              recipient == null ? _RecipientPlaceholder(label: l10n.selectRecipient) : UserIndicator(user: recipient),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipientPlaceholder extends StatelessWidget {
  const _RecipientPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        spacing: 12.0,
        children: [
          const Icon(Icons.person_search_rounded),
          Text(label),
        ],
      ),
    );
  }
}
