import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(l10n.appearance),
            centerTitle: false,
            toolbarHeight: 70.0,
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
                    '/settings/appearance/themes',
                    extra: context.read<ThunderBloc>(),
                  ),
                ),
              ],
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
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(l10n.posts),
                  leading: const Icon(Icons.splitscreen_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => GoRouter.of(context).push(
                    '/settings/appearance/posts',
                    extra: context.read<ThunderBloc>(),
                  ),
                ),
                ListTile(
                  title: Text(l10n.comments),
                  leading: const Icon(Icons.comment_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => GoRouter.of(context).push(
                    '/settings/appearance/comments',
                    extra: context.read<ThunderBloc>(),
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
