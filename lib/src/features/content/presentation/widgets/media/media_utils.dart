import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart' as content;
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';

export 'package:thunder/packages/ui/ui.dart'
    show
        fetchProxyImageUrl,
        getScaledMediaSize,
        isImageProxyUrl,
        isImageUriSvg,
        isImageUrl,
        isImageUrlSvg,
        isVideoUrl,
        processAvifImage,
        processImage,
        processImageDimensions,
        retrieveImageDimensions,
        selectImagesToUpload,
        showVideoPlayer;

/// App adapter for content package image viewer opening.
void showImageViewer(
  BuildContext context, {
  String? url,
  Uint8List? bytes,
  int? postId,
  void Function()? navigateToPost,
  String? altText,
}) {
  final clearMemoryCacheWhenDispose = context.read<ThunderBloc>().state.imageCachingMode == ImageCachingMode.relaxed;

  content.showImageViewer(
    context,
    url: url,
    bytes: bytes,
    postId: postId,
    navigateToPost: navigateToPost,
    altText: altText,
    clearMemoryCacheWhenDispose: clearMemoryCacheWhenDispose,
  );
}
