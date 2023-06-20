import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:overlay_support/overlay_support.dart';

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
  PageController pageController = PageController(initialPage: 0);

  bool hasShownUpdateDialog = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThunderBloc(),
      child: BlocBuilder<ThunderBloc, ThunderState>(
        builder: (context, state) {
          FlutterNativeSplash.remove();

          switch (state.status) {
            case ThunderStatus.initial:
              context.read<ThunderBloc>().add(InitializeAppEvent());
              return const Center(child: CircularProgressIndicator());
            case ThunderStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ThunderStatus.success:
              return Scaffold(
                bottomNavigationBar: _getScaffoldBottomNavigationBar(context),
                body: MultiBlocProvider(
                  providers: [
                    BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
                    BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
                  ],
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (AuthState previous, AuthState current) {
                      if (previous.isLoggedIn != current.isLoggedIn) return true;
                      return false;
                    },
                    listener: (context, state) {
                      context.read<AccountBloc>().add(GetAccountInformation());
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
                          Version? version = context.read<ThunderBloc>().state.version;

                          if (version?.hasUpdate == true && hasShownUpdateDialog == false) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showUpdateNotification(version);
                              setState(() => hasShownUpdateDialog = true);
                            });
                          }

                          return PageView(
                            controller: pageController,
                            onPageChanged: (index) => setState(() => selectedPageIndex = index),
                            physics: const NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              const CommunityPage(),
                              const SearchPage(),
                              const AccountPage(),
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
                ),
              );
            case ThunderStatus.failure:
              return ErrorMessage(
                message: state.errorMessage,
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

    return Theme(
      data: ThemeData.from(colorScheme: theme.colorScheme).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
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
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedPageIndex = index;
            pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
          });
        },
      ),
    );
  }

  // Update notification
  void showUpdateNotification(Version? version) {
    final theme = Theme.of(context);

    showSimpleNotification(
      GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Update released: ${version?.latestVersion}',
              style: theme.textTheme.titleMedium,
            ),
            Icon(Icons.arrow_forward, color: theme.colorScheme.tertiary),
          ],
        ),
        onTap: () => launchUrl(Uri.parse('https://github.com/hjiangsu/thunder/releases/latest')),
      ),
      background: theme.colorScheme.onSecondary,
      autoDismiss: false,
      slideDismissDirection: DismissDirection.vertical,
    );
  }
}
