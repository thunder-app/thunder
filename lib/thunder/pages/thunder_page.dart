import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/communities/bloc/communities_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/settings/pages/settings_page.dart';

class Thunder extends StatefulWidget {
  const Thunder({super.key});

  @override
  State<Thunder> createState() => _ThunderState();
}

class _ThunderState extends State<Thunder> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CommunitiesBloc>(create: (context) => CommunitiesBloc()),
        BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            bottomNavigationBar: NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              onDestinationSelected: (int index) {
                setState(() => currentPageIndex = index);
              },
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Feed',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: 'Account',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
            body: _getThunderBody(context, state),
          );
        },
      ),
    );
  }

  Widget _getThunderBody(BuildContext context, AuthState state) {
    final theme = Theme.of(context);

    switch (state.status) {
      case AuthStatus.initial:
        context.read<AuthBloc>().add(CheckAuth());
        return const Center(child: CircularProgressIndicator());
      case AuthStatus.loading:
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => currentPageIndex = 0));
        return const Center(child: CircularProgressIndicator());
      case AuthStatus.success:
        if (state.isLoggedIn) {
          context.read<AccountBloc>().add(GetAccountInformation());
        }
        return <Widget>[
          const CommunityPage(),
          const SearchPage(),
          const AccountPage(),
          SettingsPage(),
        ][currentPageIndex];
      case AuthStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, size: 100, color: Colors.red.shade300),
                const SizedBox(height: 32.0),
                Text('Oops, something went wrong!', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text(
                  state.errorMessage ?? 'No error message available',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => {context.read<AuthBloc>().add(CheckAuth())},
                  child: const Text('Refresh Content'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
