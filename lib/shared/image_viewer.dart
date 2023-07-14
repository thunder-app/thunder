import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/shared/hero.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../account/bloc/account_bloc.dart';
import '../community/bloc/community_bloc.dart';
import '../core/auth/bloc/auth_bloc.dart';
import '../post/pages/post_page.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc; // renamed to prevent clash with VotePostEvent, etc from community_bloc
import '../thunder/bloc/thunder_bloc.dart';

class ImageViewer extends StatefulWidget {
  final String url;
  final String heroKey;
  final int? postId;

  const ImageViewer({
    super.key,
    required this.url,
    required this.heroKey,
    this.postId,
  });

  get postViewMedia => null;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with TickerProviderStateMixin {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();
  final GlobalKey<ScaffoldMessengerState> _imageViewer = GlobalKey<ScaffoldMessengerState>();
  bool downloaded = false;

  double slideTransparency = 0.9;
  double imageTransparency = 1.0;

  /// User Settings
  bool isUserLoggedIn = false;

  /*@override
  void initState() {
    super.initState();

    isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  }*/

  /*bool? thunderSlideEndHandler(
      {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
    if (pageGestureAxis == SlideAxis.both) {
      return offset.distance >
          Offset(pageSize.width, pageSize.height).distance / 3.5;
    } else if (pageGestureAxis == SlideAxis.horizontal) {
      return offset.dx.abs() > pageSize.width / 3.5;
    } else if (pageGestureAxis == SlideAxis.vertical) {
      return offset.dy.abs() > pageSize.height / 3.5;
    }
    return true;
  }*/

  Future<bool> _requestPermission() async {
    bool androidVersionBelow33 = false;
    if (Platform.isAndroid) {
      androidVersionBelow33 = (await DeviceInfoPlugin().androidInfo).version.sdkInt <= 32;
    }

    if (androidVersionBelow33) {
      await Permission.storage.request();
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.photosAddOnly,
      ].request();
    }
    bool hasPermission = await Permission.photos.isGranted || await Permission.photos.isLimited || await Permission.storage.isGranted || await Permission.storage.isLimited;

    return hasPermission;
  }

  @override
  Widget build(BuildContext context) {
    AnimationController _animationController = AnimationController(duration: Duration(milliseconds: 200),vsync: this);
    Function() animationListener = () {};
    Animation? _animation;

    return ScaffoldMessenger(
      key: _imageViewer,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black.withOpacity(slideTransparency),
          body: Center(
            child: Column(
              children: [
                Expanded(
                  child: ExtendedImageSlidePage(
                    key: slidePagekey,
                    slideAxis: SlideAxis.both,
                    slideType: SlideType.onlyImage,
                    slidePageBackgroundHandler: (offset, pageSize) => Colors.transparent,
                    onSlidingPage: (state) { // Fade out image and background when sliding to dismiss
                      var offset = state.offset;
                      var pageSize = state.pageSize;

                      var scale = offset.distance / Offset(pageSize.width, pageSize.height).distance;

                      if (state.isSliding) {
                        setState(() {
                          slideTransparency = 0.9 - min( 0.9, scale);
                          imageTransparency = 1.0 - min( 1.0, scale*6);
                        });
                      }
                    },
                    /*slideEndHandler: thunderSlideEndHandler( Offset: offset, Size: Slideaxis:),*/
                    child: GestureDetector(
                      child: HeroWidget(
                        tag: widget.heroKey,
                        slideType: SlideType.onlyImage,
                        slidePagekey: slidePagekey,
                        child: ExtendedImage.network(
                          widget.url,
                          color: Colors.white.withOpacity(imageTransparency),
                          colorBlendMode: BlendMode.dstIn,
                          enableSlideOutPage: true,
                          mode: ExtendedImageMode.gesture,
                          cache: true,
                          clearMemoryCacheWhenDispose: true,
                          initGestureConfigHandler: (ExtendedImageState state) {
                            return GestureConfig(
                              minScale: 0.8,
                              animationMinScale: 0.8,
                              maxScale: 4.0,
                              animationMaxScale: 4.0,
                              speed: 1.0,
                              inertialSpeed: 100.0,
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

                            _animation?.removeListener(animationListener);
                            _animationController.stop();
                            _animationController.reset();

                            if (begin == 1) {
                              end = 1.5;
                            } else {
                              end = 1;
                            }
                            animationListener = () {
                              //print(_animation.value);
                              state.handleDoubleTap(
                                  scale: _animation!.value,
                                  doubleTapPosition: pointerDownPosition);
                            };
                            _animation = _animationController
                                .drive(Tween<double>(begin: begin, end: end));

                            _animation!.addListener(animationListener);

                            _animationController.forward();
                          },
                        ),
                      ),
                      onTap: () {
                        slidePagekey.currentState!.popPage();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(flex: 2, child: Container()) ,
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          const Spacer(),  // TODO make go to post work
                          Container(
                            child: widget.postId != null ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: IconButton(
                                    onPressed: () async {
                                      AccountBloc accountBloc = context.read<AccountBloc>();
                                      AuthBloc authBloc = context.read<AuthBloc>();
                                      ThunderBloc thunderBloc = context.read<ThunderBloc>();
                                      CommunityBloc communityBloc = context.read<CommunityBloc>();

                                      // Mark post as read when tapped
                                      if (isUserLoggedIn && widget.postId != null) context.read<CommunityBloc>().add(MarkPostAsReadEvent(postId: widget.postId!, read: true));

                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return MultiBlocProvider(
                                              providers: [
                                                BlocProvider.value(value: accountBloc),
                                                BlocProvider.value(value: authBloc),
                                                BlocProvider.value(value: thunderBloc),
                                                BlocProvider.value(value: communityBloc),
                                                BlocProvider(create: (context) => post_bloc.PostBloc()),
                                              ],
                                              child: PostPage(
                                                postView: widget.postViewMedia,
                                                onPostUpdated: () {},
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                      if (context.mounted) context.read<CommunityBloc>().add(ForceRefreshEvent());
                                    },
                                    icon: const Icon(Icons.chat_rounded, semanticLabel: "Comments"),
                                  ),
                                ),
                              ],
                            ) : const Spacer(),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              onPressed: () async {
                                try {
                                  // Try to get the cached image first
                                  var media = await DefaultCacheManager().getFileFromCache(widget.url!);
                                  File? mediaFile = media?.file;

                                  if (media == null) {
                                    // Tell user we're downloading the image, snackbars display twice for some reason, disabling here for now TODO fix that
                                    SnackBar snackBar = const SnackBar(
                                      content: Text('Downloading media to share...'),
                                      behavior: SnackBarBehavior.floating,
                                    );
                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                      _imageViewer.currentState?.clearSnackBars();
                                      _imageViewer.currentState?.showSnackBar(snackBar);
                                    });

                                    // Download
                                    mediaFile = await DefaultCacheManager().getSingleFile(widget.url!);

                                    // Hide snackbar
                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                      _imageViewer.currentState?.clearSnackBars();
                                    });
                                  }

                                  // Share
                                  await Share.shareXFiles([XFile(mediaFile!.path)]);
                                } catch (e) {
                                  // Tell the user that the download failed
                                  SnackBar snackBar = SnackBar(
                                    content: Text('There was an error downloading the media file to share: $e'),
                                    behavior: SnackBarBehavior.floating,
                                  );
                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                    _imageViewer.currentState?.clearSnackBars();
                                    _imageViewer.currentState?.showSnackBar(snackBar);
                                  });
                                }
                              },
                              icon: const Icon(Icons.share_rounded, semanticLabel: "Comments"),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              onPressed: () async {
                                File file = await DefaultCacheManager().getSingleFile(widget.url);

                                if ((Platform.isAndroid || Platform.isIOS) && await _requestPermission()) {
                                  final result = await ImageGallerySaver.saveFile(file.path);

                                  setState(() => downloaded = result['isSuccess'] == true);
                                } else if (Platform.isLinux || Platform.isWindows) {
                                  final filePath = '${(await getApplicationDocumentsDirectory()).path}/ThunderImages/${basename(file.path)}';

                                  File(filePath)
                                    ..createSync(recursive: true)
                                    ..writeAsBytesSync(file.readAsBytesSync());

                                  setState(() => downloaded = true);
                                }
                              },
                              icon: downloaded ? const Icon(Icons.check_circle, semanticLabel: 'Downloaded') : const Icon(Icons.download, semanticLabel: "Download"),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
}
