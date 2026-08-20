import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Tappable rounded row shell with selection and reorder styling.
@immutable
class ThunderSelectableTileShell extends StatelessWidget {
  const ThunderSelectableTileShell({
    super.key,
    required this.child,
    this.selected = false,
    this.reordering = false,
    this.selectedColor,
    this.onTap,
    this.borderRadius,
    this.padding = const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
  });

  /// Tile content.
  final Widget child;

  /// Whether the tile is in a selected state.
  final bool selected;

  /// When true, elevates the tile during reorder.
  final bool reordering;

  /// Background color when [selected] is true.
  final Color? selectedColor;

  /// Called when the tile is tapped.
  final void Function()? onTap;

  /// Corner radius. Defaults to the theme tile radius.
  final BorderRadius? borderRadius;

  /// Outer padding around the tile.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final thunderTheme = ThunderTheme.of(context);
    final radius = borderRadius ?? thunderTheme.tileBorderRadius;

    return Padding(
      padding: padding,
      child: Material(
        elevation: reordering ? 3.0 : 0.0,
        color: selected ? selectedColor ?? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: thunderTheme.selectableTileSelectedAlpha) : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedSize(duration: const Duration(milliseconds: 250), child: child),
        ),
      ),
    );
  }
}
