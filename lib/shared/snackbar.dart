import 'dart:math';

import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

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
  int wordCount = RegExp(r'[\w-]+').allMatches(text).length;

  if (clearSnackBars) {
    // OverlaySupportEntry.of(context)?.dismiss();
  }

  showOverlayNotification(
    (context) {
      return ThunderSnackbar(
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
                          OverlaySupportEntry.of(context)?.dismiss();
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
    },
    position: NotificationPosition.bottom,
    duration: duration ?? Duration(milliseconds: max(4000, 1000 * wordCount)), // Assuming 60 WPM or 1 WPS
  );
}

class ThunderSnackbar extends StatelessWidget {
  final Widget content;

  const ThunderSnackbar({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16.0;
    const double singleLineVerticalPadding = 14.0;

    final ThemeData theme = Theme.of(context);
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;

    final double elevation = snackBarTheme.elevation ?? 6.0;
    final Color backgroundColor = theme.colorScheme.inverseSurface;
    final ShapeBorder shape = snackBarTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0));

    Widget snackBar = Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + kBottomNavigationBarHeight + singleLineVerticalPadding),
      child: ClipRect(
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Semantics(
            container: true,
            liveRegion: true,
            onDismiss: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
            },
            child: Dismissible(
              key: const Key('dismissible'),
              direction: DismissDirection.down,
              resizeDuration: null,
              behavior: HitTestBehavior.deferToChild,
              onDismissed: (DismissDirection direction) {
                // ScaffoldMessenger.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.swipe);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                child: Material(
                  shape: shape,
                  elevation: elevation,
                  color: backgroundColor,
                  clipBehavior: Clip.none,
                  child: Theme(
                    data: theme,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: horizontalPadding, end: horizontalPadding),
                      child: Wrap(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: singleLineVerticalPadding),
                                  child: DefaultTextStyle(
                                    style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onInverseSurface),
                                    child: content,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return snackBar;
  }
}

void hideSnackbar(BuildContext context, {ScaffoldMessengerState? customState}) {
  OverlaySupportEntry.of(context)?.dismiss();
}
