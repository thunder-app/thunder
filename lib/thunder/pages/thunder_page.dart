import 'dart:async';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/utils/profiles.dart';

// Internal
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/inbox.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/settings/pages/settings_page.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class Thunder extends StatefulWidget {
  const Thunder({super.key});

  @override
  State<Thunder> createState() => _ThunderState();
}

class _ThunderState extends State<Thunder> {
  int selectedPageIndex = 0;
  int appExitCounter = 0;

  PageController pageController = PageController(initialPage: 0);

  final GlobalKey<ScaffoldState> _feedScaffoldKey = GlobalKey<ScaffoldState>();

  bool hasShownUpdateDialog = false;

  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// This is used for the swipe drag gesture on the bottom nav bar
  double _dragStartX = 0.0;
  double _dragEndX = 0.0;

  void _handleDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleDragEnd(DragEndDetails details) async {
    final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    bool bottomNavBarSwipeGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarSwipeGesture.name) ?? true;

    if (bottomNavBarSwipeGestures == true) {
      final delta = _dragEndX - _dragStartX;

      // Set some threshold to also allow for swipe up to reveal FAB
      if (delta > 20 && selectedPageIndex == 0) {
        _feedScaffoldKey.currentState?.openDrawer();
      } else if (delta < 0 && selectedPageIndex == 0) {
        _feedScaffoldKey.currentState?.closeDrawer();
      }
    }

    _dragStartX = 0.0;
  }

  // Handles drag on bottom nav bar to open the drawer
  void _handleDragUpdate(DragUpdateDetails details) async {
    _dragEndX = details.globalPosition.dx;
  }

  // Handles double-tap to open the drawer
  void _handleDoubleTap() async {
    final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    bool bottomNavBarDoubleTapGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarDoubleTapGesture.name) ?? false;

    final bool scaffoldState = _feedScaffoldKey.currentState!.isDrawerOpen;

    if (bottomNavBarDoubleTapGestures == true && scaffoldState == true) {
      _feedScaffoldKey.currentState?.closeDrawer();
    } else if (bottomNavBarDoubleTapGestures == true && scaffoldState == false) {
      _feedScaffoldKey.currentState?.openDrawer();
    }
  }

  void _showExitWarning() {
    final theme = Theme.of(context);
    const snackBarTextColor = TextStyle(color: Colors.white);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.primaryColorDark,
        width: 190,
        duration: const Duration(milliseconds: 3500),
        content: Center(child: Text(AppLocalizations.of(context)!.tapToExit, style: snackBarTextColor)),
      ),
    );
  }

  Future<bool> _handleBackButtonPress() async {
    if (selectedPageIndex != 0) {
      setState(() {
        selectedPageIndex = 0;
        pageController.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
      });
      return Future.value(false);
    }

    if (_isFabOpen == true) {
      return Future.value(false);
    }

    if (appExitCounter == 0) {
      appExitCounter++;
      _showExitWarning();
      Timer(const Duration(milliseconds: 3500), () {
        appExitCounter = 0;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThunderBloc()),
          BlocProvider(create: (context) => InboxBloc()),
        ],
        child: WillPopScope(
          onWillPop: () async {
            return _handleBackButtonPress();
          },
          child: BlocBuilder<ThunderBloc, ThunderState>(
            builder: (context, thunderBlocState) {
              switch (thunderBlocState.status) {
                case ThunderStatus.initial:
                  context.read<ThunderBloc>().add(InitializeAppEvent());
                  return const Center(child: CircularProgressIndicator());
                case ThunderStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ThunderStatus.refreshing:
                case ThunderStatus.success:
                  FlutterNativeSplash.remove();

                  // Update the variable so that it can be used in _handleBackButtonPress
                  _isFabOpen = thunderBlocState.isFabOpen;

                  return Scaffold(
                      bottomNavigationBar: BlocBuilder<InboxBloc, InboxState>(
                        builder: (context, state) {
                          return _getScaffoldBottomNavigationBar(context);
                        },
                      ),
                      body: MultiBlocProvider(
                          providers: [
                            BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
                          ],
                          child: BlocConsumer<AuthBloc, AuthState>(
                              listenWhen: (AuthState previous, AuthState current) {
                                if (previous.isLoggedIn != current.isLoggedIn || previous.status == AuthStatus.initial) return true;
                                return false;
                              },
                              buildWhen: (previous, current) => current.status != AuthStatus.failure && current.status != AuthStatus.loading,
                              listener: (context, state) {
                                context.read<AccountBloc>().add(GetAccountInformation());

                                // Add a bit of artificial delay to allow preferences to set the proper active profile
                                Future.delayed(const Duration(milliseconds: 500), () => context.read<InboxBloc>().add(const GetInboxEvent(reset: true)));
                              },
                              builder: (context, state) {
                                switch (state.status) {
                                  case AuthStatus.initial:
                                    context.read<AuthBloc>().add(CheckAuth());
                                    return const Center(child: CircularProgressIndicator());
                                  case AuthStatus.success:
                                    Version? version = thunderBlocState.version;
                                    bool showInAppUpdateNotification = thunderBlocState.showInAppUpdateNotification;

                                    if (version?.hasUpdate == true && hasShownUpdateDialog == false && showInAppUpdateNotification == true) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        showUpdateNotification(context, version);
                                        setState(() => hasShownUpdateDialog = true);
                                      });
                                    }

                                    return PageView(
                                      controller: pageController,
                                      onPageChanged: (index) => setState(() => selectedPageIndex = index),
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: <Widget>[
                                        CommunityPage(
                                          scaffoldKey: _feedScaffoldKey,
                                          pageController: pageController,
                                        ),
                                        MultiBlocProvider(
                                          providers: [BlocProvider(create: (context) => AnonymousSubscriptionsBloc()), BlocProvider(create: (context) => SearchBloc())],
                                          child: const SearchPage(),
                                        ),
                                        const AccountPage(),
                                        const InboxPage(),
                                        SettingsPage(),
                                      ],
                                    );

                                  // Should never hit these, they're handled by the login page
                                  case AuthStatus.failure:
                                  case AuthStatus.loading:
                                    return Container();
                                }
                              })));
                case ThunderStatus.failure:
                  return ErrorMessage(
                    message: thunderBlocState.errorMessage,
                    action: () => {context.read<AuthBloc>().add(CheckAuth())},
                    actionText: AppLocalizations.of(context)!.refreshContent,
                  );
              }
            },
          ),
        ));
  }

  // Generates the BottomNavigationBar
  Widget _getScaffoldBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;
    final InboxState inboxState = context.read<InboxBloc>().state;

    return Theme(
      data: ThemeData.from(colorScheme: theme.colorScheme).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onDoubleTap: state.bottomNavBarDoubleTapGestures == true ? _handleDoubleTap : null,
        child: BottomNavigationBar(
          currentIndex: selectedPageIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: theme.colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: 20.0,
          selectedFontSize: 20.0,
          elevation: 1,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: AppLocalizations.of(context)!.feed,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded),
              label: AppLocalizations.of(context)!.search,
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(onLongPress: () => showProfileModalSheet(context), child: const Icon(Icons.person_rounded)),
              label: AppLocalizations.of(context)!.account,
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: inboxState.totalUnreadCount != 0,
                label: Text(inboxState.totalUnreadCount > 9 ? '9+' : inboxState.totalUnreadCount.toString()),
                child: const Icon(Icons.inbox_rounded),
              ),
              label: AppLocalizations.of(context)!.inbox,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
          onTap: (index) {
            if (context.read<ThunderBloc>().state.isFabOpen) {
              context.read<ThunderBloc>().add(const OnFabToggle(false));
            }

            if (selectedPageIndex == 0 && index == 0) {
              context.read<ThunderBloc>().add(OnScrollToTopEvent());
            }

            if (selectedPageIndex != index) {
              setState(() {
                selectedPageIndex = index;
                pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
              });
            }

            // @todo Change this from integer to enum or some other type
            if (index == 3) {
              context.read<InboxBloc>().add(const GetInboxEvent(reset: true));
            }
          },
        ),
      ),
    );
  }

  // Update notification
  void showUpdateNotification(BuildContext context, Version? version) {
    final theme = Theme.of(context);

    final ThunderState state = context.read<ThunderBloc>().state;
    final bool openInExternalBrowser = state.openInExternalBrowser;

    showSimpleNotification(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.updateReleased(version?.latestVersion ?? ''),
              style: theme.textTheme.titleMedium,
            ),
            Icon(
              Icons.arrow_forward,
              color: theme.colorScheme.onBackground,
            ),
          ],
        ),
        onTap: () {
          openLink(context, url: 'https://github.com/hjiangsu/thunder/releases/latest', openInExternalBrowser: openInExternalBrowser);
        },
      ),
      background: theme.cardColor,
      autoDismiss: true,
      duration: const Duration(seconds: 5),
      slideDismissDirection: DismissDirection.vertical,
    );
  }
}
