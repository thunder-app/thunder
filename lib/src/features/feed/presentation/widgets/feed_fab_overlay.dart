import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/shell/state/shell_chrome_cubit.dart';
import 'package:thunder/src/features/feed/feed.dart';

/// Overlay that hosts the feed FAB barrier and the route-scoped feed FAB.
class FeedFabOverlay extends StatelessWidget {
  const FeedFabOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isFabOpen = context.select<ShellChromeCubit, bool>((cubit) => cubit.state.isFeedFabOpen);
    final enableFeedsFab = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableFeedsFab);
    final feedChrome = context.select<FeedBloc, ({FeedType? feedType, int? communityId, String? communityName, int? userId, String? username})>(
      (bloc) => (
        feedType: bloc.state.feedType,
        communityId: bloc.state.communityId,
        communityName: bloc.state.communityName,
        userId: bloc.state.userId,
        username: bloc.state.username,
      ),
    );
    final showNavigatedFab = Navigator.of(context).canPop() &&
        (feedChrome.communityId != null || feedChrome.communityName != null || feedChrome.userId != null || feedChrome.username != null) &&
        enableFeedsFab &&
        feedChrome.feedType != FeedType.account;

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: isFabOpen ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 250),
          child: Stack(
            children: [
              IgnorePointer(
                child: Container(
                  color: theme.colorScheme.surface.withValues(alpha: 0.95),
                ),
              ),
              if (isFabOpen)
                ModalBarrier(
                  color: null,
                  dismissible: true,
                  onDismiss: () => context.read<ShellChromeCubit>().setFeedFabOpen(false),
                ),
            ],
          ),
        ),
        if (showNavigatedFab)
          AnimatedOpacity(
            opacity: enableFeedsFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeIn,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: FeedFAB(heroTag: feedChrome.communityName ?? feedChrome.username),
            ),
          ),
      ],
    );
  }
}
