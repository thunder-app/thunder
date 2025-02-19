import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/shared/snackbar.dart';

void shareSetting(BuildContext context, LocalSettings? setting, String description) {
  if (setting == null) return;

  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final String settingPath = '${l10n.getLocalSettingLocalization(setting.category.toString())} > ${l10n.getLocalSettingLocalization(setting.subCategory.toString())} > $description';

  Clipboard.setData(ClipboardData(text: '[Thunder Setting: $settingPath](thunder://setting-${setting.name})'));
  showSnackbar('Setting link copied to clipboard!');
}
