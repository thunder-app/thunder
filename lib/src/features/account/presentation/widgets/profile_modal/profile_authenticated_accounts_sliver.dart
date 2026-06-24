import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_authenticated_account_tile.dart';
import 'package:thunder/src/foundation/contracts/account.dart';

/// Displays and reorders the authenticated account rows in the profile modal.
class ProfileAuthenticatedAccountsSliver extends StatelessWidget {
  const ProfileAuthenticatedAccountsSliver({
    super.key,
    required this.rows,
    required this.activeSession,
    required this.selectedColor,
    required this.quickSelectMode,
    required this.areReordering,
    required this.reorderIndex,
    required this.pendingSessionKey,
    required this.interactionsEnabled,
    required this.onSwitch,
    required this.onLogout,
    required this.onRemove,
  });

  /// Rows displayed in their persisted order.
  final List<ProfileModalAuthenticatedAccountRow> rows;

  /// Active app session used to highlight and disable the selected account.
  final Account? activeSession;

  /// Background color used to highlight the active account.
  final Color selectedColor;

  /// Whether account-management actions should be hidden.
  final bool quickSelectMode;

  /// Whether drag handles are enabled for this section.
  final bool areReordering;

  /// Index of the row currently being dragged, if any.
  final int? reorderIndex;

  /// Session key currently waiting for a mutation to complete.
  final String? pendingSessionKey;

  /// Whether switching, removal, and reordering interactions are enabled.
  final bool interactionsEnabled;

  /// Callback invoked with the account session key when switching accounts.
  final ValueChanged<String> onSwitch;

  /// Callback invoked with the active account key when logging out.
  final ValueChanged<String> onLogout;

  /// Callback invoked with an inactive account key when removing it.
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      onReorderStart: interactionsEnabled ? (index) => context.read<ProfileModalCubit>().setAuthenticatedReorderIndex(index) : null,
      onReorderEnd: interactionsEnabled ? (_) => context.read<ProfileModalCubit>().setAuthenticatedReorderIndex(null) : null,
      onReorderItem: (oldIndex, newIndex) {
        if (interactionsEnabled) context.read<ProfileModalCubit>().reorderAuthenticatedAccount(oldIndex, newIndex);
      },
      proxyDecorator: profileReorderProxyDecorator,
      itemBuilder: (context, index) {
        final row = rows[index];
        final isActive = activeSession?.anonymous == false && activeSession?.id == row.account.id;

        return ReorderableDragStartListener(
          enabled: interactionsEnabled && areReordering,
          key: Key('account-${row.sessionKey}'),
          index: index,
          child: ProfileAuthenticatedAccountTile(
            row: row,
            active: isActive,
            reordering: reorderIndex == index,
            selectedColor: selectedColor,
            quickSelectMode: quickSelectMode,
            areReordering: areReordering,
            pending: pendingSessionKey == row.sessionKey,
            interactionsEnabled: interactionsEnabled,
            onTap: !interactionsEnabled || isActive ? null : () => onSwitch(row.sessionKey),
            onLogout: () => onLogout(row.sessionKey),
            onRemove: () => onRemove(row.sessionKey),
          ),
        );
      },
      itemCount: rows.length,
    );
  }
}

/// Builds the elevated proxy displayed while a profile row is being dragged.
Widget profileReorderProxyDecorator(Widget child, int index, Animation<double> animation) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
    child: Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(50.0),
      child: child,
    ),
  );
}
