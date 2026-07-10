import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_anonymous_instance_tile.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_authenticated_accounts_sliver.dart';
import 'package:thunder/src/core/domain/models/account.dart';

/// Displays and reorders anonymous instance rows in the profile modal.
class ProfileAnonymousInstancesSliver extends StatelessWidget {
  const ProfileAnonymousInstancesSliver({
    super.key,
    required this.rows,
    required this.activeSession,
    required this.selectedColor,
    required this.authenticatedAccountCount,
    required this.areReordering,
    required this.reorderIndex,
    required this.pendingSessionKey,
    required this.interactionsEnabled,
    required this.onSwitch,
    required this.onRemove,
  });

  /// Rows displayed in their persisted order.
  final List<ProfileModalAnonymousInstanceRow> rows;

  /// Active app session used to highlight the selected instance.
  final Account? activeSession;

  /// Background color used to highlight the active instance.
  final Color selectedColor;

  /// Number of authenticated accounts currently available.
  final int authenticatedAccountCount;

  /// Whether drag handles are enabled for this section.
  final bool areReordering;

  /// Index of the row currently being dragged, if any.
  final int? reorderIndex;

  /// Session key currently waiting for a mutation to complete.
  final String? pendingSessionKey;

  /// Whether switching, removal, and reordering interactions are enabled.
  final bool interactionsEnabled;

  /// Callback invoked with the instance session key when switching sessions.
  final ValueChanged<String> onSwitch;

  /// Callback invoked with the instance session key when removing it.
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      onReorderStart: interactionsEnabled ? (index) => context.read<ProfileModalCubit>().setAnonymousReorderIndex(index) : null,
      onReorderEnd: interactionsEnabled ? (_) => context.read<ProfileModalCubit>().setAnonymousReorderIndex(null) : null,
      onReorderItem: (oldIndex, newIndex) {
        if (interactionsEnabled) context.read<ProfileModalCubit>().reorderAnonymousInstance(oldIndex, newIndex);
      },
      proxyDecorator: profileReorderProxyDecorator,
      itemBuilder: (context, index) {
        final row = rows[index];
        final isActive = activeSession?.anonymous == true && activeSession?.instance == row.account.instance;
        final canRemove = authenticatedAccountCount > 0 || rows.length > 1;

        return ReorderableDragStartListener(
          enabled: interactionsEnabled && areReordering,
          key: Key('anonymous-${row.sessionKey}'),
          index: index,
          child: ProfileAnonymousInstanceTile(
            row: row,
            active: isActive,
            reordering: reorderIndex == index,
            selectedColor: selectedColor,
            areReordering: areReordering,
            canRemove: canRemove,
            pending: pendingSessionKey == row.sessionKey,
            interactionsEnabled: interactionsEnabled,
            onTap: interactionsEnabled ? () => onSwitch(row.sessionKey) : null,
            onRemove: () => onRemove(row.sessionKey),
          ),
        );
      },
      itemCount: rows.length,
    );
  }
}
