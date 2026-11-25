import 'dart:async';

import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> thunderNavigatorKey = GlobalKey<NavigatorState>();

typedef ThunderOverlayBuilder = Widget Function(BuildContext context, Animation<double> animation, VoidCallback dismiss);

class ThunderOverlayEntry {
  ThunderOverlayEntry._();

  final GlobalKey<_TimedOverlayState> _key = GlobalKey<_TimedOverlayState>();
  OverlayEntry? _entry;

  void dismiss({bool immediately = false}) {
    if (_entry == null) return;
    final state = _key.currentState;
    if (immediately || state == null) {
      _remove();
    } else {
      state.dismiss();
    }
  }

  void _remove() {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    entry.remove();
    entry.dispose();
  }
}

ThunderOverlayEntry showThunderOverlay({required OverlayState overlay, required Duration duration, required Duration animationDuration, required ThunderOverlayBuilder builder}) {
  final handle = ThunderOverlayEntry._();
  final entry = OverlayEntry(
    builder: (context) => _TimedOverlay(key: handle._key, duration: duration, animationDuration: animationDuration, builder: builder, onDismissed: handle._remove),
  );
  handle._entry = entry;
  overlay.insert(entry);
  return handle;
}

class _TimedOverlay extends StatefulWidget {
  const _TimedOverlay({super.key, required this.duration, required this.animationDuration, required this.builder, required this.onDismissed});

  final Duration duration;
  final Duration animationDuration;
  final ThunderOverlayBuilder builder;
  final VoidCallback onDismissed;

  @override
  State<_TimedOverlay> createState() => _TimedOverlayState();
}

class _TimedOverlayState extends State<_TimedOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration)
      ..addStatusListener(_onAnimationStatus)
      ..forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.duration > Duration.zero) {
      _timer = Timer(widget.duration, dismiss);
    } else if (status == AnimationStatus.dismissed) {
      widget.onDismissed();
    }
  }

  void dismiss() {
    _timer?.cancel();
    _controller.reverse();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller, dismiss);
}
