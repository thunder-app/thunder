import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/settings/presentation/utils/local_setting_localization.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

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

    return ThunderExpandableOption(
      leading: Icon(icon),
      title: name,
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
                disabledBackgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.errorContainer).withValues(alpha: 0.5),
              ),
              onPressed: recentSuccess
                  ? null
                  : () async {
                      bool success = true;

                      for (MapEntry<LocalSettings, Object> entry in settingsToChange.entries) {
                        if (entry.value is bool) {
                          await const UserPreferencesStore().setSetting(entry.key, entry.value);
                        } else {
                          // This should never happen in production, since we should add support for any unsupported types
                          // before adding a profile containing those types.
                          success = false;
                          if (context.mounted) {
                            showThunderSnackbar(AppLocalizations.of(context)!.settingTypeNotSupported(entry.value.runtimeType));
                          }
                        }
                      }
                      if (context.mounted && success) {
                        showThunderSnackbar(AppLocalizations.of(context)!.profileAppliedSuccessfully(name));
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
