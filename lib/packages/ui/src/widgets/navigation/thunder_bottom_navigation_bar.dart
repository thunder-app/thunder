import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A [NavigationBar] that handles custom gestures.
class ThunderBottomNavigationBar extends StatefulWidget {
  const ThunderBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.labelBehavior,
    this.onDestinationLongPresses = const {},
    this.longPressTimeout = kLongPressTimeout,
    this.longPressSuppressionDuration = const Duration(seconds: 1),
    this.onHorizontalSwipeLeft,
    this.onHorizontalSwipeRight,
    this.horizontalSwipeThreshold = 20.0,
    this.onDoubleTap,
  });

  /// The index of the currently selected destination.
  final int selectedIndex;

  /// The list of destinations to display in the navigation bar.
  final List<Widget> destinations;

  /// Callback invoked when a destination is selected (tapped).
  final void Function(int) onDestinationSelected;

  /// Controls the visibility of destination labels.
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Long-press callbacks keyed by destination index.
  final Map<int, void Function()> onDestinationLongPresses;

  /// How long a press must be held before the destination long-press fires.
  final Duration longPressTimeout;

  /// How long to suppress the next selection after a long-press fires.
  final Duration longPressSuppressionDuration;

  /// Callback invoked when the bar is swiped left past the threshold.
  final void Function()? onHorizontalSwipeLeft;

  /// Callback invoked when the bar is swiped right past the threshold.
  final void Function()? onHorizontalSwipeRight;

  /// Minimum horizontal drag delta before a swipe callback is fired.
  final double horizontalSwipeThreshold;

  /// Callback invoked when the bar is double-tapped.
  final void Function()? onDoubleTap;

  @override
  State<ThunderBottomNavigationBar> createState() => _ThunderBottomNavigationBarState();
}

class _ThunderBottomNavigationBarState extends State<ThunderBottomNavigationBar> {
  /// Timer used to track long-press duration.
  Timer? _longPressTimer;

  /// The pointer ID currently being tracked for a potential long-press.
  int? _trackedPointer;

  /// The index of the destination currently being tracked for a long-press.
  int? _trackedDestinationIndex;

  /// The original position where the pointer went down, used to detect movement.
  Offset? _pressOrigin;

  /// The index of the destination for which the long-press was last triggered, used to suppress the next selection.
  int? _suppressedDestinationIndex;

  /// The timestamp until which selection of the long-pressed destination should be suppressed.
  DateTime? _suppressSelectionUntil;

  /// The starting X position of a horizontal drag, used to detect swipe gestures.
  double _dragStartX = 0.0;

  /// The ending X position of a horizontal drag, used to detect swipe gestures.
  double _dragEndX = 0.0;

  @override
  void dispose() {
    _cancelLongPressTracking();
    super.dispose();
  }

  int _destinationIndexForOffset(double dx, double maxWidth) {
    if (maxWidth <= 0 || widget.destinations.isEmpty) return -1;

    final clampedDx = dx.clamp(0.0, maxWidth - 0.001);
    return (clampedDx / (maxWidth / widget.destinations.length)).floor();
  }

  void _cancelLongPressTracking() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _trackedPointer = null;
    _trackedDestinationIndex = null;
    _pressOrigin = null;
  }

  void _handlePointerDown(PointerDownEvent event, double maxWidth) {
    _cancelLongPressTracking();

    final destinationIndex = _destinationIndexForOffset(event.localPosition.dx, maxWidth);
    if (!widget.onDestinationLongPresses.containsKey(destinationIndex)) return;

    _trackedPointer = event.pointer;
    _trackedDestinationIndex = destinationIndex;
    _pressOrigin = event.localPosition;
    _longPressTimer = Timer(widget.longPressTimeout, () {
      if (!mounted) return;

      final callback = widget.onDestinationLongPresses[destinationIndex];
      if (callback == null) return;

      _cancelLongPressTracking();
      _suppressedDestinationIndex = destinationIndex;
      _suppressSelectionUntil = DateTime.now().add(widget.longPressSuppressionDuration);
      callback();
    });
  }

  void _handlePointerMove(PointerMoveEvent event, double maxWidth) {
    if (event.pointer != _trackedPointer || _pressOrigin == null || _trackedDestinationIndex == null) return;

    final movedTooFar = (event.localPosition - _pressOrigin!).distance > kTouchSlop;
    final leftTrackedDestination = _destinationIndexForOffset(event.localPosition.dx, maxWidth) != _trackedDestinationIndex;

    if (movedTooFar || leftTrackedDestination) {
      _cancelLongPressTracking();
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _trackedPointer) return;
    _cancelLongPressTracking();
  }

  void _handleDestinationSelected(int index) {
    final shouldSuppressSelection = index == _suppressedDestinationIndex && _suppressSelectionUntil != null && DateTime.now().isBefore(_suppressSelectionUntil!);

    if (shouldSuppressSelection) {
      _suppressedDestinationIndex = null;
      _suppressSelectionUntil = null;
      return;
    }

    _suppressedDestinationIndex = null;
    _suppressSelectionUntil = null;
    widget.onDestinationSelected(index);
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _dragEndX = details.globalPosition.dx;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _dragEndX = details.globalPosition.dx;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final delta = _dragEndX - _dragStartX;

    if (delta > widget.horizontalSwipeThreshold) {
      widget.onHorizontalSwipeRight?.call();
    } else if (delta < -widget.horizontalSwipeThreshold) {
      widget.onHorizontalSwipeLeft?.call();
    }

    _dragStartX = 0.0;
    _dragEndX = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.onHorizontalSwipeLeft != null || widget.onHorizontalSwipeRight != null ? _handleHorizontalDragStart : null,
      onHorizontalDragUpdate: widget.onHorizontalSwipeLeft != null || widget.onHorizontalSwipeRight != null ? _handleHorizontalDragUpdate : null,
      onHorizontalDragEnd: widget.onHorizontalSwipeLeft != null || widget.onHorizontalSwipeRight != null ? _handleHorizontalDragEnd : null,
      onDoubleTap: widget.onDoubleTap,
      child: LayoutBuilder(
        builder: (context, constraints) => Listener(
          onPointerDown: (event) => _handlePointerDown(event, constraints.maxWidth),
          onPointerMove: (event) => _handlePointerMove(event, constraints.maxWidth),
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: NavigationBar(
            selectedIndex: widget.selectedIndex,
            labelBehavior: widget.labelBehavior,
            destinations: widget.destinations,
            onDestinationSelected: _handleDestinationSelected,
          ),
        ),
      ),
    );
  }
}
