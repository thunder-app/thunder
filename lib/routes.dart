import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD

import 'package:go_router/go_router.dart';
import 'package:thunder/settings/pages/general_settings_page.dart';

import 'package:thunder/settings/settings.dart';
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/settings/pages/general_settings_page.dart';
import 'package:thunder/settings/settings.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:thunder/thunder/thunder.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  routes: <GoRoute>[
    GoRoute(
      name: 'home',
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const Thunder(),
      routes: const <GoRoute>[],
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) => SettingsPage(),
      routes: <GoRoute>[
        GoRoute(
<<<<<<< HEAD
<<<<<<< HEAD
          name: 'general',
          path: 'general',
          builder: (BuildContext context, GoRouterState state) => const GeneralSettingsPage(),
        )
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
            name: 'general',
            path: 'general',
            builder: (context, state) {
              return BlocProvider.value(
                value: state.extra! as ThunderBloc,
                child: const GeneralSettingsPage(),
              );
            })
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      ],
    ),
  ],
);
