import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/localizations/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';

/// Holds the app bar for the account page
class AccountPageAppBar extends StatelessWidget {
  const AccountPageAppBar({super.key, this.showAppBarTitle = true});

  /// Whether to show the app bar title
  final bool showAppBarTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<ThunderBloc>().state;

    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      titleSpacing: 0.0,
      toolbarHeight: 70.0,
      surfaceTintColor: state.hideTopBarOnScroll ? Colors.transparent : null,
      title: AccountAppBarTitle(visible: showAppBarTitle),
      leading: IconButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          showProfileModalSheet(context);
        },
        icon: Icon(Icons.people_alt_rounded, semanticLabel: l10n.profiles),
        tooltip: l10n.profiles,
      ),
      actions: [AccountAppBarUserActions()],
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
    final person = feedBloc.state.fullPersonView?.personView.person;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          person?.displayName ?? person?.name ?? '',
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          generateUserFullName(context, person?.name, person?.displayName, fetchInstanceNameFromUrl(person?.actorId)),
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
  const AccountAppBarUserActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
          tooltip: l10n.refresh,
          onPressed: () {
            HapticFeedback.mediumImpact();
            triggerRefresh(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.settings_rounded, semanticLabel: l10n.accountSettings),
          tooltip: l10n.accountSettings,
          onPressed: () {
            HapticFeedback.mediumImpact();
            navigateToSettingPage(context, LocalSettings.settingsPageAccount);
          },
        ),
      ],
    );
  }
}
