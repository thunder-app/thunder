import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/inbox.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/settings/pages/settings_page.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class Thunder extends StatefulWidget {
  const Thunder({super.key});

  @override
  State<Thunder> createState() => _ThunderState();
}

class _ThunderState extends State<Thunder> {
  int selectedPageIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  final GlobalKey<ScaffoldState> _feedScaffoldKey = GlobalKey<ScaffoldState>();

  bool hasShownUpdateDialog = false;
  bool hasShownSentryDialog = false;

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

  void _handleDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragStartX = 0.0;
  }

  // Handles drag on bottom nav bar to open the drawer
  void _handleDragUpdate(DragUpdateDetails details) async {
    final SharedPreferences prefs = UserPreferences.instance.sharedPreferences;
    bool bottomNavBarSwipeGestures = prefs.getBool('setting_general_enable_swipe_gestures') ?? true;

    if (bottomNavBarSwipeGestures == true) {
      final currentPosition = details.globalPosition.dx;
      final delta = currentPosition - _dragStartX;

      if (delta > 0 && selectedPageIndex == 0) {
        _feedScaffoldKey.currentState?.openDrawer();
      } else if (delta < 0 && selectedPageIndex == 0) {
        _feedScaffoldKey.currentState?.closeDrawer();
      }
    }
  }

  // Handles double-tap to open the drawer
  void _handleDoubleTap() async {
    final SharedPreferences prefs = UserPreferences.instance.sharedPreferences;
    bool bottomNavBarDoubleTapGestures = prefs.getBool('setting_general_enable_doubletap_gestures') ?? false;

    final bool scaffoldState = _feedScaffoldKey.currentState!.isDrawerOpen;

    if (bottomNavBarDoubleTapGestures == true && scaffoldState == true) {
      _feedScaffoldKey.currentState?.closeDrawer();
    } else if (bottomNavBarDoubleTapGestures == true && scaffoldState == false) {
      _feedScaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThunderBloc()),
        BlocProvider(create: (context) => InboxBloc()),
      ],
      child: BlocBuilder<ThunderBloc, ThunderState>(
        builder: (context, thunderBlocState) {
          FlutterNativeSplash.remove();

          switch (thunderBlocState.status) {
            case ThunderStatus.initial:
              context.read<ThunderBloc>().add(InitializeAppEvent());
              return const Center(child: CircularProgressIndicator());
            case ThunderStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ThunderStatus.refreshing:
            case ThunderStatus.success:
              return Scaffold(
                bottomNavigationBar: _getScaffoldBottomNavigationBar(context),
                body: WillPopScope(
                    onWillPop: () async {
                  bool shouldThunderClose = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: Text('Confirm Close'),
                        content: Text('Are you sure you want to exit thunder?'),
                        actions: [
                    TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },

                    ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              Navigator.of(context).pop(true); //2nd pop here is to force exit when sidebar is open
                            },
                          ),
                        ]
                    )
                  );
                  return shouldThunderClose ?? false;
                },
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
                        BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
                      ],
                      child: BlocConsumer<AuthBloc, AuthState>(
                        listenWhen: (AuthState previous, AuthState current) {
                          if (previous.isLoggedIn != current.isLoggedIn || previous.status == AuthStatus.initial) return true;
                          return false;
                        },
                        listener: (context, state) {
                          context.read<AccountBloc>().add(GetAccountInformation());
                          context.read<InboxBloc>().add(const GetInboxEvent());
                        },
                        builder: (context, state) {
                          switch (state.status) {
                            case AuthStatus.initial:
                              context.read<AuthBloc>().add(CheckAuth());
                              return const Center(child: CircularProgressIndicator());
                            case AuthStatus.loading:
                              WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => selectedPageIndex = 0));
                              return const Center(child: CircularProgressIndicator());
                            case AuthStatus.success:
                              Version? version = thunderBlocState.version;
                              bool showInAppUpdateNotification = thunderBlocState.showInAppUpdateNotification;
                              bool? enableSentryErrorTracking = thunderBlocState.enableSentryErrorTracking;
                              if (version?.hasUpdate == true && hasShownUpdateDialog == false && showInAppUpdateNotification == true) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  showUpdateNotification(context, version);

                                  setState(() => hasShownUpdateDialog = true);
                                });
                              }

                              // Ask user if they want to opt-in to Sentry for the first time (based on if setting_error_tracking_enable_sentry is null)
                              if (enableSentryErrorTracking == null && hasShownSentryDialog == false) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  showSentryNotification(context);
                                  setState(() => hasShownSentryDialog = true);
                                });
                              }

                              return PageView(
                                controller: pageController,
                                onPageChanged: (index) => setState(() => selectedPageIndex = index),
                                physics: const NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  CommunityPage(scaffoldKey: _feedScaffoldKey),
                                  BlocProvider(
                                    create: (context) => SearchBloc(),
                                    child: const SearchPage(),
                                  ),
                                  const AccountPage(),
                                  const InboxPage(),
                                  SettingsPage(),
                                ],
                              );
                            case AuthStatus.failure:
                              return ErrorMessage(
                                message: state.errorMessage,
                                action: () => {context.read<AuthBloc>().add(CheckAuth())},
                                actionText: 'Refresh Content',
                              );
                          }
                        },
                      ),
                    )
              ));
            case ThunderStatus.failure:
              return ErrorMessage(
                message: thunderBlocState.errorMessage,
                action: () => {context.read<AuthBloc>().add(CheckAuth())},
                actionText: 'Refresh Content',
              );
          }
        },
      ),
    );
  }

  // Generates the BottomNavigationBar
  Widget _getScaffoldBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_rounded),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            setState(() {
              selectedPageIndex = index;
              pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
            });

            // @todo Change this from integer to enum or some other type
            if (index == 3) {
              context.read<InboxBloc>().add(const GetInboxEvent());
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
              'Update released: ${version?.latestVersion}',
              style: theme.textTheme.titleMedium,
            ),
            Icon(
              Icons.arrow_forward,
              color: theme.colorScheme.onBackground,
            ),
          ],
        ),
        onTap: () {
          if (openInExternalBrowser) {
            launchUrl(Uri.parse('https://github.com/hjiangsu/thunder/releases/latest'), mode: LaunchMode.externalApplication);
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WebView(url: 'https://github.com/hjiangsu/thunder/releases/latest')));
          }
        },
      ),
      background: theme.cardColor,
      autoDismiss: true,
      duration: const Duration(seconds: 5),
      slideDismissDirection: DismissDirection.vertical,
    );
  }

  // Sentry opt-in notification
  void showSentryNotification(BuildContext thunderBlocContext) {
    final theme = Theme.of(context);
    final SharedPreferences prefs = UserPreferences.instance.sharedPreferences;

    showOverlay(
      (context, t) {
        return Container(
          color: Color.lerp(Colors.transparent, Colors.black54, t),
          child: FractionalTranslation(
            translation: Offset.lerp(const Offset(0, 1), const Offset(0, 0), t)!,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Card(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0, bottom: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Sentry Error Reporting?',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'By opting in, any errors that you encounter will be automatically sent to Sentry to improve Thunder.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'You may opt out at any time in the Settings.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: const Text('Allow'),
                                onPressed: () {
                                  prefs.setBool('setting_error_tracking_enable_sentry', true);
                                  OverlaySupportEntry.of(context)!.dismiss();
                                },
                              ),
                              TextButton(
                                child: const Text('Do not allow'),
                                onPressed: () {
                                  prefs.setBool('setting_error_tracking_enable_sentry', false);
                                  OverlaySupportEntry.of(context)!.dismiss();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      duration: Duration.zero,
    );
  }
}
