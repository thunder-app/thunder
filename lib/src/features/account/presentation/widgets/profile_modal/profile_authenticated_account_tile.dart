import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_instance_status_avatar.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_trailing_action.dart';

/// Displays one authenticated account in the profile modal.
class ProfileAuthenticatedAccountTile extends StatelessWidget {
  const ProfileAuthenticatedAccountTile({
    super.key,
    required this.row,
    required this.active,
    required this.reordering,
    required this.selectedColor,
    required this.quickSelectMode,
    required this.areReordering,
    required this.pending,
    required this.interactionsEnabled,
    required this.onTap,
    required this.onLogout,
    required this.onRemove,
  });

  /// Account and asynchronously loaded metadata displayed by the row.
  final ProfileModalAuthenticatedAccountRow row;

  /// Whether this account is the active app session.
  final bool active;

  /// Whether this row is currently being dragged.
  final bool reordering;

  /// Background color used when [active] is `true`.
  final Color selectedColor;

  /// Whether management actions should be hidden for fast account switching.
  final bool quickSelectMode;

  /// Whether the authenticated account section is in reorder mode.
  final bool areReordering;

  /// Whether a session mutation is pending for this account.
  final bool pending;

  /// Whether profile actions are currently enabled.
  final bool interactionsEnabled;

  /// Callback invoked when the row is selected, or `null` for the active row.
  final VoidCallback? onTap;

  /// Callback invoked when the active account should be logged out.
  final VoidCallback onLogout;

  /// Callback invoked when an inactive account should be removed.
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
        leading: ProfileInstanceStatusAvatar(placeholderIcon: Icons.person, iconUrl: row.instanceIcon, alive: row.alive, selectedColor: selectedColor, active: active),
        title: Row(
          children: [
            Flexible(
              child: Text(row.account.username ?? l10n.notAvailable, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: row.totalUnreadCount == null ? 0 : 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 7.0),
                child: Badge(label: Text(row.totalUnreadCount.toString())),
              ),
            ),
          ],
        ),
        subtitle: ThunderMetadataRow(primary: row.account.instance.replaceAll('https://', ''), secondary: row.version == null ? null : 'v${row.version}'),
        trailing: ProfileTrailingAction(
          active: active,
          reordering: areReordering,
          pending: pending,
          canRemove: true,
          hidden: quickSelectMode,
          enabled: interactionsEnabled,
          onLogout: onLogout,
          onRemove: onRemove,
          logOutLabel: l10n.logOut,
          removeLabel: l10n.removeAccount,
        ),
      ),
    );
  }
}
