import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
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
  final bool? showLinkPreview;
  final ViewMode viewMode;

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
    this.showLinkPreview,
  });

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
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
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  color: theme.cardColor.darken(3),
                  child: SizedBox(
                    height: 75.0,
                    width: 75.0,
                    child: Icon(
                      Icons.article_rounded,
                      color: theme.colorScheme.onSecondaryContainer,
                      semanticLabel: 'Article Link',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 1),
              child: SizedBox(
                height: 30,
                width: 30,
                child: Material(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(2),
                  ),
                  color: theme.colorScheme.background,
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: Material(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(3),
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(3),
                      ),
                      color: theme.colorScheme.tertiary,
                      child: const Icon(size: 18, Icons.article_rounded),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    bool hideNsfw = widget.hideNsfwPreviews && (widget.postView?.postView.post.nsfw ?? true);

    // Link posts
    if (widget.postView!.media.firstOrNull?.mediaType == MediaType.link) {
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: LinkPreviewCard(
              hideNsfw: hideNsfw,
              showLinkPreviews: widget.showLinkPreview!,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 2, bottom: 1),
            child: SizedBox(
              height: 30,
              width: 30,
              child: Material(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(2),
                ),
                color: theme.colorScheme.background,
                child: Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(3),
                    ),
                    color: theme.colorScheme.primary,
                    child: const Icon(size: 18, Icons.link_rounded),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // The rest (media)
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Material(
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
                        if (widget.viewMode != ViewMode.compact) const Text("NSFW - Tap to reveal", textScaleFactor: 1.5),
                      ],
                    ),
                  ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: theme.colorScheme.tertiary.withOpacity(0.4),
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
                            transitionDuration: const Duration(milliseconds: 200),
                            reverseTransitionDuration: const Duration(milliseconds: 200),
                            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                              String heroKey = generateRandomHeroString();

                              return ImageViewer(
                                url: widget.postView!.media.first.mediaUrl!,
                                heroKey: heroKey,
                                postId: widget.postView!.postView.post.id,
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 2, bottom: 1),
          child: SizedBox(
            height: 30,
            width: 30,
            child: Material(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(2),
              ),
              color: theme.colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Material(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(3),
                  ),
                  color: theme.colorScheme.secondary,
                  child: const Icon(size: 18, Icons.image_rounded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget previewImage(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    final openInExternalBrowser = state.openInExternalBrowser;

    double? height = widget.viewMode == ViewMode.compact ? 75 : (widget.showFullHeightImages ? widget.postView!.media.first.height : 150);
    double width = widget.viewMode == ViewMode.compact ? 75 : MediaQuery.of(context).size.width - (widget.edgeToEdgeImages ? 0 : 24);

    return Hero(
      tag: widget.postView!.media.first.mediaUrl!,
      child: ExtendedImage.network(
        widget.postView!.media.first.mediaUrl!,
        height: height,
        width: width,
        fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
        cache: true,
        clearMemoryCacheWhenDispose: true,
        cacheWidth: widget.viewMode == ViewMode.compact
            ? (75 * View.of(context).devicePixelRatio.ceil())
            : ((MediaQuery.of(context).size.width - (widget.edgeToEdgeImages ? 0 : 24)) * View.of(context).devicePixelRatio.ceil()).toInt(),
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              _controller.reset();

              return Container(
                color: theme.cardColor.darken(3),
                child: SizedBox(
                  height: height,
                  width: width,
                  child: const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator())),
                ),
              );
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
                  child: InkWell(
                    onTap: () {
                      if (widget.post?.url != null) {
                        openLink(context, url: widget.post!.url!, openInExternalBrowser: openInExternalBrowser);
                      }
                    },
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
                        ],
                      ),
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
