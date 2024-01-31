import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar(
  BuildContext context,
  String text, {
  bool clearSnackBars = true,
  Duration? duration,
  Color? backgroundColor,
  Color? leadingIconColor,
  IconData? leadingIcon,
  Color? trailingIconColor,
  IconData? trailingIcon,
  void Function()? trailingAction,
}) {
  final ThemeData theme = Theme.of(context);
  final int wordCount = RegExp(r'[\w-]+').allMatches(text).length;

  GetSnackBar snackBar = GetSnackBar(
    duration: duration ?? Duration(milliseconds: max(4000, 1000 * wordCount)), // Assuming 60 WPM or 1 WPS
    messageText: Text(
      text,
      style: TextStyle(color: theme.colorScheme.onInverseSurface),
    ),
    icon: leadingIcon != null
        ? Icon(
            leadingIcon,
            color: leadingIconColor ?? theme.colorScheme.inversePrimary,
          )
        : null,
    backgroundColor: backgroundColor ?? theme.colorScheme.inverseSurface,
    mainButton: trailingIcon != null
        ? SizedBox(
            height: 20,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: trailingAction != null
                  ? () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.closeCurrentSnackbar();
                      });
                      trailingAction();
                    }
                  : null,
              icon: Icon(
                trailingIcon,
                color: trailingIconColor ?? theme.colorScheme.inversePrimary,
              ),
            ),
          )
        : null,
    margin: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
    borderRadius: 6.0,
    boxShadows: [
      BoxShadow(
        color: (backgroundColor ?? theme.colorScheme.inverseSurface).withOpacity(0.5),
        blurRadius: 5,
        offset: const Offset(1, 1),
      ),
    ],
    animationDuration: const Duration(milliseconds: 400),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (clearSnackBars) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(snackBar);
  });
}

void hideSnackbar() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.closeCurrentSnackbar();
  });
}
