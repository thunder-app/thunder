import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' hide Text;
import 'package:thunder/notification/utils/notification_utils.dart';

import 'package:thunder/shared/link_information.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/enums/image_caching_mode.dart';
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

class _MediaViewState extends State<MediaView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 130), lowerBound: 0.0, upperBound: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Creates a text preview for posts in compact mode
  Widget buildMediaText() {
    final theme = Theme.of(context);

    if (widget.viewMode == ViewMode.comfortable) return Container();

    String? plainTextComment;
    if (widget.postViewMedia.postView.post.body?.isNotEmpty == true) {
      final String htmlComment = cleanImagesFromHtml(markdownToHtml(widget.postViewMedia.postView.post.body!));
      plainTextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? widget.postViewMedia.postView.post.body!;
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Container(
        color: theme.cardColor.darken(5),
        child: widget.postViewMedia.postView.post.body?.isNotEmpty == true
            ? SizedBox(
                height: ViewMode.compact.height,
                width: ViewMode.compact.height,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      plainTextComment!,
                      style: TextStyle(
                        fontSize: min(20, max(4.5, (20 * (1 / log(widget.postViewMedia.postView.post.body!.length))))),
                        color: widget.read == true ? theme.colorScheme.onBackground.withOpacity(0.55) : theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                height: ViewMode.compact.height,
                width: ViewMode.compact.height,
                color: theme.cardColor.darken(5),
                child: Icon(
                  Icons.text_fields_rounded,
                  color: theme.colorScheme.onSecondaryContainer.withOpacity(widget.read == true ? 0.55 : 1.0),
                ),
              ),
      ),
    );
  }

  /// Overlays the image as an ImageViewer
  void showImage() {
    if (widget.isUserLoggedIn && widget.markPostReadOnMediaView) {
      try {
        // Mark post as read when on the feed page
        int postId = widget.postViewMedia.postView.post.id;
        context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: postId, value: true));
      } catch (e) {}
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

  /// Creates an image preview
  Widget buildMediaImage() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // TODO: If this site has a content warning, we don't need to blur previews.
    // (This can be implemented once the web UI does the same.)
    final blurNSFWPreviews = widget.hideNsfwPreviews && widget.postViewMedia.postView.post.nsfw;

    return InkWell(
      splashColor: theme.colorScheme.primary.withOpacity(0.4),
      borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
      onTap: showImage,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
          color: getBackgroundColor(context),
        ),
        constraints: BoxConstraints(
            maxHeight: switch (widget.viewMode) {
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => widget.showFullHeightImages
                  ? widget.postViewMedia.media.first.height ?? (widget.allowUnconstrainedImageHeight ? double.infinity : ViewMode.comfortable.height)
                  : ViewMode.comfortable.height,
            },
            minHeight: switch (widget.viewMode) {
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => widget.showFullHeightImages ? widget.postViewMedia.media.first.height ?? ViewMode.comfortable.height : ViewMode.comfortable.height,
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
            ImageFiltered(
              enabled: blurNSFWPreviews,
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: previewImage(context),
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
    );
  }

  /// Creates an video preview. This displays a thumbnail of the video, and tapping it will open the video in a fullscreen player
  Widget buildMediaVideo() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // TODO: If this site has a content warning, we don't need to blur previews.
    // (This can be implemented once the web UI does the same.)
    final blurNSFWPreviews = widget.hideNsfwPreviews && widget.postViewMedia.postView.post.nsfw;

    return InkWell(
      splashColor: theme.colorScheme.primary.withOpacity(0.4),
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
              ViewMode.comfortable => widget.showFullHeightImages
                  ? widget.postViewMedia.media.first.height ?? (widget.allowUnconstrainedImageHeight ? double.infinity : ViewMode.comfortable.height)
                  : ViewMode.comfortable.height,
            },
            minHeight: switch (widget.viewMode) {
              ViewMode.compact => ViewMode.compact.height,
              ViewMode.comfortable => widget.showFullHeightImages ? widget.postViewMedia.media.first.height ?? ViewMode.comfortable.height : ViewMode.comfortable.height,
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
                color: theme.colorScheme.onSecondaryContainer.withOpacity(widget.read == true ? 0.55 : 1.0),
              ),
            if (widget.postViewMedia.media.first.thumbnailUrl != null)
              ImageFiltered(
                enabled: blurNSFWPreviews,
                imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: previewImage(context),
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
        return buildMediaText();
      default:
        return Container();
    }
  }

  Widget previewImage(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

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

    return ExtendedImage.network(
      color: widget.read == true ? const Color.fromRGBO(255, 255, 255, 0.5) : null,
      colorBlendMode: widget.read == true ? BlendMode.modulate : null,
      widget.postViewMedia.media.first.thumbnailUrl ?? widget.postViewMedia.media.first.originalUrl!,
      height: height,
      width: width,
      fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
      cache: true,
      clearMemoryCacheWhenDispose: state.imageCachingMode == ImageCachingMode.relaxed,
      cacheWidth: width != null ? (width * View.of(context).devicePixelRatio.ceil()).toInt() : null,
      cacheHeight: height != null ? (height * View.of(context).devicePixelRatio.ceil()).toInt() : null,
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

            return widget.postViewMedia.postView.post.nsfw
                ? Container()
                : Icon(
                    switch (widget.postViewMedia.media.first.mediaType) {
                      MediaType.image => Icons.image_not_supported_outlined,
                      MediaType.video => Icons.video_camera_back_outlined,
                      MediaType.link => Icons.language_rounded,
                      // Should never come here
                      MediaType.text => Icons.text_fields_rounded,
                    },
                    color: theme.colorScheme.onSecondaryContainer.withOpacity(widget.read == true ? 0.55 : 1.0),
                  );
        }
      },
    );
  }
}
