import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/packages/ui/src/widgets/actions/thunder_swipe_action_background.dart';

/// Builds the swipe background for [ThunderMultiActionDismissible].
typedef ThunderSwipeBackgroundBuilder<T> = Widget Function(BuildContext context, DismissDirection effectiveDirection, double progress, ThunderSwipeAction<T>? action);

/// Swipe action definition with icon and dynamic background color.
@immutable
class ThunderSwipeAction<T> {
  const ThunderSwipeAction({required this.value, this.icon, required this.color});

  /// Payload returned when this action is triggered.
  final T value;

  /// Optional icon shown in the swipe background.
  final IconData? icon;

  /// Resolves the background color for this action.
  final Color Function(BuildContext context) color;
}

/// Dismissible wrapper that reveals tiered swipe actions without dismissing.
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

  /// Content revealed while swiping.
  final Widget child;

  /// Allowed swipe direction for revealing actions.
  final DismissDirection direction;

  /// Progress thresholds that map to action tiers.
  final List<double> actionThresholds;

  /// Actions revealed when swiping start to end.
  final List<ThunderSwipeAction<T>> leftActions;

  /// Actions revealed when swiping end to start.
  final List<ThunderSwipeAction<T>> rightActions;

  /// Called when a swipe action tier is committed on pointer up.
  final void Function(ThunderSwipeAction<T> action)? onAction;

  /// Called as swipe progress or the active action changes.
  final void Function(double progress, DismissDirection direction, ThunderSwipeAction<T>? action)? onProgressChanged;

  /// Called when a pointer goes down on the dismissible area.
  final void Function()? onPointerDown;

  /// Called on pointer up with the last vertical drag delta.
  final void Function(double verticalDelta)? onDragEnd;

  /// Whether to emit haptic feedback when the active action changes.
  final bool enableHaptics;

  /// Whether a right swipe can temporarily disable end-to-start dismissal.
  final bool enableBackSwipeOverride;

  /// Optional custom background builder. Defaults to a themed color fill.
  final ThunderSwipeBackgroundBuilder<T>? backgroundBuilder;

  /// Maximum background width as a fraction of screen width.
  final double backgroundMaxWidthFactor;

  @override
  State<ThunderMultiActionDismissible<T>> createState() => _ThunderMultiActionDismissibleState<T>();
}

class _ThunderMultiActionDismissibleState<T> extends State<ThunderMultiActionDismissible<T>> {
  late final Key _dismissibleKey;

  double _progress = 0;
  ThunderSwipeAction<T>? _currentAction;
  DismissDirection _currentDirection = DismissDirection.startToEnd;
  bool _overrideSwipe = false;
  double _lastVerticalDelta = 0;

  @override
  void initState() {
    super.initState();
    _dismissibleKey = widget.key ?? ValueKey(identityHashCode(this));
  }

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

  @override
  Widget build(BuildContext context) {
    final disabled = widget.direction == DismissDirection.none;
    Widget content = widget.child;

    if (!disabled) {
      content = Dismissible(
        key: _dismissibleKey,
        direction: _overrideSwipe ? DismissDirection.none : widget.direction,
        resizeDuration: Duration.zero,
        dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
        confirmDismiss: (_) async => false,
        onUpdate: _onUpdate,
        background:
            widget.backgroundBuilder?.call(context, _currentDirection, _progress, _currentAction) ??
            _ThunderSwipeDefaultBackground<T>(
              currentDirection: _currentDirection,
              progress: _progress,
              currentAction: _currentAction,
              leftActions: widget.leftActions,
              rightActions: widget.rightActions,
              actionThresholds: widget.actionThresholds,
              backgroundMaxWidthFactor: widget.backgroundMaxWidthFactor,
            ),
        child: widget.child,
      );
    }

    return Listener(behavior: HitTestBehavior.opaque, onPointerDown: (_) => widget.onPointerDown?.call(), onPointerMove: _handlePointerMove, onPointerUp: (_) => _handlePointerUp(), child: content);
  }
}

/// Default swipe background for [ThunderMultiActionDismissible].
class _ThunderSwipeDefaultBackground<T> extends StatelessWidget {
  const _ThunderSwipeDefaultBackground({
    required this.currentDirection,
    required this.progress,
    required this.currentAction,
    required this.leftActions,
    required this.rightActions,
    required this.actionThresholds,
    required this.backgroundMaxWidthFactor,
  });

  /// The current swipe direction.
  final DismissDirection currentDirection;

  /// The current swipe progress.
  final double progress;

  /// The currently active swipe action, if any.
  final ThunderSwipeAction<T>? currentAction;

  /// Actions revealed when swiping start to end.
  final List<ThunderSwipeAction<T>> leftActions;

  /// Actions revealed when swiping end to start.
  final List<ThunderSwipeAction<T>> rightActions;

  /// Progress thresholds that map to action tiers.
  final List<double> actionThresholds;

  /// Maximum background width as a fraction of screen width.
  final double backgroundMaxWidthFactor;

  @override
  Widget build(BuildContext context) {
    final alignment = currentDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight;
    final actions = currentDirection == DismissDirection.startToEnd ? leftActions : rightActions;
    final fallback = actions.isNotEmpty ? actions.first : null;

    final leadingThreshold = actionThresholds.isNotEmpty ? actionThresholds.first : 1.0;
    final defaultColor = fallback?.color(context) ?? Theme.of(context).colorScheme.primaryContainer;
    final backgroundColor = currentAction != null ? currentAction!.color(context) : defaultColor.withValues(alpha: leadingThreshold == 0 ? 0 : (progress / leadingThreshold).clamp(0.0, 1.0));

    final width = MediaQuery.sizeOf(context).width * backgroundMaxWidthFactor * progress;

    return ThunderSwipeActionBackground(alignment: alignment, backgroundColor: backgroundColor, width: width, icon: currentAction?.icon);
  }
}
