import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Internal Packages
import 'package:thunder/routes.dart';
import 'package:thunder/core/singletons/database.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';

// Ignore specific exceptions to send to Sentry
FutureOr<SentryEvent?> beforeSend(SentryEvent event, {Hint? hint}) async {
  if (event.exceptions != null &&
      event.exceptions!.isNotEmpty &&
      event.exceptions!.first.value != null &&
      event.exceptions!.first.value!.contains('The request returned an invalid status code of 400.')) {
    return null;
  }

  return event;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Load up sqlite database
  await DB.instance.database;

  String? sentryDSN = dotenv.env['SENTRY_DSN'];

  if (sentryDSN != null) {
    await SentryFlutter.init(
      (options) {
        options.dsn = kDebugMode ? '' : sentryDSN;
        options.debug = kDebugMode;
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
        options.beforeSend = beforeSend;
      },
      appRunner: () => runApp(const ThunderApp()),
    );
  } else {
    runApp(const ThunderApp());
  }
}

class ThunderApp extends StatelessWidget {
  const ThunderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          if (state.status == ThemeStatus.initial) {
            context.read<ThemeBloc>().add(ThemeChangeEvent());
          }
          return OverlaySupport.global(
            child: MaterialApp.router(
              title: 'Thunder',
              routerConfig: router,
              themeMode: state.useDarkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(useMaterial3: true),
              darkTheme: ThemeData.dark(useMaterial3: true),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
