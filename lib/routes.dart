import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:thunder/settings/pages/general_settings_page.dart';

import 'package:thunder/settings/settings.dart';
import 'package:thunder/thunder/thunder.dart';

late final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  routes: <GoRoute>[
    GoRoute(
      name: 'home',
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const Thunder(),
      routes: <GoRoute>[],
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) => SettingsPage(),
      routes: <GoRoute>[
        GoRoute(
          name: 'general',
          path: 'general',
          builder: (BuildContext context, GoRouterState state) => const GeneralSettingsPage(),
        )
      ],
    ),
  ],
);
