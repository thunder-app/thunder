import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';

import 'package:thunder/settings/pages/about_settings_page.dart';
import 'package:thunder/settings/pages/accessibility_settings_page.dart';
import 'package:thunder/settings/pages/appearance_settings_page.dart';
import 'package:thunder/settings/pages/comment_appearance_settings_page.dart';
import 'package:thunder/settings/pages/debug_settings_page.dart';
import 'package:thunder/settings/pages/fab_settings_page.dart';
import 'package:thunder/settings/pages/filter_settings_page.dart';
import 'package:thunder/settings/pages/general_settings_page.dart';
import 'package:thunder/settings/pages/gesture_settings_page.dart';
import 'package:thunder/settings/pages/post_appearance_settings_page.dart';
import 'package:thunder/settings/pages/theme_settings_page.dart';
import 'package:thunder/settings/pages/video_player_settings.dart';
import 'package:thunder/settings/settings.dart';
import 'package:thunder/thunder/thunder.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/user/pages/user_settings_page.dart';

PageController thunderPageController = PageController(initialPage: 0);

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  routes: <GoRoute>[
    GoRoute(
      name: 'home',
      path: '/',
      builder: (BuildContext context, GoRouterState state) => Thunder(pageController: thunderPageController),
      routes: const <GoRoute>[],
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
      routes: <GoRoute>[
        GoRoute(
          name: 'general',
          path: 'general',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: GeneralSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'filters',
          path: 'filters',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: FilterSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'appearance',
          path: 'appearance',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: AppearanceSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
          routes: [
            GoRoute(
              name: 'themes',
              path: 'themes',
              builder: (context, state) {
                return BlocProvider.value(
                  value: (state.extra! as List)[0] as ThunderBloc,
                  child: ThemeSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
                );
              },
            ),
            GoRoute(
              name: 'posts',
              path: 'posts',
              builder: (context, state) {
                return BlocProvider.value(
                  value: (state.extra! as List)[0] as ThunderBloc,
                  child: PostAppearanceSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
                );
              },
            ),
            GoRoute(
              name: 'comments',
              path: 'comments',
              builder: (context, state) {
                return BlocProvider.value(
                  value: (state.extra! as List)[0] as ThunderBloc,
                  child: CommentAppearanceSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: 'gestures',
          path: 'gestures',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: GestureSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'video',
          path: 'video',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: VideoPlayerSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'fab',
          path: 'fab',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: FabSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'accessibility',
          path: 'accessibility',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: AccessibilitySettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'account',
          path: 'account',
          builder: (context, state) {
            UserSettingsBloc userSettingsBloc = UserSettingsBloc();
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: (state.extra! as List)[0] as ThunderBloc),
                BlocProvider.value(value: userSettingsBloc),
              ],
              child: UserSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'about',
          path: 'about',
          builder: (context, state) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: (state.extra! as List)[0] as ThunderBloc),
                BlocProvider.value(value: (state.extra! as List)[1] as AccountBloc),
                BlocProvider.value(value: (state.extra! as List)[2] as AuthBloc),
              ],
              child: AboutSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(3) as LocalSettings?),
            );
          },
        ),
        GoRoute(
          name: 'debug',
          path: 'debug',
          builder: (context, state) {
            return BlocProvider.value(
              value: (state.extra! as List)[0] as ThunderBloc,
              child: DebugSettingsPage(settingToHighlight: (state.extra! as List).elementAtOrNull(1) as LocalSettings?),
            );
          },
        ),
      ],
    ),
  ],
);
