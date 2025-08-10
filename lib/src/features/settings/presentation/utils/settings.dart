import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/shared/snackbar.dart';

/// Generates a link to a local setting.
///
/// The link generated is in the form of `thunder://setting-{settingName}`.
void shareSetting(BuildContext context, LocalSettings? setting, String description) {
  if (setting == null) return;

  final l10n = AppLocalizations.of(context)!;
  final path = '${l10n.getLocalSettingLocalization(setting.category.toString())} > ${l10n.getLocalSettingLocalization(setting.subCategory.toString())} > $description';

  Clipboard.setData(ClipboardData(text: '[Thunder Setting: $path](thunder://setting-${setting.name})'));
  showSnackbar('Setting link copied to clipboard!');
}
