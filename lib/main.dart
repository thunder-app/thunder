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
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:overlay_support/overlay_support.dart';

// Project imports
import 'package:thunder/src/core/database/database_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/database/database.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/theme_type.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/app/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:thunder/src/app/cubits/comment_preferences_cubit/comment_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/video_preferences_cubit/video_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/fab_preferences_cubit/fab_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/fab_cubit/fab_cubit.dart';
import 'package:thunder/src/app/cubits/nav_bar_state_cubit/nav_bar_state_cubit.dart';
import 'package:thunder/src/app/cubits/feed_ui_cubit/feed_ui_cubit.dart';
import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/shared/utils/cache.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/preferences.dart';
import 'package:thunder/src/shared/utils/language/language.dart';

late AppDatabase database;

void initializeDatabase() {
  database = AppDatabase();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes the UserPreferences singleton
  await UserPreferences.instance.initialize();

  try {
    ByteData data = await PlatformAssetBundle().load('assets/ca/isrgrootx1.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  } catch (e) {
    // Continue if failed to load certificate
  }

  // Setting SystemUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize the database
  initializeDatabase();

  // Clear image cache
  await clearExtendedImageCache();

  // Register dart_ping on iOS
  if (!kIsWeb && Platform.isIOS) {
    DartPingIOS.register();
  }

  // Perform preference migrations
  await performSharedPreferencesMigration();

  // Perform database integrity checks
  await performDatabaseIntegrityChecks();

  final account = await fetchActiveProfile();

  runApp(BlocProvider<ProfileBloc>(
    create: (context) => ProfileBloc(account: account)..add(InitializeAuth()),
    child: const ThunderApp(),
  ));

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

  PageController thunderPageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? inboxNotificationType = UserPreferences.getLocalSetting(LocalSettings.inboxNotificationType);

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
          UserPreferences.removeSetting(LocalSettings.inboxNotificationType);
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
        BlocProvider(create: (context) => DeepLinksCubit()),
        BlocProvider(create: (context) => NotificationsCubit(notificationsStream: notificationsStreamController.stream)),
        BlocProvider(create: (context) => ThunderBloc()),
        BlocProvider(create: (context) => GesturePreferencesCubit()),
        BlocProvider(create: (context) => FeedPreferencesCubit()),
        BlocProvider(create: (context) => CommentPreferencesCubit()),
        BlocProvider(create: (context) => ThemePreferencesCubit()),
        BlocProvider(create: (context) => VideoPreferencesCubit()),
        BlocProvider(create: (context) => FabPreferencesCubit()),
        BlocProvider(create: (context) => FabStateCubit()),
        BlocProvider(create: (context) => NavBarStateCubit()),
        BlocProvider(create: (context) => FeedUiCubit()),
        BlocProvider(create: (context) => AnonymousSubscriptionsBloc()),
        BlocProvider(create: (context) => NetworkCheckerCubit()..getConnectionType())
      ],
      child: BlocBuilder<ThemePreferencesCubit, ThemePreferencesState>(
        builder: (context, state) {
          final appLanguageCode = context.select<ThunderBloc, String?>((bloc) => bloc.state.appLanguageCode);

          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              FlexScheme scheme = FlexScheme.values.byName(state.selectedTheme.name);

              Color? darkThemeSurfaceColor = state.themeType == ThemeType.pureBlack ? null : Colors.black.lighten(8);

              ThemeData theme = FlexThemeData.light(scheme: scheme);
              ThemeData darkTheme = FlexThemeData.dark(
                scheme: scheme,
                darkIsTrueBlack: state.themeType == ThemeType.pureBlack,
                surface: darkThemeSurfaceColor,
                scaffoldBackground: darkThemeSurfaceColor,
                appBarBackground: darkThemeSurfaceColor,
              );

              // Enable Material You theme
              if (state.useMaterialYouTheme == true) {
                theme = ThemeData(
                  colorScheme: lightColorScheme,
                );

                darkTheme = FlexThemeData.dark(
                  colorScheme: darkColorScheme,
                  darkIsTrueBlack: state.themeType == ThemeType.pureBlack,
                );
              }

              // Set the page transitions
              const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              });

              // Customize our themes with the aforementinoed page transitions, as well as some custom styling
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

              Locale? locale = LanguageLocal.parseLanguageTag(appLanguageCode ?? 'en');

              return OverlaySupport.global(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  // Set navigation bar color on Android to be transparent
                  value: FlexColorScheme.themedSystemNavigationBar(context, systemNavBarStyle: FlexSystemNavBarStyle.transparent),
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    buildWhen: (previous, current) => previous.account.id != current.account.id,
                    builder: (context, profileState) {
                      final account = profileState.account;
                      return MultiBlocProvider(
                        key: ValueKey('account_${account.id}'),
                        providers: [
                          BlocProvider(create: (context) => InboxBloc(account: account)..add(GetInboxEvent(reset: true))),
                          BlocProvider(create: (context) => SearchBloc(account: account)),
                          BlocProvider(create: (context) => FeedBloc(account: account)),
                        ],
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
                            Locale('eo'), // Additional locale which is not officially supported: Esperanto
                          ],
                          themeMode: state.themeType == ThemeType.system ? ThemeMode.system : (state.themeType == ThemeType.light ? ThemeMode.light : ThemeMode.dark),
                          theme: theme,
                          darkTheme: darkTheme,
                          debugShowCheckedModeBanner: false,
                          scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
                          scrollBehavior: (state.reduceAnimations && Platform.isAndroid) ? const ScrollBehavior().copyWith(overscroll: false) : null,
                          home: Thunder(pageController: thunderPageController),
                        ),
                      );
                    },
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
