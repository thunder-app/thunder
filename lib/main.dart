// Dart imports
import 'dart:async';
import 'dart:io';

// Flutter imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports
import "package:flutter_displaymode/flutter_displaymode.dart";
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/database/database.dart';
import 'package:thunder/core/database/migrations.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/notification/enums/notification_type.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/notification/notifications.dart';
import 'package:thunder/notification/shared/notification_server.dart';
import 'package:thunder/routes.dart';
import 'package:thunder/thunder/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:thunder/thunder/thunder.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/utils/cache.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/preferences.dart';

late AppDatabase database;

bool _isDatabaseInitialized = false;

Future<void> initializeDatabase() async {
  if (_isDatabaseInitialized) return;

  debugPrint('Initializing drift db.');

  File dbFile = File(join((await getApplicationDocumentsDirectory()).path, 'thunder.sqlite'));

  database = AppDatabase();

  if (!await dbFile.exists()) {
    debugPrint('Migrating from SQLite db.');
    await migrateToSQLite(database);
  }

  _isDatabaseInitialized = true;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Setting SystemUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await initializeDatabase();

  // Clear image cache
  await clearExtendedImageCache();

  // Register dart_ping on iOS
  if (!kIsWeb && Platform.isIOS) {
    DartPingIOS.register();
  }

  final String initialInstance = (await UserPreferences.instance).sharedPreferences.getString(LocalSettings.currentAnonymousInstance.name) ?? 'lemmy.ml';
  LemmyClient.instance.changeBaseUrl(initialInstance);

  // Perform preference migrations
  await performSharedPreferencesMigration();

  runApp(const ThunderApp());

  if (!kIsWeb && Platform.isAndroid) {
    // Set high refresh rate after app initialization
    FlutterDisplayMode.setHighRefreshRate();
  }
}

class ThunderApp extends StatefulWidget {
  const ThunderApp({super.key});

  @override
  State<ThunderApp> createState() => _ThunderAppState();
}

class _ThunderAppState extends State<ThunderApp> {
  /// Allows the top-level notification handlers to trigger actions farther down
  final StreamController<NotificationResponse> notificationsStreamController = StreamController<NotificationResponse>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      String? inboxNotificationType = prefs.getString(LocalSettings.inboxNotificationType.name);

      // If notification type is null, then don't perform any logic
      if (inboxNotificationType == null) return;

      if (NotificationType.values.byName(inboxNotificationType) != NotificationType.none) {
        // Initialize notification logic
        initPushNotificationLogic(controller: notificationsStreamController);
      } else {
        // Attempt to remove tokens from notification server. When inboxNotificationType == NotificationType.none,
        // this indicates that removing token was unsuccessful previously. We will attempt to remove it again.
        // When there is a successful removal, the inboxNotificationType will be set to null.
        bool success = await deleteAccountFromNotificationServer();

        if (success) {
          prefs.remove(LocalSettings.inboxNotificationType.name);
          debugPrint('Removed tokens from notification server');
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
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => AccountBloc(),
        ),
        BlocProvider(
          create: (context) => DeepLinksCubit(),
        ),
        BlocProvider(
          create: (context) => NotificationsCubit(notificationsStream: notificationsStreamController.stream),
        ),
        BlocProvider(
          create: (context) => ThunderBloc(),
        ),
        BlocProvider(
          create: (context) => AnonymousSubscriptionsBloc(),
        ),
        BlocProvider(
          create: (context) => CommunityBloc(lemmyClient: LemmyClient.instance),
        ),
        BlocProvider(
          create: (context) => InstanceBloc(lemmyClient: LemmyClient.instance),
        ),
        BlocProvider(
          create: (context) => UserBloc(lemmyClient: LemmyClient.instance),
        ),
        BlocProvider(
          create: (context) => NetworkCheckerCubit()..getConnectionType(),
        )
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final ThunderBloc thunderBloc = context.watch<ThunderBloc>();

          if (state.status == ThemeStatus.initial) {
            context.read<ThemeBloc>().add(ThemeChangeEvent());
          }

          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              ThemeData theme = FlexThemeData.light(useMaterial3: true, scheme: FlexScheme.values.byName(state.selectedTheme.name));
              ThemeData darkTheme = FlexThemeData.dark(useMaterial3: true, scheme: FlexScheme.values.byName(state.selectedTheme.name), darkIsTrueBlack: state.themeType == ThemeType.pureBlack);

              // Enable Material You theme
              if (state.useMaterialYouTheme == true) {
                theme = ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                );

                darkTheme = FlexThemeData.dark(
                  useMaterial3: true,
                  colorScheme: darkColorScheme,
                  darkIsTrueBlack: state.themeType == ThemeType.pureBlack,
                );
              }

              // Set the page transitions
              const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              });

              theme = theme.copyWith(
                pageTransitionsTheme: pageTransitionsTheme,
              );
              darkTheme = darkTheme.copyWith(
                pageTransitionsTheme: pageTransitionsTheme,
              );

              // Set navigation bar color on Android to be transparent
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.black.withOpacity(0.0001),
                ),
              );

              Locale? locale = AppLocalizations.supportedLocales.where((Locale locale) => locale.languageCode == thunderBloc.state.appLanguageCode).firstOrNull;

              return OverlaySupport.global(
                child: MaterialApp.router(
                  title: 'Thunder',
                  locale: locale,
                  localizationsDelegates: const [
                    ...AppLocalizations.localizationsDelegates,
                    MaterialLocalizationsEo.delegate,
                    CupertinoLocalizationsEo.delegate,
                  ],
                  supportedLocales: const [
                    ...AppLocalizations.supportedLocales,
                    Locale('eo'), // Additional locale which is not officially supported: Esperanto
                  ],
                  routerConfig: router,
                  themeMode: state.themeType == ThemeType.system ? ThemeMode.system : (state.themeType == ThemeType.light ? ThemeMode.light : ThemeMode.dark),
                  theme: theme,
                  darkTheme: darkTheme,
                  debugShowCheckedModeBanner: false,
                  scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
                  scrollBehavior: (state.reduceAnimations && Platform.isAndroid) ? const ScrollBehavior().copyWith(overscroll: false) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
