import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart' as content;
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/shared/links/widgets/link_bottom_sheet.dart';
import 'package:thunder/src/features/content/presentation/widgets/media/media_utils.dart';

/// App adapter for package-generic content media view.
class MediaView extends StatelessWidget {
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
    this.handlers = const content.ContentActionHandlers(),
  });

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

  /// Optional action handlers that decouple media and navigation behavior.
  final content.ContentActionHandlers handlers;

  @override
  Widget build(BuildContext context) {
    final imagePeekDurationMs = context.select<GesturePreferencesCubit, int>(
      (cubit) => cubit.state.imagePeekDuration,
    );
    final tabletMode = viewMode == ViewMode.comfortable ? context.select((ThunderBloc bloc) => bloc.state.tabletMode) : false;
    final l10n = AppLocalizations.of(context)!;

    final effectiveHandlers = content.ContentActionHandlers(
      onOpenLink: handlers.onOpenLink ??
          (context, url) {
            handleLink(context, url: url);
          },
      onLongPressLink: handlers.onLongPressLink ??
          (context, text, url) {
            if (url != null) {
              handleLinkLongPress(context, text, url);
            }
          },
      onOpenImage: handlers.onOpenImage ??
          (context, {url, bytes}) {
            showImageViewer(
              context,
              url: url,
              bytes: bytes,
              postId: postId,
              navigateToPost: navigateToPost,
              altText: media.altText,
            );
          },
      onOpenVideo: handlers.onOpenVideo ??
          (context, url) {
            handleVideoLink(context, url: url);
          },
      onMarkRead: handlers.onMarkRead ??
          (postId) {
            try {
              final feedBloc = BlocProvider.of<FeedBloc>(context);
              feedBloc.add(
                FeedItemActionedEvent(
                  postAction: PostAction.read,
                  postId: postId,
                  actionInput: const ReadPostInput(true),
                ),
              );
            } catch (e) {
              debugPrint('Error marking post as read: $e');
            }
          },
    );

    return content.MediaView(
      media: _mapMedia(media),
      postId: postId,
      showFullHeightImages: showFullHeightImages,
      allowUnconstrainedImageHeight: allowUnconstrainedImageHeight,
      edgeToEdgeImages: edgeToEdgeImages,
      hideNsfwPreviews: hideNsfwPreviews,
      hideThumbnails: hideThumbnails,
      markPostReadOnMediaView: markPostReadOnMediaView,
      isUserLoggedIn: isUserLoggedIn,
      viewMode: _mapViewMode(viewMode),
      navigateToPost: navigateToPost,
      read: read,
      handlers: effectiveHandlers,
      imagePeekDurationMs: imagePeekDurationMs,
      tabletMode: tabletMode,
      nsfwWarningLabel: l10n.nsfwWarning,
      retryTooltip: l10n.retry,
    );
  }
}

content.ContentMedia _mapMedia(Media media) {
  return content.ContentMedia(
    thumbnailUrl: media.thumbnailUrl,
    mediaUrl: media.mediaUrl,
    originalUrl: media.originalUrl,
    width: media.width,
    height: media.height,
    nsfw: media.nsfw,
    mediaType: _mapMediaType(media.mediaType),
    altText: media.altText,
    contentType: media.contentType,
  );
}

content.ContentViewMode _mapViewMode(ViewMode viewMode) {
  return switch (viewMode) {
    ViewMode.comment => content.ContentViewMode.comment,
    ViewMode.compact => content.ContentViewMode.compact,
    ViewMode.comfortable => content.ContentViewMode.comfortable,
  };
}

content.ContentMediaType _mapMediaType(MediaType mediaType) {
  return switch (mediaType) {
    MediaType.image => content.ContentMediaType.image,
    MediaType.video => content.ContentMediaType.video,
    MediaType.link => content.ContentMediaType.link,
    MediaType.text => content.ContentMediaType.text,
  };
}
