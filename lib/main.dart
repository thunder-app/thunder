import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thunder/core/enums/theme_type.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/thunder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  runApp(const ThunderApp());
}

class ThunderApp extends StatelessWidget {
  const ThunderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThunderBloc(),
      child: BlocBuilder<ThunderBloc, ThunderState>(
        builder: (context, state) {
          switch (state.status) {
            case ThunderStatus.initial:
              context.read<ThunderBloc>().add(ThemeChangeEvent(themeType: ThemeType.black));
              return const Material(child: Center(child: CircularProgressIndicator()));
            case ThunderStatus.loading:
              return const Material(child: Center(child: CircularProgressIndicator()));
            case ThunderStatus.success:
              return MaterialApp(
                title: 'Thunder',
                // theme: state.theme,
                theme: ThemeData.dark(
                  useMaterial3: true,
                ),
                debugShowCheckedModeBanner: false,
                home: const Thunder(),
              );
            case ThunderStatus.failure:
              return const Material(child: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
