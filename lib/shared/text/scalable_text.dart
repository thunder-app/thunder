import 'package:flutter/material.dart';

import 'package:thunder/core/enums/font_scale.dart';

class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final FontScale? fontScale;
  final String? semanticsLabel;

  const ScalableText(this.text, {super.key, this.style, this.textAlign, this.fontScale, this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = style ?? theme.textTheme.bodyMedium!;

    return Text(
      text,
      textAlign: textAlign,
      semanticsLabel: semanticsLabel,
      style: textStyle.copyWith(
        fontSize: MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? theme.textTheme.bodyMedium!.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
      ),
    );
  }
}
