import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/l10n/generated/app_localizations_en.dart';

import 'package:thunder/src/foundation/config/global_context.dart';

abstract class LocalizationService {
  AppLocalizations get l10n;
}

/// The localization service for the app, using the global context
class ThunderLocalizationService implements LocalizationService {
  const ThunderLocalizationService();

  @override
  AppLocalizations get l10n => GlobalContext.l10n;
}

/// The localization service for testing, using a mock context
class TestLocalizationService implements LocalizationService {
  const TestLocalizationService();

  @override
  AppLocalizations get l10n => AppLocalizationsEn();
}
