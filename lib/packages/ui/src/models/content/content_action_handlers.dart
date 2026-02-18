import 'dart:typed_data';

import 'package:flutter/widgets.dart';

typedef OpenLinkHandler = void Function(BuildContext context, String url);
typedef OpenImageHandler = void Function(BuildContext context, {String? url, Uint8List? bytes});
typedef OpenVideoHandler = void Function(BuildContext context, String url);
typedef MarkReadHandler = void Function(int? postId);
typedef LongPressLinkHandler = void Function(BuildContext context, String text, String? url);

class ContentActionHandlers {
  const ContentActionHandlers({
    this.onOpenLink,
    this.onLongPressLink,
    this.onOpenImage,
    this.onOpenVideo,
    this.onMarkRead,
  });

  final OpenLinkHandler? onOpenLink;
  final LongPressLinkHandler? onLongPressLink;
  final OpenImageHandler? onOpenImage;
  final OpenVideoHandler? onOpenVideo;
  final MarkReadHandler? onMarkRead;
}
