import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/communities/bloc/communities_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/communities/pages/communities_page.dart';

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
        BlocProvider<ThunderBloc>(create: (context) => ThunderBloc()),
        BlocProvider<CommunitiesBloc>(create: (context) => CommunitiesBloc()),
        BlocProvider<CommunityBloc>(create: (context) => CommunityBloc()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.initial:
              context.read<AuthBloc>().add(CheckAuth());
              return const Center(child: CircularProgressIndicator());
            case AuthStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AuthStatus.success:
              if (state.isLoggedIn) context.read<AccountBloc>().add(GetAccountInformation());
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
                      label: 'Communities',
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
                body: <Widget>[
                  const CommunityPage(),
                  const CommunitiesPage(),
                  const AccountPage(),
                  Container(
                    alignment: Alignment.center,
                    child: const Text('Settings'),
                  ),
                ][currentPageIndex],
              );
            case AuthStatus.failure:
              return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
