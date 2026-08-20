import 'package:flutter/material.dart';

import 'package:thunder/src/core/config/global_context.dart';

/// Displays the drag, progress, logout, or removal action for a profile row.
class ProfileTrailingAction extends StatelessWidget {
  const ProfileTrailingAction({
    super.key,
    required this.active,
    required this.reordering,
    required this.pending,
    required this.canRemove,
    required this.hidden,
    required this.enabled,
    required this.onLogout,
    required this.onRemove,
    required this.logOutLabel,
    required this.removeLabel,
  });

  /// Whether the row represents the active session.
  final bool active;

  /// Whether the surrounding section is in reorder mode.
  final bool reordering;

  /// Whether a session mutation is currently pending for this row.
  final bool pending;

  /// Whether the session may be removed without leaving the app sessionless.
  final bool canRemove;

  /// Whether profile-management actions should be hidden entirely.
  final bool hidden;

  /// Whether the action can currently be invoked.
  final bool enabled;

  /// Callback invoked when the active session should be logged out.
  final VoidCallback onLogout;

  /// Callback invoked when an inactive session should be removed.
  final VoidCallback onRemove;

  /// Localized accessibility label for the logout action.
  final String logOutLabel;

  /// Localized accessibility label for the remove action.
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    if (hidden) return const SizedBox.shrink();
    if (reordering) return const Icon(Icons.drag_handle);
    if (!canRemove) return const SizedBox.shrink();

    return IconButton(
      icon: pending
          ? Semantics(
              label: GlobalContext.l10n.profileOperationInProgress,
              child: const SizedBox(height: 20.0, width: 20.0, child: CircularProgressIndicator()),
            )
          : Icon(active ? Icons.logout : Icons.delete),
      tooltip: active ? logOutLabel : removeLabel,
      onPressed: enabled && !pending ? (active ? onLogout : onRemove) : null,
    );
  }
}
