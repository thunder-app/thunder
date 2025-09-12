import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/app/thunder.dart';

/// Provides a preview of the post body when the post is collapsed.
///
/// This widget shows a truncated view of the post content with a gradient fade at the bottom to indicate additional content.
/// When tapped, it expands to show the full content.
class PostBodyPreview extends StatelessWidget {
  const PostBodyPreview({
    super.key,
    required this.post,
    required this.viewSource,
    this.gradientBackgroundColor,
    this.maxHeight = 80.0,
    required this.onTap,
  });

  /// The post to display the preview of
  final ThunderPost post;

  /// Callback function which triggers when the post preview is tapped
  final Function() onTap;

  /// Whether to view the raw post source
  final bool viewSource;

  /// Background color for the gradient
  final Color? gradientBackgroundColor;

  /// Maximum height for the preview container
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentFontSizeScale = context.select<ThunderBloc, FontScale>((bloc) => bloc.state.contentFontSizeScale);
    final hideNsfwPreviews = context.select((ThunderBloc bloc) => bloc.state.hideNsfwPreviews);

    final color = gradientBackgroundColor ?? theme.scaffoldBackgroundColor;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 1.0],
      colors: [color.withValues(alpha: 0.0), color],
    );

    /// TODO: combine logic with the post body
    final content = viewSource
        ? ScalableText(
            post.body ?? '',
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            fontScale: contentFontSizeScale,
          )
        : CommonMarkdownBody(body: post.body ?? '', nsfw: post.nsfw && hideNsfwPreviews);

    return LimitedBox(
      maxHeight: maxHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: GestureDetector(
          onTap: () => onTap(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Wrap(
                direction: Axis.horizontal,
                children: [content],
              ),
              Positioned(
                left: 0,
                right: 0,
                height: maxHeight,
                child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
