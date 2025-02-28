import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/shared/image/image_preview.dart';
import 'package:thunder/shared/link_information.dart';
import 'package:thunder/shared/media/media_view_text.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/utils/media/video.dart';

class MediaView extends StatefulWidget {
  /// The post containing the media information
  final PostViewMedia postViewMedia;

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
  final void Function({PostViewMedia? postViewMedia})? navigateToPost;

  /// Whether the post has been read
  final bool? read;

  const MediaView({
    super.key,
    required this.postViewMedia,
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

  /// Overlays the image as an ImageViewer
  void showImage() {
    if (widget.isUserLoggedIn && widget.markPostReadOnMediaView) {
      try {
        // Mark post as read when on the feed page
        int postId = widget.postViewMedia.postView.post.id;
        context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: postId, value: true));
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
            url: widget.postViewMedia.media.first.imageUrl,
            postId: widget.postViewMedia.postView.post.id,
            navigateToPost: widget.navigateToPost,
            altText: widget.postViewMedia.media.first.altText,
          );
        },
      ),
    );
  }

  double getMinHeight() {
    if (!widget.showFullHeightImages) return ViewMode.comfortable.height;

    if (widget.postViewMedia.media.first.height != null) {
      if (MediaQuery.of(context).size.height < widget.postViewMedia.media.first.height!) return MediaQuery.of(context).size.height;
      return widget.postViewMedia.media.first.height!;
    }

    return ViewMode.comfortable.height;
  }

  double getMaxHeight() {
    if (widget.allowUnconstrainedImageHeight) return MediaQuery.of(context).size.height;
    if (!widget.showFullHeightImages) return ViewMode.comfortable.height;

    if (widget.postViewMedia.media.first.height != null) {
      if (MediaQuery.of(context).size.height < widget.postViewMedia.media.first.height!) return MediaQuery.of(context).size.height;
      return widget.postViewMedia.media.first.height!;
    }

    return ViewMode.comfortable.height;
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.postViewMedia.media.firstOrNull;
    if (media == null) return Container();

    // If hiding thumbnails is enabled or if the media has no image URL (e.g., text or links with no images), we should display a link preview instead
    // This only applies for [ViewMode.comfortable]
    if (widget.viewMode == ViewMode.comfortable && (widget.hideThumbnails || media.imageUrl == null)) {
      return LinkInformation(
        viewMode: widget.viewMode,
        originURL: media.originalUrl,
        mediaType: media.mediaType,
        onTap: media.mediaType == MediaType.image ? showImage : null,
        showEdgeToEdgeImages: widget.edgeToEdgeImages,
      );
    }

    if (widget.viewMode == ViewMode.compact && media.mediaType == MediaType.text) {
      return MediaViewText(
        text: widget.postViewMedia.postView.post.body,
        read: widget.read,
      );
    }

    // At this point, all other media types should contain images, so we display the image as well as any additional information
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    final blurNSFWPreviews = widget.hideNsfwPreviews && widget.postViewMedia.postView.post.nsfw;

    double? width;
    double? height;

    switch (widget.viewMode) {
      case ViewMode.compact:
        width = null; // Setting this to null will use the image's width. This will allow the image to not be stretched or squished.
        height = ViewMode.compact.height;
        break;
      case ViewMode.comfortable:
        width = (state.tabletMode ? (MediaQuery.of(context).size.width / 2) - 24.0 : MediaQuery.of(context).size.width) - (widget.edgeToEdgeImages ? 0 : 24);
        height = (widget.showFullHeightImages && !widget.allowUnconstrainedImageHeight) ? widget.postViewMedia.media.first.height : null;
    }

    Widget? child;

    // For links, add inkwell to handle links. For [ViewMode.comfortable], add link information below the image
    if (media.mediaType == MediaType.link) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onLongPress: () => handleLinkLongPress(context, media.originalUrl!, media.originalUrl),
        child: widget.viewMode == ViewMode.comfortable
            ? SizedBox(
                height: 70.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: LinkInformation(
                    viewMode: widget.viewMode,
                    mediaType: widget.postViewMedia.media.first.mediaType,
                    originURL: widget.postViewMedia.media.first.originalUrl ?? '',
                    showEdgeToEdgeImages: widget.edgeToEdgeImages,
                  ),
                ),
              )
            : SizedBox(),
      );
    }

    // For images, add hold to peek gesture
    if (media.mediaType == MediaType.image) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: showImage,
        child: GestureDetector(
          onLongPressStart: (_) {
            _overlayEntry = OverlayEntry(
              builder: (context) {
                return FadeTransition(
                  opacity: _overlayAnimationController,
                  child: ImageViewer(
                    url: widget.postViewMedia.media.first.thumbnailUrl ?? widget.postViewMedia.media.first.mediaUrl,
                    postId: widget.postViewMedia.postView.post.id,
                    navigateToPost: widget.navigateToPost,
                    isPeek: true,
                  ),
                );
              },
            );
            Overlay.of(context).insert(_overlayEntry!);
            _overlayAnimationController.forward();
          },
          onLongPressEnd: (_) async {
            await _overlayAnimationController.reverse();
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
        ),
      );
    }

    // For videos, add a play icon and tap gesture to play the video
    if (media.mediaType == MediaType.video) {
      child = InkWell(
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
        onTap: () {
          if (widget.isUserLoggedIn && widget.markPostReadOnMediaView && widget.postViewMedia.postView.read == false) {
            FeedBloc feedBloc = BlocProvider.of<FeedBloc>(context);
            feedBloc.add(FeedItemActionedEvent(postAction: PostAction.read, postId: widget.postViewMedia.postView.post.id, value: true));
          }

          showVideoPlayer(context, url: widget.postViewMedia.media.first.mediaUrl ?? widget.postViewMedia.media.first.originalUrl, postId: widget.postViewMedia.postView.post.id);
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
                        mediaType: widget.postViewMedia.media.first.mediaType,
                        originURL: widget.postViewMedia.media.first.originalUrl ?? '',
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
                ViewMode.compact => ViewMode.compact.height,
                ViewMode.comfortable => getMaxHeight(),
              },
              minHeight: switch (widget.viewMode) {
                ViewMode.compact => ViewMode.compact.height,
                ViewMode.comfortable => getMinHeight(),
              },
              maxWidth: switch (widget.viewMode) {
                ViewMode.compact => ViewMode.compact.height,
                ViewMode.comfortable => widget.edgeToEdgeImages ? double.infinity : MediaQuery.of(context).size.width,
              },
              minWidth: switch (widget.viewMode) {
                ViewMode.compact => ViewMode.compact.height,
                ViewMode.comfortable => widget.edgeToEdgeImages ? double.infinity : MediaQuery.of(context).size.width,
              }),
          child: Stack(
            fit: widget.allowUnconstrainedImageHeight ? StackFit.loose : StackFit.expand,
            alignment: Alignment.center,
            children: [
              ImagePreview(
                url: widget.postViewMedia.media.first.thumbnailUrl ?? widget.postViewMedia.media.first.originalUrl!,
                width: width,
                height: height,
                fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
                mediaType: widget.postViewMedia.media.first.mediaType,
                viewed: widget.read,
                blur: blurNSFWPreviews,
              ),
              if (blurNSFWPreviews)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    media.mediaType == MediaType.image
                        ? Icon(Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30)
                        : Icon(widget.viewMode != ViewMode.compact ? Icons.play_arrow_rounded : Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30),
                    if (widget.viewMode != ViewMode.compact) Text(l10n.nsfwWarning, textScaler: const TextScaler.linear(1.5)),
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
