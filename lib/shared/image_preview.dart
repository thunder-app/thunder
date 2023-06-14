import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ImagePreview extends StatefulWidget {
  final String url;
  final bool nsfw;
  final double? height;
  final double? width;
  final bool isGallery;
  final bool isExpandable;

  const ImagePreview({super.key, required this.url, this.height, this.width, this.nsfw = false, this.isGallery = false, this.isExpandable = true});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool blur = false;
  double endBlur = 15;
  double startBlur = 0;

  @override
  void initState() {
    super.initState();
    setState(() => blur = widget.nsfw);
  }

  void onImageTap() {}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: widget.isExpandable
            ? InkWell(
                child: imagePreview(),
                onTap: () {
                  if (widget.nsfw && blur) {
                    setState(() => blur = false);
                  } else {
                    onImageTap();
                  }
                },
              )
            : imagePreview(),
      ),
    );
  }

  Widget imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6), // Image border
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.url,
            height: widget.isGallery ? null : widget.height,
            width: widget.isGallery ? null : widget.width,
            memCacheHeight: widget.height?.toInt(),
            memCacheWidth: widget.width?.toInt(),
            fit: BoxFit.fitWidth,
            progressIndicatorBuilder: (context, url, downloadProgress) => Container(
              color: Colors.grey.shade900,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(value: downloadProgress.progress),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.error),
                ),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: blur ? startBlur : endBlur, end: blur ? endBlur : startBlur),
            duration: Duration(milliseconds: widget.nsfw ? 250 : 0),
            builder: (_, value, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                child: child,
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
            ),
          )
        ],
      ),
    );
  }
}
