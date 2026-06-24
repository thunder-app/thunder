import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/config/global_context.dart';

/// Displays the profile modal's initial loading or recoverable failure state.
class ProfileModalLoadState extends StatelessWidget {
  const ProfileModalLoadState.loading({super.key})
      : failed = false,
        onRetry = null;

  const ProfileModalLoadState.failure({super.key, required this.onRetry}) : failed = true;

  /// Whether the initial session load failed.
  final bool failed;

  /// Retries the initial session load after a failure.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: failed
            ? Column(
                key: const Key('profile-load-failure'),
                mainAxisSize: MainAxisSize.min,
                spacing: 16.0,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 40.0),
                  Text(l10n.somethingWentWrong, textAlign: TextAlign.center),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ],
              )
            : Semantics(
                label: l10n.loading,
                child: const CircularProgressIndicator(key: Key('profile-load-progress')),
              ),
      ),
    );
  }
}
