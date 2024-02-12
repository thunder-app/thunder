import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_displaymode/flutter_displaymode.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';

// Internal Packages
import 'package:thunder/routes.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/singletons/database.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:thunder/thunder/thunder.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/utils/cache.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:flutter/foundation.dart';
import 'package:thunder/utils/notifications.dart';
import 'package:thunder/utils/preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Setting SystemUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load up preferences
  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

  // Load up sqlite database
  await DB.instance.database;

  // Clear image cache
  await clearExtendedImageCache();

  // Register dart_ping on iOS
  if (!kIsWeb && Platform.isIOS) {
    DartPingIOS.register();
  }

  /// Allows the top-level notification handlers to trigger actions farther down
  final StreamController<NotificationResponse> notificationsStreamController = StreamController<NotificationResponse>();

  if (!kIsWeb && Platform.isAndroid) {
    // Initialize local notifications. Note that this doesn't request permissions or actually send any notifications.
    // It's just hooking up callbacks and settings.
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // Initialize the Android-specific settings, using the splash asset as the notification icon.
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('splash');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (notificationResponse) => notificationsStreamController.add(notificationResponse));

    // See if Thunder is launching because a notification was tapped. If so, we want to jump right to the appropriate page.
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true && notificationAppLaunchDetails!.notificationResponse != null) {
      notificationsStreamController.add(notificationAppLaunchDetails.notificationResponse!);
    }

    // Initialize background fetch (this is async and can go run on its own).
    if (prefs.getBool(LocalSettings.enableInboxNotifications.name) ?? false) {
      initBackgroundFetch();
    }
  }

  final String initialInstance = (await UserPreferences.instance).sharedPreferences.getString(LocalSettings.currentAnonymousInstance.name) ?? 'lemmy.ml';
  LemmyClient.instance.changeBaseUrl(initialInstance);

  // Perform preference migrations
  performSharedPreferencesMigration();

  // Do a notifications check on startup
  pollRepliesAndShowNotifications();

  runApp(ThunderApp(notificationsStream: notificationsStreamController.stream));

  if (!kIsWeb && Platform.isAndroid) {
    // Set high refresh rate after app initialization
    FlutterDisplayMode.setHighRefreshRate();
  }

  // Register to receive BackgroundFetch events after app is terminated.
  if (!kIsWeb && Platform.isAndroid && (prefs.getBool(LocalSettings.enableInboxNotifications.name) ?? false)) {
    initHeadlessBackgroundFetch();
  }
}

class ThunderApp extends StatelessWidget {
  final Stream<NotificationResponse> notificationsStream;

  const ThunderApp({super.key, required this.notificationsStream});

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
          create: (context) => NotificationsCubit(notificationsStream: notificationsStream),
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
        // Used for global user events like block/unblock
        BlocProvider(
          create: (context) => UserBloc(),
        ),
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

// ---------------- START BACKGROUND FETCH STUFF ---------------- //

/// This method handles "headless" callbacks,
/// i.e., whent the app is not running
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) {
    BackgroundFetch.finish(task.taskId);
    return;
  }
  // Run the poll!
  await pollRepliesAndShowNotifications();
  BackgroundFetch.finish(task.taskId);
}

/// The method initializes background fetching while the app is running
Future<void> initBackgroundFetch() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiredNetworkType: NetworkType.NONE,
      requiresBatteryNotLow: false,
      requiresStorageNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      // Uncomment this line (and set the minimumFetchInterval to 1) for quicker testing.
      //forceAlarmManager: true,
    ),
    // This is the callback that handles background fetching while the app is running.
    (String taskId) async {
      // Run the poll!
      await pollRepliesAndShowNotifications();
      BackgroundFetch.finish(taskId);
    },
    // This is the timeout callback.
    (String taskId) async {
      BackgroundFetch.finish(taskId);
    },
  );
}

void disableBackgroundFetch() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: true,
      startOnBoot: false,
      enableHeadless: false,
    ),
    () {},
    () {},
  );
}

// This method initializes background fetching while the app is not running
void initHeadlessBackgroundFetch() async {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

// ---------------- END BACKGROUND FETCH STUFF ---------------- //
