import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/common/thunder_state_action.dart';

/// Action buttons for Thunder state views.
@immutable
class ThunderStateActions extends StatelessWidget {
  const ThunderStateActions({
    super.key,
    required this.actions,
  });

  /// Action buttons rendered in a vertical column.
  final List<ThunderStateAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          SizedBox(
            width: double.infinity,
            child: _ThunderStateActionButton(
              action: actions[i],
              primary: actions[i].primary || i == 0,
            ),
          ),
          if (i != actions.length - 1) const SizedBox(height: 12.0),
        ],
      ],
    );
  }
}

/// Single action button for [ThunderStateActions].
class _ThunderStateActionButton extends StatelessWidget {
  const _ThunderStateActionButton({
    required this.action,
    required this.primary,
  });

  /// The action configuration to render.
  final ThunderStateAction action;

  /// Whether to render as a primary elevated button.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final child = action.loading ? const SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator()) : Text(action.label);

    if (primary) {
      return ElevatedButton(
        onPressed: action.loading ? null : action.onPressed,
        child: child,
      );
    }

    return TextButton(
      onPressed: action.loading ? null : action.onPressed,
      child: child,
    );
  }
}
