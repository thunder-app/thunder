import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';

import 'package:thunder/core/models/models.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/thunder.dart';

/// Provides a preview of the post body when the post is collapsed.
class PostBodyPreview extends StatelessWidget {
  const PostBodyPreview({
    super.key,
    required this.post,
    required this.expandableController,
    required this.onTapped,
    required this.viewSource,
  });

  /// The post to display the preview of
  final ThunderPost post;

  /// The expandable controller used to toggle the expanded/collapsed state of the post
  final ExpandableController expandableController;

  /// Callback function which triggers when the post preview is tapped
  final Function() onTapped;

  /// Whether to view the raw post source
  final bool viewSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentFontSizeScale = context.select<ThunderBloc, FontScale>((bloc) => bloc.state.contentFontSizeScale);

    return LimitedBox(
      maxHeight: 80.0,
      child: GestureDetector(
        onTap: () {
          expandableController.toggle();
          onTapped();
        },
        child: Stack(
          children: [
            Wrap(
              direction: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: viewSource
                      ? ScalableText(post.body ?? '', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'), fontScale: contentFontSizeScale)
                      : CommonMarkdownBody(body: post.body ?? ''),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 1.0],
                    colors: [
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
