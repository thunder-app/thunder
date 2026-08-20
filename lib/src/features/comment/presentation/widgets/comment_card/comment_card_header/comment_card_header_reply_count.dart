import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/packages/ui/ui.dart';

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

    final collapseParentCommentOnGesture = context.select<CommentPreferencesCubit, bool>((cubit) => cubit.state.collapseParentCommentOnGesture);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    return AnimatedOpacity(
      opacity: (hidden && (collapseParentCommentOnGesture || replies > 0)) ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 130),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0))),
        child: ThunderScalableText('+$replies', textScaleFactor: metadataFontSizeScale.textScaleFactor),
      ),
    );
  }
}
