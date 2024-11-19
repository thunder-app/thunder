import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/user_share.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
      child: IconButton(
        onPressed: () => showProfileModalSheet(context),
        icon: Icon(
          Icons.people_alt_rounded,
          semanticLabel: AppLocalizations.of(context)!.profiles,
        ),
        tooltip: AppLocalizations.of(context)!.profiles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thunderBloc = context.read<ThunderBloc>();
    final accountState = context.read<AccountBloc>().state;

    person = accountState.reload ? accountState.personView?.person : person;

    return SliverAppBar(
      pinned: true,
      floating: true,
      centerTitle: false,
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

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          getAppBarTitle(feedBloc.state),
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
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
          icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
          onPressed: () {
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
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
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
