import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// A custom bottom navigation bar that enables tap/swipe gestures
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key, required this.selectedPageIndex, required this.onPageChange});

  /// The index of the currently selected page
  final int selectedPageIndex;

  /// Callback function that is triggered when a page is changed
  final Function(int index) onPageChange;

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  /// This is used for the swipe drag gesture on the bottom nav bar
  double _dragStartX = 0.0;
  double _dragEndX = 0.0;

  // Handles drag on bottom nav bar to open the drawer
  void _handleDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  // Handles drag on bottom nav bar to open the drawer
  void _handleDragUpdate(DragUpdateDetails details) async {
    _dragEndX = details.globalPosition.dx;
  }

  // Handles drag on bottom nav bar to open the drawer
  void _handleDragEnd(DragEndDetails details, BuildContext context) async {
    if (widget.selectedPageIndex != 0) return;

    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    bool bottomNavBarSwipeGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarSwipeGesture.name) ?? true;
    if (bottomNavBarSwipeGestures == false) return;

    double delta = _dragEndX - _dragStartX;

    // Set some threshold to also allow for swipe up to reveal FAB
    if (delta > 20) {
      if (context.mounted) Scaffold.of(context).openDrawer();
    } else if (delta < 0) {
      if (context.mounted) Scaffold.of(context).closeDrawer();
    }

    _dragStartX = 0.0;
  }

  // Handles double-tap to open the drawer
  void _handleDoubleTap(BuildContext context) async {
    if (widget.selectedPageIndex != 0) return;

    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    bool bottomNavBarDoubleTapGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarDoubleTapGesture.name) ?? false;
    if (bottomNavBarDoubleTapGestures == false) return;

    bool isDrawerOpen = context.mounted ? Scaffold.of(context).isDrawerOpen : false;

    if (isDrawerOpen) {
      if (context.mounted) Scaffold.of(context).closeDrawer();
    } else {
      if (context.mounted) Scaffold.of(context).openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final state = context.watch<ThunderBloc>().state;
    final inboxState = context.watch<InboxBloc>().state;

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: (DragEndDetails dragEndDetails) => _handleDragEnd(dragEndDetails, context),
      onDoubleTap: state.bottomNavBarDoubleTapGestures == true ? () => _handleDoubleTap(context) : null,
      child: NavigationBar(
        selectedIndex: widget.selectedPageIndex,
        labelBehavior: state.showNavigationLabels ? NavigationDestinationLabelBehavior.alwaysShow : NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: l10n.feed,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            label: l10n.search,
          ),
          GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              showProfileModalSheet(context);
            },
            child: NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.account(1),
              tooltip: '', // Disable tooltip so that gesture detector triggers properly
            ),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: inboxState.totalUnreadCount != 0,
              label: Text(inboxState.totalUnreadCount > 99 ? '99+' : inboxState.totalUnreadCount.toString()),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: inboxState.totalUnreadCount != 0,
              label: Text(inboxState.totalUnreadCount > 99 ? '99+' : inboxState.totalUnreadCount.toString()),
              child: const Icon(Icons.inbox_rounded),
            ),
            label: l10n.inbox,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.settings,
          ),
        ],
        onDestinationSelected: (index) {
          if (state.isFabOpen) {
            context.read<ThunderBloc>().add(const OnFabToggle(false));
          }

          if (widget.selectedPageIndex == 1 && index != 1) {
            FocusManager.instance.primaryFocus?.unfocus();
          }

          if (widget.selectedPageIndex == 0 && index == 0) {
            context.read<FeedBloc>().add(ScrollToTopEvent());
          }

          if (widget.selectedPageIndex == 1 && index == 1) {
            context.read<SearchBloc>().add(FocusSearchEvent());
          }

          if (widget.selectedPageIndex == 3 && index == 3) {
            return;
          }

          if (widget.selectedPageIndex != index) {
            widget.onPageChange(index);
          }

          // TODO: Change this from integer to enum or some other type
          if (index == 3) {
            context.read<InboxBloc>().add(const GetInboxEvent(reset: true));
          }
        },
      ),
    );
  }
}
