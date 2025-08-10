import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/src/core/enums/swipe_action.dart';

typedef SwipeBackgroundBuilder = Widget Function(
  BuildContext context,
  DismissDirection effectiveDirection,
  double progress,
  SwipeAction? action,
);

typedef SwipeIconResolver = IconData? Function(SwipeAction action);

/// A dismissible widget that supports multiple swipe actions.
class MultiActionDismissible extends StatefulWidget {
  const MultiActionDismissible({
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

  /// The content of the dismissible widget.
  final Widget child;

  /// The allowed swipe directions.
  final DismissDirection direction;

  /// The thresholds (0.0 - 1.0 of width) at which successive actions should trigger.
  ///
  /// For example: [0.15, 0.35, 0.6] supports up to 3 actions.
  /// If there are more thresholds than actions on a side, the last action repeats for further thresholds.
  /// If empty, no actions will be triggered.
  final List<double> actionThresholds;

  /// The actions to be displayed on the left side of the widget, ordered from shortest to longest swipe.
  final List<SwipeAction> leftActions;

  /// The actions to be displayed on the right side of the widget, ordered from shortest to longest swipe.
  final List<SwipeAction> rightActions;

  /// The action to be performed when the user releases the widget.
  final void Function(SwipeAction action)? onAction;

  /// A callback that is called when the progress changes.
  final void Function(double progress, DismissDirection direction, SwipeAction? action)? onProgressChanged;

  /// A callback that is called when the user presses down on the widget.
  final VoidCallback? onPointerDown;

  /// A callback that is called when the user releases the widget.
  final void Function(double verticalDelta)? onDragEnd;

  /// Whether to produce haptic feedback when the action changes.
  final bool enableHaptics;

  /// Whether to temporarily disable swipe. This is used to allow the system back gesture to work when the user is swiping right.
  final bool enableBackSwipeOverride;

  /// A custom background builder. If not provided, a default will be used.
  final SwipeBackgroundBuilder? backgroundBuilder;

  /// The max width fraction used by the default background.
  final double backgroundMaxWidthFactor;

  @override
  State<MultiActionDismissible> createState() => _MultiActionDismissibleState();
}

class _MultiActionDismissibleState extends State<MultiActionDismissible> {
  double _progress = 0.0;
  SwipeAction? _currentAction;
  DismissDirection _currentDirection = DismissDirection.startToEnd;
  bool _overrideSwipe = false;
  double _lastVerticalDelta = 0.0;

  void _handlePointerDown() {
    widget.onPointerDown?.call();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _lastVerticalDelta = event.delta.dy;

    if (!widget.enableBackSwipeOverride) return;
    if (widget.direction != DismissDirection.endToStart) return;

    final bool isSwipingRight = event.delta.dx > 0;

    if (isSwipingRight && !_overrideSwipe && _progress == 0.0) {
      setState(() => _overrideSwipe = true);
    } else if (!isSwipingRight && _overrideSwipe) {
      setState(() => _overrideSwipe = false);
    }
  }

  void _handlePointerUp() {
    if (_overrideSwipe) setState(() => _overrideSwipe = false);
    if (_currentAction != null && _currentAction != SwipeAction.none) widget.onAction?.call(_currentAction!);
    widget.onDragEnd?.call(_lastVerticalDelta);
  }

  void _onUpdate(DismissUpdateDetails details) {
    final progress = details.progress;
    final dir = details.direction;

    SwipeAction? next;
    final bool isStartToEnd = dir == DismissDirection.startToEnd;
    if (widget.actionThresholds.isNotEmpty && progress > widget.actionThresholds.first) {
      int tierIndex = 0;
      for (int i = 0; i < widget.actionThresholds.length; i++) {
        if (progress >= widget.actionThresholds[i]) {
          tierIndex = i;
        } else {
          break;
        }
      }
      final List<SwipeAction> actions = isStartToEnd ? widget.leftActions : widget.rightActions;
      if (actions.isNotEmpty) {
        final int actionIndex = tierIndex.clamp(0, actions.length - 1);
        next = actions[actionIndex];
      }
    } else {
      next = null;
    }

    final bool actionChanged = next != _currentAction && next != null;

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
    final fallback = actions.isNotEmpty ? actions.first : SwipeAction.none;
    final defaultColor = fallback.getColor(context);
    final double leadingThreshold = widget.actionThresholds.isNotEmpty ? widget.actionThresholds.first : 1.0;
    final backgroundColor = _currentAction != null ? _currentAction!.getColor(context) : defaultColor.withValues(alpha: leadingThreshold == 0 ? 0 : (_progress / leadingThreshold).clamp(0.0, 1.0));

    final width = MediaQuery.of(context).size.width * widget.backgroundMaxWidthFactor * _progress;
    final icon = _currentAction?.getIcon();

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
      onPointerDown: (_) => _handlePointerDown(),
      onPointerMove: _handlePointerMove,
      onPointerUp: (_) => _handlePointerUp(),
      child: content,
    );
  }
}
