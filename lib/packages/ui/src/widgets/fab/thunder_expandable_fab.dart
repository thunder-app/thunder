import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThunderFabActionButton extends StatelessWidget {
  const ThunderFabActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final Icon icon;
  final String? label;
  final Color? backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return SizedBox(
        width: 160,
        child: Material(
          color: Colors.transparent,
          elevation: 3,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            onTap: onPressed,
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(icon.icon, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
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
        if (label != null) const SizedBox(width: 16),
        SizedBox(
          height: 40,
          width: 40,
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
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

class ThunderExpandableFab extends StatefulWidget {
  const ThunderExpandableFab({
    super.key,
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

  final bool initialOpen;
  final double distance;
  final List<Widget> children;
  final Icon icon;
  final VoidCallback? onSlideUp;
  final VoidCallback? onSlideLeft;
  final VoidCallback? onSlideDown;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool centered;
  final String? heroTag;
  final Color? fabBackgroundColor;
  final ValueChanged<bool>? onOpenChanged;

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
    _isOpen = widget.initialOpen;
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
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
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: widget.centered ? 45 : 56,
      height: widget.centered ? 45 : 56,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) => child!,
        child: FadeTransition(
          opacity: _expandAnimation,
          child: Center(
            child: Material(
              shape: widget.centered ? null : const CircleBorder(),
              clipBehavior: widget.centered ? Clip.none : Clip.antiAlias,
              color: widget.centered ? Colors.transparent : null,
              elevation: widget.centered ? 0 : 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _setOpen(false),
                child: Padding(
                  padding: EdgeInsets.all(widget.centered ? 12 : 8),
                  child: Icon(
                    Icons.close,
                    size: widget.centered ? 20 : 25,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;

    for (var i = 0, distance = widget.distance; i < count; i++, distance += widget.distance) {
      children.add(
        _ThunderExpandingActionButton(
          maxDistance: distance,
          progress: _expandAnimation,
          centered: widget.centered,
          child: widget.children[i],
        ),
      );
    }

    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _isOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(_isOpen ? 0.7 : 1, _isOpen ? 0.7 : 1, 1),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _isOpen ? 0 : 1,
          curve: const Interval(0.25, 1, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy < -5) {
                _setOpen(true);
                widget.onSlideUp?.call();
              }
              if (details.delta.dy > 5) {
                widget.onSlideDown?.call();
              }
            },
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx < -5) widget.onSlideLeft?.call();
            },
            onLongPress: () {
              HapticFeedback.heavyImpact();
              widget.onLongPress?.call();
            },
            onTapDown: (_) => HapticFeedback.mediumImpact(),
            child: widget.centered
                ? SizedBox(
                    width: 45,
                    height: 45,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onPressed?.call();
                        },
                        child: Icon(widget.icon.icon, size: 20, semanticLabel: widget.icon.semanticLabel),
                      ),
                    ),
                  )
                : FloatingActionButton(
                    heroTag: widget.heroTag,
                    backgroundColor: widget.fabBackgroundColor,
                    onPressed: widget.onPressed,
                    child: widget.icon,
                  ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ThunderExpandingActionButton extends StatefulWidget {
  const _ThunderExpandingActionButton({
    required this.maxDistance,
    required this.progress,
    required this.child,
    this.centered = false,
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final bool centered;

  @override
  State<_ThunderExpandingActionButton> createState() => _ThunderExpandingActionButtonState();
}

class _ThunderExpandingActionButtonState extends State<_ThunderExpandingActionButton> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          90 * (math.pi / 180.0),
          widget.progress.value * widget.maxDistance,
        );
        _visible = !widget.progress.isDismissed;

        return Visibility(
          visible: _visible,
          child: Positioned(
            right: widget.centered ? null : 8 + offset.dx,
            bottom: (widget.centered ? 15 : 10) + offset.dy,
            child: child!,
          ),
        );
      },
      child: FadeTransition(opacity: widget.progress, child: widget.child),
    );
  }
}
