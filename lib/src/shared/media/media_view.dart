import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/shared/links/link_bottom_sheet.dart';

import 'package:thunder/src/shared/media/image_preview.dart';
import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/src/shared/media/link_information.dart';
import 'package:thunder/src/shared/media/media_view_text.dart';

class MediaView extends StatefulWidget {
  /// The media information.
  final Media media;

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
  final ViewMode viewMode;

  /// The function to navigate to the post.
  final void Function()? navigateToPost;

  /// Whether the post has been read.
  final bool? read;

  /// Optional callback for marking the parent post as read.
  final Future<void> Function()? onMarkPostRead;

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
    this.viewMode = ViewMode.comfortable,
    this.navigateToPost,
    this.read,
    this.onMarkPostRead,
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

    if (widget.onMarkPostRead != null) {
      widget.onMarkPostRead!();
      return;
    }

    try {
      final feedBloc = BlocProvider.of<FeedBloc>(context);
      feedBloc.add(
        FeedItemActionedEvent(
          postAction: PostAction.read,
          postId: widget.postId,
          actionInput: const ReadPostInput(true),
        ),
      );
    } catch (e) {
      debugPrint('Error marking post as read: $e');
    }
  }

  void _openLink(String url) {
    handleLink(context, url: url);
  }

  void _openLinkLongPress(String text, String? url) {
    if (url != null) {
      handleLinkLongPress(context, text, url, preferredImageUrl: widget.media.thumbnailUrl);
    }
  }

  void _openImage({String? url, Uint8List? bytes}) {
    showImageViewer(
      context,
      url: url,
      bytes: bytes,
      postId: widget.postId,
      navigateToPost: widget.navigateToPost,
      altText: widget.media.altText,
    );
  }

  void _openVideo(String url) {
    handleVideoLink(context, url: url);
  }

  String? get _resolvedImageUrl => widget.media.imageUrl ?? widget.media.mediaUrl ?? widget.media.originalUrl ?? widget.media.thumbnailUrl;

  String? get _resolvedPreviewUrl => widget.media.thumbnailUrl ?? widget.media.imageUrl ?? widget.media.mediaUrl ?? widget.media.originalUrl;

  /// Overlays the image as an ImageViewer.
  void showImage() {
    _markPostAsRead();

    final url = _resolvedImageUrl;
    if (url != null) {
      _openImage(url: url);
    }
  }

  double getMinHeight() {
    if (!widget.showFullHeightImages && widget.viewMode != ViewMode.comment) {
      return ViewMode.comfortable.height;
    }

    if (widget.media.height != null) {
      if (MediaQuery.of(context).size.height < widget.media.height!) {
        return MediaQuery.of(context).size.height;
      }
      return widget.media.height!;
    }

    return ViewMode.comfortable.height;
  }

  double getMaxHeight() {
    if (widget.viewMode != ViewMode.comment) {
      if (widget.allowUnconstrainedImageHeight) {
        return MediaQuery.of(context).size.height;
      }
      if (!widget.showFullHeightImages) {
        return ViewMode.comfortable.height;
      }
    }

    if (widget.media.height != null) {
      if (MediaQuery.of(context).size.height < widget.media.height!) {
        return MediaQuery.of(context).size.height;
      }
      return widget.media.height!;
    }

    return ViewMode.comfortable.height;
  }

  void handleTap() {
    _markPostAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final imagePeekDurationMs = context.select<GesturePreferencesCubit, int>((cubit) => cubit.state.imagePeekDuration);
    final tabletMode = widget.viewMode == ViewMode.comfortable ? context.select((ThunderCubit bloc) => bloc.state.tabletMode) : false;
    final l10n = AppLocalizations.of(context)!;

    final imageUrlCandidate = widget.media.imageUrl ?? widget.media.mediaUrl ?? widget.media.originalUrl;
    final isImage = isImageUrl(imageUrlCandidate ?? '');
    final previewUrl = _resolvedPreviewUrl;

    // If hiding thumbnails is enabled or if the media has no image URL,
    // display a link preview instead in comfortable mode.
    if (widget.viewMode == ViewMode.comfortable && (widget.hideThumbnails || !isImage)) {
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
          if (url != null) _openLinkLongPress(url, url);
        },
        showEdgeToEdgeImages: widget.edgeToEdgeImages,
      );
    }

    if (widget.viewMode == ViewMode.compact && widget.media.mediaType == MediaType.text) {
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
      case ViewMode.comment:
        width = widget.media.width;
        height = widget.media.height ?? ViewMode.comment.height;
        break;
      case ViewMode.compact:
        width = null;
        height = ViewMode.compact.height;
        break;
      case ViewMode.comfortable:
        width = (tabletMode ? (MediaQuery.of(context).size.width / 2) - 24.0 : MediaQuery.of(context).size.width) - (widget.edgeToEdgeImages ? 0 : 24);
        height = (widget.showFullHeightImages && !widget.allowUnconstrainedImageHeight) ? widget.media.height : null;
    }

    final shouldContainTallFullHeightImage =
        widget.media.mediaType == MediaType.image && widget.viewMode == ViewMode.comfortable && widget.showFullHeightImages && widget.media.height != null && widget.media.height! > getMaxHeight();

    Widget? child;

    if (widget.media.mediaType == MediaType.link) {
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
          if (url != null) _openLinkLongPress(url, url);
        },
        child: widget.viewMode == ViewMode.comfortable
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

    if (widget.media.mediaType == MediaType.image && _imagePreviewState == ImagePreviewState.success) {
      final imagePeekDuration = Duration(milliseconds: imagePeekDurationMs);

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
                          child: buildImageViewerWidget(
                            context,
                            url: previewUrl,
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

    if (widget.media.mediaType == MediaType.image && previewUrl == null) {
      if (widget.media.originalUrl != null) {
        return LinkInformation(
          viewMode: widget.viewMode,
          url: widget.media.originalUrl,
          mediaType: widget.media.mediaType,
          showEdgeToEdgeImages: widget.edgeToEdgeImages,
        );
      }

      return const SizedBox.shrink();
    }

    if (widget.media.mediaType == MediaType.video) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          handleTap();
          final url = widget.media.mediaUrl ?? widget.media.originalUrl;
          if (url != null) _openVideo(url);
        },
        child: widget.viewMode == ViewMode.comfortable
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
              ViewMode.comment => getMaxHeight(),
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => getMaxHeight(),
            },
            minHeight: switch (widget.viewMode) {
              ViewMode.comment => getMinHeight(),
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => getMinHeight(),
            },
            maxWidth: switch (widget.viewMode) {
              ViewMode.comment => MediaQuery.of(context).size.width / 2,
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => widget.edgeToEdgeImages ? double.infinity : MediaQuery.of(context).size.width,
            },
            minWidth: switch (widget.viewMode) {
              ViewMode.comment => 0,
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => widget.edgeToEdgeImages ? double.infinity : MediaQuery.of(context).size.width,
            },
          ),
          child: Stack(
            fit: widget.allowUnconstrainedImageHeight ? StackFit.loose : StackFit.expand,
            alignment: Alignment.center,
            children: [
              ImagePreview(
                url: previewUrl!,
                contentType: widget.media.contentType,
                width: width,
                height: height,
                fit: widget.viewMode == ViewMode.compact
                    ? BoxFit.cover
                    : shouldContainTallFullHeightImage
                        ? BoxFit.contain
                        : BoxFit.fitWidth,
                mediaType: widget.media.mediaType,
                viewed: widget.read,
                blur: blurNSFWPreviews,
                allowRetry: widget.media.mediaType == MediaType.image,
                onStateChanged: _onImagePreviewStateChanged,
                retryTooltip: l10n.retry,
              ),
              if (blurNSFWPreviews)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.media.mediaType == MediaType.image
                        ? Icon(Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30)
                        : Icon(
                            widget.viewMode != ViewMode.compact ? Icons.play_arrow_rounded : Icons.warning_rounded,
                            size: widget.viewMode != ViewMode.compact ? 55 : 30,
                          ),
                    if (widget.viewMode == ViewMode.comfortable) Text(l10n.nsfwWarning, textScaler: const TextScaler.linear(1.5)),
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
