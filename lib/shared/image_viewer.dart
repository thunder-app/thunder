import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';

import 'package:thunder/shared/hero.dart';

class ImageViewer extends StatefulWidget {
  final String url;

  const ImageViewer({super.key, required this.url});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
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
      ),
    );
  }
}
