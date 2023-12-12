import 'dart:math';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/models/favourite.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/global_context.dart';

class CommunityDrawer extends StatefulWidget {
  const CommunityDrawer({super.key, this.navigateToAccount});

  final Function()? navigateToAccount;

  @override
  State<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends State<CommunityDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: min(MediaQuery.of(context).size.width * 0.85, 400.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserDrawerItem(navigateToAccount: widget.navigateToAccount),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeedDrawerItems(),
                    FavoriteCommunities(),
                    SubscribedCommunities(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDrawerItem extends StatelessWidget {
  const UserDrawerItem({super.key, this.navigateToAccount});

  final Function()? navigateToAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    AuthState authState = context.watch<AuthBloc>().state;
    AccountState accountState = context.watch<AccountBloc>().state;

    bool isLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;
    String anonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance;

    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 16, 16, 0),
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: () => navigateToAccount?.call(),
        child: Row(
          children: [
            UserAvatar(
              person: isLoggedIn ? accountState.personView?.person : null,
              radius: 16.0,
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!isLoggedIn) ...[
                      Icon(
                        Icons.person_off_rounded,
                        color: theme.textTheme.bodyMedium?.color,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      isLoggedIn ? accountState.personView?.person.name ?? '' : l10n.anonymous,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Text(
                  isLoggedIn ? authState.account?.instance ?? '' : anonymousInstance,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              icon: Icon(
                Icons.more_vert_outlined,
                color: theme.textTheme.bodyMedium?.color,
                semanticLabel: l10n.openAccountSwitcher,
              ),
              onPressed: () => showProfileModalSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedDrawerItems extends StatelessWidget {
  const FeedDrawerItems({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    FeedState feedState = context.watch<FeedBloc>().state;
    ThunderState thunderState = context.read<ThunderBloc>().state;

    bool isLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
          child: Text(l10n.feed, style: theme.textTheme.titleSmall),
        ),
        Column(
          children: destinations.map(
            (Destination destination) {
              return DrawerItem(
                disabled: destination.listingType == ListingType.subscribed && isLoggedIn == false,
                isSelected: destination.listingType == feedState.postListingType,
                onTap: () {
                  Navigator.of(context).pop();
                  navigateToFeedPage(context, feedType: FeedType.general, postListingType: destination.listingType, sortType: thunderState.defaultSortType);
                },
                label: destination.label,
                icon: destination.icon,
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class FavoriteCommunities extends StatelessWidget {
  const FavoriteCommunities({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    FeedState feedState = context.watch<FeedBloc>().state;
    AccountState accountState = context.watch<AccountBloc>().state;
    ThunderState thunderState = context.read<ThunderBloc>().state;

    bool isLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;

    if (!isLoggedIn || accountState.favorites.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
          child: Text(l10n.favorites, style: theme.textTheme.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accountState.favorites.length,
            itemBuilder: (context, index) {
              Community community = accountState.favorites[index].community;
              bool isCommunitySelected = feedState.communityId == community.id;

              return TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: isCommunitySelected ? theme.colorScheme.primaryContainer.withOpacity(0.25) : Colors.transparent,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<FeedBloc>().add(
                        FeedFetchedEvent(
                          feedType: FeedType.community,
                          sortType: thunderState.defaultSortType,
                          communityId: community.id,
                          reset: true,
                        ),
                      );
                },
                child: CommunityItem(community: community, isFavorite: true),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SubscribedCommunities extends StatelessWidget {
  const SubscribedCommunities({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    FeedState feedState = context.watch<FeedBloc>().state;
    AccountState accountState = context.watch<AccountBloc>().state;
    ThunderState thunderState = context.read<ThunderBloc>().state;

    AnonymousSubscriptionsBloc subscriptionsBloc = context.watch<AnonymousSubscriptionsBloc>();
    subscriptionsBloc.add(GetSubscribedCommunitiesEvent());

    bool isLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;

    List<Community> subscriptions = [];

    if (isLoggedIn) {
      Set<int> favoriteCommunityIds = accountState.favorites.map((cv) => cv.community.id).toSet();

      List<CommunityView> filteredSubscriptions = accountState.subsciptions.where((CommunityView communityView) => !favoriteCommunityIds.contains(communityView.community.id)).toList();
      subscriptions = filteredSubscriptions.map((CommunityView communityView) => communityView.community).toList();
    } else {
      subscriptions = subscriptionsBloc.state.subscriptions;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
          child: Text(l10n.subscriptions, style: theme.textTheme.titleSmall),
        ),
        if (subscriptions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                Community community = subscriptions[index];

                final bool isCommunitySelected = feedState.communityId == community.id;

                return TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: isCommunitySelected ? theme.colorScheme.primaryContainer.withOpacity(0.25) : Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<FeedBloc>().add(
                          FeedFetchedEvent(
                            feedType: FeedType.community,
                            sortType: thunderState.defaultSortType,
                            communityId: community.id,
                            reset: true,
                          ),
                        );
                  },
                  child: CommunityItem(community: community, showFavoriteAction: isLoggedIn, isFavorite: false),
                );
              },
            ),
          ),
        ],
        if (subscriptions.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: Text(
              l10n.noSubscriptions,
              style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
            ),
          )
        ],
      ],
    );
  }
}

class Destination {
  const Destination(this.label, this.listingType, this.icon);

  final String label;
  final ListingType listingType;
  final IconData icon;
}

List<Destination> destinations = <Destination>[
  Destination(AppLocalizations.of(GlobalContext.context)!.subscriptions, ListingType.subscribed, Icons.view_list_rounded),
  Destination(AppLocalizations.of(GlobalContext.context)!.localPosts, ListingType.local, Icons.home_rounded),
  Destination(AppLocalizations.of(GlobalContext.context)!.allPosts, ListingType.all, Icons.grid_view_rounded),
];

class DrawerItem extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  final bool disabled;
  final bool isSelected;

  const DrawerItem({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.disabled = false,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: 56.0,
        child: Material(
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.25) : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            splashColor: disabled ? Colors.transparent : null,
            highlightColor: Colors.transparent,
            onTap: disabled ? null : onTap,
            customBorder: const StadiumBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const SizedBox(width: 16),
                    Icon(icon, color: disabled ? theme.dividerColor : null),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: disabled ? theme.textTheme.bodyMedium?.copyWith(color: theme.dividerColor) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityItem extends StatelessWidget {
  const CommunityItem({super.key, required this.community, this.showFavoriteAction = true, this.isFavorite = false});

  final Community community;
  final bool isFavorite;
  final bool showFavoriteAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        CommunityIcon(community: community, radius: 16),
        const SizedBox(width: 16.0),
        Expanded(
          child: Tooltip(
            excludeFromSemantics: true,
            message: '${community.title}\n${community.name} · ${fetchInstanceNameFromUrl(community.actorId)}',
            preferBelow: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  fetchInstanceNameFromUrl(community.actorId) ?? '',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        showFavoriteAction
            ? IconButton(
                onPressed: () async {
                  if (isFavorite) {
                    await Favorite.deleteFavorite(communityId: community.id);
                    if (context.mounted) context.read<AccountBloc>().add(GetFavoritedCommunities());
                    return;
                  }

                  Account? account = await fetchActiveProfileAccount();

                  Uuid uuid = const Uuid();
                  String id = uuid.v4().replaceAll('-', '').substring(0, 13);

                  Favorite favorite = Favorite(
                    id: id,
                    communityId: community.id,
                    accountId: account!.id,
                  );

                  await Favorite.insertFavorite(favorite);
                  if (context.mounted) context.read<AccountBloc>().add(GetFavoritedCommunities());
                },
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  semanticLabel: isFavorite ? l10n.addToFavorites : l10n.removeFromFavorites,
                ),
              )
            : Container(),
      ],
    );
  }
}
