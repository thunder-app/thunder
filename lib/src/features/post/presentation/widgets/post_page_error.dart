import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/shared/error_message.dart';

/// Error state displayed when the post page cannot load its content.
class PostPageError extends StatelessWidget {
  const PostPageError({super.key, required this.onRetry});

  /// Called when the user taps the retry action.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Center(
      child: ErrorMessage(
        title: l10n.unableToLoadPost,
        message: l10n.internetOrInstanceIssues,
        actions: [
          (
            text: l10n.retry,
            action: onRetry,
            loading: false,
          ),
        ],
      ),
    );
  }
}
