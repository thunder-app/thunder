import 'package:flutter/material.dart';

import 'package:thunder/core/enums/font_scale.dart';

/// Creates a [Text] widget that scales its font size based on the current [fontScale].
class ScalableText extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The style to use for the text. If null, defaults to the [ThemeData.textTheme.bodyMedium] style.
  final TextStyle? style;

  /// The alignment of the text.
  final TextAlign? textAlign;

  /// The font scale to use for the text.
  final FontScale? fontScale;

  /// The semantic label to use for the text.
  final String? semanticsLabel;

  /// The type of overflow to use for the text.
  final TextOverflow? overflow;

  /// The maximum number of lines to use for the text.
  final int? maxLines;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.fontScale,
    this.semanticsLabel,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium!;

    final baseStyle = style ?? defaultStyle;
    final baseFontSize = baseStyle.fontSize ?? defaultStyle.fontSize!;

    // Get the final style by applying the font scale to the base font size.
    final textScaler = MediaQuery.textScalerOf(context);
    final scaleFactor = fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor;
    final finalStyle = baseStyle.copyWith(fontSize: textScaler.scale(baseFontSize * scaleFactor));

    return Text(
      text,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
      overflow: overflow,
      maxLines: maxLines,
      style: finalStyle,
      textScaler: TextScaler.noScaling,
    );
  }
}
