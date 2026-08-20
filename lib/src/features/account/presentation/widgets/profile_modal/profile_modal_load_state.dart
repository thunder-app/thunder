import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';

/// Displays the profile modal's initial loading or recoverable failure state.
class ProfileModalLoadState extends StatelessWidget {
  const ProfileModalLoadState.loading({super.key}) : failed = false, onRetry = null;

  const ProfileModalLoadState.failure({super.key, required this.onRetry}) : failed = true;

  /// Whether the initial session load failed.
  final bool failed;

  /// Retries the initial session load after a failure.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    if (failed) {
      return ThunderStateView(
        key: const Key('profile-load-failure'),
        sliver: true,
        fillRemaining: true,
        compact: true,
        icon: Icons.error_outline_rounded,
        title: l10n.somethingWentWrong,
        actions: [ThunderStateAction(label: l10n.retry, onPressed: onRetry!, primary: true)],
      );
    }

    return ThunderStateView.loading(key: const Key('profile-load-progress'), sliver: true, semanticsLabel: l10n.loading);
  }
}
