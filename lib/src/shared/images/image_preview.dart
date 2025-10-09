import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/src/core/enums/media_type.dart';
import 'package:thunder/src/shared/utils/media/image.dart';

/// Displays a preview of an image.
class ImagePreview extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // TODO: Move the logic for determining if the image is valid into data layer so that we don't need to re-evaluate this on every build.
    final isValidImageUrl = contentType != null || isImageUrl(url);

    if (!isValidImageUrl) {
      return ImagePreviewError(
        mediaType: mediaType,
        blur: blur == true,
        viewed: viewed == true,
      );
    }

    return _ImageContent(
      url: url,
      width: width,
      height: height,
      fit: fit,
      viewed: viewed,
      blur: blur,
      mediaType: mediaType,
    );
  }
}

/// A widget that displays an image.
class _ImageContent extends StatelessWidget {
  /// The URL of the image to display.
  final String url;

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

  const _ImageContent({
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    required this.viewed,
    required this.blur,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context).ceil();

    final image = CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      color: viewed == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
      colorBlendMode: viewed == true ? BlendMode.modulate : null,
      fadeInDuration: const Duration(milliseconds: 130),
      memCacheWidth: width != null ? (width! * devicePixelRatio).toInt() : null,
      memCacheHeight: height != null ? (height! * devicePixelRatio).toInt() : null,
      placeholder: (context, url) => const SizedBox.shrink(),
      errorWidget: (context, url, error) => ImagePreviewError(mediaType: mediaType, blur: blur == true, viewed: viewed == true),
    );

    if (blur == true) return _BlurredImage(child: image);
    return image;
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

  const ImagePreviewError({super.key, this.mediaType, this.blur = false, this.viewed = false});

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
    final theme = Theme.of(context);

    // Don't display the associated icon if blur is enabled, otherwise there will be two icons displayed at once.
    if (blur) return const SizedBox.shrink();

    return Center(
      child: Icon(
        _getErrorIcon(mediaType),
        color: theme.colorScheme.onSecondaryContainer.withValues(
          alpha: viewed ? 0.55 : 1.0,
        ),
      ),
    );
  }
}
