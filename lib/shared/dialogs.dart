import 'dart:math';

import 'package:flutter/material.dart';

Future<T?> showThunderDialog<T>({
  required BuildContext context,
  required String title,
  String? contentText,
  // This allows the caller to provide a custom build function for the content widget.
  // We also give them a callback to set the enabled state of the primary button.
  Widget Function(void Function(bool) setPrimaryButtonEnabled)? contentWidgetBuilder,
  String? primaryButtonText,
  String? secondaryButtonText,
  // This is the function that we call when the primary button is pressed.
  // We also give the caller a callback to set the enabled state of the primary button.
  void Function(BuildContext dialogContext, void Function(bool) setPrimaryButtonEnabled)? onPrimaryButtonPressed,
  void Function(BuildContext dialogContext)? onSecondaryButtonPressed,
  // This is a builder which lets the caller wrap the AlertDialog (which we generate here)
  // with any other widget of their choosing (e.g., Bloc-related things).
  Widget Function(Widget alertDialog)? customBuilder,
  bool? primaryButtonInitialEnabled,
}) {
  // Assert that we have text or widget, but not both
  assert((contentText != null || contentWidgetBuilder != null) && !(contentText != null && contentWidgetBuilder != null));

  // This is a function that generates our AlertDialog.
  // We can call it directory or pass it as an argument to the caller's custom builder.
  // It is stateful so that we can change the state of the primary button.
  Widget generateAlertDialogForThunderDialog() {
    bool primaryButtonEnabled = primaryButtonInitialEnabled ?? true;
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: min(MediaQuery.of(context).size.width, 700),
          child: contentText != null
              ? Text(contentText)
              : contentWidgetBuilder!(
                  (enabled) => setState(() => primaryButtonEnabled = enabled),
                ),
        ),
        actions: [
          if (secondaryButtonText != null)
            TextButton(
              onPressed: onSecondaryButtonPressed == null ? null : () => onSecondaryButtonPressed(context),
              child: Text(secondaryButtonText),
            ),
          if (primaryButtonText != null)
            FilledButton(
              onPressed: !primaryButtonEnabled || onPrimaryButtonPressed == null
                  ? null
                  : () => onPrimaryButtonPressed(
                        context,
                        (enabled) => setState(() => primaryButtonEnabled = enabled),
                      ),
              child: Text(primaryButtonText),
            ),
        ],
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return customBuilder != null ? customBuilder(generateAlertDialogForThunderDialog()) : generateAlertDialogForThunderDialog();
    },
  );
}
