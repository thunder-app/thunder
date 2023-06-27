import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lemmy/lemmy.dart';

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
  final ViewMode viewMode;

  const MediaView({
    super.key,
    this.post,
    this.postView,
    this.showFullHeightImages = true,
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
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    if (widget.postView == null || widget.postView!.media.isEmpty) {
      if (widget.viewMode == ViewMode.compact) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
            child: const SizedBox(
              height: 75.0,
              width: 75.0,
              child: Icon(
                Icons.article_rounded,
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
        viewMode: widget.viewMode,
      );
    }

    bool hideNsfw = widget.hideNsfwPreviews && (widget.postView?.post.nsfw ?? true);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
              return ImageViewer(url: widget.postView!.media.first.mediaUrl!);
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              hideNsfw ? ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: previewImage(context)) : previewImage(context),
              if (hideNsfw)
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.warning_rounded, size: widget.viewMode != ViewMode.compact ? 55 : 30),
                      if (widget.viewMode != ViewMode.compact) const Text("NSFW - Tap to unhide", textScaleFactor: 1.5),
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
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;
    final openInExternalBrowser = context.read<ThunderBloc>().state.preferences?.getBool('setting_links_open_in_external_browser') ?? false;

    double? height = widget.viewMode == ViewMode.compact ? 75 : (widget.showFullHeightImages ? widget.postView!.media.first.height : 150);
    double width = widget.viewMode == ViewMode.compact ? 75 : (widget.postView!.media.first.width ?? MediaQuery.of(context).size.width - 24);

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
            : ((widget.postView!.media.first.width ?? MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              _controller.reset();

              return Container(
                color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
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
                color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: InkWell(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6), // Image border
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                            color: Colors.grey.shade900,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(
                                    Icons.link,
                                    color: Colors.white60,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.post?.url ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: Colors.white60,
                                    ),
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
