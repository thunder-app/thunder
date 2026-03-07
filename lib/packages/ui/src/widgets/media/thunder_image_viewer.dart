import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

/// Describes the image content displayed by a [ThunderImageViewer].
///
/// Create a source with either [ThunderImageViewerSource.network] for cached
/// network images or [ThunderImageViewerSource.memory] for in-memory bytes.
///
/// The optional [contentType] can be used to hint the image format when the URL
/// alone is not sufficient, such as for AVIF images served without an `.avif`
/// file extension.
sealed class ThunderImageViewerSource {
  /// Creates a descriptor for image content shown by a
  /// [ThunderImageViewer].
  const ThunderImageViewerSource({this.contentType});

  /// Creates a source backed by raw in-memory image bytes.
  const factory ThunderImageViewerSource.memory(
    Uint8List bytes, {
    String? contentType,
  }) = ThunderImageViewerMemorySource;

  /// Creates a source backed by a network image URL.
  const factory ThunderImageViewerSource.network(
    String url, {
    String? contentType,
  }) = ThunderImageViewerNetworkSource;

  /// The MIME content type associated with this image, if known.
  final String? contentType;
}

/// A [ThunderImageViewerSource] backed by image bytes held in memory.
class ThunderImageViewerMemorySource extends ThunderImageViewerSource {
  /// Creates a memory-backed image source.
  const ThunderImageViewerMemorySource(this.bytes, {super.contentType});

  /// The encoded image bytes to display.
  final Uint8List bytes;
}

/// A [ThunderImageViewerSource] backed by a network URL.
class ThunderImageViewerNetworkSource extends ThunderImageViewerSource {
  /// Creates a network-backed image source.
  const ThunderImageViewerNetworkSource(this.url, {super.contentType});

  /// The URL used to fetch and cache the image.
  final String url;
}

enum _ViewerGestureMode {
  idle,
  transform,
  dismiss,
}

class ThunderImageViewer extends StatefulWidget {
  /// Creates an interactive image viewer.
  ///
  /// [source] must not be null.
  ///
  /// The viewer supports:
  ///
  ///  * single-tap callbacks through [onTap]
  ///  * double-tap zoom using [doubleTapScales]
  ///  * double-tap-and-drag zoom
  ///  * pinch zoom and panning
  ///  * optional drag-to-dismiss through [dismissible] and [onDismiss]
  const ThunderImageViewer({
    super.key,
    required this.source,
    this.backgroundColor = Colors.black,
    this.contentSize,
    this.dismissible = true,
    this.doubleTapScales = const <double>[2.0, 4.0],
    this.errorBuilder,
    this.filterQuality = FilterQuality.medium,
    this.loadingBuilder,
    this.maxScale = 4.0,
    this.minScale = 1.0,
    this.onDismiss,
    this.onLongPress,
    this.onScaleChanged,
    this.onTap,
    this.semanticLabel,
  })  : assert(minScale > 0),
        assert(maxScale >= minScale);

  /// The color painted behind the image.
  ///
  /// This color also fades during a drag-to-dismiss gesture.
  final Color backgroundColor;

  /// The intrinsic size of the image content, if known.
  ///
  /// When provided, the viewer uses this to compute a more accurate contained
  /// layout before the image is transformed.
  final Size? contentSize;

  /// Whether a vertical drag can dismiss the viewer when it is at rest.
  ///
  /// Dismiss gestures are ignored while zoomed in or while another transform
  /// gesture is active.
  final bool dismissible;

  /// The zoom levels cycled through by a double tap.
  ///
  /// Once all values in this list have been used, the next double tap resets the
  /// viewer back to [minScale].
  final List<double> doubleTapScales;

  /// Builds a widget shown when the image fails to load.
  ///
  /// If null, a default broken-image icon is shown.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// The filter quality used when painting the image.
  final FilterQuality filterQuality;

  /// Builds a widget shown while a network image is still loading.
  ///
  /// If null, a [CircularProgressIndicator] is displayed.
  final WidgetBuilder? loadingBuilder;

  /// The maximum zoom scale allowed by user gestures.
  final double maxScale;

  /// The minimum zoom scale allowed by user gestures.
  ///
  /// This is typically `1.0`, which represents the image's contained layout.
  final double minScale;

  /// Called when the viewer has been dragged far enough to dismiss.
  ///
  /// This callback is only invoked when [dismissible] is true.
  final VoidCallback? onDismiss;

  /// Called when the viewer detects a long press.
  final VoidCallback? onLongPress;

  /// Called whenever the effective zoom scale changes.
  ///
  /// This includes animated double-tap zoom, double-tap-and-drag zoom, pinch
  /// gestures, and snap-back corrections after a gesture ends.
  final ValueChanged<double>? onScaleChanged;

  /// Called after a completed single tap.
  ///
  /// Single taps are delayed slightly so the viewer can distinguish them from a
  /// double tap.
  final VoidCallback? onTap;

  /// The semantic label used for the underlying image.
  final String? semanticLabel;

  /// The source describing the image to display.
  final ThunderImageViewerSource source;

  @override
  State<ThunderImageViewer> createState() => _ThunderImageViewerState();
}

class _ThunderImageViewerState extends State<ThunderImageViewer> with TickerProviderStateMixin {
  static const Duration _doubleTapTimeout = Duration(milliseconds: 280);
  static const double _doubleTapDragSlop = 8;
  static const double _doubleTapSlop = 36;
  static const double _gestureEpsilon = 0.01;

  late final AnimationController _transformAnimationController;

  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;
  Animation<Offset>? _dismissOffsetAnimation;

  Size _baseContentSize = Size.zero;
  Size _viewportSize = Size.zero;

  double _gestureStartScale = 1.0;
  double _scale = 1.0;
  double _doubleTapBaseScale = 1.0;

  Timer? _singleTapTimer;
  DateTime? _lastTapUpTime;

  Offset _dismissOffset = Offset.zero;
  Offset _gestureStartOffset = Offset.zero;
  Offset _offset = Offset.zero;
  Offset _doubleTapBaseOffset = Offset.zero;
  Offset? _doubleTapAnchor;
  Offset? _doubleTapStartLocalPosition;
  Offset? _gestureStartFocalPoint;
  Offset? _lastTapUpPosition;
  Offset? _primaryDownPosition;

  _ViewerGestureMode _gestureMode = _ViewerGestureMode.idle;

  int _activePointers = 0;
  int? _doubleTapPointer;
  int? _primaryTapPointer;

  bool _dragZoomActive = false;
  bool _didTriggerLongPress = false;
  bool _ignoreScaleEnd = false;
  bool _tapMoved = false;

  void _setScale(double value) {
    if ((_scale - value).abs() <= _gestureEpsilon) {
      _scale = value;
      return;
    }

    _scale = value;
    widget.onScaleChanged?.call(value);
  }

  void _handleLongPress() {
    _didTriggerLongPress = true;
    widget.onLongPress?.call();
  }

  @override
  void initState() {
    super.initState();
    _transformAnimationController = AnimationController(vsync: this)..addListener(_handleTransformAnimationTick);
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    _transformAnimationController.dispose();
    super.dispose();
  }

  void _handleTransformAnimationTick() {
    if (!mounted) return;

    setState(() {
      if (_scaleAnimation != null) {
        _setScale(_scaleAnimation!.value);
      }
      if (_offsetAnimation != null) {
        _offset = _offsetAnimation!.value;
      }
      if (_dismissOffsetAnimation != null) {
        _dismissOffset = _dismissOffsetAnimation!.value;
      }
    });
  }

  void _animateTo({
    Duration duration = const Duration(milliseconds: 180),
    Curve curve = Curves.easeOutCubic,
    required double targetScale,
    required Offset targetOffset,
    Offset targetDismissOffset = Offset.zero,
  }) {
    _transformAnimationController
      ..stop()
      ..duration = duration;

    final animation = CurvedAnimation(parent: _transformAnimationController, curve: curve);

    _scaleAnimation = Tween<double>(begin: _scale, end: targetScale).animate(animation);
    _offsetAnimation = Tween<Offset>(begin: _offset, end: targetOffset).animate(animation);
    _dismissOffsetAnimation = Tween<Offset>(begin: _dismissOffset, end: targetDismissOffset).animate(animation);

    _transformAnimationController
      ..reset()
      ..forward();
  }

  Size _resolveBaseContentSize(Size viewportSize) {
    final contentSize = widget.contentSize;

    if (contentSize == null || contentSize.width <= 0 || contentSize.height <= 0) {
      return viewportSize;
    }

    return applyBoxFit(BoxFit.contain, contentSize, viewportSize).destination;
  }

  Offset _maxPanOffset(Size baseContentSize, double scale) {
    final scaledWidth = baseContentSize.width * scale;
    final scaledHeight = baseContentSize.height * scale;

    return Offset(
      math.max((scaledWidth - _viewportSize.width) / 2, 0),
      math.max((scaledHeight - _viewportSize.height) / 2, 0),
    );
  }

  Offset _clampOffset(Offset offset, Size baseContentSize, double scale) {
    if (_viewportSize == Size.zero || scale <= widget.minScale + _gestureEpsilon) {
      return Offset.zero;
    }

    final maxOffset = _maxPanOffset(baseContentSize, scale);

    return Offset(
      offset.dx.clamp(-maxOffset.dx, maxOffset.dx),
      offset.dy.clamp(-maxOffset.dy, maxOffset.dy),
    );
  }

  Offset _anchoredOffsetForScale({
    required Offset anchor,
    required Offset baseOffset,
    required double baseScale,
    required double targetScale,
  }) {
    final viewportCenter = _viewportSize.center(Offset.zero);
    final contentPoint = (anchor - viewportCenter - baseOffset) / baseScale;
    final targetOffset = anchor - viewportCenter - contentPoint * targetScale;

    return _clampOffset(targetOffset, _baseContentSize, targetScale);
  }

  void _snapBackIntoBounds() {
    final targetScale = _scale <= widget.minScale + _gestureEpsilon ? widget.minScale : _scale;
    final targetOffset = targetScale <= widget.minScale + _gestureEpsilon ? Offset.zero : _clampOffset(_offset, _baseContentSize, targetScale);

    if ((targetScale - _scale).abs() <= _gestureEpsilon && (targetOffset - _offset).distance <= _gestureEpsilon && _dismissOffset.distance <= _gestureEpsilon) {
      return;
    }

    _animateTo(targetScale: targetScale, targetOffset: targetOffset);
  }

  double _nextDoubleTapScale() {
    for (final scale in widget.doubleTapScales) {
      if (_scale < scale - _gestureEpsilon) {
        return scale.clamp(widget.minScale, widget.maxScale);
      }
    }

    return widget.minScale;
  }

  void _handleDoubleTap(Offset anchor) {
    final targetScale = _nextDoubleTapScale();
    final targetOffset = targetScale <= widget.minScale + _gestureEpsilon
        ? Offset.zero
        : _anchoredOffsetForScale(
            anchor: anchor,
            baseOffset: _offset,
            baseScale: _scale,
            targetScale: targetScale,
          );

    _animateTo(targetScale: targetScale, targetOffset: targetOffset);
  }

  void _handleDoubleTapDrag(PointerMoveEvent event) {
    final anchor = _doubleTapAnchor;
    final startLocalPosition = _doubleTapStartLocalPosition;

    if (anchor == null || startLocalPosition == null || _viewportSize == Size.zero) {
      return;
    }

    final delta = event.localPosition - startLocalPosition;

    if (!_dragZoomActive && delta.distance < _doubleTapDragSlop) {
      return;
    }

    _dragZoomActive = true;

    final scaleDelta = -delta.dy / 160;
    final targetScale = (_doubleTapBaseScale * (1 + scaleDelta)).clamp(widget.minScale, widget.maxScale);
    final targetOffset = targetScale <= widget.minScale + _gestureEpsilon
        ? Offset.zero
        : _anchoredOffsetForScale(
            anchor: anchor,
            baseOffset: _doubleTapBaseOffset,
            baseScale: _doubleTapBaseScale,
            targetScale: targetScale,
          );

    setState(() {
      _setScale(targetScale);
      _offset = targetOffset;
      _dismissOffset = Offset.zero;
    });
  }

  bool _shouldDismiss() {
    if (!widget.dismissible || widget.onDismiss == null || _viewportSize == Size.zero) {
      return false;
    }

    final threshold = math.min(_viewportSize.shortestSide * 0.18, 120.0);
    return _dismissOffset.distance > threshold;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers += 1;

    if (_activePointers != 1) {
      _singleTapTimer?.cancel();
      _primaryTapPointer = null;
      _tapMoved = true;
      return;
    }

    final now = DateTime.now();
    final isSecondTap =
        _lastTapUpTime != null && now.difference(_lastTapUpTime!) <= _doubleTapTimeout && _lastTapUpPosition != null && (_lastTapUpPosition! - event.localPosition).distance <= _doubleTapSlop;

    if (isSecondTap) {
      _singleTapTimer?.cancel();
      _doubleTapPointer = event.pointer;
      _doubleTapAnchor = event.localPosition;
      _doubleTapBaseScale = _scale;
      _doubleTapBaseOffset = _offset;
      _doubleTapStartLocalPosition = event.localPosition;
      _dragZoomActive = false;
      _ignoreScaleEnd = true;
      _primaryTapPointer = null;
      _tapMoved = true;
      return;
    }

    _primaryTapPointer = event.pointer;
    _primaryDownPosition = event.localPosition;
    _tapMoved = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_primaryTapPointer == event.pointer && _primaryDownPosition != null) {
      final moved = (_primaryDownPosition! - event.localPosition).distance;
      if (moved > _doubleTapDragSlop) {
        _tapMoved = true;
      }
    }

    if (_doubleTapPointer == event.pointer) {
      _handleDoubleTapDrag(event);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    final wasDoubleTapPointer = _doubleTapPointer == event.pointer;
    final wasPrimaryTapPointer = _primaryTapPointer == event.pointer;

    if (wasDoubleTapPointer) {
      if (_dragZoomActive) {
        _snapBackIntoBounds();
      } else if (_doubleTapAnchor != null) {
        _handleDoubleTap(_doubleTapAnchor!);
      }

      _doubleTapPointer = null;
      _doubleTapAnchor = null;
      _doubleTapStartLocalPosition = null;
      _dragZoomActive = false;
      _lastTapUpTime = null;
      _lastTapUpPosition = null;
    } else if (wasPrimaryTapPointer && !_tapMoved && !_didTriggerLongPress) {
      _lastTapUpTime = DateTime.now();
      _lastTapUpPosition = event.localPosition;
      _singleTapTimer?.cancel();
      _singleTapTimer = Timer(_doubleTapTimeout, () {
        if (!mounted) return;
        widget.onTap?.call();
        _lastTapUpTime = null;
        _lastTapUpPosition = null;
      });
    }

    if (wasPrimaryTapPointer) {
      _didTriggerLongPress = false;
    }

    _primaryTapPointer = wasPrimaryTapPointer ? null : _primaryTapPointer;
    _primaryDownPosition = wasPrimaryTapPointer ? null : _primaryDownPosition;
    _activePointers = math.max(0, _activePointers - 1);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_doubleTapPointer == event.pointer) {
      _doubleTapPointer = null;
      _doubleTapAnchor = null;
      _doubleTapStartLocalPosition = null;
      _dragZoomActive = false;
      _ignoreScaleEnd = false;
    }

    if (_primaryTapPointer == event.pointer) {
      _primaryTapPointer = null;
      _primaryDownPosition = null;
      _tapMoved = true;
    }

    _activePointers = math.max(0, _activePointers - 1);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_dragZoomActive) return;

    _transformAnimationController.stop();
    _gestureStartScale = _scale;
    _gestureStartOffset = _offset;
    _gestureStartFocalPoint = details.localFocalPoint;
    _gestureMode = (_activePointers > 1 || _scale > widget.minScale + _gestureEpsilon) ? _ViewerGestureMode.transform : _ViewerGestureMode.dismiss;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_dragZoomActive || _viewportSize == Size.zero) return;

    final focalPoint = details.localFocalPoint;
    final gestureStartFocalPoint = _gestureStartFocalPoint;

    if (gestureStartFocalPoint == null) return;

    final isTransformGesture = _activePointers > 1 || _gestureMode == _ViewerGestureMode.transform || _scale > widget.minScale + _gestureEpsilon || details.scale != 1.0;

    if (isTransformGesture) {
      _gestureMode = _ViewerGestureMode.transform;
      final nextScale = (_gestureStartScale * details.scale).clamp(widget.minScale, widget.maxScale);
      final nextOffset = nextScale <= widget.minScale + _gestureEpsilon
          ? Offset.zero
          : _anchoredOffsetForScale(
              anchor: focalPoint,
              baseOffset: _gestureStartOffset,
              baseScale: _gestureStartScale,
              targetScale: nextScale,
            );

      setState(() {
        _setScale(nextScale);
        _offset = nextOffset;
        _dismissOffset = Offset.zero;
      });
      return;
    }

    if (!widget.dismissible) return;

    setState(() {
      _gestureMode = _ViewerGestureMode.dismiss;
      _dismissOffset = focalPoint - gestureStartFocalPoint;
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_ignoreScaleEnd) {
      _ignoreScaleEnd = false;
      _gestureMode = _ViewerGestureMode.idle;
      return;
    }

    if (_dragZoomActive) return;

    if (_gestureMode == _ViewerGestureMode.dismiss) {
      if (_shouldDismiss()) {
        widget.onDismiss?.call();
      } else {
        _animateTo(targetScale: _scale, targetOffset: _offset);
      }
    } else {
      _snapBackIntoBounds();
    }

    _gestureMode = _ViewerGestureMode.idle;
  }

  Widget _buildDefaultLoader(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDefaultError(BuildContext context, Object error) {
    return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white70, size: 36));
  }

  Widget _buildImageWidget() {
    final source = widget.source;

    if (source is ThunderImageViewerMemorySource) {
      return Image.memory(
        source.bytes,
        filterQuality: widget.filterQuality,
        fit: BoxFit.contain,
        semanticLabel: widget.semanticLabel,
      );
    }

    final networkSource = source as ThunderImageViewerNetworkSource;
    final isAvifByUrl = networkSource.url.toLowerCase().endsWith('.avif');
    final isAvifByContentType = source.contentType?.toLowerCase() == 'image/avif';
    final isAvif = isAvifByUrl || isAvifByContentType;

    if (isAvif) {
      return CachedNetworkAvifImage(
        networkSource.url,
        fit: BoxFit.contain,
        filterQuality: widget.filterQuality,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorBuilder?.call(context, error) ?? _buildDefaultError(context, error);
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: networkSource.url,
      fadeInDuration: const Duration(milliseconds: 100),
      fadeOutDuration: Duration.zero,
      fit: BoxFit.contain,
      imageBuilder: (context, imageProvider) {
        return Image(
          image: imageProvider,
          filterQuality: widget.filterQuality,
          fit: BoxFit.contain,
          semanticLabel: widget.semanticLabel,
        );
      },
      placeholder: (context, url) => widget.loadingBuilder?.call(context) ?? _buildDefaultLoader(context),
      errorWidget: (context, url, error) {
        return widget.errorBuilder?.call(context, error) ?? _buildDefaultError(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        _baseContentSize = _resolveBaseContentSize(_viewportSize);

        final dismissProgress = _viewportSize == Size.zero ? 0.0 : (_dismissOffset.distance / (_viewportSize.shortestSide * 0.35)).clamp(0.0, 1.0);
        final backgroundOpacity = 1.0 - (dismissProgress * 0.75);
        final imageOpacity = 1.0 - (dismissProgress * 0.35);
        final visualOffset = (_scale <= widget.minScale + _gestureEpsilon ? Offset.zero : _offset) + _dismissOffset;

        return ColoredBox(
          color: Color.lerp(Colors.transparent, widget.backgroundColor, backgroundOpacity) ?? widget.backgroundColor,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerCancel: _handlePointerCancel,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: widget.onLongPress == null ? null : _handleLongPress,
              onScaleEnd: _handleScaleEnd,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              child: ClipRect(
                child: Center(
                  child: Opacity(
                    opacity: imageOpacity,
                    child: Transform.translate(
                      offset: visualOffset,
                      child: Transform.scale(
                        alignment: Alignment.center,
                        scale: _scale,
                        child: RepaintBoundary(
                          child: SizedBox(
                            height: _baseContentSize.height,
                            width: _baseContentSize.width,
                            child: _buildImageWidget(),
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
      },
    );
  }
}
