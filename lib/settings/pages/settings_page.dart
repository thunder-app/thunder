import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/settings_utils.dart';

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
  final SearchController _searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<SettingTopic> topics = [
      SettingTopic(title: l10n.general, icon: Icons.settings, path: SETTINGS_GENERAL_PAGE),
      SettingTopic(title: l10n.filters, icon: Icons.filter_alt_rounded, path: SETTINGS_FILTERS_PAGE),
      SettingTopic(title: l10n.appearance, icon: Icons.color_lens_rounded, path: SETTINGS_APPEARANCE_PAGE),
      SettingTopic(title: l10n.gestures, icon: Icons.swipe, path: SETTINGS_GESTURES_PAGE),
      SettingTopic(title: l10n.video, icon: Icons.video_settings, path: SETTINGS_VIDEO_PAGE),
      SettingTopic(title: l10n.floatingActionButton, icon: Icons.settings_applications_rounded, path: SETTINGS_FAB_PAGE),
      SettingTopic(title: l10n.accessibility, icon: Icons.accessibility, path: SETTINGS_ACCESSIBILITY_PAGE),
      SettingTopic(title: l10n.account(0), icon: Icons.person_rounded, path: SETTINGS_ACCOUNT_PAGE),
      SettingTopic(title: l10n.about, icon: Icons.info_rounded, path: SETTINGS_ABOUT_PAGE),
      SettingTopic(title: l10n.debug, icon: Icons.developer_mode_rounded, path: SETTINGS_DEBUG_PAGE),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.settings),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FocusableActionDetector(
                onFocusChange: (focused) {
                  if (focused) {
                    FocusScope.of(context).unfocus();
                    _searchController.text = '';
                  }
                },
                child: SearchAnchor.bar(
                  searchController: _searchController,
                  barBackgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surfaceVariant),
                  barElevation: MaterialStateProperty.all(0),
                  barHintText: l10n.search,
                  suggestionsBuilder: (BuildContext context, SearchController controller) {
                    final List<LocalSettings> localSettings = LocalSettings.values
                        .where((item) =>
                            item.searchable &&
                            l10n.getLocalSettingLocalization(item.key).toLowerCase().contains(
                                  controller.text.toLowerCase(),
                                ))
                        .toSet()
                        .toList();

                    localSettings.removeWhere((setting) => setting.key.isEmpty);
                    localSettings.sortBy((setting) => setting.key);

                    return List<ListTile>.generate(
                        localSettings.length,
                        (index) => ListTile(
                              subtitle: Text(
                                  "${l10n.getLocalSettingLocalization(localSettings[index].category!.toString())} > ${l10n.getLocalSettingLocalization(localSettings[index].subCategory.toString())}"),
                              onTap: () {
                                navigateToSetting(context, localSettings[index]);
                                controller.closeView(null);
                                controller.clear();
                              },
                              title: Text(
                                l10n.getLocalSettingLocalization(localSettings[index].key),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ));
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              topics
                  .map((SettingTopic topic) => ListTile(
                        title: Text(topic.title),
                        leading: Icon(topic.icon),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => GoRouter.of(context).push(
                          topic.path,
                          extra: topic.path == SETTINGS_ABOUT_PAGE
                              ? [
                                  context.read<ThunderBloc>(),
                                  context.read<AccountBloc>(),
                                  context.read<AuthBloc>(),
                                ]
                              : [context.read<ThunderBloc>()],
                        ),
                      ))
                  .toList(),
            ),
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
