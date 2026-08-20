import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/shell/shell_chrome_cubit.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';

/// Defines the bottom navigation bar for Thunder. Uses a custom [ThunderBottomNavigationBar] to handle additional gestures and long-press behavior.
class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({super.key, required this.selectedPageIndex, required this.onPageChange, this.feedActionController});

  /// The index of the currently selected page
  final int selectedPageIndex;

  /// Callback function that is triggered when a page is changed
  final Function(int index) onPageChange;

  /// Optional controller for the root feed page.
  final FeedActionController? feedActionController;

  /// The index of the account tab in the navigation bar. Used to trigger the profile modal sheet on long-press.
  static const int _accountTabIndex = 2;

  void _handleDestinationSelected(BuildContext context, int index) {
    if (context.read<ShellChromeCubit>().state.isFeedFabOpen) {
      context.read<ShellChromeCubit>().setFeedFabOpen(false);
    }

    if (selectedPageIndex == 0 && index == 0) {
      feedActionController?.scrollToTop();
    }

    if (selectedPageIndex == 1 && index != 1) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else if (selectedPageIndex == 1 && index == 1) {
      context.read<SearchBloc>().add(SearchFocusRequested());
    }

    if (selectedPageIndex == 3 && index == 3) {
      return;
    }

    if (selectedPageIndex != index) {
      onPageChange(index);
    }

    if (index == 3) {
      context.read<InboxBloc>().add(const GetInboxEvent(reset: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final showNavigationLabels = context.select<ThunderCubit, bool>((bloc) => bloc.state.showNavigationLabels);
    final bottomNavBarSwipeGestures = context.select<GesturePreferencesCubit, bool>((cubit) => cubit.state.bottomNavBarSwipeGestures);
    final bottomNavBarDoubleTapGestures = context.select<GesturePreferencesCubit, bool>((cubit) => cubit.state.bottomNavBarDoubleTapGestures);

    final enableDrawerGestures = selectedPageIndex == 0 && bottomNavBarSwipeGestures;
    final enableDrawerDoubleTap = selectedPageIndex == 0 && bottomNavBarDoubleTapGestures;

    final totalUnreadCount = context.select<InboxBloc, int>((bloc) => bloc.state.totalUnreadCount);

    return ThunderBottomNavigationBar(
      selectedIndex: selectedPageIndex,
      labelBehavior: showNavigationLabels ? NavigationDestinationLabelBehavior.alwaysShow : NavigationDestinationLabelBehavior.alwaysHide,
      longPressTimeout: const Duration(milliseconds: 300),
      onHorizontalSwipeRight: enableDrawerGestures
          ? () {
              if (context.mounted) Scaffold.of(context).openDrawer();
            }
          : null,
      onHorizontalSwipeLeft: enableDrawerGestures
          ? () {
              if (context.mounted) Scaffold.of(context).closeDrawer();
            }
          : null,
      onDoubleTap: enableDrawerDoubleTap
          ? () {
              if (!context.mounted) return;

              final scaffold = Scaffold.of(context);
              if (scaffold.isDrawerOpen) {
                scaffold.closeDrawer();
              } else {
                scaffold.openDrawer();
              }
            }
          : null,
      onDestinationLongPresses: {
        _accountTabIndex: () {
          HapticFeedback.mediumImpact();
          showProfileModalSheet(context);
        },
      },
      destinations: [
        NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard_rounded), label: l10n.feed),
        NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search_rounded), label: l10n.search),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: l10n.account(1),
          tooltip: '', // Keep tooltip disabled so long-press opens the profile selector instead.
        ),
        NavigationDestination(
          icon: Badge(isLabelVisible: totalUnreadCount != 0, label: Text(totalUnreadCount > 99 ? '99+' : totalUnreadCount.toString()), child: const Icon(Icons.inbox_outlined)),
          selectedIcon: Badge(isLabelVisible: totalUnreadCount != 0, label: Text(totalUnreadCount > 99 ? '99+' : totalUnreadCount.toString()), child: const Icon(Icons.inbox_rounded)),
          label: l10n.inbox,
        ),
        NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings_rounded), label: l10n.settings),
      ],
      onDestinationSelected: (index) => _handleDestinationSelected(context, index),
    );
  }
}
