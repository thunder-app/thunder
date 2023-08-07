import 'package:flutter/material.dart';

enum SnackBarMode { normal, warning }

void showSnackbar(BuildContext context, String text, {SnackBarMode mode = SnackBarMode.normal, bool clearSnackBars = true, Duration? duration, void Function()? undoAction}) {
  SnackBar snackBar = SnackBar(
    duration: duration ?? const Duration(milliseconds: 4000),
    backgroundColor: mode == SnackBarMode.warning ? Theme.of(context).colorScheme.onErrorContainer : null,
    content: undoAction == null
        ? switch (mode) {
            SnackBarMode.normal => Text(text),
            SnackBarMode.warning => Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.errorContainer,
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(text, maxLines: 4),
                  )
                ],
              ),
          }
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                ),
              ),
              SizedBox(
                height: 20,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    undoAction();
                  },
                  icon: Icon(
                    Icons.undo_rounded,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
  );

  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (clearSnackBars) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  });
}

void hideSnackbar(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    ScaffoldMessenger.of(context).clearSnackBars();
  });
}
