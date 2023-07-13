
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

// Internal Packages
import 'package:thunder/routes.dart';
import 'package:thunder/core/singletons/database.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //Setting SystmeUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Load up sqlite database
  await DB.instance.database;

  runApp(const ThunderApp());
}

class ThunderApp extends StatelessWidget {
  const ThunderApp({super.key});

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
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          if (state.status == ThemeStatus.initial) {
            context.read<ThemeBloc>().add(ThemeChangeEvent());
          }
          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              ThemeData theme = FlexThemeData.light(
                  useMaterial3: true, scheme: FlexScheme.deepBlue);
              ThemeData darkTheme = FlexThemeData.dark(
                  useMaterial3: true,
                  scheme: FlexScheme.deepBlue,
                  darkIsTrueBlack: state.useBlackTheme);

              // Enable Material You theme
              if (state.useMaterialYouTheme == true) {
                theme = ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                );

                darkTheme = FlexThemeData.dark(
                  useMaterial3: true,
                  colorScheme: darkColorScheme,
                  darkIsTrueBlack: state.useBlackTheme,
                );
              }

              // Set navigation bar color on Android to be transparent
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.black.withOpacity(0.0001),
                ),
              );

              return OverlaySupport.global(
                child: MaterialApp.router(
                  title: 'Thunder',
                  routerConfig: router,
                  themeMode: state.useSystemTheme
                      ? ThemeMode.system
                      : (state.useDarkTheme ? ThemeMode.dark : ThemeMode.light),
                  theme: theme,
                  darkTheme: darkTheme,
                  debugShowCheckedModeBanner: false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
