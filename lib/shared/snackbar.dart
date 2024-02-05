import 'dart:math';

import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';
import 'package:thunder/utils/global_context.dart';

const Duration _snackBarTransitionDuration = Duration(milliseconds: 500);

void showSnackbar(
  String text, {
  Duration? duration,
  Color? backgroundColor,
  Color? leadingIconColor,
  IconData? leadingIcon,
  Color? trailingIconColor,
  IconData? trailingIcon,
  void Function()? trailingAction,
}) {
  int wordCount = RegExp(r'[\w-]+').allMatches(text).length;

  // Allows us to clear the previous overlay before showing the next one
  const key = TransientKey('transient');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showOverlay(
      (context, progress) {
        return SnackbarNotification(
          builder: (context) => ThunderSnackbar(
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
          ),
          progress: progress,
        );
      },
      animationDuration: _snackBarTransitionDuration,
      duration: duration ?? Duration(milliseconds: max(kNotificationDuration.inMilliseconds, max(4000, 1000 * wordCount))), // Assuming 60 WPM or 1 WPS
      context: GlobalContext.context,
      key: key,
    );
  });
}

/// Build the slide translation for the snack bar
class SnackbarNotification extends StatefulWidget {
  final WidgetBuilder builder;

  final double progress;

  const SnackbarNotification({super.key, required this.builder, required this.progress});

  @override
  State<SnackbarNotification> createState() => _SnackbarNotificationState();
}

class _SnackbarNotificationState extends State<SnackbarNotification> with TickerProviderStateMixin {
  late AnimationController _controller;

  static const Curve _snackBarM3HeightCurve = Curves.easeInOutQuart;
  static const Curve _snackBarM3FadeInCurve = Interval(0.4, 0.6, curve: Curves.easeInCirc);
  static const Curve _snackBarFadeOutCurve = Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _snackBarTransitionDuration, // Set the duration of the animation.
    );
  }

  @override
  void didUpdateWidget(SnackbarNotification oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.progress - oldWidget.progress) > 0) {
      if (!_controller.isAnimating) _controller.forward();
    } else if ((widget.progress - oldWidget.progress) < 0) {
      if (!_controller.isAnimating) _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation fadeInM3Animation = CurvedAnimation(parent: _controller, curve: _snackBarM3FadeInCurve, reverseCurve: _snackBarFadeOutCurve);

    final CurvedAnimation heightM3Animation = CurvedAnimation(
      parent: _controller,
      curve: _snackBarM3HeightCurve,
      reverseCurve: const Threshold(0.0),
    );

    return FadeTransition(
      opacity: fadeInM3Animation,
      child: AnimatedBuilder(
        animation: heightM3Animation,
        builder: (BuildContext context, Widget? child) {
          return Align(
            alignment: AlignmentDirectional.bottomStart,
            heightFactor: heightM3Animation.value,
            child: child,
          );
        },
        child: widget.builder(context),
      ),
    );
  }
}

class ThunderSnackbar extends StatefulWidget {
  /// The content of the snackbar.
  final Widget content;

  const ThunderSnackbar({super.key, required this.content});

  @override
  State<ThunderSnackbar> createState() => _ThunderSnackbarState();
}

class _ThunderSnackbarState extends State<ThunderSnackbar> {
  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16.0;
    const double singleLineVerticalPadding = 14.0;

    final ThemeData theme = Theme.of(context);
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;

    final double elevation = snackBarTheme.elevation ?? 6.0;
    final Color backgroundColor = theme.colorScheme.inverseSurface;
    final ShapeBorder shape = snackBarTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0));

    Widget snackBar = Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.down,
      behavior: HitTestBehavior.deferToChild,
      onDismissed: (direction) {},
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + kBottomNavigationBarHeight + singleLineVerticalPadding),
        child: ClipRect(
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Semantics(
              container: true,
              liveRegion: true,
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
                                    child: widget.content,
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
