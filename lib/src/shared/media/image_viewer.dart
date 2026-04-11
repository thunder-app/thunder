import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:extended_image/extended_image.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/packages/ui/ui.dart' show showSnackbar;
import 'package:thunder/src/shared/media/media_utils.dart';

class ImageViewer extends StatefulWidget {
  /// The URL of the image to display
  final String? url;

  /// The bytes of the image to display
  final Uint8List? bytes;

  /// The ID of the post to navigate to
  final int? postId;

  /// The function to navigate to the post
  final void Function()? navigateToPost;

  /// The alt text of the image
  final String? altText;

  /// Whether this image viewer is being shown within the context of a peek.
  final bool isPeek;

  /// Controls whether image cache should be aggressively cleared on dispose.
  final bool clearMemoryCacheWhenDispose;

  const ImageViewer({
    super.key,
    this.url,
    this.bytes,
    this.postId,
    this.navigateToPost,
    this.altText,
    this.isPeek = false,
    this.clearMemoryCacheWhenDispose = false,
  }) : assert(url != null || bytes != null);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with TickerProviderStateMixin {
  final slidePagekey = GlobalKey<ExtendedImageSlidePageState>();
  final gestureKey = GlobalKey<ExtendedImageGestureState>();

  bool downloaded = false;
  double slideTransparency = 0.92;
  double imageTransparency = 1.0;
  bool maybeSlideZooming = false;
  bool slideZooming = false;
  bool fullscreen = false;
  Offset downCoord = Offset.zero;
  double delta = 0.0;
  bool areImageDimensionsLoaded = false;

  /// User Settings
  bool isUserLoggedIn = false;
  bool isDownloadingMedia = false;
  bool isSavingMedia = false;
  late double imageWidth = 0;
  late double imageHeight = 0;
  late double maxZoomLevel = 3;

  /// Whether to show the alt text at the bottom of the image viewer
  bool showAltText = false;

  void _maybeSlide(BuildContext context) {
    setState(() => maybeSlideZooming = true);
    Timer(const Duration(milliseconds: 500), () => context.mounted ? setState(() => maybeSlideZooming = false) : null);
  }

  void enterFullScreen() {
    setState(() => fullscreen = true);
    if (fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  void exitFullScreen() {
    setState(() => fullscreen = false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
  }

  Future<void> getImageSize() async {
    try {
      Size decodedImage = await retrieveImageDimensions(imageUrl: widget.url, imageBytes: widget.bytes).timeout(const Duration(seconds: 2));

      setState(() {
        imageWidth = decodedImage.width;
        imageHeight = decodedImage.height;
        maxZoomLevel = max(imageWidth, imageHeight) / 128;
        areImageDimensionsLoaded = true;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        maxZoomLevel = 3;
        areImageDimensionsLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getImageSize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    AnimationController animationController = AnimationController(duration: const Duration(milliseconds: 140), vsync: this);
    Function() animationListener = () {};
    Animation? animation;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          exitFullScreen();
        }
      },
      child: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            systemOverlayStyle: const SystemUiOverlayStyle(
              // Forcing status bar to display bright icons even in light mode
              statusBarIconBrightness: Brightness.light, // For Android (dark icons)
              statusBarBrightness: Brightness.dark, // For iOS (dark icons)
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubicEmphasized,
            color: fullscreen ? Colors.black : Colors.black.withValues(alpha: slideTransparency),
          ),
          Positioned.fill(
            child: GestureDetector(
              onLongPress: () {
                HapticFeedback.lightImpact();
                if (fullscreen) {
                  exitFullScreen();
                } else {
                  enterFullScreen();
                }
              },
              onTap: () {
                if (!fullscreen) {
                  slidePagekey.currentState!.popPage();
                  Navigator.pop(context);
                } else {
                  exitFullScreen();
                }
              },
              // Start doubletap zoom if conditions are met
              onVerticalDragStart: maybeSlideZooming
                  ? (details) {
                      setState(() {
                        slideZooming = true;
                      });
                    }
                  : null,
              // Zoom image in an out based on movement in vertical axis if conditions are met
              onVerticalDragUpdate: maybeSlideZooming || slideZooming
                  ? (details) {
                      // Need to catch the drag during "maybe" phase or it wont activate fast enough
                      if (slideZooming) {
                        double newScale = max(gestureKey.currentState!.gestureDetails!.totalScale! * (1 + (details.delta.dy / 150)), 1);
                        gestureKey.currentState?.handleDoubleTap(scale: newScale, doubleTapPosition: gestureKey.currentState!.pointerDownPosition);
                      }
                    }
                  : null,
              // End doubletap zoom
              onVerticalDragEnd: slideZooming
                  ? (details) {
                      setState(() {
                        slideZooming = false;
                      });
                    }
                  : null,
              child: Listener(
                // Start watching for double tap zoom
                onPointerDown: (details) {
                  downCoord = details.position;
                },
                onPointerUp: (details) {
                  delta = (downCoord - details.position).distance;
                  if (!slideZooming && delta < 0.5) {
                    _maybeSlide(context);
                  }
                },
                onPointerMove: (details) {
                  if (gestureKey.currentState!.gestureDetails!.totalScale! > 1.2) {
                    enterFullScreen();
                  } else {
                    exitFullScreen();
                  }
                },
                child: ExtendedImageSlidePage(
                  key: slidePagekey,
                  slideAxis: SlideAxis.both,
                  slideType: SlideType.onlyImage,
                  slidePageBackgroundHandler: (offset, pageSize) {
                    return Colors.transparent;
                  },
                  onSlidingPage: (state) {
                    // Fade out image and background when sliding to dismiss
                    var offset = state.offset;
                    var pageSize = state.pageSize;

                    var scale = offset.distance / Offset(pageSize.width, pageSize.height).distance;

                    if (state.isSliding) {
                      setState(() {
                        slideTransparency = 0.9 - min(0.9, scale * 0.5);
                        imageTransparency = 1.0 - min(1.0, scale * 10);
                      });
                    }
                  },
                  slideEndHandler: (
                    // Decrease slide to dismiss threshold so it can be done easier
                    Offset offset, {
                    ExtendedImageSlidePageState? state,
                    ScaleEndDetails? details,
                  }) {
                    if (state != null) {
                      var offset = state.offset;
                      var pageSize = state.pageSize;
                      return offset.distance.greaterThan(Offset(pageSize.width, pageSize.height).distance / 10);
                    }
                    return true;
                  },
                  child: widget.url != null
                      ? ExtendedImage.network(
                          widget.url!,
                          color: Colors.white.withValues(alpha: imageTransparency),
                          colorBlendMode: BlendMode.dstIn,
                          enableSlideOutPage: true,
                          mode: ExtendedImageMode.gesture,
                          extendedImageGestureKey: gestureKey,
                          cache: true,
                          clearMemoryCacheWhenDispose: widget.clearMemoryCacheWhenDispose,
                          layoutInsets: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 50, top: MediaQuery.of(context).padding.top + 50),
                          initGestureConfigHandler: (ExtendedImageState state) {
                            return GestureConfig(
                              minScale: 0.8,
                              animationMinScale: 0.8,
                              maxScale: maxZoomLevel.toDouble(),
                              animationMaxScale: maxZoomLevel.toDouble(),
                              speed: 1.0,
                              inertialSpeed: 250.0,
                              initialScale: 1.0,
                              inPageView: false,
                              initialAlignment: InitialAlignment.center,
                              reverseMousePointerScrollDirection: true,
                              gestureDetailsIsChanged: (GestureDetails? details) {},
                            );
                          },
                          onDoubleTap: (ExtendedImageGestureState state) {
                            var pointerDownPosition = state.pointerDownPosition;
                            double begin = state.gestureDetails!.totalScale!;
                            double end;

                            animation?.removeListener(animationListener);
                            animationController.stop();
                            animationController.reset();

                            if (begin == 1) {
                              end = 2;
                              enterFullScreen();
                            } else if (begin > 1.99 && begin < 2.01) {
                              end = 4;
                            } else {
                              end = 1;
                              exitFullScreen();
                            }
                            animationListener = () {
                              state.handleDoubleTap(scale: animation!.value, doubleTapPosition: pointerDownPosition);
                            };
                            animation = animationController.drive(Tween<double>(begin: begin, end: end));

                            animation!.addListener(animationListener);

                            animationController.forward();
                          },
                          loadStateChanged: (state) {
                            if (state.extendedImageLoadState == LoadState.loading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white.withValues(alpha: 0.90),
                                ),
                              );
                            }
                            return null;
                          },
                        )
                      : ExtendedImage.memory(
                          widget.bytes!,
                          color: Colors.white.withValues(alpha: imageTransparency),
                          colorBlendMode: BlendMode.dstIn,
                          enableSlideOutPage: true,
                          mode: ExtendedImageMode.gesture,
                          extendedImageGestureKey: gestureKey,
                          clearMemoryCacheWhenDispose: widget.clearMemoryCacheWhenDispose,
                          initGestureConfigHandler: (ExtendedImageState state) {
                            return GestureConfig(
                              minScale: 0.8,
                              animationMinScale: 0.8,
                              maxScale: 4.0,
                              animationMaxScale: 4.0,
                              speed: 1.0,
                              inertialSpeed: 250.0,
                              initialScale: 1.0,
                              inPageView: false,
                              initialAlignment: InitialAlignment.center,
                              reverseMousePointerScrollDirection: true,
                              gestureDetailsIsChanged: (GestureDetails? details) {},
                            );
                          },
                          onDoubleTap: (ExtendedImageGestureState state) {
                            var pointerDownPosition = state.pointerDownPosition;
                            double begin = state.gestureDetails!.totalScale!;
                            double end;

                            animation?.removeListener(animationListener);
                            animationController.stop();
                            animationController.reset();

                            if (begin == 1) {
                              end = 2;
                              enterFullScreen();
                            } else if (begin > 1.99 && begin < 2.01) {
                              end = 4;
                            } else {
                              end = 1;
                              exitFullScreen();
                            }
                            animationListener = () {
                              state.handleDoubleTap(scale: animation!.value, doubleTapPosition: pointerDownPosition);
                            };
                            animation = animationController.drive(Tween<double>(begin: begin, end: end));

                            animation!.addListener(animationListener);

                            animationController.forward();
                          },
                          loadStateChanged: (state) {
                            if (state.extendedImageLoadState == LoadState.loading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white.withValues(alpha: 0.90),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                ),
              ),
            ),
          ),
          if (!widget.isPeek)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedOpacity(
                  opacity: fullscreen ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0, 0.3, 1],
                        colors: [
                          Colors.transparent,
                          Colors.black26,
                          Colors.black45,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              semanticLabel: "Back",
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: fullscreen ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.3, 1],
                        colors: [
                          Colors.transparent,
                          Colors.black26,
                          Colors.black45,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.url != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              tooltip: l10n.share,
                              onPressed: fullscreen
                                  ? null
                                  : () async {
                                      try {
                                        // Try to get the cached image first
                                        var media = await DefaultCacheManager().getFileFromCache(widget.url!);
                                        File? mediaFile = media?.file;

                                        if (media == null) {
                                          setState(() => isDownloadingMedia = true);

                                          // Download
                                          mediaFile = await DefaultCacheManager().getSingleFile(widget.url!);
                                        }

                                        // Share
                                        await SharePlus.instance.share(ShareParams(
                                          files: [XFile(mediaFile!.path)],
                                          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                                        ));
                                      } catch (e) {
                                        // Tell the user that the download failed
                                        showSnackbar(l10n.errorDownloadingMedia(e));
                                      } finally {
                                        setState(() => isDownloadingMedia = false);
                                      }
                                    },
                              icon: isDownloadingMedia
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white.withValues(alpha: 0.90),
                                      ),
                                    )
                                  : Icon(
                                      Icons.share_rounded,
                                      semanticLabel: l10n.share,
                                      color: Colors.white.withValues(alpha: 0.90),
                                    ),
                            ),
                          ),
                        if (widget.url != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              tooltip: l10n.save,
                              onPressed: (downloaded || isSavingMedia || fullscreen || widget.url == null || kIsWeb)
                                  ? null
                                  : () async {
                                      File file = await DefaultCacheManager().getSingleFile(widget.url!);
                                      bool hasPermission = await Gal.hasAccess(toAlbum: true);
                                      if (!hasPermission) {
                                        await Gal.requestAccess(toAlbum: true);
                                      }

                                      setState(() => isSavingMedia = true);

                                      try {
                                        // Save image on Linux platform
                                        if (Platform.isLinux) {
                                          final filePath = '${(await getApplicationDocumentsDirectory()).path}/Thunder/${basename(file.path)}';

                                          File(filePath)
                                            ..createSync(recursive: true)
                                            ..writeAsBytesSync(file.readAsBytesSync());

                                          return setState(() => downloaded = true);
                                        }

                                        // Save image on all other supported platforms (Android, iOS, macOS, Windows)
                                        try {
                                          await Gal.putImage(file.path, album: "Thunder");
                                          setState(() => downloaded = true);
                                        } on GalException catch (e) {
                                          if (context.mounted) {
                                            showSnackbar(e.type.message);
                                          }
                                          setState(() => downloaded = false);
                                        }
                                      } finally {
                                        setState(() => isSavingMedia = false);
                                      }
                                    },
                              icon: isSavingMedia
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white.withValues(alpha: 0.90),
                                      ),
                                    )
                                  : downloaded
                                      ? Icon(
                                          Icons.check_circle,
                                          semanticLabel: 'Downloaded',
                                          color: Colors.white.withValues(alpha: 0.90),
                                        )
                                      : Icon(
                                          Icons.download,
                                          semanticLabel: "Download",
                                          color: Colors.white.withValues(alpha: 0.90),
                                        ),
                            ),
                          ),
                        if (widget.navigateToPost != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              tooltip: l10n.comments,
                              onPressed: () {
                                Navigator.pop(context);
                                widget.navigateToPost!();
                              },
                              icon: Icon(
                                Icons.chat_rounded,
                                semanticLabel: l10n.comments,
                                color: Colors.white.withValues(alpha: 0.90),
                              ),
                            ),
                          ),
                        if (widget.altText?.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              tooltip: l10n.altText,
                              onPressed: () => setState(() => showAltText = !showAltText),
                              icon: Icon(
                                Icons.text_fields,
                                semanticLabel: l10n.altText,
                                color: Colors.white.withValues(alpha: showAltText ? 0.90 : 0.5),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: IconButton(
                            tooltip: l10n.fullscreen,
                            onPressed: () {
                              if (fullscreen) {
                                exitFullScreen();
                              } else {
                                enterFullScreen();
                              }
                            },
                            icon: Icon(
                              Icons.fullscreen,
                              semanticLabel: l10n.fullscreen,
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (widget.altText?.isNotEmpty == true && showAltText)
            Positioned(
              bottom: kBottomNavigationBarHeight + 25,
              width: MediaQuery.sizeOf(context).width,
              child: AnimatedOpacity(
                opacity: fullscreen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ImageAltText(text: widget.altText!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ImageAltText extends StatelessWidget {
  /// The text to display
  final String text;

  const ImageAltText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.90),
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            color: Colors.black.withValues(alpha: 1),
            blurRadius: 5.0,
          )
        ],
      ),
    );
  }
}
