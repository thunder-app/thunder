import 'package:flutter/material.dart';

import 'package:thunder/localizations/app_localizations.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/shared/divider.dart';
import 'package:thunder/utils/navigation.dart';

class AppearanceSettingsPage extends StatelessWidget {
  final LocalSettings? settingToHighlight;

  const AppearanceSettingsPage({super.key, this.settingToHighlight});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.appearance),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(l10n.theming),
                  leading: const Icon(Icons.text_fields),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAppearanceTheming),
                ),
              ],
            ),
          ),
          const ThunderDivider(sliver: true),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(l10n.posts),
                  leading: const Icon(Icons.splitscreen_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAppearancePosts),
                ),
                ListTile(
                  title: Text(l10n.comments),
                  leading: const Icon(Icons.comment_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAppearanceComments),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
