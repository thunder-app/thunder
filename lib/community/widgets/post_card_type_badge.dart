import 'package:flutter/material.dart';

import '../../core/enums/media_type.dart';
import '../../core/models/post_view_media.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({
    super.key,
    required this.postViewMedia,
  });

  final PostViewMedia postViewMedia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getMaterialColor(Color blendColor) {
      return Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.6), blendColor);
    }

    Color getIconColor(Color blendColor) {
      return Color.alphaBlend(theme.colorScheme.onPrimaryContainer.withOpacity(0.9), blendColor);
    }

    return SizedBox(
      height: 28,
      width: 28,
      child: Material(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(12),
          topRight: Radius.circular(4),
        ),
        color: theme.colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 2.5,
            top: 2.5,
          ),
          child: postViewMedia == null || postViewMedia.media.isEmpty
              ? Material(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(4),
                  ),
                  color: getMaterialColor(Colors.green),
                  child: Icon(
                    size: 17,
                    Icons.wysiwyg_rounded,
                    color: getIconColor(Colors.green),
                  ),
                )
              : postViewMedia.media.firstOrNull?.mediaType == MediaType.link
                  ? Material(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(4),
                      ),
                      color: getMaterialColor(Colors.blue),
                      child: Icon(
                        size: 19,
                        Icons.link_rounded,
                        color: getIconColor(Colors.blue),
                      ),
                    )
                  : Material(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(4),
                      ),
                      color: getMaterialColor(Colors.red),
                      child: Icon(
                        size: 17,
                        Icons.image_outlined,
                        color: getIconColor(Colors.red),
                      ),
                    ),
        ),
      ),
    );
  }
}
