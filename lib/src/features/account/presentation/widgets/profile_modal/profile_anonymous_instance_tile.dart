import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_instance_status_avatar.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_trailing_action.dart';

/// Displays one anonymous instance in the profile modal.
class ProfileAnonymousInstanceTile extends StatelessWidget {
  const ProfileAnonymousInstanceTile({
    super.key,
    required this.row,
    required this.active,
    required this.reordering,
    required this.selectedColor,
    required this.areReordering,
    required this.canRemove,
    required this.pending,
    required this.interactionsEnabled,
    required this.onTap,
    required this.onRemove,
  });

  /// Anonymous session and asynchronously loaded metadata displayed by the row.
  final ProfileModalAnonymousInstanceRow row;

  /// Whether this anonymous instance is the active app session.
  final bool active;

  /// Whether this row is currently being dragged.
  final bool reordering;

  /// Background color used when [active] is `true`.
  final Color selectedColor;

  /// Whether the anonymous instance section is in reorder mode.
  final bool areReordering;

  /// Whether the instance can be removed without leaving no available session.
  final bool canRemove;

  /// Whether a session mutation is pending for this instance.
  final bool pending;

  /// Callback invoked when the instance is selected.
  final VoidCallback? onTap;

  /// Whether profile actions are currently enabled.
  final bool interactionsEnabled;

  /// Callback invoked when the instance should be removed.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return ThunderSelectableTileShell(
      selected: active,
      reordering: reordering,
      selectedColor: selectedColor,
      onTap: onTap,
      child: ListTile(
        leading: ProfileInstanceStatusAvatar(placeholderIcon: Icons.language, iconUrl: row.instanceIcon, alive: row.alive, selectedColor: selectedColor, active: active),
        title: Row(
          children: [
            const Icon(Icons.person_off_rounded, size: 15.0),
            const SizedBox(width: 5.0),
            Flexible(
              child: Text(l10n.anonymous, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
            ),
          ],
        ),
        subtitle: ThunderMetadataRow(primary: row.account.instance, secondary: row.version == null ? null : 'v${row.version}'),
        trailing: ProfileTrailingAction(
          active: active,
          reordering: areReordering,
          pending: pending,
          canRemove: canRemove,
          hidden: false,
          enabled: interactionsEnabled,
          onLogout: onRemove,
          onRemove: onRemove,
          logOutLabel: l10n.removeInstance,
          removeLabel: l10n.removeInstance,
        ),
      ),
    );
  }
}
