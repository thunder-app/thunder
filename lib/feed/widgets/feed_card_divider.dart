import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// A user-customizable divider used between items (posts/comments) in the feed page.
///
/// This is used in [FeedPostCardList] and [FeedCommentCardList].
class FeedCardDivider extends StatelessWidget {
  const FeedCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<ThunderBloc>().state;

    final feedCardDividerThickness = state.feedCardDividerThickness;
    final feedCardDividerColor = state.feedCardDividerColor;

    return Divider(
      height: feedCardDividerThickness.value,
      thickness: feedCardDividerThickness.value,
      color: feedCardDividerColor == Colors.transparent
          ? ElevationOverlay.applySurfaceTint(theme.colorScheme.surface, theme.colorScheme.surfaceTint, 10)
          : Color.alphaBlend(theme.colorScheme.primaryContainer.withValues(alpha: 0.6), feedCardDividerColor).withValues(alpha: 0.2),
    );
  }
}
