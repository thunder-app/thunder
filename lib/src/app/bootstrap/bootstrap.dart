import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/app/shell/thunder_app.dart';
import 'package:thunder/src/app/bootstrap/preferences_migration.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/account/api.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Fixes an issue with older Android devices connecting to instances with LetsEncrypt certificates
    // https://github.com/thunder-app/thunder/pull/1675
    final certificate = await PlatformAssetBundle().load('assets/ca/isrgrootx1.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(certificate.buffer.asUint8List());
  } catch (_) {
    // Continue if failed to load certificate
  }

  // Enables edge-to-edge on older Android devices. Android 15 and up automatically enforces it.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize preferences and database
  await UserPreferences.instance.initialize();
  await performSharedPreferencesMigration();
  initializeDatabase();
  await performDatabaseIntegrityChecks();

  final account = await fetchActiveProfile();

  runApp(
    BlocProvider<ProfileBloc>(
      create: (context) => createProfileBloc(account)..add(InitializeAuth()),
      child: const ThunderApp(),
    ),
  );

  // Additional platform-specific setup
  if (!kIsWeb && Platform.isAndroid) FlutterDisplayMode.setHighRefreshRate();
  if (!kIsWeb && Platform.isIOS) DartPingIOS.register();

  await clearExtendedImageCache();
}
