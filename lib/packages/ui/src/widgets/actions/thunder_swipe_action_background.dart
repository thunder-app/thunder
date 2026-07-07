import 'package:flutter/material.dart';

/// Animated background revealed during swipe actions on list cards.
@immutable
class ThunderSwipeActionBackground extends StatelessWidget {
  const ThunderSwipeActionBackground({
    super.key,
    required this.alignment,
    required this.backgroundColor,
    required this.width,
    this.icon,
    this.duration = const Duration(milliseconds: 200),
  });

  /// Horizontal alignment of the background content.
  final Alignment alignment;

  /// Fill color revealed during the swipe.
  final Color backgroundColor;

  /// Width of the revealed background area.
  final double width;

  /// Optional icon centered in the background.
  final IconData? icon;

  /// Animation duration when the width changes.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: alignment,
      duration: duration,
      color: backgroundColor,
      child: SizedBox(
        width: width,
        child: icon != null ? Icon(icon) : const SizedBox.shrink(),
      ),
    );
  }
}
