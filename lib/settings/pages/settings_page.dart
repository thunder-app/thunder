import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class SettingTopic {
  final String title;
  final IconData icon;
  final String path;

  SettingTopic({required this.title, required this.icon, required this.path});
}

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final List<SettingTopic> topics = [
    SettingTopic(title: 'General', icon: Icons.settings, path: '/settings/general'),
    SettingTopic(title: 'Theming', icon: Icons.text_fields, path: '/settings/themes'),
    SettingTopic(title: 'Gestures', icon: Icons.swipe, path: '/settings/gestures'),
    SettingTopic(title: 'About', icon: Icons.info_rounded, path: '/settings/about'),
    SettingTopic(title: 'Debug', icon: Icons.developer_mode_rounded, path: '/settings/debug'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        centerTitle: false,
        title: AutoSizeText('Settings', style: theme.textTheme.titleLarge),
        scrolledUnderElevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView(
            shrinkWrap: true,
            children: topics
                .map((topic) => ListTile(
                      title: Text(topic.title),
                      leading: Icon(topic.icon),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => GoRouter.of(context).push(topic.path, extra: context.read<ThunderBloc>()),
                    ))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: getCurrentVersion(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(child: Text('Thunder ${snapshot.data ?? 'N/A'}'));
                }
                return Container();
              },
            ),
          )
        ],
      ),
    );
  }
}
