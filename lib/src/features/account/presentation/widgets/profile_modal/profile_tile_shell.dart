import 'package:flutter/material.dart';

/// Provides the shared selection, elevation, and tap styling for profile rows.
class ProfileTileShell extends StatelessWidget {
  const ProfileTileShell({
    super.key,
    required this.active,
    required this.reordering,
    required this.selectedColor,
    required this.onTap,
    required this.child,
  });

  /// Whether the row represents the active session.
  final bool active;

  /// Whether the row is currently being dragged during reordering.
  final bool reordering;

  /// Background color used to identify the active session.
  final Color selectedColor;

  /// Callback invoked when the row is selected, or `null` to disable taps.
  final VoidCallback? onTap;

  /// Row content displayed inside the interactive surface.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Material(
        elevation: reordering ? 3.0 : 0.0,
        color: active ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(50.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50.0),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: child,
          ),
        ),
      ),
    );
  }
}
