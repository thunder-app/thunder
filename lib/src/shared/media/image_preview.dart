import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:thunder/src/core/domain/domain.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_avif/flutter_avif.dart';

import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// The loading state of an image preview.
enum ImagePreviewState {
  /// The image is currently loading.
  loading,

  /// The image has loaded successfully.
  success,

  /// The image failed to load.
  error,
}

/// Displays a preview of an image.
class ImagePreview extends StatefulWidget {
  /// The URL of the image to display.
  final String url;

  /// The content type of the image.
  final String? contentType;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// The box fit of the image.
  final BoxFit? fit;

  /// The media type that the underlying image represents.
  final MediaType? mediaType;

  /// Whether the image has been viewed. This will affect the opacity of the image.
  final bool? viewed;

  /// Whether the image should be blurred.
  final bool? blur;

  /// Whether to allow retrying with the original URL when a proxy URL fails.
  final bool allowRetry;

  /// Callback invoked when the image loading state changes.
  final void Function(ImagePreviewState state)? onStateChanged;

  /// Localized tooltip shown when retry is available.
  final String retryTooltip;

  const ImagePreview({
    super.key,
    required this.url,
    this.contentType,
    this.width,
    this.height,
    this.fit,
    this.mediaType,
    this.viewed,
    this.blur,
    this.allowRetry = false,
    this.onStateChanged,
    this.retryTooltip = 'Retry',
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  /// Whether we're using the fallback (original) URL instead of the proxy URL.
  bool _useFallbackUrl = false;

  /// The current loading state of the image.
  ImagePreviewState _state = ImagePreviewState.loading;

  /// The current URL being used to load the image.
  String get _currentUrl {
    if (_useFallbackUrl) return fetchProxyImageUrl(widget.url);
    return widget.url;
  }

  /// Whether the current URL is a proxy URL that can be retried with the original URL.
  bool get _canRetryWithOriginalUrl {
    if (!widget.allowRetry) return false;
    final originalUrl = fetchProxyImageUrl(widget.url);
    return originalUrl != widget.url && !_useFallbackUrl;
  }

  void _retryWithOriginalUrl() {
    setState(() {
      _useFallbackUrl = true;
      _state = ImagePreviewState.loading;
    });
    widget.onStateChanged?.call(ImagePreviewState.loading);
  }

  void _onImageLoaded() {
    if (_state != ImagePreviewState.success) {
      setState(() => _state = ImagePreviewState.success);
      widget.onStateChanged?.call(ImagePreviewState.success);
    }
  }

  void _onImageError() {
    if (_state != ImagePreviewState.error) {
      setState(() => _state = ImagePreviewState.error);
      widget.onStateChanged?.call(ImagePreviewState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValidImageUrl = widget.contentType != null || isImageUrl(widget.url);

    if (!isValidImageUrl) {
      return ImagePreviewError(
        mediaType: widget.mediaType,
        blur: widget.blur == true,
        viewed: widget.viewed == true,
        retryTooltip: widget.retryTooltip,
      );
    }

    return _ImageContent(
      key: ValueKey(_currentUrl),
      url: _currentUrl,
      contentType: widget.contentType,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      viewed: widget.viewed,
      blur: widget.blur,
      mediaType: widget.mediaType,
      canRetry: _canRetryWithOriginalUrl,
      onRetry: _retryWithOriginalUrl,
      onLoaded: _onImageLoaded,
      onError: _onImageError,
      retryTooltip: widget.retryTooltip,
    );
  }
}

/// A widget that displays an image.
class _ImageContent extends StatelessWidget {
  /// The URL of the image to display.
  final String url;

  /// The content type of the image (e.g., 'image/avif', 'image/jpeg').
  final String? contentType;

  /// The width of the image.
  final double? width;

  /// The height of the image.
  final double? height;

  /// The box fit of the image.
  final BoxFit? fit;

  /// Whether the image has been viewed. This will affect the opacity of the image.
  final bool? viewed;

  /// Whether the image should be blurred.
  final bool? blur;

  /// The media type that the underlying image represents.
  final MediaType? mediaType;

  /// Whether the image can be retried with the original URL.
  final bool canRetry;

  /// Callback to retry loading the image with the original URL.
  final VoidCallback? onRetry;

  /// Callback when the image loads successfully.
  final VoidCallback? onLoaded;

  /// Callback when the image fails to load.
  final VoidCallback? onError;

  /// Localized tooltip shown when retry is available.
  final String retryTooltip;

  const _ImageContent({
    super.key,
    required this.url,
    this.contentType,
    required this.width,
    required this.height,
    required this.fit,
    required this.viewed,
    required this.blur,
    required this.mediaType,
    this.canRetry = false,
    this.onRetry,
    this.onLoaded,
    this.onError,
    required this.retryTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context).ceil();

    // Calculate cache dimensions based on device pixel ratio.
    final int? cacheWidth = width != null ? (width! * devicePixelRatio).toInt() : null;
    final int? cacheHeight = height != null ? (height! * devicePixelRatio).toInt() : null;

    final int? diskCacheWidth = cacheWidth != null ? (cacheWidth * 1.5).toInt() : null;
    final int? diskCacheHeight = cacheHeight != null ? (cacheHeight * 1.5).toInt() : null;

    final filterQuality = (cacheWidth != null && cacheWidth < 200) ? FilterQuality.low : FilterQuality.medium;

    final isAvifByUrl = url.toLowerCase().endsWith('.avif');
    final isAvifByContentType = contentType?.toLowerCase() == 'image/avif';
    final isAvif = isAvifByUrl || isAvifByContentType;

    Widget image;

    if (isAvif) {
      image = CachedNetworkAvifImage(
        url,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: viewed == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
        colorBlendMode: viewed == true ? BlendMode.modulate : null,
        filterQuality: filterQuality,
        isAntiAlias: false,
        gaplessPlayback: false,
        errorBuilder: (context, error, stackTrace) {
          Future.microtask(() => onError?.call());
          return ImagePreviewError(
            mediaType: mediaType,
            blur: blur == true,
            viewed: viewed == true,
            canRetry: canRetry,
            onRetry: onRetry,
            retryTooltip: retryTooltip,
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            Future.microtask(() => onLoaded?.call());
          }
          return child;
        },
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: fit,
        color: viewed == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
        colorBlendMode: viewed == true ? BlendMode.modulate : null,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: Duration.zero,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: diskCacheWidth,
        maxHeightDiskCache: diskCacheHeight,
        filterQuality: filterQuality,
        useOldImageOnUrlChange: true,
        placeholder: (context, url) => const SizedBox.shrink(),
        imageBuilder: (context, imageProvider) {
          Future.microtask(() => onLoaded?.call());

          return Image(
            image: imageProvider,
            height: height,
            width: width,
            fit: fit,
            color: viewed == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
            colorBlendMode: viewed == true ? BlendMode.modulate : null,
            filterQuality: filterQuality,
            gaplessPlayback: false,
            isAntiAlias: false,
          );
        },
        errorWidget: (context, url, error) {
          Future.microtask(() => onError?.call());

          return ImagePreviewError(
            mediaType: mediaType,
            blur: blur == true,
            viewed: viewed == true,
            canRetry: canRetry,
            onRetry: onRetry,
            retryTooltip: retryTooltip,
          );
        },
      );
    }

    if (blur == true) return _BlurredImage(child: image);

    return RepaintBoundary(child: image);
  }
}

/// A widget that blurs the child widget.
class _BlurredImage extends StatelessWidget {
  /// The child widget to display.
  final Widget child;

  const _BlurredImage({required this.child});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      enabled: true,
      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: child,
    );
  }
}

/// Displays the fallback widget when an image fails to load.
class ImagePreviewError extends StatelessWidget {
  /// The media type that the underlying image represents.
  final MediaType? mediaType;

  /// Whether the image should be blurred.
  final bool blur;

  /// Whether the image has been viewed. This will affect the opacity of the image.
  final bool viewed;

  /// Whether the image can be retried with the original URL.
  final bool canRetry;

  /// Callback to retry loading the image with the original URL.
  final VoidCallback? onRetry;

  /// Localized tooltip shown when retry is available.
  final String retryTooltip;

  const ImagePreviewError({
    super.key,
    this.mediaType,
    this.blur = false,
    this.viewed = false,
    this.canRetry = false,
    this.onRetry,
    this.retryTooltip = 'Retry',
  });

  /// Returns the icon to display when the image fails to load.
  static IconData _getErrorIcon(MediaType? mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return Icons.image_not_supported_outlined;
      case MediaType.video:
        return Icons.video_camera_back_outlined;
      case MediaType.link:
        return Icons.language_rounded;
      case MediaType.text:
        return Icons.text_fields_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThunderMediaPreviewError(
      icon: _getErrorIcon(mediaType),
      blur: blur,
      viewed: viewed,
      canRetry: canRetry,
      onRetry: onRetry,
      retryTooltip: retryTooltip,
    );
  }
}
