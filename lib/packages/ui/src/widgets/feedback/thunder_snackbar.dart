import 'dart:math';

import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

const Duration _snackBarTransitionDuration = Duration(milliseconds: 500);
const _snackbarDismissibleKey = ValueKey<String>('thunder_snackbar_dismissible');

/// Shows a Thunder-styled overlay snackbar with optional icons and actions.
///
/// Duration defaults based on word count when [duration] is not provided.
/// The snackbar is positioned above the bottom navigation bar.
void showThunderSnackbar(
  String text, {
  Duration? duration,
  Color? backgroundColor,
  Color? leadingIconColor,
  IconData? leadingIcon,
  Color? trailingIconColor,
  IconData? trailingIcon,
  bool closable = true,
  void Function()? trailingAction,
}) {
  final int wordCount = RegExp(r'[\w-]+').allMatches(text).length;

  const key = TransientKey('transient');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showOverlay(
      (context, progress) {
        return _ThunderSnackbarNotification(
          builder: (context) => ThunderSnackbar(
            backgroundColor: backgroundColor,
            content: _ThunderSnackbarContent(
              text: text,
              leadingIcon: leadingIcon,
              leadingIconColor: leadingIconColor,
              trailingIcon: trailingIcon,
              trailingIconColor: trailingIconColor,
              trailingAction: trailingAction,
              closable: closable,
            ),
            closable: closable,
          ),
          progress: progress,
        );
      },
      animationDuration: _snackBarTransitionDuration,
      duration: duration ?? Duration(milliseconds: max(kNotificationDuration.inMilliseconds, max(4000, 1000 * wordCount))),
      key: key,
    );
  });
}

/// Row content for [ThunderSnackbar] with icons and actions.
class _ThunderSnackbarContent extends StatelessWidget {
  const _ThunderSnackbarContent({required this.text, required this.closable, this.leadingIcon, this.leadingIconColor, this.trailingIcon, this.trailingIconColor, this.trailingAction});

  /// The snackbar message text.
  final String text;

  /// Whether a close affordance is shown.
  final bool closable;

  /// Optional icon shown before the text.
  final IconData? leadingIcon;

  /// Color for the leading icon.
  final Color? leadingIconColor;

  /// Optional icon shown after the text.
  final IconData? trailingIcon;

  /// Color for the trailing icon.
  final Color? trailingIconColor;

  /// Called when the trailing icon is tapped.
  final void Function()? trailingAction;

  @override
  Widget build(BuildContext context) {
    final tileBorderRadius = ThunderTheme.of(context).tileBorderRadius;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leadingIcon != null) ...[Icon(leadingIcon, color: leadingIconColor), const SizedBox(width: 8.0)],
        Expanded(child: Text(text)),
        if (trailingIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: InkWell(
              borderRadius: tileBorderRadius,
              onTap: trailingAction != null
                  ? () {
                      OverlaySupportEntry.of(context)?.dismiss();
                      trailingAction!();
                    }
                  : null,
              child: Icon(trailingIcon, color: trailingIconColor ?? theme.colorScheme.inversePrimary),
            ),
          ),
        if (closable)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: InkWell(
              borderRadius: tileBorderRadius,
              onTap: () => OverlaySupportEntry.of(context)?.dismiss(),
              child: Icon(Icons.close_rounded, color: theme.colorScheme.surface),
            ),
          ),
      ],
    );
  }
}

class _ThunderSnackbarNotification extends StatefulWidget {
  const _ThunderSnackbarNotification({required this.builder, required this.progress});

  final WidgetBuilder builder;
  final double progress;

  @override
  State<_ThunderSnackbarNotification> createState() => _ThunderSnackbarNotificationState();
}

class _ThunderSnackbarNotificationState extends State<_ThunderSnackbarNotification> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _fadeInM3Animation;
  late final CurvedAnimation _heightM3Animation;

  static const Curve _snackBarM3HeightCurve = Curves.easeInOutQuart;
  static const Curve _snackBarM3FadeInCurve = Interval(0.4, 0.6, curve: Curves.easeInCirc);
  static const Curve _snackBarFadeOutCurve = Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _snackBarTransitionDuration);
    _fadeInM3Animation = CurvedAnimation(parent: _controller, curve: _snackBarM3FadeInCurve, reverseCurve: _snackBarFadeOutCurve);
    _heightM3Animation = CurvedAnimation(parent: _controller, curve: _snackBarM3HeightCurve, reverseCurve: const Threshold(0.0));
  }

  @override
  void didUpdateWidget(_ThunderSnackbarNotification oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.progress - oldWidget.progress) > 0) {
      if (!_controller.isAnimating) _controller.forward();
    } else if ((widget.progress - oldWidget.progress) < 0) {
      if (!_controller.isAnimating) _controller.reverse();
    }
  }

  @override
  void dispose() {
    _fadeInM3Animation.dispose();
    _heightM3Animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInM3Animation,
      child: AnimatedBuilder(
        animation: _heightM3Animation,
        builder: (BuildContext context, Widget? child) {
          return Align(alignment: AlignmentDirectional.bottomStart, heightFactor: _heightM3Animation.value, child: child);
        },
        child: widget.builder(context),
      ),
    );
  }
}

/// Material snackbar body positioned above the bottom navigation bar.
class ThunderSnackbar extends StatefulWidget {
  const ThunderSnackbar({super.key, required this.content, this.closable = true, this.backgroundColor});

  /// Snackbar body content, typically a [Row] of text and action icons.
  final Widget content;

  /// Whether the snackbar reserves trailing space for a close affordance.
  final bool closable;

  /// Background color for the snackbar surface. Defaults to [ColorScheme.inverseSurface].
  final Color? backgroundColor;

  @override
  State<ThunderSnackbar> createState() => _ThunderSnackbarState();
}

class _ThunderSnackbarState extends State<ThunderSnackbar> with WidgetsBindingObserver {
  static const double _horizontalPadding = 16.0;
  static const double _singleLineVerticalPadding = 14.0;

  bool _dismissed = false;

  double _calculateBottomPadding(BuildContext context) {
    final double minimumPadding = MediaQuery.viewPaddingOf(context).bottom + kBottomNavigationBarHeight + _singleLineVerticalPadding;
    final double bottomViewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return max(minimumPadding, bottomViewInsets);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final snackBarTheme = theme.snackBarTheme;
    final elevation = snackBarTheme.elevation ?? 6.0;
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.inverseSurface;
    final shape = snackBarTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0));

    return Dismissible(
      key: _snackbarDismissibleKey,
      direction: DismissDirection.down,
      behavior: HitTestBehavior.deferToChild,
      onDismissed: (_) => setState(() => _dismissed = true),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(bottom: _calculateBottomPadding(context)),
          child: ClipRect(
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Semantics(
                container: true,
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Material(
                    shape: shape,
                    elevation: elevation,
                    color: backgroundColor,
                    clipBehavior: Clip.none,
                    child: Theme(
                      data: theme,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: _horizontalPadding, end: widget.closable ? 12.0 : 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: _singleLineVerticalPadding),
                                child: DefaultTextStyle(
                                  style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onInverseSurface),
                                  child: widget.content,
                                ),
                              ),
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
      ),
    );
  }
}
