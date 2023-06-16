import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:thunder/routes.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  String? SENTRY_DSN = dotenv.env['SENTRY_DSN'];

  if (SENTRY_DSN != null) {
    await SentryFlutter.init(
      (options) {
        options.dsn = kDebugMode ? '' : SENTRY_DSN;
        options.debug = kDebugMode;
        options.tracesSampleRate = 1.0;
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
        },
      ),
    );
  }
}
