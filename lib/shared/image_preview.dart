import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/enums/image_caching_mode.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/colors.dart';

import 'package:thunder/utils/media/image.dart';

class ImagePreview extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final bool nsfw;
  final double? height;
  final double? width;
  final double? maxWidth;
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
    this.maxWidth,
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
                  showImageViewer(
                    context,
                    url: widget.url,
                    bytes: widget.bytes,
                    postId: widget.postId,
                    navigateToPost: widget.navigateToPost,
                  );
                }
              },
            )
          : imagePreview(context),
    );
  }

  Widget imagePreview(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThunderState thunderState = context.read<ThunderBloc>().state;

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
                      : BoxConstraints(
                          maxWidth: widget.maxWidth ?? MediaQuery.of(context).size.width - 24,
                        ),
                  alignment: widget.isComment == true ? Alignment.topCenter : Alignment.center,
                  widget.url!,
                  height: widget.height,
                  width: widget.width,
                  fit: BoxFit.cover,
                  cache: true,
                  clearMemoryCacheWhenDispose: thunderState.imageCachingMode == ImageCachingMode.relaxed,
                  cacheWidth: ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return Container(color: getBackgroundColor(context));
                    }
                    if (state.extendedImageLoadState == LoadState.failed) {
                      return Container(
                        color: getBackgroundColor(context),
                        child: const Icon(Icons.image_not_supported_outlined),
                      );
                    }
                    return null;
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
                      : BoxConstraints(
                          maxWidth: widget.maxWidth ?? MediaQuery.of(context).size.width - 24,
                        ),
                  alignment: widget.isComment == true ? Alignment.topCenter : Alignment.center,
                  widget.bytes!,
                  height: widget.height,
                  width: widget.width,
                  fit: BoxFit.cover,
                  clearMemoryCacheWhenDispose: thunderState.imageCachingMode == ImageCachingMode.relaxed,
                  cacheWidth: ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return Container(color: getBackgroundColor(context));
                    }
                    if (state.extendedImageLoadState == LoadState.failed) {
                      return Text(
                        l10n.unableToLoadImage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      );
                    }
                    return null;
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
