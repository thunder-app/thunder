import 'package:flutter/material.dart';

class MediaViewText extends StatelessWidget {
  const MediaViewText({
    super.key,
    this.text,
    this.read,
  });

  final String? text;
  final bool? read;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface.withValues(
      alpha: read == true ? 0.55 : 1.0,
    );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text ?? '',
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
      ),
    );
  }
}
