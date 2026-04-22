import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/utils/check_github_update.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';

class SettingTopic {
  final String title;
  final IconData icon;
  final String path;

  SettingTopic({required this.title, required this.icon, required this.path});
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final topics = [
      SettingTopic(title: l10n.general, icon: Icons.settings, path: SETTINGS_GENERAL_PAGE),
      SettingTopic(title: l10n.filters, icon: Icons.filter_alt_rounded, path: SETTINGS_FILTERS_PAGE),
      SettingTopic(title: l10n.appearance, icon: Icons.color_lens_rounded, path: SETTINGS_APPEARANCE_PAGE),
      SettingTopic(title: l10n.gestures, icon: Icons.swipe, path: SETTINGS_GESTURES_PAGE),
      SettingTopic(title: l10n.video, icon: Icons.video_settings, path: SETTINGS_VIDEO_PAGE),
      SettingTopic(title: l10n.floatingActionButton, icon: Icons.settings_applications_rounded, path: SETTINGS_FAB_PAGE),
      SettingTopic(title: l10n.accessibility, icon: Icons.accessibility, path: SETTINGS_ACCESSIBILITY_PAGE),
      SettingTopic(title: l10n.account(0), icon: Icons.person_rounded, path: SETTINGS_ACCOUNT_PAGE),
      SettingTopic(title: l10n.userLabels, icon: Icons.label_rounded, path: SETTINGS_USER_LABELS_PAGE),
      SettingTopic(title: l10n.drafts, icon: Icons.article_rounded, path: SETTINGS_DRAFTS_PAGE),
      SettingTopic(title: l10n.about, icon: Icons.info_rounded, path: SETTINGS_ABOUT_PAGE),
      SettingTopic(title: l10n.debug, icon: Icons.developer_mode_rounded, path: SETTINGS_DEBUG_PAGE),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.settings), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0).copyWith(top: 16.0),
              child: FocusableActionDetector(
                onFocusChange: (focused) {
                  if (focused) {
                    FocusScope.of(context).unfocus();
                    searchController.clear();
                  }
                },
                child: SearchAnchor.bar(
                  searchController: searchController,
                  barHintText: l10n.search,
                  barElevation: const WidgetStatePropertyAll(0.0),
                  suggestionsBuilder: (BuildContext context, SearchController controller) {
                    final theme = Theme.of(context);

                    final query = controller.text.toLowerCase();
                    final settings = LocalSettings.values.where((item) => item.searchable && l10n.getLocalSettingLocalization(item.key).toLowerCase().contains(query)).toList();

                    settings.removeWhere((setting) => setting.key.isEmpty);
                    settings.sortBy((setting) => setting.key);

                    return List<ListTile>.generate(settings.length, (index) {
                      final setting = settings[index];
                      final key = l10n.getLocalSettingLocalization(setting.key);
                      final category = l10n.getLocalSettingLocalization(setting.category.toString());
                      final subCategory = l10n.getLocalSettingLocalization(setting.subCategory.toString());

                      return ListTile(
                        title: Text(key, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(setting.isPage ? l10n.settingsPage : "$category > $subCategory"),
                        onTap: () {
                          controller.closeView(null);
                          controller.clear();
                          navigateToSettingPage(context, setting);
                        },
                      );
                    });
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverList.list(
            children: topics
                .map(
                  (SettingTopic topic) => ListTile(
                    title: Text(topic.title),
                    leading: Icon(topic.icon),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (topic.path == SETTINGS_ABOUT_PAGE) {
                        navigateToSettingPage(context, LocalSettings.settingsPageAbout);
                      } else if (topic.path == SETTINGS_ACCOUNT_PAGE) {
                        navigateToSettingPage(context, LocalSettings.settingsPageAccount);
                      } else {
                        switch (topic.path) {
                          case SETTINGS_GENERAL_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageGeneral);
                            break;
                          case SETTINGS_FILTERS_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageFilters);
                            break;
                          case SETTINGS_APPEARANCE_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageAppearance);
                            break;
                          case SETTINGS_GESTURES_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageGestures);
                            break;
                          case SETTINGS_VIDEO_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageVideo);
                            break;
                          case SETTINGS_FAB_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageFloatingActionButton);
                            break;
                          case SETTINGS_ACCESSIBILITY_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageAccessibility);
                            break;
                          case SETTINGS_USER_LABELS_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageUserLabels);
                            break;
                          case SETTINGS_DRAFTS_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageDrafts);
                            break;
                          case SETTINGS_DEBUG_PAGE:
                            navigateToSettingPage(context, LocalSettings.settingsPageDebug);
                            break;
                        }
                      }
                    },
                  ),
                )
                .toList(),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Thunder ${getCurrentVersion(removeInternalBuildNumber: true)}'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
