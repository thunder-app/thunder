import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';
import 'package:thunder/packages/ui/src/widgets/feedback/thunder_overlay.dart';

const Duration _snackBarTransitionDuration = Duration(milliseconds: 500);
const _snackbarDismissibleKey = ValueKey<String>('thunder_snackbar_dismissible');
ThunderOverlayEntry? _activeSnackbar;

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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final overlay = thunderNavigatorKey.currentState?.overlay;
    if (overlay == null) {
      FlutterError.reportError(FlutterErrorDetails(exception: FlutterError('Cannot show a snackbar without the Thunder navigator overlay.')));
      return;
    }

    _activeSnackbar?.dismiss(immediately: true);
    _activeSnackbar = showThunderOverlay(
      overlay: overlay,
      builder: (context, animation, dismiss) {
        return _ThunderSnackbarNotification(
          animation: animation,
          child: ThunderSnackbar(
            backgroundColor: backgroundColor,
            content: _ThunderSnackbarContent(
              text: text,
              leadingIcon: leadingIcon,
              leadingIconColor: leadingIconColor,
              trailingIcon: trailingIcon,
              trailingIconColor: trailingIconColor,
              trailingAction: trailingAction,
              closable: closable,
              onDismiss: dismiss,
            ),
            closable: closable,
            onDismissed: dismiss,
          ),
        );
      },
      animationDuration: _snackBarTransitionDuration,
      duration: duration ?? Duration(milliseconds: max(4000, 1000 * wordCount)),
    );
  });
  WidgetsBinding.instance.ensureVisualUpdate();
}

/// Row content for [ThunderSnackbar] with icons and actions.
class _ThunderSnackbarContent extends StatelessWidget {
  const _ThunderSnackbarContent({
    required this.text,
    required this.closable,
    required this.onDismiss,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailingIcon,
    this.trailingIconColor,
    this.trailingAction,
  });

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

  final VoidCallback onDismiss;

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
                      onDismiss();
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
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, color: theme.colorScheme.surface),
            ),
          ),
      ],
    );
  }
}

class _ThunderSnackbarNotification extends StatelessWidget {
  const _ThunderSnackbarNotification({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  static const Curve _snackBarM3HeightCurve = Curves.easeInOutQuart;
  static const Curve _snackBarM3FadeInCurve = Interval(0.4, 0.6, curve: Curves.easeInCirc);
  static const Curve _snackBarFadeOutCurve = Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final reversing = animation.status == AnimationStatus.reverse;
        final opacity = (reversing ? _snackBarFadeOutCurve : _snackBarM3FadeInCurve).transform(animation.value);
        final height = (reversing ? const Threshold(0.0) : _snackBarM3HeightCurve).transform(animation.value);
        return Opacity(
          opacity: opacity,
          child: Align(alignment: AlignmentDirectional.bottomStart, heightFactor: height, child: child),
        );
      },
      child: child,
    );
  }
}

/// Material snackbar body positioned above the bottom navigation bar.
class ThunderSnackbar extends StatefulWidget {
  const ThunderSnackbar({super.key, required this.content, this.closable = true, this.backgroundColor, this.onDismissed});

  /// Snackbar body content, typically a [Row] of text and action icons.
  final Widget content;

  /// Whether the snackbar reserves trailing space for a close affordance.
  final bool closable;

  /// Background color for the snackbar surface. Defaults to [ColorScheme.inverseSurface].
  final Color? backgroundColor;

  final VoidCallback? onDismissed;

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
      onDismissed: (_) {
        setState(() => _dismissed = true);
        widget.onDismissed?.call();
      },
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
