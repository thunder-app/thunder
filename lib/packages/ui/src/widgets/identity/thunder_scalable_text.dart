import 'package:flutter/material.dart';

/// Text that applies a manual scale factor while ignoring system text scaling.
///
/// System [MediaQuery.textScaler] is read once to compute the final font size,
/// then [TextScaler.noScaling] is used so the result is not scaled again.
@immutable
class ThunderScalableText extends StatelessWidget {
  const ThunderScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textScaleFactor = 1.0,
    this.semanticsLabel,
    this.overflow,
    this.maxLines,
  });

  /// The text to display.
  final String text;

  /// Base style before scaling. Defaults to [ThemeData.textTheme.bodyMedium].
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Multiplier applied on top of the system text scaler.
  final double textScaleFactor;

  /// Semantic label for accessibility.
  final String? semanticsLabel;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Maximum number of lines for the text to span.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium!;

    final baseStyle = style ?? defaultStyle;
    final baseFontSize = baseStyle.fontSize ?? defaultStyle.fontSize!;

    final textScaler = MediaQuery.textScalerOf(context);
    final finalStyle = baseStyle.copyWith(
      fontSize: textScaler.scale(baseFontSize * textScaleFactor),
    );

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
