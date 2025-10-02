import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/bloc/thunder_bloc.dart';

/// A user-customizable divider used between items (posts/comments) in the feed page.
///
/// This is used in [FeedPostCardList] and [FeedCommentCardList].
class FeedCardDivider extends StatelessWidget {
  const FeedCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thickness = context.select<ThunderBloc, double>((bloc) => bloc.state.feedCardDividerThickness.value);
    final dividerColor = context.select<ThunderBloc, Color?>((bloc) => bloc.state.feedCardDividerColor);

    Color color = ElevationOverlay.applySurfaceTint(theme.colorScheme.surface, theme.colorScheme.surfaceTint, 10);

    if (dividerColor == Colors.transparent) {
      color = Colors.transparent;
    } else if (dividerColor != null) {
      color = Color.alphaBlend(theme.colorScheme.primaryContainer.withValues(alpha: 0.6), dividerColor).withValues(alpha: 0.2);
    }

    return Divider(height: thickness, thickness: thickness, color: color);
  }
}
