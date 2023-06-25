import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatefulWidget {
  final String url;

  const ImageViewer({super.key, required this.url});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PhotoViewControllerBase controller;

  double defScale = 0.1;
  double scale = 0;

  @override
  void initState() {
    controller = PhotoViewController(initialScale: defScale)..outputStateStream.listen(onController);
    super.initState();
  }

  void onController(PhotoViewControllerValue value) {
    setState(() {
      scale = value.scale ?? 0;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Dismissible(
          behavior: HitTestBehavior.translucent,
          direction: scale < 1.1 ? DismissDirection.vertical : DismissDirection.none,
          dismissThresholds: const {DismissDirection.vertical: 0.2},
          onDismissed: (direction) => Navigator.pop(context),
          key: Key(widget.url),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              PhotoView(
                controller: controller,
                imageProvider: CachedNetworkImageProvider(widget.url),
                backgroundDecoration: BoxDecoration(color: theme.cardColor),
                heroAttributes: PhotoViewHeroAttributes(tag: widget.url),
              ),
              // IconButton(
              //   color: theme.textTheme.titleLarge?.color,
              //   onPressed: () => Navigator.pop(context),
              //   icon: const Icon(
              //     Icons.close,
              //     semanticLabel: 'Close Preview',
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
