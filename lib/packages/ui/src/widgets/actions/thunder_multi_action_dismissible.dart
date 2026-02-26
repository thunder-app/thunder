import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ThunderSwipeBackgroundBuilder<T> = Widget Function(
  BuildContext context,
  DismissDirection effectiveDirection,
  double progress,
  ThunderSwipeAction<T>? action,
);

class ThunderSwipeAction<T> {
  const ThunderSwipeAction({
    required this.value,
    this.icon,
    required this.color,
  });

  final T value;
  final IconData? icon;
  final Color Function(BuildContext context) color;
}

class ThunderMultiActionDismissible<T> extends StatefulWidget {
  const ThunderMultiActionDismissible({
    super.key,
    required this.child,
    required this.direction,
    required this.leftActions,
    required this.rightActions,
    this.actionThresholds = const [0.15, 0.35],
    this.enableHaptics = true,
    this.enableBackSwipeOverride = true,
    this.onAction,
    this.onProgressChanged,
    this.onPointerDown,
    this.onDragEnd,
    this.backgroundBuilder,
    this.backgroundMaxWidthFactor = 1.0,
  });

  final Widget child;
  final DismissDirection direction;
  final List<double> actionThresholds;
  final List<ThunderSwipeAction<T>> leftActions;
  final List<ThunderSwipeAction<T>> rightActions;
  final void Function(ThunderSwipeAction<T> action)? onAction;
  final void Function(double progress, DismissDirection direction, ThunderSwipeAction<T>? action)? onProgressChanged;
  final VoidCallback? onPointerDown;
  final void Function(double verticalDelta)? onDragEnd;
  final bool enableHaptics;
  final bool enableBackSwipeOverride;
  final ThunderSwipeBackgroundBuilder<T>? backgroundBuilder;
  final double backgroundMaxWidthFactor;

  @override
  State<ThunderMultiActionDismissible<T>> createState() => _ThunderMultiActionDismissibleState<T>();
}

class _ThunderMultiActionDismissibleState<T> extends State<ThunderMultiActionDismissible<T>> {
  double _progress = 0;
  ThunderSwipeAction<T>? _currentAction;
  DismissDirection _currentDirection = DismissDirection.startToEnd;
  bool _overrideSwipe = false;
  double _lastVerticalDelta = 0;

  void _handlePointerMove(PointerMoveEvent event) {
    _lastVerticalDelta = event.delta.dy;

    if (!widget.enableBackSwipeOverride) return;
    if (widget.direction != DismissDirection.endToStart) return;

    final isSwipingRight = event.delta.dx > 0;

    if (isSwipingRight && !_overrideSwipe && _progress == 0) {
      setState(() => _overrideSwipe = true);
    } else if (!isSwipingRight && _overrideSwipe) {
      setState(() => _overrideSwipe = false);
    }
  }

  void _handlePointerUp() {
    if (_overrideSwipe) setState(() => _overrideSwipe = false);
    if (_currentAction != null) widget.onAction?.call(_currentAction!);
    widget.onDragEnd?.call(_lastVerticalDelta);
  }

  void _onUpdate(DismissUpdateDetails details) {
    final progress = details.progress;
    final dir = details.direction;

    ThunderSwipeAction<T>? next;
    final isStartToEnd = dir == DismissDirection.startToEnd;
    if (widget.actionThresholds.isNotEmpty && progress > widget.actionThresholds.first) {
      int tierIndex = 0;
      for (int i = 0; i < widget.actionThresholds.length; i++) {
        if (progress >= widget.actionThresholds[i]) {
          tierIndex = i;
        } else {
          break;
        }
      }

      final actions = isStartToEnd ? widget.leftActions : widget.rightActions;
      if (actions.isNotEmpty) {
        final actionIndex = tierIndex.clamp(0, actions.length - 1);
        next = actions[actionIndex];
      }
    } else {
      next = null;
    }

    final actionChanged = next != _currentAction && next != null;

    setState(() {
      _progress = progress;
      _currentDirection = dir;
      _currentAction = next;
    });

    widget.onProgressChanged?.call(_progress, _currentDirection, _currentAction);

    if (actionChanged && widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
  }

  Widget _buildDefaultBackground(BuildContext context) {
    final alignment = _currentDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight;
    final actions = _currentDirection == DismissDirection.startToEnd ? widget.leftActions : widget.rightActions;
    final fallback = actions.isNotEmpty ? actions.first : null;

    final leadingThreshold = widget.actionThresholds.isNotEmpty ? widget.actionThresholds.first : 1.0;
    final defaultColor = fallback?.color(context) ?? Theme.of(context).colorScheme.primaryContainer;
    final backgroundColor = _currentAction != null ? _currentAction!.color(context) : defaultColor.withValues(alpha: leadingThreshold == 0 ? 0 : (_progress / leadingThreshold).clamp(0.0, 1.0));

    final width = MediaQuery.of(context).size.width * widget.backgroundMaxWidthFactor * _progress;
    final icon = _currentAction?.icon;

    return AnimatedContainer(
      alignment: alignment,
      duration: const Duration(milliseconds: 200),
      color: backgroundColor,
      child: SizedBox(
        width: width,
        child: icon != null ? Icon(icon) : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.direction == DismissDirection.none;
    Widget content = widget.child;

    if (!disabled) {
      content = Dismissible(
        key: widget.key ?? UniqueKey(),
        direction: _overrideSwipe ? DismissDirection.none : widget.direction,
        resizeDuration: Duration.zero,
        dismissThresholds: const {
          DismissDirection.endToStart: 1,
          DismissDirection.startToEnd: 1,
        },
        confirmDismiss: (_) async => false,
        onUpdate: _onUpdate,
        background: widget.backgroundBuilder?.call(context, _currentDirection, _progress, _currentAction) ?? _buildDefaultBackground(context),
        child: widget.child,
      );
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => widget.onPointerDown?.call(),
      onPointerMove: _handlePointerMove,
      onPointerUp: (_) => _handlePointerUp(),
      child: content,
    );
  }
}
