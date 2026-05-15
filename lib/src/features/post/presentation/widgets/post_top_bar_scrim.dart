import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';

/// Covers the status-bar area when the top app bar scrolls away.
class PostTopBarScrim extends StatelessWidget {
  const PostTopBarScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final hideTopBarOnScroll = context.select<ThunderCubit, bool>((cubit) => cubit.state.hideTopBarOnScroll);
    if (!hideTopBarOnScroll) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Positioned(
      child: Container(
        height: MediaQuery.paddingOf(context).top,
        color: theme.colorScheme.surface,
      ),
    );
  }
}
