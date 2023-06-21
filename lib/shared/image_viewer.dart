import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final String url;
  final PhotoViewController photoViewController = PhotoViewController();

  ImageViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            PhotoView(
              controller: photoViewController,
              imageProvider: CachedNetworkImageProvider(url),
              backgroundDecoration: BoxDecoration(color: theme.cardColor),
            ),
            IconButton(
              color: theme.textTheme.titleLarge?.color,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
