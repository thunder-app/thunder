import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/settings/pages/comment_appearance_settings_page.dart';
import 'package:thunder/settings/pages/post_appearance_settings_page.dart';
import 'package:thunder/settings/pages/theme_settings_page.dart';
import 'package:thunder/shared/divider.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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
                  onTap: () {
                    final ThunderBloc thunderBloc = context.read<ThunderBloc>();

                    Navigator.of(context).push(
                      SwipeablePageRoute(
                        transitionDuration: thunderBloc.state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                        canSwipe: Platform.isIOS || thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        builder: (context) => MultiBlocProvider(
                          providers: [BlocProvider.value(value: thunderBloc)],
                          child: const ThemeSettingsPage(),
                        ),
                      ),
                    );
                  },
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
                  onTap: () {
                    final ThunderBloc thunderBloc = context.read<ThunderBloc>();

                    Navigator.of(context).push(
                      SwipeablePageRoute(
                        transitionDuration: thunderBloc.state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                        canSwipe: Platform.isIOS || thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        builder: (context) => MultiBlocProvider(
                          providers: [BlocProvider.value(value: thunderBloc)],
                          child: const PostAppearanceSettingsPage(),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(l10n.comments),
                  leading: const Icon(Icons.comment_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    final ThunderBloc thunderBloc = context.read<ThunderBloc>();

                    Navigator.of(context).push(
                      SwipeablePageRoute(
                        transitionDuration: thunderBloc.state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                        canSwipe: Platform.isIOS || thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        builder: (context) => MultiBlocProvider(
                          providers: [BlocProvider.value(value: thunderBloc)],
                          child: const CommentAppearanceSettingsPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
