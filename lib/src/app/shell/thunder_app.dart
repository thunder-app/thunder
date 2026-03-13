import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/app/shell/state/shell_chrome_cubit.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/widgets/session.dart';
import 'package:thunder/src/app/shell/widgets/session_scope.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/app/shell/pages/thunder_page.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/community/api.dart';
import 'package:thunder/src/features/notification/api.dart';
import 'package:thunder/src/features/settings/domain/models/language_local.dart';

class ThunderApp extends StatefulWidget {
  const ThunderApp({super.key});

  @override
  State<ThunderApp> createState() => _ThunderAppState();
}

class _ThunderAppState extends State<ThunderApp> {
  final notificationsStreamController = StreamController<NotificationResponse>();

  final thunderPageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final String? inboxNotificationType = UserPreferences.getLocalSetting(LocalSettings.inboxNotificationType);

      if (inboxNotificationType == null) return;

      if (NotificationType.values.byName(inboxNotificationType) != NotificationType.none) {
        initPushNotificationLogic(controller: notificationsStreamController);
      } else {
        final bool success = await deleteAccountFromNotificationServer();

        if (success) {
          UserPreferences.removeSetting(LocalSettings.inboxNotificationType);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    notificationsStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => createDeepLinksCubit()),
        BlocProvider(create: (context) => NotificationsCubit(notificationsStream: notificationsStreamController.stream)),
        BlocProvider(create: (context) => createAppBootstrapCubit()),
        BlocProvider(create: (context) => createThunderCubit()),
        BlocProvider(create: (context) => GesturePreferencesCubit(preferencesStore: const UserPreferencesStore())),
        BlocProvider(create: (context) => FeedPreferencesCubit(preferencesStore: const UserPreferencesStore())),
        BlocProvider(create: (context) => CommentPreferencesCubit(preferences: const UserPreferencesStore())),
        BlocProvider(create: (context) => ThemePreferencesCubit(preferencesStore: const UserPreferencesStore())),
        BlocProvider(create: (context) => VideoPreferencesCubit(preferencesStore: const UserPreferencesStore())),
        BlocProvider(create: (context) => FabPreferencesCubit(preferencesStore: const UserPreferencesStore())),
        BlocProvider(create: (context) => ShellChromeCubit()),
        BlocProvider(create: (context) => AnonymousSubscriptionsCubit()..loadSubscribedCommunities()),
        BlocProvider(create: (context) => createNetworkCheckerCubit()..getConnectionType()),
      ],
      child: BlocBuilder<ThemePreferencesCubit, ThemePreferencesState>(
        builder: (context, state) {
          final appLanguageCode = context.select<ThunderCubit, String?>((bloc) => bloc.state.appLanguageCode);

          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              final FlexScheme scheme = FlexScheme.values.byName(state.selectedTheme.name);

              final Color? darkThemeSurfaceColor = state.themeType == ThemeType.pureBlack ? null : Colors.black.lighten(8);

              ThemeData theme = FlexThemeData.light(scheme: scheme);
              ThemeData darkTheme = FlexThemeData.dark(
                scheme: scheme,
                darkIsTrueBlack: state.themeType == ThemeType.pureBlack,
                surface: darkThemeSurfaceColor,
                scaffoldBackground: darkThemeSurfaceColor,
                appBarBackground: darkThemeSurfaceColor,
              );

              if (state.useMaterialYouTheme == true) {
                theme = ThemeData(
                  colorScheme: lightColorScheme,
                );

                darkTheme = FlexThemeData.dark(
                  colorScheme: darkColorScheme,
                  darkIsTrueBlack: state.themeType == ThemeType.pureBlack,
                );
              }

              const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              });

              theme = theme.copyWith(
                pageTransitionsTheme: pageTransitionsTheme,
                inputDecorationTheme: InputDecorationTheme(
                  hintStyle: TextStyle(
                    color: lightColorScheme?.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );
              darkTheme = darkTheme.copyWith(
                pageTransitionsTheme: pageTransitionsTheme,
                inputDecorationTheme: InputDecorationTheme(
                  hintStyle: TextStyle(
                    color: darkColorScheme?.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );

              final Locale? locale = LanguageLocal.parseLanguageTag(appLanguageCode ?? 'en');

              return OverlaySupport.global(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: FlexColorScheme.themedSystemNavigationBar(context, systemNavBarStyle: FlexSystemNavBarStyle.transparent),
                  child: MaterialApp(
                    title: 'Thunder',
                    locale: locale,
                    localizationsDelegates: const [
                      ...AppLocalizations.localizationsDelegates,
                      MaterialLocalizationsEo.delegate,
                      CupertinoLocalizationsEo.delegate,
                    ],
                    supportedLocales: const [
                      ...AppLocalizations.supportedLocales,
                      Locale('eo'),
                    ],
                    themeMode: state.themeType == ThemeType.system ? ThemeMode.system : (state.themeType == ThemeType.light ? ThemeMode.light : ThemeMode.dark),
                    theme: theme,
                    darkTheme: darkTheme,
                    debugShowCheckedModeBanner: false,
                    scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
                    scrollBehavior: (state.reduceAnimations && Platform.isAndroid) ? const ScrollBehavior().copyWith(overscroll: false) : null,
                    home: Session(
                      builder: (context, sessionState) {
                        final account = sessionState.activeAccount!;

                        return SessionScope(
                          account: account,
                          generation: sessionState.generation,
                          profileBloc: createProfileBloc,
                          inboxBloc: createInboxBloc,
                          searchBloc: createSearchBloc,
                          feedBloc: createFeedBloc,
                          builder: (context, profileState) => Thunder(pageController: thunderPageController),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
