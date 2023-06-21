<<<<<<< HEAD
=======
import 'dart:async';

>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// External Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
<<<<<<< HEAD
=======
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:sentry_flutter/sentry_flutter.dart';

// Internal Packages
import 'package:thunder/routes.dart';
<<<<<<< HEAD
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
=======
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
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  // Load up environment variables
  await dotenv.load(fileName: ".env");

<<<<<<< HEAD
=======
  // Load up sqlite database
  await DB.instance.database;

>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  String? sentryDSN = dotenv.env['SENTRY_DSN'];

  if (sentryDSN != null) {
    await SentryFlutter.init(
      (options) {
        options.dsn = kDebugMode ? '' : sentryDSN;
        options.debug = kDebugMode;
<<<<<<< HEAD
        options.tracesSampleRate = 1.0;
=======
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
        options.beforeSend = beforeSend;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
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
<<<<<<< HEAD
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThunderBloc()),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: BlocBuilder<ThunderBloc, ThunderState>(
        builder: (context, state) {
          switch (state.status) {
            case ThunderStatus.initial:
              context.read<ThunderBloc>().add(const ThemeChangeEvent(themeType: ThemeType.black));
              return const Material(child: Center(child: CircularProgressIndicator()));
            case ThunderStatus.loading:
              return const Material(child: Center(child: CircularProgressIndicator()));
            case ThunderStatus.success:
              return MaterialApp.router(
                title: 'Thunder',
                routerConfig: router,
                theme: ThemeData.dark(useMaterial3: true),
                debugShowCheckedModeBanner: false,
              );
            case ThunderStatus.failure:
              return const Material(child: Center(child: CircularProgressIndicator()));
          }
=======
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
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
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
        },
      ),
    );
  }
}
