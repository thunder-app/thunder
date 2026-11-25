import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/src/widgets/feedback/thunder_overlay.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/shell/legacy_ui_compatibility.dart';
import 'package:thunder/src/core/services/platform_detection_service.dart';
import 'package:thunder/src/core/services/preferences_store.dart';
import 'package:thunder/src/core/services/localization_service.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/settings/api.dart';

/// Pumps [child] inside a localized [MaterialApp] wired to [GlobalContext].
Future<void> pumpLocalizedWidget(WidgetTester tester, Widget child, {Locale? locale}) async {
  GlobalContext.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  await tester.pumpWidget(
    MaterialApp(
      scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
      navigatorKey: thunderNavigatorKey,
      locale: locale,
      localizationsDelegates: const [AppLocalizations.delegate, MaterialLocalizationsEo.delegate, CupertinoLocalizationsEo.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => LegacyUiCompatibility(child: child!),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

ProfileBloc createTestProfileBloc({required Account account, bool isLoggedIn = false}) {
  return ProfileBloc(
    account: account,
    instanceRepositoryFactory: (_) => throw UnimplementedError(),
    accountRepositoryFactory: (_) => throw UnimplementedError(),
    userRepositoryFactory: (_) => throw UnimplementedError(),
    platformDetectionService: _FakePlatformDetectionService(),
    localizationService: const TestLocalizationService(),
  )..emit(ProfileState(account: account, isLoggedIn: isLoggedIn));
}

Widget wrapWithProfileBloc({required Account account, required Widget child, bool isLoggedIn = false}) {
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
  Future<Map<String, dynamic>?> detectPlatform(String instance, {Duration? timeout}) async => null;
}
