import 'package:flutter/material.dart';

class ScalableText extends StatelessWidget {
  final String text;

  final TextStyle? style;

  final TextAlign? textAlign;

  final double textScaleFactor;

  final String? semanticsLabel;

  final TextOverflow? overflow;

  final int? maxLines;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textScaleFactor = 1.0,
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
