import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImageViewer extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final int? postId;
  final void Function()? navigateToPost;

  const ImageViewer({
    super.key,
    this.url,
    this.bytes,
    this.postId,
    this.navigateToPost,
  }) : assert(url != null || bytes != null);

  get postViewMedia => null;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with TickerProviderStateMixin {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();
  final GlobalKey<ScaffoldMessengerState> _imageViewer = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ExtendedImageGestureState> gestureKey = GlobalKey<ExtendedImageGestureState>();
  bool downloaded = false;

  double slideTransparency = 0.92;
  double imageTransparency = 1.0;

  bool maybeSlideZooming = false;
  bool slideZooming = false;
  bool fullscreen = false;
  Offset downCoord = Offset.zero;

  /// User Settings
  bool isUserLoggedIn = false;

  bool isDownloadingMedia = false;

  void _maybeSlide(BuildContext context) {
    setState(() {
      maybeSlideZooming = true;
    });
    Timer(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        setState(() {
          maybeSlideZooming = false;
        });
      }
    });
  }

  Future<bool> _requestPermission() async {
    bool androidVersionBelow33 = false;

    if (Platform.isAndroid) {
      androidVersionBelow33 = (await DeviceInfoPlugin().androidInfo).version.sdkInt <= 32;
    }

    // Check first if we have permissions
    bool hasStoragePermission = await Permission.storage.isGranted || await Permission.storage.isLimited;
    bool hasPhotosPermission = await Permission.photos.isGranted || await Permission.photos.isLimited;

    if (androidVersionBelow33 && !hasStoragePermission) {
      await Permission.storage.request();
      hasStoragePermission = await Permission.storage.isGranted || await Permission.storage.isLimited;
    } else if (!androidVersionBelow33 && !hasPhotosPermission) {
      await Permission.photos.request();
      hasPhotosPermission = await Permission.photos.isGranted || await Permission.photos.isLimited;
    }

    if (Platform.isAndroid && androidVersionBelow33) return hasStoragePermission;
    return hasPhotosPermission;
  }

  /// Shows a dialog indicating that permissions have been denied, and must be granted in order to save image.
  void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Thunder requires some permissions in order to save this image which has been denied.'),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Open Settings'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AnimationController animationController = AnimationController(duration: const Duration(milliseconds: 140), vsync: this);
    Function() animationListener = () {};
    Animation? animation;

    return ScaffoldMessenger(
      key: _imageViewer,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: fullscreen ? Colors.black : Colors.transparent,
          ),
          Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: fullscreen ? Colors.transparent : Colors.white,
                shadows: fullscreen ? null : <Shadow>[const Shadow(color: Colors.black, blurRadius: 50.0)],
              ),
              backgroundColor: Colors.transparent,
              toolbarHeight: 70.0,
            ),
            backgroundColor: Colors.black.withOpacity(slideTransparency),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        fullscreen = !fullscreen;
                      });
                    },
                    onTap: () {
                      if (!fullscreen) {
                        slidePagekey.currentState!.popPage();
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          fullscreen = false;
                        });
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
                    // End doubltap zoom
                    onVerticalDragEnd: slideZooming
                        ? (details) {
                            setState(() {
                              slideZooming = false;
                            });
                          }
                        : null,
                    child: Listener(
                      // Start watching for double tap zoom
                      onPointerUp: (details) {
                        downCoord = details.position;
                        if (!slideZooming) {
                          _maybeSlide(context);
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
                                color: Colors.white.withOpacity(imageTransparency),
                                colorBlendMode: BlendMode.dstIn,
                                enableSlideOutPage: true,
                                mode: ExtendedImageMode.gesture,
                                extendedImageGestureKey: gestureKey,
                                cache: true,
                                clearMemoryCacheWhenDispose: false,
                                cacheMaxAge: const Duration(minutes: 1),
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
                                  } else if (begin > 1.99 && begin < 2.01) {
                                    end = 4;
                                  } else {
                                    end = 1;
                                  }
                                  animationListener = () {
                                    state.handleDoubleTap(scale: animation!.value, doubleTapPosition: pointerDownPosition);
                                  };
                                  animation = animationController.drive(Tween<double>(begin: begin, end: end));

                                  animation!.addListener(animationListener);

                                  animationController.forward();
                                },
                              )
                            : ExtendedImage.memory(
                                widget.bytes!,
                                color: Colors.white.withOpacity(imageTransparency),
                                colorBlendMode: BlendMode.dstIn,
                                enableSlideOutPage: true,
                                mode: ExtendedImageMode.gesture,
                                extendedImageGestureKey: gestureKey,
                                clearMemoryCacheWhenDispose: true,
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
                                  } else if (begin > 1.99 && begin < 2.01) {
                                    end = 4;
                                  } else {
                                    end = 1;
                                  }
                                  animationListener = () {
                                    state.handleDoubleTap(scale: animation!.value, doubleTapPosition: pointerDownPosition);
                                  };
                                  animation = animationController.drive(Tween<double>(begin: begin, end: end));

                                  animation!.addListener(animationListener);

                                  animationController.forward();
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: fullscreen ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.url != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
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
                                        await Share.shareXFiles([XFile(mediaFile!.path)]);
                                      } catch (e) {
                                        // Tell the user that the download failed
                                        showSnackbar(context, AppLocalizations.of(context)!.errorDownloadingMedia(e), customState: _imageViewer.currentState);
                                      } finally {
                                        setState(() => isDownloadingMedia = false);
                                      }
                                    },
                              icon: isDownloadingMedia
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white.withOpacity(0.90),
                                      ),
                                    )
                                  : Icon(
                                      Icons.share_rounded,
                                      semanticLabel: "Share",
                                      color: Colors.white.withOpacity(0.90),
                                      shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 50.0)],
                                    ),
                            ),
                          ),
                        if (widget.url != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              onPressed: fullscreen || widget.url == null
                                  ? null
                                  : () async {
                                      File file = await DefaultCacheManager().getSingleFile(widget.url!);
                                      bool hasPermission = await _requestPermission();

                                      if (!hasPermission) {
                                        if (context.mounted) showPermissionDeniedDialog(context);
                                      }

                                      if ((Platform.isAndroid || Platform.isIOS) && hasPermission) {
                                        if (Platform.isAndroid) {
                                          // Save image to [internal storage]/Pictures/Thunder
                                          GallerySaver.saveImage(file.path, albumName: "Thunder").then((value) {
                                            setState(() => downloaded = value as bool);
                                          });
                                        } else if (Platform.isIOS) {
                                          GallerySaver.saveImage(file.path, albumName: "Thunder").then((bool? value) {
                                            if (value == null || value == false) {
                                              // If the image cannot be saved to the Thunder album, then just save it to Photos
                                              GallerySaver.saveImage(file.path).then((value) => setState(() => downloaded = value as bool));
                                            }

                                            setState(() => downloaded = value ?? false);
                                          });
                                        }
                                      } else if (Platform.isLinux || Platform.isWindows) {
                                        final filePath = '${(await getApplicationDocumentsDirectory()).path}/Thunder/${basename(file.path)}';

                                        File(filePath)
                                          ..createSync(recursive: true)
                                          ..writeAsBytesSync(file.readAsBytesSync());

                                        setState(() => downloaded = true);
                                      }
                                    },
                              icon: downloaded
                                  ? const Icon(
                                      Icons.check_circle,
                                      semanticLabel: 'Downloaded',
                                      color: Colors.white,
                                      shadows: <Shadow>[Shadow(color: Colors.black45, blurRadius: 50.0)],
                                    )
                                  : Icon(
                                      Icons.download,
                                      semanticLabel: "Download",
                                      color: Colors.white.withOpacity(0.90),
                                      shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 50.0)],
                                    ),
                            ),
                          ),
                        if (widget.navigateToPost != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.navigateToPost!();
                              },
                              icon: Icon(
                                Icons.chat_rounded,
                                semanticLabel: "Comments",
                                color: Colors.white.withOpacity(0.90),
                                shadows: const <Shadow>[Shadow(color: Colors.black, blurRadius: 50.0)],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
