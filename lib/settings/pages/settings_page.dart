import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class SettingTopic {
  final String title;
  final IconData icon;
  final String path;

  SettingTopic({required this.title, required this.icon, required this.path});
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<SettingTopic> topics = [
      SettingTopic(title: l10n.general, icon: Icons.settings, path: '/settings/general'),
      SettingTopic(title: l10n.appearance, icon: Icons.color_lens_rounded, path: '/settings/appearance'),
      SettingTopic(title: l10n.gestures, icon: Icons.swipe, path: '/settings/gestures'),
      SettingTopic(title: l10n.floatingActionButton, icon: Icons.settings_applications_rounded, path: '/settings/fab'),
      SettingTopic(title: l10n.accessibility, icon: Icons.accessibility, path: '/settings/accessibility'),
      SettingTopic(title: l10n.about, icon: Icons.info_rounded, path: '/settings/about'),
      SettingTopic(title: l10n.debug, icon: Icons.developer_mode_rounded, path: '/settings/debug'),
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
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              topics
                  .map((SettingTopic topic) => ListTile(
                        title: Text(topic.title),
                        leading: Icon(topic.icon),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => GoRouter.of(context).push(
                          topic.path,
                          extra: topic.path == '/settings/about'
                              ? [
                                  context.read<ThunderBloc>(),
                                  context.read<AccountBloc>(),
                                  context.read<AuthBloc>(),
                                ]
                              : context.read<ThunderBloc>(),
                        ),
                      ))
                  .toList(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: getCurrentVersion(removeInternalBuildNumber: true),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Thunder ${snapshot.data ?? 'N/A'}',
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
