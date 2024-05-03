import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/notification/shared/notification_server.dart';

import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/utils/cache.dart';

class DebugSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const DebugSettingsPage({super.key, this.settingToHighlight});

  @override
  State<DebugSettingsPage> createState() => _DebugSettingsPageState();
}

class _DebugSettingsPageState extends State<DebugSettingsPage> {
  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.settingToHighlight != null) {
        setState(() => settingToHighlight = widget.settingToHighlight);

        // Need some delay to finish building, even though we're in a post-frame callback.
        Timer(const Duration(milliseconds: 500), () {
          if (settingToHighlightKey.currentContext != null) {
            // Ensure that the selected setting is visible on the screen
            Scrollable.ensureVisible(
              settingToHighlightKey.currentContext!,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }

          // Give time for the highlighting to appear, then turn it off
          Timer(const Duration(seconds: 1), () {
            setState(() => settingToHighlight = null);
          });
        });
      }
    });
  }

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
            child: SettingsListTile(
              icon: Icons.co_present_rounded,
              description: l10n.deleteLocalPreferences,
              widget: const SizedBox(
                height: 42.0,
                child: Icon(Icons.chevron_right_rounded),
              ),
              onTap: () async {
                showThunderDialog<void>(
                  context: context,
                  title: l10n.deleteLocalPreferences,
                  contentText: l10n.deleteLocalPreferencesDescription,
                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                  secondaryButtonText: l10n.cancel,
                  onPrimaryButtonPressed: (dialogContext, _) {
                    SharedPreferences.getInstance().then((prefs) async {
                      await prefs.clear();

                      if (context.mounted) {
                        context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
                        showSnackbar(AppLocalizations.of(context)!.clearedUserPreferences);
                      }
                    });

                    Navigator.of(dialogContext).pop();
                  },
                  primaryButtonText: l10n.clearPreferences,
                );
              },
              highlightKey: settingToHighlightKey,
              setting: null,
              highlightedSetting: settingToHighlight,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
          SliverToBoxAdapter(
            child: SettingsListTile(
              icon: Icons.data_array_rounded,
              description: l10n.deleteLocalDatabase,
              widget: const SizedBox(
                height: 42.0,
                child: Icon(Icons.chevron_right_rounded),
              ),
              onTap: () async {
                showThunderDialog<void>(
                  context: context,
                  title: l10n.deleteLocalDatabase,
                  contentText: l10n.deleteLocalDatabaseDescription,
                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                  secondaryButtonText: l10n.cancel,
                  onPrimaryButtonPressed: (dialogContext, _) async {
                    String path = join(await getDatabasesPath(), 'thunder.db');

                    final dbFolder = await getApplicationDocumentsDirectory();
                    final file = File(join(dbFolder.path, 'thunder.sqlite'));

                    await databaseFactory.deleteDatabase(file.path);

                    if (context.mounted) {
                      showSnackbar(AppLocalizations.of(context)!.clearedDatabase);
                      Navigator.of(context).pop();
                    }
                  },
                  primaryButtonText: l10n.clearDatabase,
                );
              },
              highlightKey: settingToHighlightKey,
              setting: null,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              indent: 32.0,
              height: 32.0,
              endIndent: 32.0,
              thickness: 2.0,
              color: theme.dividerColor.withOpacity(0.6),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<int>(
              future: getExtendedImageCacheSize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SettingsListTile(
                    icon: Icons.data_saver_off_rounded,
                    description: l10n.clearCache('${(snapshot.data! / (1024 * 1024)).toStringAsFixed(2)} MB'),
                    widget: const SizedBox(
                      height: 42.0,
                      child: Icon(Icons.chevron_right_rounded),
                    ),
                    onTap: () async {
                      await clearDiskCachedImages();
                      if (context.mounted) showSnackbar(l10n.clearedCache);
                      setState(() {}); // Trigger a rebuild to refresh the cache size
                    },
                    highlightKey: settingToHighlightKey,
                    setting: null,
                    highlightedSetting: settingToHighlight,
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
