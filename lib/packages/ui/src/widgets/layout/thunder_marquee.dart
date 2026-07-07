import 'package:flutter/material.dart';

/// Scroll animation mode for [ThunderMarquee].
enum ThunderMarqueeDirection {
  /// Scrolls in one direction only.
  oneDirection,

  /// Scrolls forward, pauses, then scrolls back.
  twoDirection,
}

/// Animated scrolling text or child content.
class ThunderMarquee extends StatefulWidget {
  const ThunderMarquee({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.textDirection = TextDirection.ltr,
    this.animationDuration = const Duration(milliseconds: 5000),
    this.backDuration = const Duration(milliseconds: 5000),
    this.pauseDuration = const Duration(milliseconds: 2000),
    this.marqueeDirection = ThunderMarqueeDirection.twoDirection,
    this.forwardAnimation = Curves.easeIn,
    this.backwardAnimation = Curves.easeOut,
    this.autoRepeat = true,
  });

  /// Content to scroll.
  final Widget child;

  /// Scroll axis.
  final Axis direction;

  /// Text direction for the scroll view.
  final TextDirection textDirection;

  /// Duration of the forward scroll animation.
  final Duration animationDuration;

  /// Duration of the backward scroll animation in two-direction mode.
  final Duration backDuration;

  /// Pause between scroll segments.
  final Duration pauseDuration;

  /// Whether to scroll one way or back and forth.
  final ThunderMarqueeDirection marqueeDirection;

  /// Curve for the forward scroll animation.
  final Cubic forwardAnimation;

  /// Curve for the backward scroll animation.
  final Cubic backwardAnimation;

  /// Whether to repeat the scroll animation.
  final bool autoRepeat;

  @override
  State<ThunderMarquee> createState() => _ThunderMarqueeState();
}

class _ThunderMarqueeState extends State<ThunderMarquee> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll(true);
  }

  Future<void> _scroll(bool repeated) async {
    do {
      if (_scrollController.hasClients) {
        await Future.delayed(widget.pauseDuration);
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: widget.animationDuration,
            curve: widget.forwardAnimation,
          );
        }
        await Future.delayed(widget.pauseDuration);
        if (_scrollController.hasClients) {
          switch (widget.marqueeDirection) {
            case ThunderMarqueeDirection.oneDirection:
              _scrollController.jumpTo(0);
            case ThunderMarqueeDirection.twoDirection:
              await _scrollController.animateTo(0, duration: widget.backDuration, curve: widget.backwardAnimation);
          }
        }
        repeated = widget.autoRepeat;
      } else {
        await Future.delayed(widget.pauseDuration);
      }
    } while (repeated && mounted);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.textDirection,
      child: SingleChildScrollView(
        scrollDirection: widget.direction,
        controller: _scrollController,
        child: widget.child,
      ),
    );
  }
}
