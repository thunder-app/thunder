import 'dart:typed_data';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/utils/image.dart';

class ImagePreview extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final bool nsfw;
  final double? height;
  final double? width;
  final bool isGallery;
  final bool isExpandable;
  final bool showFullHeightImages;
  final int? postId;
  final void Function()? navigateToPost;
  final bool? isComment;
  final bool? read;

  const ImagePreview({
    super.key,
    this.url,
    this.bytes,
    this.height,
    this.width,
    this.nsfw = false,
    this.isGallery = false,
    this.isExpandable = true,
    this.showFullHeightImages = false,
    this.postId,
    this.navigateToPost,
    this.isComment,
    this.read,
  }) : assert(url != null || bytes != null);

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

  void onImageTap(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 50),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return ImageViewer(
            url: widget.url,
            bytes: widget.bytes,
            postId: widget.postId,
            navigateToPost: widget.navigateToPost,
          );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.isExpandable
          ? InkWell(
              child: imagePreview(context),
              onTap: () {
                if (widget.nsfw && blur) {
                  setState(() => blur = false);
                } else {
                  onImageTap(context);
                }
              },
            )
          : imagePreview(context),
    );
  }

  Widget imagePreview(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // This is used for link posts where the preview comes from Lemmy
          // in both compact and comfortable view
          widget.url != null
              ? ExtendedImage.network(
                  color: widget.read == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
                  colorBlendMode: widget.read == true ? BlendMode.modulate : null,
                  constraints: widget.isComment == true
                      ? BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.width * 0.55,
                          maxWidth: MediaQuery.of(context).size.width * 0.60,
                        )
                      : null,
                  alignment: widget.isComment == true ? Alignment.topCenter : Alignment.center,
                  widget.url!,
                  height: widget.height,
                  width: widget.width ?? MediaQuery.of(context).size.width - 24,
                  fit: BoxFit.cover,
                  cache: true,
                  clearMemoryCacheWhenDispose: false,
                  cacheMaxAge: const Duration(minutes: 1),
                  cacheWidth: ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return Container();
                    }
                  },
                )
              : ExtendedImage.memory(
                  color: widget.read == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null,
                  colorBlendMode: widget.read == true ? BlendMode.modulate : null,
                  constraints: widget.isComment == true
                      ? BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.width * 0.55,
                          maxWidth: MediaQuery.of(context).size.width * 0.60,
                        )
                      : null,
                  alignment: widget.isComment == true ? Alignment.topCenter : Alignment.center,
                  widget.bytes!,
                  height: widget.height,
                  width: widget.width ?? MediaQuery.of(context).size.width - 24,
                  fit: BoxFit.cover,
                  clearMemoryCacheWhenDispose: true,
                  cacheWidth: ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return Container();
                    }
                  },
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
