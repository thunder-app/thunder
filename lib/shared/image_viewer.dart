import 'dart:io';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';

import 'package:thunder/shared/hero.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:permission_handler/permission_handler.dart';

class ImageViewer extends StatefulWidget {
  final String url;

  const ImageViewer({super.key, required this.url});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  bool downloaded = false;
  Future<bool> _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
    ].request();

    final info2 = statuses[Permission.photos].toString();
    print(info2);
    return Permission.photos.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            child: IconButton(
              color: theme.textTheme.titleLarge?.color,
              onPressed: () async {
                File file =
                    await DefaultCacheManager().getSingleFile(widget.url);
                if ((Platform.isAndroid || Platform.isIOS) &&
                    await _requestPermission()) {
                  final result = await ImageGallerySaver.saveFile(file.path);
                } else if (Platform.isLinux || Platform.isWindows) {
                  final filePath =
                      '${(await getApplicationDocumentsDirectory()).path}/ThunderImages/${basename(file.path)}';
                  File(filePath)
                    ..createSync(recursive: true)
                    ..writeAsBytesSync(file.readAsBytesSync());
                }
                setState(() {
                  downloaded = true;
                });
              },
              icon: downloaded
                  ? Icon(Icons.check_circle, semanticLabel: 'Downloaded')
                  : Icon(Icons.download, semanticLabel: "Download"),
            ),
          ),
          Center(
            child: ExtendedImageSlidePage(
              key: slidePagekey,
              slideAxis: SlideAxis.both,
              slideType: SlideType.onlyImage,
              child: GestureDetector(
                child: HeroWidget(
                  tag: widget.url,
                  slideType: SlideType.onlyImage,
                  slidePagekey: slidePagekey,
                  child: ExtendedImage.network(
                    widget.url,
                    enableSlideOutPage: true,
                    mode: ExtendedImageMode.gesture,
                    cache: true,
                    clearMemoryCacheWhenDispose: true,
                    initGestureConfigHandler: (ExtendedImageState state) {
                      return GestureConfig(
                        minScale: 0.9,
                        animationMinScale: 0.7,
                        maxScale: 4.0,
                        animationMaxScale: 4.5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: 1.0,
                        inPageView: false,
                        initialAlignment: InitialAlignment.center,
                        reverseMousePointerScrollDirection: true,
                        gestureDetailsIsChanged: (GestureDetails? details) {},
                      );
                    },
                  ),
                ),
                onTap: () {
                  slidePagekey.currentState!.popPage();
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
