import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Used by [PageTransitionsTheme] to define a horizontal [MaterialPageRoute]
/// page transition animation that matches [SwipeablePageRoute].
///
/// See [SwipeablePageRoute] for documentation of all properties.
///
/// ⚠️ [SwipeablePageTransitionsBuilder] *must* be set for [TargetPlatform.iOS].
/// For all other platforms, you can decide whether you want to use it. This is
/// because [PageTransitionsTheme] uses the builder for iOS whenever a pop
/// gesture is in progress.
class SwipeablePageTransitionsBuilder extends PageTransitionsBuilder {
  const SwipeablePageTransitionsBuilder({
    this.canOnlySwipeFromEdge = false,
    this.backGestureDetectionWidth = kMinInteractiveDimension,
    this.backGestureDetectionStartOffset = 0,
    this.transitionBuilder,
  });

  final bool canOnlySwipeFromEdge;
  final double backGestureDetectionWidth;
  final double backGestureDetectionStartOffset;
  final SwipeableTransitionBuilder? transitionBuilder;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SwipeablePageRoute.buildPageTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
      canOnlySwipeFromEdge: () => canOnlySwipeFromEdge,
      backGestureDetectionWidth: () => backGestureDetectionWidth,
      backGestureDetectionStartOffset: () => backGestureDetectionStartOffset,
      transitionBuilder: transitionBuilder,
    );
  }
}

/// A specialized [CupertinoPageRoute] that allows for swiping back anywhere on
/// the page unless `canOnlySwipeFromEdge` is `true`.
///
/// See also:
///
///  * [SwipeablePage], for a [Page] version of this class.
class SwipeablePageRoute<T> extends CupertinoPageRoute<T> {
  SwipeablePageRoute({
    this.canSwipe = true,
    this.canOnlySwipeFromEdge = false,
    this.backGestureDetectionWidth = kMinInteractiveDimension,
    this.backGestureDetectionStartOffset = 0.0,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    SwipeableTransitionBuilder? transitionBuilder,
    required super.builder,
    super.title,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.barrierDismissible,
  })  : _transitionDuration = transitionDuration,
        _reverseTransitionDuration = reverseTransitionDuration,
        transitionBuilder = transitionBuilder ?? _defaultTransitionBuilder(fullscreenDialog);

  /// {@template swipeable_page_route.SwipeablePageRoute.canSwipe}
  /// Whether the user can swipe to navigate back.
  ///
  /// Set this to `false` to disable swiping completely.
  /// {@endtemplate}
  bool canSwipe;

  /// {@template swipeable_page_route.SwipeablePageRoute.canOnlySwipeFromEdge}
  /// Whether only back gestures close to the left (LTR) or right (RTL) screen
  /// edge are counted.
  ///
  /// This only takes effect if [canSwipe] ist set to `true`.
  ///
  /// If set to `true`, this distance can be controlled via
  /// [backGestureDetectionWidth].
  /// If set to `false`, the user can start dragging anywhere on the screen.
  /// {@endtemplate}
  bool canOnlySwipeFromEdge;

  // ignore: lines_longer_than_80_chars
  /// {@template swipeable_page_route.SwipeablePageRoute.backGestureDetectionWidth}
  /// If [canOnlySwipeFromEdge] is set to `true`, this value controls the width
  /// of the gesture detection area.
  ///
  /// For comparison, in [CupertinoPageRoute], this value is `20`.
  /// {@endtemplate}
  double backGestureDetectionWidth;

  // ignore: lines_longer_than_80_chars
  /// {@template swipeable_page_route.SwipeablePageRoute.backGestureDetectionStartOffset}
  /// If [canOnlySwipeFromEdge] is set to `true`, this value controls how far
  /// away from the left (LTR) or right (RTL) screen edge a gesture must start
  /// to be recognized for back navigation.
  /// {@endtemplate}
  double backGestureDetectionStartOffset;

  /// An optional override for the [transitionDuration].
  final Duration? _transitionDuration;
  @override
  Duration get transitionDuration => _transitionDuration ?? super.transitionDuration;

  /// An optional override for the [reverseTransitionDuration].
  final Duration? _reverseTransitionDuration;
  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration ?? super.reverseTransitionDuration;

  /// {@template swipeable_page_route.SwipeablePageRoute.transitionBuilder}
  /// Custom builder to wrap the child widget.
  ///
  /// By default, this wraps the child in a [CupertinoPageTransition], or, if
  /// it's a full-screen dialog, in a [CupertinoFullscreenDialogTransition].
  ///
  /// You can override this to, e.g., customize the position or shadow
  /// animations.
  /// {@endtemplate}
  final SwipeableTransitionBuilder transitionBuilder;

  static SwipeableTransitionBuilder _defaultTransitionBuilder(
    bool fullscreenDialog,
  ) {
    return (context, animation, secondaryAnimation, isSwipeGesture, child) => fullscreenDialog
        ? CupertinoFullscreenDialogTransition(
            primaryRouteAnimation: animation,
            secondaryRouteAnimation: secondaryAnimation,
            linearTransition: isSwipeGesture,
            child: child,
          )
        : CupertinoPageTransition(
            primaryRouteAnimation: animation,
            secondaryRouteAnimation: secondaryAnimation,
            linearTransition: isSwipeGesture,
            child: child,
          );
  }

  @override
  bool get popGestureEnabled => _isPopGestureEnabled(this, canSwipe);
  // Copied and modified from `CupertinoRouteTransitionMixin`
  static bool _isPopGestureEnabled<T>(PageRoute<T> route, bool canSwipe) {
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (route.isFirst) return false;
    // If the route wouldn't actually pop if we popped it, then the gesture
    // would be really confusing (or would skip internal routes), so disallow
    // it.
    if (route.willHandlePopInternally) return false;
    // If attempts to dismiss this route might be vetoed such as in a page
    // with forms, then do not allow the user to dismiss the route with a swipe.
    // ignore: deprecated_member_use
    if (route.hasScopedWillPopCallback || route.popDisposition == RoutePopDisposition.doNotPop) {
      return false;
    }
    // Fullscreen dialogs aren't dismissible by back swipe.
    if (route.fullscreenDialog) return false;
    // If we're in an animation already, we cannot be manually swiped.
    if (route.animation!.status != AnimationStatus.completed) return false;
    // If we're being popped into, we also cannot be swiped until the pop above
    // it completes. This translates to our secondary animation being
    // dismissed.
    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) {
      return false;
    }
    // If we're in a gesture already, we cannot start another.
    if (route.popGestureInProgress) return false;

    // Added
    if (!canSwipe) return false;

    // Looks like a back gesture would be welcome!
    return true;
  }

  // Called by `_FancyBackGestureDetector` when a pop ("back") drag start
  // gesture is detected. The returned controller handles all of the subsequent
  // drag events.
  static _CupertinoBackGestureController<T> _startPopGesture<T>(
    PageRoute<T> route,
  ) =>
      _CupertinoBackGestureController<T>(
        navigator: route.navigator!,
        controller: route.controller!, // protected access
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildPageTransitions(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
      canSwipe: () => canSwipe,
      canOnlySwipeFromEdge: () => canOnlySwipeFromEdge,
      backGestureDetectionWidth: () => backGestureDetectionWidth,
      backGestureDetectionStartOffset: () => backGestureDetectionStartOffset,
      transitionBuilder: transitionBuilder,
    );
  }

  static Widget buildPageTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    ValueGetter<bool> canSwipe = _defaultCanSwipe,
    ValueGetter<bool> canOnlySwipeFromEdge = _defaultCanOnlySwipeFromEdge,
    ValueGetter<double> backGestureDetectionWidth = _defaultBackGestureDetectionWidth,
    ValueGetter<double> backGestureDetectionStartOffset = _defaultBackGestureDetectionStartOffset,
    SwipeableTransitionBuilder? transitionBuilder,
  }) {
    final Widget wrappedChild = route.fullscreenDialog
        ? child
        : _FancyBackGestureDetector<T>(
            enabledCallback: () => _isPopGestureEnabled(route, canSwipe()),
            onStartPopGesture: () {
              assert(
                _isPopGestureEnabled(route, canSwipe()),
                'Pop gesture is not enabled',
              );
              return _startPopGesture(route);
            },
            canOnlySwipeFromEdge: canOnlySwipeFromEdge,
            backGestureDetectionWidth: backGestureDetectionWidth,
            backGestureDetectionStartOffset: backGestureDetectionStartOffset,
            child: child,
          );

    transitionBuilder ??= _defaultTransitionBuilder(route.fullscreenDialog);
    return transitionBuilder(
      context,
      animation,
      secondaryAnimation,
      /* isSwipeGesture: */ route.popGestureInProgress,
      wrappedChild,
    );
  }

  static bool _defaultCanSwipe() => true;
  static bool _defaultCanOnlySwipeFromEdge() => false;
  static double _defaultBackGestureDetectionWidth() => kMinInteractiveDimension;
  static double _defaultBackGestureDetectionStartOffset() => 0;
}

typedef SwipeableTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  // ignore: avoid_positional_boolean_parameters
  bool isSwipeGesture,
  Widget child,
);

/// A specialized variant of [CupertinoPage] that allows for swiping back
/// anywhere on the page unless `canOnlySwipeFromEdge` is `true`.
///
/// See also:
///
///  * [SwipeablePageRoute], for a [PageRoute] version of this class.
class SwipeablePage<T> extends Page<T> {
  SwipeablePage({
    this.canSwipe = true,
    this.canOnlySwipeFromEdge = false,
    this.backGestureDetectionWidth = kMinInteractiveDimension,
    this.backGestureDetectionStartOffset = 0.0,
    this.transitionDuration,
    this.reverseTransitionDuration,
    SwipeableTransitionBuilder? transitionBuilder,
    this.title,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    required this.builder,
  }) : transitionBuilder = transitionBuilder ?? SwipeablePageRoute._defaultTransitionBuilder(fullscreenDialog);

  /// {@macro swipeable_page_route.SwipeablePageRoute.canSwipe}
  final bool canSwipe;

  /// {@macro swipeable_page_route.SwipeablePageRoute.canOnlySwipeFromEdge}
  final bool canOnlySwipeFromEdge;

  /// {@macro swipeable_page_route.SwipeablePageRoute.backGestureDetectionWidth}
  final double backGestureDetectionWidth;

  // ignore: lines_longer_than_80_chars
  /// {@macro swipeable_page_route.SwipeablePageRoute.backGestureDetectionStartOffset}
  final double backGestureDetectionStartOffset;

  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;

  /// {@macro swipeable_page_route.SwipeablePageRoute.transitionBuilder}
  final SwipeableTransitionBuilder transitionBuilder;

  /// {@macro flutter.cupertino.CupertinoRouteTransitionMixin.title}
  final String? title;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.allowSnapshotting}
  final bool allowSnapshotting;

  /// The content to be shown in the [Route] created by this page.
  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) {
    return SwipeablePageRoute(
      canSwipe: canSwipe,
      canOnlySwipeFromEdge: canOnlySwipeFromEdge,
      backGestureDetectionWidth: backGestureDetectionWidth,
      backGestureDetectionStartOffset: backGestureDetectionStartOffset,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionBuilder: transitionBuilder,
      builder: builder,
      title: title,
      settings: this,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
    );
  }
}

extension BuildContextSwipeablePageRoute on BuildContext {
  SwipeablePageRoute<T>? getSwipeablePageRoute<T>() {
    final route = ModalRoute.of(this);
    return route is SwipeablePageRoute<T> ? route : null;
  }
}

// Mostly copies and modified variations of the private widgets related to
// [CupertinoPageRoute].

const double _kMinFlingVelocity = 1; // Screen widths per second.

// An eyeballed value for the maximum time it takes for a page to animate
// forward if the user releases a page mid swipe.
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.

// The maximum time for a page to get reset to it's original position if the
// user releases a page mid swipe.
const int _kMaxPageBackAnimationTime = 300; // Milliseconds.

// An adapted version of `_CupertinoBackGestureDetector`.
class _FancyBackGestureDetector<T> extends StatefulWidget {
  const _FancyBackGestureDetector({
    super.key,
    required this.canOnlySwipeFromEdge,
    required this.backGestureDetectionWidth,
    required this.backGestureDetectionStartOffset,
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
  });

  final ValueGetter<bool> canOnlySwipeFromEdge;
  final ValueGetter<double> backGestureDetectionWidth;
  final ValueGetter<double> backGestureDetectionStartOffset;

  final Widget child;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_CupertinoBackGestureController<T>> onStartPopGesture;

  @override
  _FancyBackGestureDetectorState<T> createState() => _FancyBackGestureDetectorState<T>();
}

class _FancyBackGestureDetectorState<T> extends State<_FancyBackGestureDetector<T>> {
  _CupertinoBackGestureController<T>? _backGestureController;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context), 'Directionality is not set');

    final gestureDetector = RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _DirectionDependentDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<_DirectionDependentDragGestureRecognizer>(
          _gestureRecognizerConstructor,
          (instance) => instance
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd
            ..onCancel = _handleDragCancel,
        ),
      },
    );

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(child: gestureDetector),
      ],
    );
  }

  _DirectionDependentDragGestureRecognizer _gestureRecognizerConstructor() {
    return _DirectionDependentDragGestureRecognizer(
      debugOwner: this,
      directionality: Directionality.of(context),
      checkStartedCallback: () => _backGestureController != null,
      enabledCallback: widget.enabledCallback,
      detectionArea: () => widget.canOnlySwipeFromEdge()
          ? (
              startOffset: widget.backGestureDetectionStartOffset(),
              width: _dragAreaWidth(context),
            )
          : null,
    );
  }

  void _handleDragStart(DragStartDetails _) {
    assert(mounted, 'Widget is not mounted');
    assert(
      _backGestureController == null,
      'Back gesture controller is not null',
    );
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted, 'Widget is not mounted');
    assert(_backGestureController != null, 'Back gesture controller is null');
    _backGestureController!.dragUpdate(
      _convertToLogical(details.primaryDelta! / context.size!.width),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted, 'Widget is not mounted');
    assert(_backGestureController != null, 'Back gesture controller is null');
    _backGestureController!.dragEnd(
      _convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size!.width,
      ),
    );
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted, 'Widget is not mounted');
    // This can be called even if start is not called, paired with the "down"
    // event that we don't consider here.
    _backGestureController?.dragEnd(0);
    _backGestureController = null;
  }

  double _convertToLogical(double value) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => -value,
      TextDirection.ltr => value,
    };
  }

  double _dragAreaWidth(BuildContext context) {
    // For devices with notches, the drag area needs to be larger on the side
    // that has the notch.
    final dragAreaWidth = switch (Directionality.of(context)) {
      TextDirection.ltr => MediaQuery.paddingOf(context).left,
      TextDirection.rtl => MediaQuery.paddingOf(context).right,
    };
    return math.max(dragAreaWidth, widget.backGestureDetectionWidth());
  }
}

// Copied from `flutter/cupertino`.
class _CupertinoBackGestureController<T> {
  _CupertinoBackGestureController({
    required this.navigator,
    required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  /// The drag gesture has changed by [delta]. The total range of the
  /// drag should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of [velocity] as a
  /// fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final droppedPageForwardAnimationTime = math.min(
        lerpDouble(
          _kMaxDroppedSwipePageForwardAnimationTime,
          0,
          controller.value,
        )!
            .floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1,
        duration: Duration(milliseconds: droppedPageForwardAnimationTime),
        curve: animationCurve,
      );
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();

      // The popping may have finished inline if already at the target
      // destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final droppedPageBackAnimationTime = lerpDouble(
          0,
          _kMaxDroppedSwipePageForwardAnimationTime,
          controller.value,
        )!
            .floor();
        controller.animateBack(
          0,
          duration: Duration(milliseconds: droppedPageBackAnimationTime),
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since CupertinoPageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

class _DirectionDependentDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  _DirectionDependentDragGestureRecognizer({
    required this.directionality,
    required this.enabledCallback,
    required this.detectionArea,
    required this.checkStartedCallback,
    super.debugOwner,
  });

  final TextDirection directionality;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_DetectionArea?> detectionArea;
  final ValueGetter<bool> checkStartedCallback;

  @override
  void handleEvent(PointerEvent event) {
    if (_shouldHandle(event)) {
      super.handleEvent(event);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  bool _shouldHandle(PointerEvent event) {
    if (checkStartedCallback()) return true;
    if (!enabledCallback()) return false;

    final isCorrectDirection = switch ((directionality, event.delta.dx)) {
      (TextDirection.ltr, > 0) || (TextDirection.rtl, < 0) || (_, 0) => true,
      _ => false,
    };
    if (!isCorrectDirection) return false;

    final detectionArea = this.detectionArea();
    final x = event.localPosition.dx;
    if (detectionArea != null && event is PointerDownEvent && (x < detectionArea.startOffset || x > detectionArea.startOffset + detectionArea.width)) {
      return false;
    }

    return true;
  }
}

typedef _DetectionArea = ({double startOffset, double width});
