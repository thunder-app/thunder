import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';

class CommunityDrawer extends StatefulWidget {
  const CommunityDrawer({super.key, this.navigateToAccount});

  final Function()? navigateToAccount;

  @override
  State<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends State<CommunityDrawer> {
  @override
  void initState() {
    super.initState();

    context.read<ProfileBloc>().add(const FetchProfileSubscriptions());
    context.read<ProfileBloc>().add(const FetchProfileFavorites());
    context.read<AnonymousSubscriptionsCubit>().loadSubscribedCommunities();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ProfileState profileState = context.watch<ProfileBloc>().state;
    FeedState feedState = context.watch<FeedBloc>().state;

    final feedCubit = context.read<FeedPreferencesCubit>();

    final subscriptionsCubit = context.watch<AnonymousSubscriptionsCubit>();

    bool isLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;

    List<ThunderCommunity> subscriptions = [];

    if (isLoggedIn) {
      final favoriteCommunityIds = profileState.favorites.map((community) => community.id).toSet();
      final moderatedCommunityIds = profileState.moderates.map((community) => community.id).toSet();
      final filteredSubscriptions = profileState.subscriptions.where((community) => !favoriteCommunityIds.contains(community.id) && !moderatedCommunityIds.contains(community.id)).toList();

      subscriptions = filteredSubscriptions;
    } else {
      subscriptions = subscriptionsCubit.state.subscriptions;
    }

    return Drawer(
      width: min(MediaQuery.of(context).size.width * 0.85, 400.0),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            PinnedHeaderSliver(child: UserDrawerItem(navigateToAccount: widget.navigateToAccount)),
            SliverList.list(
              children: [
                const FeedDrawerItems(),
                const FavoriteCommunities(),
                const ModeratedCommunities(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
                  child: Text(l10n.subscriptions, style: theme.textTheme.titleSmall),
                ),
                if (subscriptions.isNotEmpty)
                  ...subscriptions.map<Widget>((ThunderCommunity community) {
                    final bool isCommunitySelected = feedState.communityId == community.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: isCommunitySelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25) : Colors.transparent,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();

                          final postSortType = profileState.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType;

                          context.read<FeedBloc>().add(
                            FeedFetchedEvent(
                              feedType: FeedType.community,
                              postSortType: postSortType,
                              communityId: isLoggedIn ? community.id : null,
                              communityName: !isLoggedIn ? await getLemmyCommunity(community.actorId) : null,
                              reset: true,
                              showHidden: feedCubit.state.showHiddenPosts,
                            ),
                          );
                        },
                        child: CommunityItem(community: community, showFavoriteAction: isLoggedIn, isFavorite: false),
                      ),
                    );
                  }),
                if (subscriptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
                    child: Text(l10n.noSubscriptions, style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor)),
                  ),
              ],
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

    ProfileState profileState = context.watch<ProfileBloc>().state;

    bool isLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(13.0, 16.0, 4.0, 0),
      child: TextButton(
        style: TextButton.styleFrom(alignment: Alignment.centerLeft, minimumSize: const Size.fromHeight(50)),
        onPressed: () => navigateToAccount?.call(),
        child: Row(
          children: [
            if (profileState.user != null) UserAvatar(user: profileState.user!, radius: 16.0),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!isLoggedIn) ...[Icon(Icons.person_off_rounded, color: theme.textTheme.bodyMedium?.color, size: 15), const SizedBox(width: 5)],
                    Text(
                      isLoggedIn ? profileState.user?.name ?? '' : l10n.anonymous,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Text(profileState.account.instance, style: theme.textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              icon: Icon(Icons.more_vert_outlined, color: theme.textTheme.bodyMedium?.color, semanticLabel: l10n.openAccountSwitcher),
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
    final feedBloc = context.watch<FeedBloc>();

    FeedState feedState = feedBloc.state;
    ProfileState profileState = context.watch<ProfileBloc>().state;

    bool isLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
          child: Text(l10n.feed, style: theme.textTheme.titleSmall),
        ),
        Column(
          children: destinations.map((Destination destination) {
            return DrawerItem(
              disabled: destination.listingType == FeedListType.subscribed && isLoggedIn == false,
              isSelected: destination.listingType == feedState.feedListType,
              onTap: () {
                Navigator.of(context).pop();
                navigateToFeedPage(context, feedType: FeedType.general, feedListType: destination.listingType);
              },
              label: destination.label,
              icon: destination.icon,
            );
          }).toList(),
        ),
        if (profileState.moderates.isNotEmpty || profileState.user?.context.isAdmin == true)
          DrawerItem(
            label: l10n.report(2),
            onTap: () {
              HapticFeedback.mediumImpact();
              navigateToReportPage(context);
            },
            icon: Icons.report_rounded,
            trailing: const Icon(Icons.arrow_forward_rounded),
            disabled: false,
            isSelected: false,
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

    ProfileState profileState = context.watch<ProfileBloc>().state;
    FeedState feedState = context.watch<FeedBloc>().state;
    final feedCubit = context.read<FeedPreferencesCubit>();

    bool isLoggedIn = context.watch<ProfileBloc>().state.isLoggedIn;

    if (!isLoggedIn || profileState.favorites.isEmpty) return Container();

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
            itemCount: profileState.favorites.length,
            itemBuilder: (context, index) {
              final community = profileState.favorites[index];
              final isCommunitySelected = feedState.communityId == community.id;

              return TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: isCommunitySelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25) : Colors.transparent,
                ),
                onPressed: () {
                  Navigator.of(context).pop();

                  final postSortType = profileState.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType;

                  context.read<FeedBloc>().add(
                    FeedFetchedEvent(feedType: FeedType.community, postSortType: postSortType, communityId: community.id, reset: true, showHidden: feedCubit.state.showHiddenPosts),
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

class ModeratedCommunities extends StatelessWidget {
  const ModeratedCommunities({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ProfileState profileState = context.watch<ProfileBloc>().state;
    FeedState feedState = context.watch<FeedBloc>().state;
    final feedCubit = context.read<FeedPreferencesCubit>();

    List<ThunderCommunity> moderatedCommunities = profileState.moderates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (moderatedCommunities.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
            child: Text(l10n.moderatedCommunities, style: theme.textTheme.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: moderatedCommunities.length,
              itemBuilder: (context, index) {
                final community = moderatedCommunities[index];
                final isCommunitySelected = feedState.communityId == community.id;

                return TextButton(
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: isCommunitySelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25) : Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    final postSortType = profileState.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType;

                    context.read<FeedBloc>().add(
                      FeedFetchedEvent(feedType: FeedType.community, postSortType: postSortType, communityId: community.id, reset: true, showHidden: feedCubit.state.showHiddenPosts),
                    );
                  },
                  child: CommunityItem(community: community, showFavoriteAction: false, isFavorite: false),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class Destination {
  const Destination(this.label, this.listingType, this.icon);

  final String label;
  final FeedListType listingType;
  final IconData icon;
}

List<Destination> destinations = <Destination>[
  Destination(AppLocalizations.of(GlobalContext.context)!.subscriptions, FeedListType.subscribed, Icons.view_list_rounded),
  Destination(AppLocalizations.of(GlobalContext.context)!.localPosts, FeedListType.local, Icons.home_rounded),
  Destination(AppLocalizations.of(GlobalContext.context)!.allPosts, FeedListType.all, Icons.grid_view_rounded),
];

class DrawerItem extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Widget? trailing;

  final bool disabled;
  final bool isSelected;

  const DrawerItem({super.key, required this.onTap, required this.label, required this.icon, this.trailing, this.disabled = false, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: 56.0,
        child: Material(
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25) : Colors.transparent,
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
                    Text(label, style: disabled ? theme.textTheme.bodyMedium?.copyWith(color: theme.dividerColor) : null),
                    if (trailing != null) ...[const Spacer(), trailing!, const SizedBox(width: 16)],
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

  final ThunderCommunity community;
  final bool isFavorite;
  final bool showFavoriteAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        CommunityAvatar(community: community, radius: 16, thumbnailSize: 100, format: 'png'),
        const SizedBox(width: 16.0),
        Expanded(
          child: Tooltip(
            excludeFromSemantics: true,
            message: '${community.title}\n${generateCommunityFullName(context, community.name, community.title, fetchInstanceNameFromUrl(community.actorId))}',
            preferBelow: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(community.title, overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(fetchInstanceNameFromUrl(community.actorId) ?? '', style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
        showFavoriteAction
            ? IconButton(
                onPressed: () async => await toggleFavoriteCommunity(context, community, isFavorite),
                icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded, size: 24, semanticLabel: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites),
              )
            : Container(),
      ],
    );
  }
}
