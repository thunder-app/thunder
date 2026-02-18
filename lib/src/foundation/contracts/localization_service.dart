import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

abstract class LocalizationService {
  AppLocalizations get l10n;
}

class GlobalContextLocalizationService implements LocalizationService {
  const GlobalContextLocalizationService();

  @override
  AppLocalizations get l10n => GlobalContext.l10n;
}
