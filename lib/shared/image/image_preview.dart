import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/image_caching_mode.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/media/image.dart';

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
  ///
  /// This value dictates the icon that will be displayed if the image fails to load.
  /// If none is provided, a generic error icon will be displayed.
  final MediaType? mediaType;

  /// Whether the image has been viewed. This will affect the opacity of the image.
  final bool? viewed;

  /// Whether the image should be blurred.
  final bool? blur;

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
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> with SingleTickerProviderStateMixin {
  /// The controller for the image fade animation.
  late AnimationController _controller;

  /// Whether the image URL is valid.
  late bool _isValidImageUrl;

  @override
  void initState() {
    super.initState();

    _isValidImageUrl = widget.contentType != null || isImageUrl(widget.url);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void didUpdateWidget(ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _isValidImageUrl = isImageUrl(widget.url);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidImageUrl) return ImagePreviewError(mediaType: widget.mediaType, blur: widget.blur == true, viewed: widget.viewed == true);

    return BlocSelector<ThunderBloc, ThunderState, ImageCachingMode>(
      selector: (state) => state.imageCachingMode,
      builder: (context, imageCachingMode) {
        return _buildImage(context, imageCachingMode);
      },
    );
  }

  Widget _buildImage(BuildContext context, ImageCachingMode imageCachingMode) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context).ceil();

    Widget image = ExtendedImage.network(
      widget.url,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      color: widget.viewed == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
      colorBlendMode: widget.viewed == true ? BlendMode.modulate : null,
      cache: true,
      clearMemoryCacheWhenDispose: imageCachingMode == ImageCachingMode.relaxed,
      cacheWidth: widget.width != null ? (widget.width! * devicePixelRatio).toInt() : null,
      cacheHeight: widget.height != null ? (widget.height! * devicePixelRatio).toInt() : null,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            _controller.reset();
            return const SizedBox.shrink();

          case LoadState.completed:
            if (state.wasSynchronouslyLoaded) return state.completedWidget;

            _controller.forward();
            return FadeTransition(opacity: _controller, child: state.completedWidget);

          case LoadState.failed:
            _controller.reset();
            state.imageProvider.evict();

            return ImagePreviewError(mediaType: widget.mediaType, blur: widget.blur == true, viewed: widget.viewed == true);
        }
      },
    );

    if (widget.blur == true) {
      return ImageFiltered(
        enabled: true,
        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: image,
      );
    }

    return image;
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

  const ImagePreviewError({super.key, this.mediaType, this.blur = false, this.viewed = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Don't display the associated icon if blur is enabled, otherwise there will be two icons displayed at once.
    if (blur == true) return SizedBox.shrink();

    return Center(
      child: Icon(
        _getErrorIcon(mediaType),
        color: theme.colorScheme.onSecondaryContainer.withValues(alpha: viewed == true ? 0.55 : 1.0),
      ),
    );
  }

  IconData _getErrorIcon(MediaType? mediaType) {
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
}
