import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/communities/bloc/communities_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';

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
      ],
      child: Scaffold(
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
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
        body: <Widget>[
          const CommunityPage(),
          const CommunitiesPage(),
          Container(
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('Page 3'),
          ),
        ][currentPageIndex],
      ),
    );
  }
}
