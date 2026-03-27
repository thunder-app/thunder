import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Displays PieFed flairs and tags for a post.
class PostFlairTags extends StatelessWidget {
  /// The flair metadata attached to the post.
  final List<ThunderFlair> flairs;

  /// The tags attached to the post.
  final List<String> tags;

  /// Whether the labels should be dimmed.
  final bool dim;

  /// Maximum number of tags to display before collapsing into a counter.
  final int? maxVisibleTags;

  const PostFlairTags({
    super.key,
    this.flairs = const [],
    this.tags = const [],
    this.dim = false,
    this.maxVisibleTags,
  });

  @override
  Widget build(BuildContext context) {
    if (flairs.isEmpty && tags.isEmpty) return const SizedBox.shrink();

    final visibleTags = maxVisibleTags == null ? tags : tags.take(maxVisibleTags!).toList();
    final hiddenTagCount = tags.length - visibleTags.length;
    final labels = [
      ...flairs.map(_PostLabel.flair),
      ...visibleTags.map(_PostLabel.tag),
      if (hiddenTagCount > 0) _PostLabel.tag('+$hiddenTagCount'),
    ];

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: labels.map((label) => _PostLabelChip(label: label, dim: dim)).toList(),
    );
  }
}

class _PostLabel {
  /// The text to display in the label.
  final String text;

  /// Whether the label is a flair or a tag. This is used to determine the default styling of the label.
  final bool isFlair;

  /// The background color of the label. If null, a default color based on the label type will be used.
  final Color? backgroundColor;

  /// The foreground color of the label. If null, a default color based on the label type will be used.
  final Color? foregroundColor;

  const _PostLabel({required this.text, required this.isFlair, this.backgroundColor, this.foregroundColor});

  factory _PostLabel.flair(ThunderFlair flair) {
    return _PostLabel(
      text: flair.title,
      isFlair: true,
      backgroundColor: flair.parsedBackgroundColor,
      foregroundColor: flair.parsedTextColor,
    );
  }

  factory _PostLabel.tag(String tag) {
    return _PostLabel(text: tag.startsWith('+') ? tag : '#$tag', isFlair: false);
  }
}

class _PostLabelChip extends StatelessWidget {
  /// The label to display, which can be either a flair or a tag.
  final _PostLabel label;

  /// Whether the label should be dimmed.
  final bool dim;

  const _PostLabelChip({required this.label, required this.dim});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fallbackBackground = label.isFlair ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHighest;
    final fallbackForeground = label.isFlair ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant;

    final resolvedBackground = (label.backgroundColor ?? fallbackBackground).withValues(alpha: dim ? 0.55 : 1.0);
    final resolvedForeground = (label.foregroundColor ?? fallbackForeground).withValues(alpha: dim ? 0.75 : 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: resolvedForeground,
          fontWeight: label.isFlair ? FontWeight.w600 : FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}
