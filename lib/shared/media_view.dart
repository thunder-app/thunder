import 'dart:math';
import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/community/bloc/community_bloc_old.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class MediaView extends StatefulWidget {
  final Post? post;
  final PostViewMedia? postView;
  final bool showFullHeightImages;
  final bool hideNsfwPreviews;
  final bool edgeToEdgeImages;
  final bool markPostReadOnMediaView;
  final bool isUserLoggedIn;
  final bool? scrapeMissingPreviews;
  final ViewMode viewMode;
  final void Function()? navigateToPost;
  final bool? read;

  const MediaView({
    super.key,
    this.post,
    this.postView,
    this.showFullHeightImages = true,
    this.edgeToEdgeImages = false,
    required this.hideNsfwPreviews,
    required this.markPostReadOnMediaView,
    required this.isUserLoggedIn,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Text posts
    if (widget.postView == null || widget.postView!.media.isEmpty) {
      if (widget.viewMode == ViewMode.compact) {
        // This is used for previewing text posts in compact mde by showing a small version of the text
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Container(
            color: theme.cardColor.darken(5),
            child: widget.postView!.postView.post.body?.isNotEmpty == true
                ? SizedBox(
                    height: 75.0,
                    width: 75.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.postView!.postView.post.body!,
                          style: TextStyle(
                            fontSize: min(20, max(4.5, (20 * (1 / log(widget.postView!.postView.post.body!.length))))),
                            color: widget.read == true ? theme.colorScheme.onBackground.withOpacity(0.55) : theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 75,
                    width: 75,
                    color: theme.cardColor.darken(5),
                    child: Icon(
                      Icons.text_fields_rounded,
                      color: theme.colorScheme.onSecondaryContainer.withOpacity(widget.read == true ? 0.55 : 1.0),
                    ),
                  ),
          ),
        );
      } else {
        return Container();
      }
    }

    bool hideNsfw = widget.hideNsfwPreviews && (widget.postView?.postView.post.nsfw ?? true);

    // Link posts
    if (widget.postView!.media.firstOrNull?.mediaType == MediaType.link) {
      return LinkPreviewCard(
        hideNsfw: hideNsfw,
        scrapeMissingPreviews: widget.scrapeMissingPreviews!,
        originURL: widget.postView!.media.first.originalUrl,
        mediaURL: widget.postView!.media.first.mediaUrl ?? widget.postView!.postView.post.thumbnailUrl,
        mediaHeight: widget.postView!.media.first.height,
        mediaWidth: widget.postView!.media.first.width,
        showFullHeightImages: widget.viewMode == ViewMode.comfortable ? widget.showFullHeightImages : false,
        edgeToEdgeImages: widget.viewMode == ViewMode.comfortable ? widget.edgeToEdgeImages : false,
        viewMode: widget.viewMode,
        postId: widget.postView!.postView.post.id,
        markPostReadOnMediaView: widget.markPostReadOnMediaView,
        isUserLoggedIn: widget.isUserLoggedIn,
        read: widget.read,
      );
    }

    // The rest (media)
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          hideNsfw ? ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), child: previewImage(context)) : previewImage(context),
          if (hideNsfw)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30),
                  if (widget.viewMode != ViewMode.compact) Text("NSFW - Tap to reveal", textScaleFactor: MediaQuery.of(context).textScaleFactor * 1.5),
                ],
              ),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: theme.colorScheme.primary.withOpacity(0.4),
                borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 12)),
                onTap: () {
                  if (widget.isUserLoggedIn && widget.markPostReadOnMediaView) {
                    int postId = widget.postView!.postView.post.id;
                    try {
                      UserBloc userBloc = BlocProvider.of<UserBloc>(context);
                      userBloc.add(MarkUserPostAsReadEvent(postId: postId, read: true));
                    } catch (e) {
                      CommunityBloc communityBloc = BlocProvider.of<CommunityBloc>(context);
                      communityBloc.add(MarkPostAsReadEvent(postId: postId, read: true));
                    }
                  }
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      transitionDuration: const Duration(milliseconds: 100),
                      reverseTransitionDuration: const Duration(milliseconds: 50),
                      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                        return ImageViewer(
                          url: widget.postView!.media.first.mediaUrl!,
                          postId: widget.postView!.postView.post.id,
                          navigateToPost: widget.navigateToPost,
                        );
                      },
                      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                        return Align(
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget previewImage(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    final openInExternalBrowser = state.openInExternalBrowser;

    double? height = widget.viewMode == ViewMode.compact ? 75 : (widget.showFullHeightImages ? widget.postView!.media.first.height : 150);
    double width = widget.viewMode == ViewMode.compact ? 75 : MediaQuery.of(context).size.width - (widget.edgeToEdgeImages ? 0 : 24);

    return ExtendedImage.network(
      color: widget.read == true ? const Color.fromRGBO(255, 255, 255, 0.5) : null,
      colorBlendMode: widget.read == true ? BlendMode.modulate : null,
      widget.postView!.media.first.mediaUrl!,
      height: height,
      width: width,
      fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
      cache: true,
      clearMemoryCacheWhenDispose: false,
      cacheMaxAge: const Duration(minutes: 1),
      cacheWidth: widget.viewMode == ViewMode.compact
          ? (75 * View.of(context).devicePixelRatio.ceil())
          : ((MediaQuery.of(context).size.width - (widget.edgeToEdgeImages ? 0 : 24)) * View.of(context).devicePixelRatio.ceil()).toInt(),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            _controller.reset();

            return Container();
          case LoadState.completed:
            if (state.wasSynchronouslyLoaded) {
              return state.completedWidget;
            }
            _controller.forward();

            return FadeTransition(
              opacity: _controller,
              child: state.completedWidget,
            );
          case LoadState.failed:
            _controller.reset();

            state.imageProvider.evict();

            return Container(
              color: theme.cardColor.darken(3),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    fit: StackFit.passthrough,
                    children: [
                      Container(
                        color: theme.colorScheme.secondary.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(
                                Icons.link,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.post?.url ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (widget.post?.url != null) {
                            openLink(context, url: widget.post!.url!, openInExternalBrowser: openInExternalBrowser);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
