import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/shared/divider.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';

class AppearanceSettingsPage extends StatelessWidget {
  final LocalSettings? settingToHighlight;

  const AppearanceSettingsPage({super.key, this.settingToHighlight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  onTap: () => GoRouter.of(context).push(
                    SETTINGS_APPEARANCE_THEMES_PAGE,
                    extra: [context.read<ThunderBloc>()],
                  ),
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
                  onTap: () => GoRouter.of(context).push(
                    SETTINGS_APPEARANCE_POSTS_PAGE,
                    extra: [context.read<ThunderBloc>()],
                  ),
                ),
                ListTile(
                  title: Text(l10n.comments),
                  leading: const Icon(Icons.comment_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => GoRouter.of(context).push(
                    SETTINGS_APPEARANCE_COMMENTS_PAGE,
                    extra: [context.read<ThunderBloc>()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
