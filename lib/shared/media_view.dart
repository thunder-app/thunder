import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/utils/image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class MediaView extends StatefulWidget {
  final Post? post;
  final PostViewMedia? postView;
  final bool showFullHeightImages;
  final bool hideNsfwPreviews;
  final bool edgeToEdgeImages;
  final ViewMode viewMode;

  const MediaView({
    super.key,
    this.post,
    this.postView,
    this.showFullHeightImages = true,
    this.edgeToEdgeImages = false,
    required this.hideNsfwPreviews,
    this.viewMode = ViewMode.comfortable,
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

    if (widget.postView == null || widget.postView!.media.isEmpty) {
      if (widget.viewMode == ViewMode.compact) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
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
        );
      } else {
        return Container();
      }
    }

    if (widget.postView!.media.firstOrNull?.mediaType == MediaType.link) {
      return LinkPreviewCard(
        originURL: widget.postView!.media.first.originalUrl,
        mediaURL: widget.postView!.media.first.mediaUrl,
        mediaHeight: widget.postView!.media.first.height,
        mediaWidth: widget.postView!.media.first.width,
        showFullHeightImages: widget.viewMode == ViewMode.comfortable ? widget.showFullHeightImages : false,
        // edgeToEdgeImages: widget.viewMode == ViewMode.comfortable ? widget.edgeToEdgeImages : false,
        viewMode: widget.viewMode,
      );
    }

    bool hideNsfw = widget.hideNsfwPreviews && (widget.postView?.postView.post.nsfw ?? true);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
              String heroKey = generateRandomHeroString();

              return ImageViewer(url: widget.postView!.media.first.mediaUrl!, heroKey: heroKey);
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
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular((widget.edgeToEdgeImages ? 0 : 6))),
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
            ],
          ),
        ),
      ),
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
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
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
                    onTap: () {
                      if (widget.post?.url != null) {
                        if (openInExternalBrowser) {
                          launchUrl(Uri.parse(widget.post!.url!), mode: LaunchMode.externalApplication);
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => WebView(url: widget.post!.url!)));
                        }
                      }
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
