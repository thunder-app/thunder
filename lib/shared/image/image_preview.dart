import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/image_caching_mode.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Displays a preview of an image.
class ImagePreview extends StatefulWidget {
  /// The URL of the image to display.
  final String url;

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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    final devicePixelRatio = View.of(context).devicePixelRatio.ceil();

    Widget image = ExtendedImage.network(
      widget.url,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      cache: true,
      clearMemoryCacheWhenDispose: state.imageCachingMode == ImageCachingMode.relaxed,
      cacheWidth: widget.width != null ? (widget.width! * devicePixelRatio).toInt() : null,
      cacheHeight: widget.height != null ? (widget.height! * devicePixelRatio).toInt() : null,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            _controller.reset();
            return Container();
          case LoadState.completed:
            if (state.wasSynchronouslyLoaded) return state.completedWidget;

            _controller.forward();
            return FadeTransition(opacity: _controller, child: state.completedWidget);
          case LoadState.failed:
            _controller.reset();
            state.imageProvider.evict();

            return Center(
              child: Icon(
                _getErrorIcon(widget.mediaType),
                color: theme.colorScheme.onSecondaryContainer.withValues(alpha: widget.viewed == true ? 0.55 : 1.0),
              ),
            );
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
