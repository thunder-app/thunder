import 'package:flutter/material.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/text/scalable_text.dart';

/// Creates a widget that displays an icon followed by text.
///
/// The [icon] parameter must not be null.
class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    this.text,
    this.textColor,
    this.fontScale,
    this.padding = 3.0,
  });

  /// The icon to display.
  final Icon icon;

  /// The text to display beside the icon.
  final String? text;

  /// The color of the text. If null, defaults to the [ThemeData.textTheme.bodyMedium.color].
  final Color? textColor;

  /// The font scale to use for the text.
  final FontScale? fontScale;

  /// The padding between the icon and the text. Defaults to 3.0.
  final double padding;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) return icon;
    final textStyle = TextStyle(color: textColor);

    return Row(
      spacing: padding,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        ScalableText(text!, fontScale: fontScale, style: textStyle),
      ],
    );
  }
}
