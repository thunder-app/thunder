import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/media/image_preview.dart';
import 'package:thunder/packages/ui/src/widgets/media/image_viewer.dart';
import 'package:thunder/packages/ui/src/utils/media/media_utils.dart';
import 'package:thunder/packages/ui/src/models/content/content_action_handlers.dart';
import 'package:thunder/packages/ui/src/models/content/content_media.dart';
import 'package:thunder/packages/ui/src/models/content/content_media_type.dart';
import 'package:thunder/packages/ui/src/models/content/content_view_mode.dart';
import 'package:thunder/packages/ui/src/widgets/media/link_information.dart';
import 'package:thunder/packages/ui/src/widgets/media/media_view_text.dart';

class MediaView extends StatefulWidget {
  /// The media information.
  final ContentMedia media;

  /// The associated post ID for the media.
  final int? postId;

  /// Whether to show the full height for images.
  final bool showFullHeightImages;

  /// When enabled, the image height will be unconstrained.
  final bool allowUnconstrainedImageHeight;

  /// Whether to blur NSFW images.
  final bool hideNsfwPreviews;

  /// Whether to hide thumbnails.
  final bool hideThumbnails;

  /// Whether to extend the image to the edge of the screen.
  final bool edgeToEdgeImages;

  /// Whether to mark the post as read when the media is viewed.
  final bool markPostReadOnMediaView;

  /// Whether the user is logged in.
  final bool isUserLoggedIn;

  /// The view mode of the media.
  final ContentViewMode viewMode;

  /// The function to navigate to the post.
  final void Function()? navigateToPost;

  /// Whether the post has been read.
  final bool? read;

  /// Optional action handlers that decouple media and navigation behavior.
  final ContentActionHandlers handlers;

  /// Duration before peek preview starts when long pressing an image.
  final int imagePeekDurationMs;

  /// Whether content should be laid out in tablet mode.
  final bool tabletMode;

  /// Localized NSFW warning label shown in comfortable view.
  final String nsfwWarningLabel;

  /// Localized retry tooltip used by image fallback UI.
  final String retryTooltip;

  const MediaView({
    super.key,
    required this.media,
    this.postId,
    this.showFullHeightImages = true,
    this.allowUnconstrainedImageHeight = false,
    this.edgeToEdgeImages = false,
    this.hideNsfwPreviews = true,
    this.hideThumbnails = false,
    this.markPostReadOnMediaView = false,
    this.isUserLoggedIn = false,
    this.viewMode = ContentViewMode.comfortable,
    this.navigateToPost,
    this.read,
    this.handlers = const ContentActionHandlers(),
    this.imagePeekDurationMs = 300,
    this.tabletMode = false,
    this.nsfwWarningLabel = 'NSFW',
    this.retryTooltip = 'Retry',
  });

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> with TickerProviderStateMixin {
  // An overlay entry to display the image overlay for hold to peek.
  OverlayEntry? _overlayEntry;

  // An animation controller to animate the image overlay.
  late final AnimationController _overlayAnimationController;

  // The current state of the image preview.
  ImagePreviewState _imagePreviewState = ImagePreviewState.loading;

  @override
  void initState() {
    super.initState();
    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    super.dispose();
  }

  void _onImagePreviewStateChanged(ImagePreviewState state) {
    if (mounted) setState(() => _imagePreviewState = state);
  }

  void _markPostAsRead() {
    if (!widget.isUserLoggedIn || !widget.markPostReadOnMediaView) return;
    widget.handlers.onMarkRead?.call(widget.postId);
  }

  void _openLink(String url) {
    widget.handlers.onOpenLink?.call(context, url);
  }

  void _openImage({String? url, Uint8List? bytes}) {
    final onOpenImage = widget.handlers.onOpenImage;
    if (onOpenImage != null) {
      onOpenImage(context, url: url, bytes: bytes);
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return ImageViewer(
            url: url,
            bytes: bytes,
            postId: widget.postId,
            navigateToPost: widget.navigateToPost,
            altText: widget.media.altText,
          );
        },
      ),
    );
  }

  void _openVideo(String url) {
    widget.handlers.onOpenVideo?.call(context, url);
  }

  /// Overlays the image as an ImageViewer.
  void showImage() {
    _markPostAsRead();
    _openImage(url: widget.media.imageUrl);
  }

  double getMinHeight() {
    if (!widget.showFullHeightImages && widget.viewMode != ContentViewMode.comment) {
      return ContentViewMode.comfortable.height;
    }

    if (widget.media.height != null) {
      if (MediaQuery.of(context).size.height < widget.media.height!) {
        return MediaQuery.of(context).size.height;
      }
      return widget.media.height!;
    }

    return ContentViewMode.comfortable.height;
  }

  double getMaxHeight() {
    if (widget.viewMode != ContentViewMode.comment) {
      if (widget.allowUnconstrainedImageHeight) {
        return MediaQuery.of(context).size.height;
      }
      if (!widget.showFullHeightImages) {
        return ContentViewMode.comfortable.height;
      }
    }

    if (widget.media.height != null) {
      if (MediaQuery.of(context).size.height < widget.media.height!) {
        return MediaQuery.of(context).size.height;
      }
      return widget.media.height!;
    }

    return ContentViewMode.comfortable.height;
  }

  void handleTap() {
    _markPostAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrlCandidate = widget.media.imageUrl ?? widget.media.mediaUrl ?? widget.media.originalUrl;
    final isImage = isImageUrl(imageUrlCandidate ?? '');

    // If hiding thumbnails is enabled or if the media has no image URL,
    // display a link preview instead in comfortable mode.
    if (widget.viewMode == ContentViewMode.comfortable && (widget.hideThumbnails || !isImage)) {
      return LinkInformation(
        viewMode: widget.viewMode,
        url: widget.media.originalUrl,
        mediaType: widget.media.mediaType,
        onTap: () {
          handleTap();
          final url = widget.media.originalUrl;
          if (url != null) _openLink(url);
        },
        onLongPress: () {
          final url = widget.media.originalUrl;
          if (url != null) {
            widget.handlers.onLongPressLink?.call(context, url, url);
          }
        },
        showEdgeToEdgeImages: widget.edgeToEdgeImages,
      );
    }

    if (widget.viewMode == ContentViewMode.compact && widget.media.mediaType == ContentMediaType.text) {
      return MediaViewText(
        text: widget.media.altText,
        read: widget.read,
      );
    }

    // At this point, all other media types should contain images.
    final theme = Theme.of(context);

    final blurNSFWPreviews = widget.hideNsfwPreviews && widget.media.nsfw;

    double? width;
    double? height;

    switch (widget.viewMode) {
      case ContentViewMode.comment:
        width = widget.media.width;
        height = widget.media.height ?? ContentViewMode.comment.height;
        break;
      case ContentViewMode.compact:
        width = null;
        height = ContentViewMode.compact.height;
        break;
      case ContentViewMode.comfortable:
        width = (widget.tabletMode ? (MediaQuery.of(context).size.width / 2) - 24.0 : MediaQuery.of(context).size.width) - (widget.edgeToEdgeImages ? 0 : 24);
        height = (widget.showFullHeightImages && !widget.allowUnconstrainedImageHeight) ? widget.media.height : null;
    }

    Widget? child;

    if (widget.media.mediaType == ContentMediaType.link) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          handleTap();
          final url = widget.media.originalUrl;
          if (url != null) _openLink(url);
        },
        onLongPress: () {
          final url = widget.media.originalUrl;
          if (url != null) {
            widget.handlers.onLongPressLink?.call(context, url, url);
          }
        },
        child: widget.viewMode == ContentViewMode.comfortable
            ? SizedBox(
                height: 70.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: LinkInformation(
                    viewMode: widget.viewMode,
                    mediaType: widget.media.mediaType,
                    url: widget.media.originalUrl,
                    showEdgeToEdgeImages: widget.edgeToEdgeImages,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
    }

    if (widget.media.mediaType == ContentMediaType.image && _imagePreviewState == ImagePreviewState.success) {
      final imagePeekDuration = Duration(milliseconds: widget.imagePeekDurationMs);

      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          handleTap();
          showImage();
        },
        child: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: imagePeekDuration),
              (LongPressGestureRecognizer instance) {
                instance
                  ..onLongPressStart = (_) {
                    _overlayEntry = OverlayEntry(
                      builder: (context) {
                        return FadeTransition(
                          opacity: _overlayAnimationController,
                          child: ImageViewer(
                            url: widget.media.thumbnailUrl ?? widget.media.mediaUrl,
                            postId: widget.postId,
                            navigateToPost: widget.navigateToPost,
                            isPeek: true,
                          ),
                        );
                      },
                    );
                    Overlay.of(context).insert(_overlayEntry!);
                    _overlayAnimationController.forward();
                  }
                  ..onLongPressEnd = (_) async {
                    await _overlayAnimationController.reverse();
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  };
              },
            ),
          },
        ),
      );
    }

    if (widget.media.mediaType == ContentMediaType.video) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          handleTap();
          final url = widget.media.mediaUrl ?? widget.media.originalUrl;
          if (url != null) _openVideo(url);
        },
        child: widget.viewMode == ContentViewMode.comfortable
            ? Column(
                children: [
                  const Expanded(child: Icon(Icons.play_arrow_rounded, size: 55)),
                  SizedBox(
                    height: 70.0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: LinkInformation(
                        viewMode: widget.viewMode,
                        mediaType: widget.media.mediaType,
                        url: widget.media.originalUrl,
                        showEdgeToEdgeImages: widget.edgeToEdgeImages,
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      );
    }

    return Stack(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          constraints: BoxConstraints(
            maxHeight: switch (widget.viewMode) {
              ContentViewMode.comment => getMaxHeight(),
              ContentViewMode.compact => ContentViewMode.compact.height,
              ContentViewMode.comfortable => getMaxHeight(),
            },
            minHeight: switch (widget.viewMode) {
              ContentViewMode.comment => getMinHeight(),
              ContentViewMode.compact => ContentViewMode.compact.height,
              ContentViewMode.comfortable => getMinHeight(),
            },
            maxWidth: switch (widget.viewMode) {
              ContentViewMode.comment => MediaQuery.of(context).size.width / 2,
              ContentViewMode.compact => ContentViewMode.compact.height,
              ContentViewMode.comfortable => widget.edgeToEdgeImages ? double.infinity : MediaQuery.of(context).size.width,
            },
            minWidth: switch (widget.viewMode) {
              ContentViewMode.comment => 0,
              ContentViewMode.compact => ContentViewMode.compact.height,
              ContentViewMode.comfortable => widget.edgeToEdgeImages ? double.infinity : MediaQuery.of(context).size.width,
            },
          ),
          child: Stack(
            fit: widget.allowUnconstrainedImageHeight ? StackFit.loose : StackFit.expand,
            alignment: Alignment.center,
            children: [
              ImagePreview(
                url: widget.media.thumbnailUrl ?? widget.media.imageUrl ?? widget.media.originalUrl!,
                contentType: widget.media.contentType,
                width: width,
                height: height,
                fit: widget.viewMode == ContentViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
                mediaType: widget.media.mediaType,
                viewed: widget.read,
                blur: blurNSFWPreviews,
                allowRetry: widget.media.mediaType == ContentMediaType.image,
                onStateChanged: _onImagePreviewStateChanged,
                retryTooltip: widget.retryTooltip,
              ),
              if (blurNSFWPreviews)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.media.mediaType == ContentMediaType.image
                        ? Icon(Icons.warning_rounded, size: widget.viewMode != ContentViewMode.compact ? 55 : 30)
                        : Icon(
                            widget.viewMode != ContentViewMode.compact ? Icons.play_arrow_rounded : Icons.warning_rounded,
                            size: widget.viewMode != ContentViewMode.compact ? 55 : 30,
                          ),
                    if (widget.viewMode == ContentViewMode.comfortable) Text(widget.nsfwWarningLabel, textScaler: const TextScaler.linear(1.5)),
                  ],
                ),
              if (child != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: child,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
