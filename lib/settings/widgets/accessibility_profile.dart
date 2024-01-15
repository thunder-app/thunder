import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/expandable_option.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingProfile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final Map<LocalSettings, Object> settingsToChange;

  const SettingProfile({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.settingsToChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    bool recentSuccess = false;

    return ExpandableOption(
      icon: icon,
      description: name,
      child: Column(
        children: [
          Text(description),
          ...settingsToChange.entries.map(
            (entry) {
              return Row(
                children: [
                  Text('• ${l10n.getLocalSettingLocalization(entry.key.key)}'),
                  const Icon(Icons.arrow_right_rounded, size: 20),
                  Text(_humanizeValue(context, entry.value)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          StatefulBuilder(
            builder: (context, setState) => TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                backgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.errorContainer),
                disabledBackgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.errorContainer).withOpacity(0.5),
              ),
              onPressed: recentSuccess
                  ? null
                  : () async {
                      bool success = true;
                      final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

                      for (MapEntry<LocalSettings, Object> entry in settingsToChange.entries) {
                        if (entry.value is bool) {
                          await prefs.setBool(entry.key.name, entry.value as bool);
                        } else {
                          // This should never happen in production, since we should add support for any unsupported types
                          // before adding a profile containing those types.
                          success = false;
                          if (context.mounted) {
                            showSnackbar(context, AppLocalizations.of(context)!.settingTypeNotSupported(entry.value.runtimeType));
                          }
                        }
                      }
                      if (context.mounted && success) {
                        showSnackbar(context, AppLocalizations.of(context)!.profileAppliedSuccessfully(name));
                        setState(() => recentSuccess = true);
                        Future.delayed(const Duration(seconds: 5), () async {
                          setState(() => recentSuccess = false);
                        });
                      }
                    },
              child: recentSuccess ? Text(AppLocalizations.of(context)!.applied) : Text(AppLocalizations.of(context)!.apply),
            ),
          ),
        ],
      ),
    );
  }

  String _humanizeValue(BuildContext context, Object value) {
    if (value is bool) {
      return value ? AppLocalizations.of(context)!.on : AppLocalizations.of(context)!.off;
    }

    return value.toString();
  }
}
