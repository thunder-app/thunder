import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.debug),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.resetPreferencesAndData, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8.0),
                  Text(
                    l10n.debugDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SettingsListTile(
                icon: Icons.co_present_rounded,
                description: l10n.deleteLocalPreferences,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () async {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.deleteLocalPreferences),
                      content: Text(l10n.deleteLocalPreferencesDescription),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            SharedPreferences.getInstance().then((prefs) async {
                              await prefs.clear();

                              if (context.mounted) {
                                context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
                                showSnackbar(context, AppLocalizations.of(context)!.clearedUserPreferences);
                              }
                            });

                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(l10n.clearPreferences),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SettingsListTile(
                icon: Icons.data_array_rounded,
                description: l10n.deleteLocalDatabase,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () async {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteLocalDatabase),
                      content: Text(l10n.deleteLocalDatabaseDescription),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () async {
                            String path = join(await getDatabasesPath(), 'thunder.db');
                            await databaseFactory.deleteDatabase(path);

                            if (context.mounted) {
                              showSnackbar(context, AppLocalizations.of(context)!.clearedDatabase);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(l10n.clearDatabase),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
