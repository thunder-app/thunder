import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Debug'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug Settings',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              const Text('The following debug settings should only be used for troubleshooting purposes.'),
              const SizedBox(height: 32.0),
              TextButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.co_present_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      'Delete Local Preferences',
                      style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ],
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        'This will clear all your user preferences.\n\nDo you want to continue?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                            onPressed: () {
                              SharedPreferences.getInstance().then((prefs) async {
                                await prefs.clear();

                                if (context.mounted) {
                                  context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
                                }

                                showSnackbar(context, AppLocalizations.of(context)!.clearedUserPreferences);
                              });

                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Clear Preferences')),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.data_array_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      'Delete Local Database',
                      style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
                onPressed: () async {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'This action will remove the local database and will log you out of all your accounts.\n\nDo you want to continue?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                            onPressed: () async {
                              String path = join(await getDatabasesPath(), 'thunder.db');
                              await databaseFactory.deleteDatabase(path);
                              showSnackbar(context, AppLocalizations.of(context)!.clearedDatabase);
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            child: const Text('Clear Database')),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
