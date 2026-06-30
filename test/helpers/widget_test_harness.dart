import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/contracts/platform_detection_service.dart';
import 'package:thunder/src/foundation/contracts/preferences_store.dart';
import 'package:thunder/src/foundation/services/localization_service.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/settings/api.dart';

/// Pumps [child] inside a localized [MaterialApp] wired to [GlobalContext].
Future<void> pumpLocalizedWidget(WidgetTester tester, Widget child) async {
  GlobalContext.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  await tester.pumpWidget(
    MaterialApp(
      scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

ProfileBloc createTestProfileBloc({
  required Account account,
  bool isLoggedIn = false,
}) {
  return ProfileBloc(
    account: account,
    instanceRepositoryFactory: (_) => throw UnimplementedError(),
    accountRepositoryFactory: (_) => throw UnimplementedError(),
    userRepositoryFactory: (_) => throw UnimplementedError(),
    platformDetectionService: _FakePlatformDetectionService(),
    localizationService: const TestLocalizationService(),
  )..emit(ProfileState(account: account, isLoggedIn: isLoggedIn));
}

Widget wrapWithProfileBloc({
  required Account account,
  required Widget child,
  bool isLoggedIn = false,
}) {
  return BlocProvider<ProfileBloc>(
    create: (_) => createTestProfileBloc(account: account, isLoggedIn: isLoggedIn),
    child: child,
  );
}

Widget wrapWithThemePreferences(Widget child) {
  return BlocProvider<ThemePreferencesCubit>(
    create: (_) => ThemePreferencesCubit(preferencesStore: const UserPreferencesStore()),
    child: child,
  );
}

class _FakePlatformDetectionService implements PlatformDetectionService {
  @override
  Future<Map<String, dynamic>?> detectPlatform(String instance) async => null;
}
