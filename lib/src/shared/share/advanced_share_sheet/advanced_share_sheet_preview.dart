import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

import 'package:thunder/src/shared/media/media_utils.dart';

class ShareImagePreview extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final bool nsfw;
  final double? height;
  final double? width;
  final double? maxWidth;
  final bool isGallery;
  final bool isExpandable;
  final bool showFullHeightImages;
  final bool edgeToEdgeImages;
  final int? postId;
  final void Function()? navigateToPost;
  final bool? isComment;
  final bool? read;
  final String? altText;

  const ShareImagePreview({
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
    this.edgeToEdgeImages = false,
    this.postId,
    this.navigateToPost,
    this.isComment,
    this.read,
    this.altText,
  }) : assert(url != null || bytes != null);

  @override
  State<ShareImagePreview> createState() => _ShareImagePreviewState();
}

class _ShareImagePreviewState extends State<ShareImagePreview> {
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
                    altText: widget.altText,
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
    final memCacheWidth = ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt();
    final readColor = widget.read == true ? const Color.fromRGBO(255, 255, 255, 0.55) : null;
    final readBlendMode = widget.read == true ? BlendMode.modulate : null;
    final alignment = widget.isComment == true ? Alignment.topCenter : Alignment.center;
    final constraints = widget.isComment == true
        ? BoxConstraints(
            maxHeight: MediaQuery.of(context).size.width * 0.55,
            maxWidth: MediaQuery.of(context).size.width * 0.60,
          )
        : BoxConstraints(
            maxWidth: widget.maxWidth ?? MediaQuery.of(context).size.width - (widget.url != null && widget.edgeToEdgeImages ? 0 : 24),
          );

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.edgeToEdgeImages ? 0 : 12)),
      child: Stack(
        children: [
          // This is used for link posts where the preview comes from Lemmy
          // in both compact and comfortable view
          ConstrainedBox(
            constraints: constraints,
            child: widget.url != null
                ? CachedNetworkImage(
                    imageUrl: widget.url!,
                    color: readColor,
                    colorBlendMode: readBlendMode,
                    alignment: alignment,
                    height: widget.height,
                    width: widget.width,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 100),
                    fadeOutDuration: Duration.zero,
                    memCacheWidth: memCacheWidth,
                    placeholder: (context, url) => Container(color: getBackgroundColor(context)),
                    errorWidget: (context, url, error) => Container(
                      color: getBackgroundColor(context),
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                    imageBuilder: (context, imageProvider) {
                      return Image(
                        image: imageProvider,
                        color: readColor,
                        colorBlendMode: readBlendMode,
                        alignment: alignment,
                        height: widget.height,
                        width: widget.width,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.memory(
                    widget.bytes!,
                    color: readColor,
                    colorBlendMode: readBlendMode,
                    alignment: alignment,
                    height: widget.height,
                    width: widget.width,
                    fit: BoxFit.cover,
                    cacheWidth: memCacheWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        l10n.unableToLoadImage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                      );
                    },
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
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5)),
            ),
          )
        ],
      ),
    );
  }
}
