import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/user_share.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/user/pages/user_settings_page.dart';
import 'package:thunder/utils/instance.dart';

/// Holds the app bar for the account page
class AccountPageAppBar extends StatefulWidget {
  const AccountPageAppBar({
    super.key,
    this.showAppBarTitle = true,
    this.showSaved = false,
    this.onToggleSaved,
  });

  /// Whether to show the app bar title
  final bool showAppBarTitle;

  /// Whether or not to show saved posts/comments
  final bool showSaved;

  /// Callback to show saved posts/comments
  final Function(bool showSaved)? onToggleSaved;

  @override
  State<AccountPageAppBar> createState() => _AccountPageAppBarState();
}

class _AccountPageAppBarState extends State<AccountPageAppBar> {
  /// The current person
  Person? person;

  Widget getLeadingWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      onPressed: () => showProfileModalSheet(context),
      icon: Icon(Icons.people_alt_rounded, semanticLabel: l10n.profiles),
      tooltip: l10n.profiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final thunderBloc = context.read<ThunderBloc>();
    final accountState = context.read<AccountBloc>().state;

    person = accountState.reload ? accountState.personView?.person : person;

    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      titleSpacing: 0.0,
      toolbarHeight: 70.0,
      surfaceTintColor: thunderBloc.state.hideTopBarOnScroll ? Colors.transparent : null,
      title: AccountAppBarTitle(visible: widget.showAppBarTitle),
      leading: getLeadingWidget(context),
      actions: [AccountAppBarUserActions(showSaved: widget.showSaved, onToggleSaved: widget.onToggleSaved)],
    );
  }
}

/// The title of the app bar for the account page
class AccountAppBarTitle extends StatelessWidget {
  const AccountAppBarTitle({super.key, this.visible = true});

  /// Whether to show the title. When the user scrolls down the title will be hidden
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedBloc = context.watch<FeedBloc>();
    final user = feedBloc.state.fullPersonView;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          user?.personView.person.displayName ?? user?.personView.person.name ?? '',
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          generateUserFullName(context, user?.personView.person.name, user?.personView.person.displayName, fetchInstanceNameFromUrl(user?.personView.person.actorId)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// The actions of the app bar for the account page
class AccountAppBarUserActions extends StatelessWidget {
  const AccountAppBarUserActions({super.key, this.showSaved = false, this.onToggleSaved});

  final bool showSaved;

  final void Function(bool showSaved)? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedBloc = context.read<FeedBloc>();

    return Row(
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onToggleSaved?.call(!showSaved);
          },
          icon: Icon(showSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, semanticLabel: l10n.saved),
        ),
        IconButton(
          onPressed: () {
            final AccountBloc accountBloc = context.read<AccountBloc>();
            final ThunderBloc thunderBloc = context.read<ThunderBloc>();
            final UserSettingsBloc userSettingsBloc = UserSettingsBloc();

            Navigator.of(context).push(
              SwipeablePageRoute(
                transitionDuration: thunderBloc.state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                canSwipe: Platform.isIOS || thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: accountBloc),
                    BlocProvider.value(value: thunderBloc),
                    BlocProvider.value(value: userSettingsBloc),
                  ],
                  child: const UserSettingsPage(),
                ),
              ),
            );
          },
          icon: Icon(
            Icons.settings_rounded,
            semanticLabel: AppLocalizations.of(context)!.accountSettings,
          ),
          tooltip: AppLocalizations.of(context)!.accountSettings,
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            ThunderPopupMenuItem(
                onTap: () {
                  HapticFeedback.mediumImpact();

                  showModalBottomSheet<void>(
                    showDragHandle: true,
                    context: context,
                    isScrollControlled: true,
                    builder: (builderContext) => SortPicker(
                      title: l10n.sortOptions,
                      onSelect: (selected) async => feedBloc.add(FeedChangeSortTypeEvent(selected.payload)),
                      previouslySelected: feedBloc.state.sortType,
                      minimumVersion: LemmyClient.instance.version,
                    ),
                  );
                },
                icon: Icons.sort,
                title: l10n.sortBy),
            ThunderPopupMenuItem(
              onTap: () => triggerRefresh(context),
              icon: Icons.refresh_rounded,
              title: l10n.refresh,
            ),
            ThunderPopupMenuItem(
              onTap: () => showUserShareSheet(context, feedBloc.state.fullPersonView!.personView),
              icon: Icons.share_rounded,
              title: l10n.share,
            ),
          ],
        ),
      ],
    );
  }
}
