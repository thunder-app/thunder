import 'package:flutter/material.dart';
import 'package:thunder/utils/colors.dart';

/// A border that can be wrapped around User/Commnity avatars
class AvatarBorder extends StatelessWidget {
  /// The width of the border
  final double? width;

  /// The color of the border
  final Color? color;

  /// The child widget
  final Widget child;

  const AvatarBorder({super.key, this.width, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? theme.colorScheme.onBackground,
          width: width ?? 2,
        ),
      ),
      child: child,
    );
  }
}
