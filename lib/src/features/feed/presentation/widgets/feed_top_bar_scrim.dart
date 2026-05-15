import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';

/// Safe-area scrim shown when the top app bar hides during feed scrolling.
class FeedTopBarScrim extends StatelessWidget {
  const FeedTopBarScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final hideTopBarOnScroll = context.select<ThunderCubit, bool>((bloc) => bloc.state.hideTopBarOnScroll);
    if (!hideTopBarOnScroll) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final padding = MediaQuery.paddingOf(context).top;

    return Positioned(
      child: Container(
        height: padding,
        color: theme.colorScheme.surface,
      ),
    );
  }
}
