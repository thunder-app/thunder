import 'dart:io';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';

import 'package:thunder/shared/hero.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImageViewer extends StatefulWidget {
  final String url;
  final String heroKey;

  const ImageViewer({super.key, required this.url, required this.heroKey});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();
  bool downloaded = false;

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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ExtendedImageSlidePage(
                  key: slidePagekey,
                  slideAxis: SlideAxis.both,
                  slideType: SlideType.onlyImage,
                  child: GestureDetector(
                    child: HeroWidget(
                      tag: widget.heroKey,
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
              ),
              Row(
                children: [
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
                ],
              ),
            ],
          ),
        ),
      );
  }
}
