import 'package:flutter/material.dart';

/// Displays an instance host with optional version metadata.
class ProfileMetadata extends StatelessWidget {
  const ProfileMetadata({
    super.key,
    required this.instance,
    required this.version,
  });

  /// Instance host displayed at the start of the metadata row.
  final String instance;

  /// Optional instance software version.
  final String? version;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(instance),
        _AnimatedMetadataSegment(text: version == null ? null : 'v$version'),
      ],
    );
  }
}

class _AnimatedMetadataSegment extends StatelessWidget {
  const _AnimatedMetadataSegment({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.55);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: text == null
          ? const SizedBox(height: 20.0, width: 0.0)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5.0),
                Text('•', style: TextStyle(color: color)),
                const SizedBox(width: 5.0),
                Text(text!, style: TextStyle(color: color)),
              ],
            ),
    );
  }
}
