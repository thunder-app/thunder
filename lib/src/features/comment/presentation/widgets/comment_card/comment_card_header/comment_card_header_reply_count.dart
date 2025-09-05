import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';

/// A widget that displays the number of replies to a comment.
///
/// This widget generally appears when a comment is collapsed.
class CommentCardHeaderReplyCount extends StatelessWidget {
  /// The number of replies to the comment
  final int replies;

  /// Whether the comment is currently hidden/collapsed
  final bool hidden;

  const CommentCardHeaderReplyCount({super.key, required this.replies, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final collapseParentCommentOnGesture = context.select((ThunderBloc bloc) => bloc.state.collapseParentCommentOnGesture);

    return AnimatedOpacity(
      opacity: (hidden && (collapseParentCommentOnGesture || replies > 0)) ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 130),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
        ),
        child: BlocSelector<ThunderBloc, ThunderState, FontScale>(
          selector: (state) => state.metadataFontSizeScale,
          builder: (context, metadataFontSizeScale) {
            return ScalableText('+$replies', fontScale: metadataFontSizeScale);
          },
        ),
      ),
    );
  }
}
