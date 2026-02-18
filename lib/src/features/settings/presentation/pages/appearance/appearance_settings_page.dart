import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderDivider;

class AppearanceSettingsPage extends StatelessWidget {
  final LocalSettings? settingToHighlight;

  const AppearanceSettingsPage({super.key, this.settingToHighlight});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.appearance), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              SizedBox(height: 16.0),
              ListTile(
                title: Text(l10n.theming),
                leading: const Icon(Icons.text_fields),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAppearanceTheming),
              ),
              const ThunderDivider(sliver: false),
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
        ],
      ),
    );
  }
}
