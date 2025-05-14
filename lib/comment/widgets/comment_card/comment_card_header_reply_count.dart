import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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

    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final collapseParentCommentOnGesture = context.select((ThunderBloc bloc) => bloc.state.collapseParentCommentOnGesture);

    return AnimatedOpacity(
      opacity: (hidden && (collapseParentCommentOnGesture || replies > 0)) ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 130),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: ScalableText('+$replies', fontScale: metadataFontSizeScale),
        ),
      ),
    );
  }
}
