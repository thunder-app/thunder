import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Compact or default-styled action button used by [ThunderExpandableFab].
@immutable
class ThunderFabActionButton extends StatelessWidget {
  const ThunderFabActionButton({super.key, this.onPressed, required this.icon, this.label, this.backgroundColor, this.compact = false});

  /// Called when the button is pressed.
  final void Function()? onPressed;

  /// Icon shown on the button.
  final Icon icon;

  /// Optional label shown beside the icon in compact mode.
  final String? label;

  /// Background color for the default (non-compact) button.
  final Color? backgroundColor;

  /// When true, renders a wider pill-shaped button with an inline label.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return SizedBox(
        width: 160.0,
        child: Material(
          color: Colors.transparent,
          elevation: 3,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            onTap: onPressed,
            child: SizedBox(
              height: 40.0,
              child: Row(
                children: [
                  const SizedBox(width: 12.0),
                  Icon(icon.icon, size: 20.0),
                  const SizedBox(width: 10.0),
                  Expanded(child: Text(label ?? '', overflow: TextOverflow.ellipsis, maxLines: 1)),
                  const SizedBox(width: 12.0),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) Text(label!),
        if (label != null) const SizedBox(width: 16.0),
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            clipBehavior: Clip.antiAlias,
            color: backgroundColor ?? theme.colorScheme.primaryContainer,
            elevation: 4,
            child: InkWell(onTap: onPressed, child: icon),
          ),
        ),
      ],
    );
  }
}

/// Expandable floating action button with directional child actions.
@immutable
class ThunderExpandableFab extends StatefulWidget {
  const ThunderExpandableFab({
    super.key,
    this.open,
    this.initialOpen = false,
    required this.distance,
    required this.children,
    required this.icon,
    this.onSlideUp,
    this.onSlideLeft,
    this.onSlideDown,
    this.onPressed,
    this.onLongPress,
    this.centered = false,
    this.heroTag,
    this.fabBackgroundColor,
    this.onOpenChanged,
  });

  /// Controlled open state. When null, open state is managed internally.
  final bool? open;

  /// Initial open state when [open] is null.
  final bool initialOpen;

  /// Distance between stacked child action buttons.
  final double distance;

  /// Action buttons revealed when the FAB is expanded.
  final List<Widget> children;

  /// Icon shown on the main FAB.
  final Icon icon;

  /// Called when the user slides up on the main FAB.
  final void Function()? onSlideUp;

  /// Called when the user slides left on the main FAB.
  final void Function()? onSlideLeft;

  /// Called when the user slides down on the main FAB.
  final void Function()? onSlideDown;

  /// Called when the main FAB is tapped.
  final void Function()? onPressed;

  /// Called when the main FAB is long-pressed.
  final void Function()? onLongPress;

  /// When true, centers the FAB horizontally in its parent.
  final bool centered;

  /// Hero tag for the main FAB.
  final String? heroTag;

  /// Background color for the main FAB.
  final Color? fabBackgroundColor;

  /// Called when the expanded state changes.
  final void Function(bool)? onOpenChanged;

  @override
  State<ThunderExpandableFab> createState() => _ThunderExpandableFabState();
}

class _ThunderExpandableFabState extends State<ThunderExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.open ?? widget.initialOpen;
    _controller = AnimationController(value: _isOpen ? 1.0 : 0.0, duration: const Duration(milliseconds: 250), vsync: this);
    _expandAnimation = CurvedAnimation(curve: Curves.fastOutSlowIn, reverseCurve: Curves.easeOutQuad, parent: _controller);
  }

  @override
  void didUpdateWidget(ThunderExpandableFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controlledOpen = widget.open;
    if (controlledOpen != null && controlledOpen != _isOpen) {
      _setOpen(controlledOpen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setOpen(bool open) {
    if (_isOpen == open) return;
    setState(() => _isOpen = open);
    if (open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onOpenChanged?.call(open);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: widget.centered ? Alignment.bottomCenter : Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _ThunderTapToCloseFab(centered: widget.centered, expandAnimation: _expandAnimation, onClose: () => _setOpen(false)),
          for (var i = 0, distance = widget.distance; i < widget.children.length; i++, distance += widget.distance)
            _ThunderExpandingActionButton(maxDistance: distance, progress: _expandAnimation, centered: widget.centered, child: widget.children[i]),
          _ThunderTapToOpenFab(
            centered: widget.centered,
            isOpen: _isOpen,
            icon: widget.icon,
            heroTag: widget.heroTag,
            fabBackgroundColor: widget.fabBackgroundColor,
            onPressed: widget.onPressed,
            onLongPress: widget.onLongPress,
            onSlideUp: widget.onSlideUp,
            onSlideLeft: widget.onSlideLeft,
            onSlideDown: widget.onSlideDown,
            onOpen: () => _setOpen(true),
          ),
        ],
      ),
    );
  }
}

/// Close overlay shown when [ThunderExpandableFab] is expanded.
class _ThunderTapToCloseFab extends StatelessWidget {
  const _ThunderTapToCloseFab({required this.centered, required this.expandAnimation, required this.onClose});

  /// Whether the FAB is centered horizontally.
  final bool centered;

  /// Animation driving the expand/collapse transition.
  final Animation<double> expandAnimation;

  /// Called when the close affordance is tapped.
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    final tileBorderRadius = ThunderTheme.of(context).tileBorderRadius;

    return SizedBox(
      width: centered ? 45.0 : 56.0,
      height: centered ? 45.0 : 56.0,
      child: AnimatedBuilder(
        animation: expandAnimation,
        builder: (context, child) => child!,
        child: FadeTransition(
          opacity: expandAnimation,
          child: Center(
            child: Material(
              shape: centered ? null : const CircleBorder(),
              clipBehavior: centered ? Clip.none : Clip.antiAlias,
              color: centered ? Colors.transparent : null,
              elevation: centered ? 0.0 : 4.0,
              child: InkWell(
                borderRadius: tileBorderRadius,
                onTap: onClose,
                child: Padding(
                  padding: EdgeInsets.all(centered ? 12.0 : 8.0),
                  child: Icon(Icons.close, size: centered ? 20.0 : 25.0, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Main FAB that opens [ThunderExpandableFab] child actions.
class _ThunderTapToOpenFab extends StatelessWidget {
  const _ThunderTapToOpenFab({
    required this.centered,
    required this.isOpen,
    required this.icon,
    required this.onOpen,
    this.heroTag,
    this.fabBackgroundColor,
    this.onPressed,
    this.onLongPress,
    this.onSlideUp,
    this.onSlideLeft,
    this.onSlideDown,
  });

  /// Whether the FAB is centered horizontally.
  final bool centered;

  /// Whether the expandable FAB is currently open.
  final bool isOpen;

  /// Icon shown on the main FAB.
  final Icon icon;

  /// Hero tag for the main FAB.
  final String? heroTag;

  /// Background color for the main FAB.
  final Color? fabBackgroundColor;

  /// Called when the main FAB is tapped.
  final void Function()? onPressed;

  /// Called when the main FAB is long-pressed.
  final void Function()? onLongPress;

  /// Called when the user slides up on the main FAB.
  final void Function()? onSlideUp;

  /// Called when the user slides left on the main FAB.
  final void Function()? onSlideLeft;

  /// Called when the user slides down on the main FAB.
  final void Function()? onSlideDown;

  /// Called to open the expandable FAB.
  final void Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final tileBorderRadius = ThunderTheme.of(context).tileBorderRadius;

    return IgnorePointer(
      ignoring: isOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(isOpen ? 0.7 : 1, isOpen ? 0.7 : 1, 1),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: isOpen ? 0.0 : 1.0,
          curve: const Interval(0.25, 1, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy < -5) {
                onOpen();
                onSlideUp?.call();
              }
              if (details.delta.dy > 5) {
                onSlideDown?.call();
              }
            },
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx < -5) onSlideLeft?.call();
            },
            onLongPress: () {
              HapticFeedback.heavyImpact();
              onLongPress?.call();
            },
            onTapDown: (_) => HapticFeedback.mediumImpact(),
            child: centered
                ? SizedBox(
                    width: 45.0,
                    height: 45.0,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: tileBorderRadius,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onPressed?.call();
                        },
                        child: Icon(icon.icon, size: 20.0, semanticLabel: icon.semanticLabel),
                      ),
                    ),
                  )
                : FloatingActionButton(heroTag: heroTag, backgroundColor: fabBackgroundColor, onPressed: onPressed, child: icon),
          ),
        ),
      ),
    );
  }
}

/// Positions and animates one child action in [ThunderExpandableFab].
@immutable
class _ThunderExpandingActionButton extends StatelessWidget {
  const _ThunderExpandingActionButton({required this.maxDistance, required this.progress, required this.child, this.centered = false});

  /// Maximum vertical offset from the main FAB.
  final double maxDistance;

  /// Expand animation progress.
  final Animation<double> progress;

  /// The action button to position.
  final Widget child;

  /// Whether the FAB stack is centered horizontally.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(90 * (math.pi / 180.0), progress.value * maxDistance);
        final visible = !progress.isDismissed;

        return Visibility(
          visible: visible,
          child: Positioned(right: centered ? null : 8 + offset.dx, bottom: (centered ? 15.0 : 10.0) + offset.dy, child: child!),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}
