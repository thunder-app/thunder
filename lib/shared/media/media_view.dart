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
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/utils/media/video.dart';

class MediaView extends StatefulWidget {
  /// The post containing the media information
  final PostViewMedia postViewMedia;

  /// Whether to show the full height for images
  final bool showFullHeightImages;

  /// When enabled, the image height will be unconstrained. This is only applicable when [showFullHeightImages] is enabled.
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

  /// Whether to scrape missing previews for thumbnails
  final bool? scrapeMissingPreviews;

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
    this.scrapeMissingPreviews,
    this.navigateToPost,
    this.read,
  });

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> with TickerProviderStateMixin {
  // Overlay used for image peeking
  OverlayEntry? _overlayEntry;
  late final AnimationController _overlayAnimationController;

  @override
  void initState() {
    _overlayAnimationController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    super.initState();
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
    if (!widget.showFullHeightImages) return ViewMode.comfortable.height;

    if (widget.postViewMedia.media.first.height != null) {
      if (MediaQuery.of(context).size.height < widget.postViewMedia.media.first.height!) return MediaQuery.of(context).size.height;
      return widget.postViewMedia.media.first.height!;
    }

    if (widget.allowUnconstrainedImageHeight) return MediaQuery.of(context).size.height;

    return ViewMode.comfortable.height;
  }

  /// Creates an image preview
  Widget buildMediaImage() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final state = context.read<ThunderBloc>().state;

    // TODO: If this site has a content warning, we don't need to blur previews.
    // (This can be implemented once the web UI does the same.)
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
        height = widget.showFullHeightImages ? widget.postViewMedia.media.first.height : null;
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
                    Icon(Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30),
                    if (widget.viewMode != ViewMode.compact) Text(l10n.nsfwWarning, textScaler: const TextScaler.linear(1.5)),
                  ],
                ),
            ],
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
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
            ),
          ),
        ),
      ],
    );
  }

  /// Creates an video preview. This displays a thumbnail of the video, and tapping it will open the video in a fullscreen player
  Widget buildMediaVideo() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    // TODO: If this site has a content warning, we don't need to blur previews.
    // (This can be implemented once the web UI does the same.)
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
        height = widget.showFullHeightImages ? widget.postViewMedia.media.first.height : null;
    }

    return InkWell(
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
      onTap: () {
        if (widget.isUserLoggedIn && widget.markPostReadOnMediaView && widget.postViewMedia.postView.read == false) {
          FeedBloc feedBloc = BlocProvider.of<FeedBloc>(context);
          feedBloc.add(FeedItemActionedEvent(postAction: PostAction.read, postId: widget.postViewMedia.postView.post.id, value: true));
        }

        showVideoPlayer(context, url: widget.postViewMedia.media.first.mediaUrl ?? widget.postViewMedia.media.first.originalUrl, postId: widget.postViewMedia.postView.post.id);
      },
      child: Container(
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
          alignment: Alignment.bottomLeft,
          children: [
            if (!widget.postViewMedia.postView.post.nsfw && widget.postViewMedia.media.first.thumbnailUrl?.isNotEmpty != true)
              Icon(
                Icons.video_camera_back_outlined,
                color: theme.colorScheme.onSecondaryContainer.withValues(alpha: widget.read == true ? 0.55 : 1.0),
              ),
            if (widget.postViewMedia.media.first.thumbnailUrl != null)
              ImagePreview(
                url: widget.postViewMedia.media.first.thumbnailUrl ?? widget.postViewMedia.media.first.originalUrl!,
                width: width,
                height: height,
                fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
                mediaType: widget.postViewMedia.media.first.mediaType,
                viewed: widget.read,
                blur: blurNSFWPreviews,
              ),
            if (widget.postViewMedia.postView.post.nsfw)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.viewMode != ViewMode.compact ? Icons.play_arrow_rounded : Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30),
                  if (widget.viewMode != ViewMode.compact) Text(l10n.nsfwWarning, textScaler: const TextScaler.linear(1.5)),
                ],
              )
            else if (widget.viewMode == ViewMode.comfortable)
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideThumbnails) {
      return LinkInformation(
        viewMode: widget.viewMode,
        originURL: widget.postViewMedia.media.first.originalUrl,
        mediaType: widget.postViewMedia.media.first.mediaType,
        onTap: widget.postViewMedia.media.first.mediaType == MediaType.image ? showImage : null,
        showEdgeToEdgeImages: widget.edgeToEdgeImages,
      );
    }
    switch (widget.postViewMedia.media.firstOrNull?.mediaType) {
      case MediaType.image:
        return buildMediaImage();
      case MediaType.video:
        if (widget.viewMode == ViewMode.comfortable && widget.postViewMedia.media.first.thumbnailUrl == null) {
          return LinkInformation(
            viewMode: widget.viewMode,
            mediaType: widget.postViewMedia.media.first.mediaType,
            originURL: widget.postViewMedia.media.first.originalUrl ?? '',
            showEdgeToEdgeImages: widget.edgeToEdgeImages,
          );
        }

        return buildMediaVideo();
      case MediaType.link:
        return LinkPreviewCard(
          hideNsfw: widget.hideNsfwPreviews && widget.postViewMedia.postView.post.nsfw,
          scrapeMissingPreviews: widget.scrapeMissingPreviews!,
          originURL: widget.postViewMedia.media.first.originalUrl,
          mediaURL: widget.postViewMedia.media.first.thumbnailUrl ?? widget.postViewMedia.postView.post.thumbnailUrl,
          mediaHeight: widget.postViewMedia.media.first.height,
          mediaWidth: widget.postViewMedia.media.first.width,
          showFullHeightImages: widget.viewMode == ViewMode.comfortable ? widget.showFullHeightImages : false,
          edgeToEdgeImages: widget.viewMode == ViewMode.comfortable ? widget.edgeToEdgeImages : false,
          viewMode: widget.viewMode,
          postId: widget.postViewMedia.postView.post.id,
          markPostReadOnMediaView: widget.markPostReadOnMediaView,
          isUserLoggedIn: widget.isUserLoggedIn,
          read: widget.read,
        );
      case MediaType.text:
        if (widget.viewMode == ViewMode.comfortable) return Container();

        return MediaViewText(
          text: widget.postViewMedia.postView.post.body,
          read: widget.read,
        );
      default:
        return Container();
    }
  }
}
