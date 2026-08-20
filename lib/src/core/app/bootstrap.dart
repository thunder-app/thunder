import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/core/app/app_startup_gate.dart';
import 'package:thunder/src/core/shell/thunder_app.dart';
import 'package:thunder/src/core/state/app_startup_cubit.dart';
import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:thunder/src/features/session/api.dart';

/// Initializes Thunder, including setting up the database, user preferences, and session management.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enables edge-to-edge on older Android devices. Android 15 and up automatically enforces it.
  if (!kIsWeb && Platform.isAndroid) SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    BlocProvider<AppStartupCubit>(
      create: (context) => AppStartupCubit(taskRunner: runStartupTasks),
      child: AppStartupGate(
        builder: (context) => BlocProvider<SessionBloc>(create: (context) => createSessionBloc()..add(const SessionInitialized()), child: const ThunderApp()),
        onReady: () => clearImageCache(),
      ),
    ),
  );

  // Additional platform-specific setup
  if (!kIsWeb && Platform.isAndroid) FlutterDisplayMode.setHighRefreshRate();
}

Future<void> runStartupTasks() async {
  final appDatabase = initializeDatabase();

  await Future.wait([_initializePersistence(appDatabase), _loadCompatibilityCertificate()]);

  await performSharedPreferencesMigration();
}

Future<void> _initializePersistence(AppDatabase appDatabase) async {
  await Future.wait([performDatabaseIntegrityChecks(appDatabase), UserPreferences.instance.initialize()]);
}

Future<void> _loadCompatibilityCertificate() async {
  try {
    // Fixes an issue with older Android devices connecting to instances with LetsEncrypt certificates.
    // https://github.com/thunder-app/thunder/pull/1675
    final certificate = await PlatformAssetBundle().load('assets/ca/isrgrootx1.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(certificate.buffer.asUint8List());
  } catch (_) {
    // Continue if failed to load certificate.
  }
}
