import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/shell/shell_chrome_cubit.dart';

/// Barrier shown behind the expanded post FAB menu.
class PostFabOverlay extends StatelessWidget {
  const PostFabOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isFabOpen = context.select<ShellChromeCubit, bool>((cubit) => cubit.state.isPostFabOpen);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isFabOpen
          ? Listener(
              onPointerUp: (_) => context.read<ShellChromeCubit>().setPostFabOpen(false),
              child: Container(color: theme.colorScheme.surface.withValues(alpha: 0.95)),
            )
          : null,
    );
  }
}
