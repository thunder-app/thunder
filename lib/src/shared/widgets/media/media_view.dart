import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/models/media.dart';
import 'package:thunder/src/shared/images/image_preview.dart';
import 'package:thunder/src/shared/link_information.dart';
import 'package:thunder/src/shared/widgets/media/media_view_text.dart';
import 'package:thunder/src/shared/utils/colors.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/shared/images/image_viewer.dart';
import 'package:thunder/src/core/enums/view_mode.dart';
import 'package:thunder/src/core/enums/media_type.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/shared/utils/media/image.dart';
import 'package:thunder/src/shared/utils/media/video.dart';

class MediaView extends StatefulWidget {
  /// The media information
  final Media media;

  /// The associated post ID for the media
  final int? postId;

  /// Whether to show the full height for images
  final bool showFullHeightImages;

  /// When enabled, the image height will be unconstrained.
  final bool allowUnconstrainedImageHeight;

  /// Whether to blur NSFW images
  final bool hideNsfwPreviews;

  /// Whether to hide thumbnails
  final bool hideThumbnails;

  /// Whether to extend the image to the edge of the screen (ViewMode.comfortable)
  final bool edgeToEdgeImages;

  /// Whether to mark the post as read when the media is viewed
  final bool markPostReadOnMediaView;

  /// Whether the user is logged in
  final bool isUserLoggedIn;

  /// The view mode of the media
  final ViewMode viewMode;

  /// The function to navigate to the post
  final void Function()? navigateToPost;

  /// Whether the post has been read
  final bool? read;

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
  });

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> with TickerProviderStateMixin {
  // An overlay entry to display the image overlay for hold to peek
  OverlayEntry? _overlayEntry;

  // An animation controller to animate the image overlay
  late final AnimationController _overlayAnimationController;

  // The current state of the image preview
  ImagePreviewState _imagePreviewState = ImagePreviewState.loading;

  @override
  void initState() {
    super.initState();
    _overlayAnimationController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    super.dispose();
  }

  void _onImagePreviewStateChanged(ImagePreviewState state) {
    if (mounted) setState(() => _imagePreviewState = state);
  }

  /// Overlays the image as an ImageViewer
  void showImage() {
    if (widget.isUserLoggedIn && widget.markPostReadOnMediaView) {
      try {
        // Mark post as read when on the feed page
        context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: widget.postId, value: true));
      } catch (e) {
        // Do nothing otherwise
      }
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
            url: widget.media.imageUrl,
            postId: widget.postId,
            navigateToPost: widget.navigateToPost,
            altText: widget.media.altText,
          );
        },
      ),
    );
  }

  double getMinHeight() {
    if (!widget.showFullHeightImages && widget.viewMode != ViewMode.comment) return ViewMode.comfortable.height;

    if (widget.media.height != null) {
      if (MediaQuery.of(context).size.height < widget.media.height!) return MediaQuery.of(context).size.height;
      return widget.media.height!;
    }

    return ViewMode.comfortable.height;
  }

  double getMaxHeight() {
    if (widget.viewMode != ViewMode.comment) {
      if (widget.allowUnconstrainedImageHeight) return MediaQuery.of(context).size.height;
      if (!widget.showFullHeightImages) return ViewMode.comfortable.height;
    }

    if (widget.media.height != null) {
      if (MediaQuery.of(context).size.height < widget.media.height!) return MediaQuery.of(context).size.height;
      return widget.media.height!;
    }

    return ViewMode.comfortable.height;
  }

  void handleTap() {
    if (widget.isUserLoggedIn && widget.markPostReadOnMediaView) {
      try {
        final feedBloc = BlocProvider.of<FeedBloc>(context);
        feedBloc.add(FeedItemActionedEvent(postAction: PostAction.read, postId: widget.postId, value: true));
      } catch (e) {
        debugPrint('Error marking post as read: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isImage = isImageUrl(widget.media.imageUrl ?? widget.media.mediaUrl ?? widget.media.originalUrl!);

    // If hiding thumbnails is enabled or if the media has no image URL (e.g., text or links with no images), we should display a link preview instead
    // This only applies for [ViewMode.comfortable]
    if (widget.viewMode == ViewMode.comfortable && (widget.hideThumbnails || !isImage)) {
      return LinkInformation(
        viewMode: widget.viewMode,
        url: widget.media.originalUrl,
        mediaType: widget.media.mediaType,
        onTap: () {
          handleTap();
          handleLink(context, url: widget.media.originalUrl!);
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

    // At this point, all other media types should contain images, so we display the image as well as any additional information
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    final imagePeekDurationMs = context.select((ThunderBloc bloc) => bloc.state.imagePeekDuration);
    final blurNSFWPreviews = widget.hideNsfwPreviews && widget.media.nsfw;

    double? width;
    double? height;

    switch (widget.viewMode) {
      case ViewMode.comment:
        width = widget.media.width;
        height = widget.media.height ?? ViewMode.comment.height; // If the height is not set, use the default height
        break;
      case ViewMode.compact:
        width = null; // Setting this to null will use the image's width. This will allow the image to not be stretched or squished.
        height = ViewMode.compact.height;
        break;
      case ViewMode.comfortable:
        width = (state.tabletMode ? (MediaQuery.of(context).size.width / 2) - 24.0 : MediaQuery.of(context).size.width) - (widget.edgeToEdgeImages ? 0 : 24);
        height = (widget.showFullHeightImages && !widget.allowUnconstrainedImageHeight) ? widget.media.height : null;
    }

    Widget? child;

    // For links, add inkwell to handle links. For [ViewMode.comfortable], add link information below the image
    if (widget.media.mediaType == MediaType.link) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          handleTap();
          handleLink(context, url: widget.media.originalUrl!);
        },
        onLongPress: () => handleLinkLongPress(context, widget.media.originalUrl!, widget.media.originalUrl),
        child: widget.viewMode == ViewMode.comfortable
            ? SizedBox(
                height: 70.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: LinkInformation(
                    viewMode: widget.viewMode,
                    mediaType: widget.media.mediaType,
                    url: widget.media.originalUrl ?? '',
                    showEdgeToEdgeImages: widget.edgeToEdgeImages,
                  ),
                ),
              )
            : SizedBox(),
      );
    }

    // For images, add hold to peek gesture (only when image is loaded successfully)
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

    // For videos, add a play icon and tap gesture to play the video
    if (widget.media.mediaType == MediaType.video) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          handleTap();
          showVideoPlayer(context, url: widget.media.mediaUrl ?? widget.media.originalUrl, postId: widget.postId);
        },
        child: widget.viewMode == ViewMode.comfortable
            ? Column(
                children: [
                  Expanded(child: Icon(Icons.play_arrow_rounded, size: 55)),
                  SizedBox(
                    height: 70.0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: LinkInformation(
                        viewMode: widget.viewMode,
                        mediaType: widget.media.mediaType,
                        url: widget.media.originalUrl ?? '',
                        showEdgeToEdgeImages: widget.edgeToEdgeImages,
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(),
      );
    }

    return Stack(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
            color: getBackgroundColor(context),
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
              }),
          child: Stack(
            fit: widget.allowUnconstrainedImageHeight ? StackFit.loose : StackFit.expand,
            alignment: Alignment.center,
            children: [
              ImagePreview(
                url: widget.media.thumbnailUrl ?? widget.media.imageUrl ?? widget.media.originalUrl!,
                contentType: widget.media.contentType,
                width: width,
                height: height,
                fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
                mediaType: widget.media.mediaType,
                viewed: widget.read,
                blur: blurNSFWPreviews,
                allowRetry: widget.media.mediaType == MediaType.image,
                onStateChanged: _onImagePreviewStateChanged,
              ),
              if (blurNSFWPreviews)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.media.mediaType == MediaType.image
                        ? Icon(Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30)
                        : Icon(widget.viewMode != ViewMode.compact ? Icons.play_arrow_rounded : Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30),
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
