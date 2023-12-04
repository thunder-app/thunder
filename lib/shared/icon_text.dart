import 'package:flutter/material.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/text/scalable_text.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    this.text,
    this.textColor,
    this.fontScale,
    this.padding = 3.0,
  });

  final Icon icon;
  final String? text;
  final Color? textColor;
  final FontScale? fontScale;

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        if (text != null) ...[
          SizedBox(width: padding),
          ScalableText(
            text!,
            fontScale: fontScale,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }
}
