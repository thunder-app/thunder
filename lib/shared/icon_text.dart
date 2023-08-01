import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.textColor,
    this.textScaleFactor = 1.0,
    this.padding = 3.0,
  });

  final Icon icon;
  final String text;
  final Color? textColor;
  final double textScaleFactor;

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: padding),
        Text(
          text,
          textScaleFactor: textScaleFactor,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ],
    );
  }
}
