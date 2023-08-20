import 'package:flutter/material.dart';

void showSnackbar(
  BuildContext context,
  String text, {
  ScaffoldMessengerState? customState,
  bool clearSnackBars = true,
  Duration? duration,
  Color? backgroundColor,
  Color? leadingIconColor,
  IconData? leadingIcon,
  Color? trailingIconColor,
  IconData? trailingIcon,
  void Function()? trailingAction,
}) {
  SnackBar snackBar = SnackBar(
    duration: duration ?? const Duration(milliseconds: 4000),
    backgroundColor: backgroundColor,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leadingIcon != null)
          Icon(
            leadingIcon,
            color: leadingIconColor,
          ),
        if (leadingIcon != null) const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
          ),
        ),
        if (trailingIcon != null)
          SizedBox(
            height: 20,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: trailingAction != null
                  ? () {
                      (customState ?? ScaffoldMessenger.of(context)).clearSnackBars();
                      trailingAction();
                    }
                  : null,
              icon: Icon(
                trailingIcon,
                color: trailingIconColor ?? Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
      ],
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (clearSnackBars) {
      (customState ?? ScaffoldMessenger.of(context)).clearSnackBars();
    }
    (customState ?? ScaffoldMessenger.of(context)).showSnackBar(snackBar);
  });
}

void hideSnackbar(BuildContext context, {ScaffoldMessengerState? customState}) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    (customState ?? ScaffoldMessenger.of(context)).clearSnackBars();
  });
}
