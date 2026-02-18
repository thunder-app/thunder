import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart' as identity;
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// App adapter for the generic identity package scalable text.
class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final FontScale? fontScale;
  final String? semanticsLabel;
  final TextOverflow? overflow;
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
    return identity.ScalableText(
      text,
      style: style,
      textAlign: textAlign,
      textScaleFactor: fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor,
      semanticsLabel: semanticsLabel,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
