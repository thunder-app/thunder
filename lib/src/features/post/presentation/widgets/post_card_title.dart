import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/domain/domain.dart';

/// Creates the title of a post card. This includes the post title and any status icons.
class PostCardTitle extends StatelessWidget {
  /// The title of the post. If there are any escaped characters, they will be unescaped.
  final String title;

  /// The post status to indicate whether the post is hidden.
  final bool hidden;

  /// The post status to indicate whether the post is locked.
  final bool locked;

  /// The post status to indicate whether the post is saved.
  final bool saved;

  /// The post status to indicate whether the post is pinned.
  final bool pinned;

  /// The post status to indicate whether the post is deleted.
  final bool deleted;

  /// The post status to indicate whether the post is removed.
  final bool removed;

  /// Determines whether the title should be dimmed or not. This is usually to indicate when a post has been read.
  final bool dim;

  /// PieFed flair metadata attached to the post.
  final List<ThunderFlair> flairs;

  const PostCardTitle({
    super.key,
    required this.title,
    this.hidden = false,
    this.locked = false,
    this.saved = false,
    this.pinned = false,
    this.deleted = false,
    this.removed = false,
    this.dim = false,
    this.flairs = const [],
  });

  Color? _getDimmedColor(Color? color) => color?.withValues(alpha: 0.55);

  /// Returns the color of the title.
  Color? _getTitleColor(ThemeData theme) {
    if (pinned) return dim ? _getDimmedColor(Colors.green) : Colors.green;
    if (dim) return _getDimmedColor(theme.textTheme.bodyMedium?.color);

    return null;
  }

  /// Calculates the font size for the title.
  double _calculateFontSize(BuildContext context, TextStyle? textStyle, double textScaleFactor) {
    final baseFontSize = (textStyle?.fontSize ?? 14.0) + 0.5;
    return MediaQuery.textScalerOf(context).scale(baseFontSize * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    final titleFontWeight = context.select<ThemePreferencesCubit, TitleFontWeight>((cubit) => cubit.state.titleFontWeight);
    final textScaleFactor = context.select<ThemePreferencesCubit, double>((cubit) => cubit.state.titleFontSizeScale.textScaleFactor);
    final fontSize = _calculateFontSize(context, textStyle, textScaleFactor);

    final statuses = PostStatusIcon(hidden: hidden, locked: locked, saved: saved, pinned: pinned, deleted: deleted, removed: removed, dim: dim);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              WidgetSpan(child: statuses),
              TextSpan(
                text: title,
                style: textStyle?.copyWith(fontWeight: titleFontWeight.toWeight(), fontSize: fontSize, color: _getTitleColor(theme)),
              ),
            ],
          ),
          textScaler: TextScaler.noScaling,
        ),
        if (flairs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: PostFlairTags(flairs: flairs, dim: dim),
          ),
      ],
    );
  }
}
