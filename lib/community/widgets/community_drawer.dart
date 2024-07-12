import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/moderator/view/report_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/feed/utils/community.dart';

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

    context.read<AccountBloc>().add(const GetAccountSubscriptions());
    context.read<AccountBloc>().add(const GetFavoritedCommunities());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    AuthState authState = context.watch<AuthBloc>().state;
    FeedState feedState = context.watch<FeedBloc>().state;

    AccountState accountState = context.watch<AccountBloc>().state;
    ThunderState thunderState = context.read<ThunderBloc>().state;

    AnonymousSubscriptionsBloc subscriptionsBloc = context.watch<AnonymousSubscriptionsBloc>();
    subscriptionsBloc.add(GetSubscribedCommunitiesEvent());

    bool isLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;

    List<Community> subscriptions = [];

    if (isLoggedIn) {
      Set<int> favoriteCommunityIds = accountState.favorites.map((cv) => cv.community.id).toSet();
      Set<int> moderatedCommunityIds = accountState.moderates.map((cmv) => cmv.community.id).toSet();

      List<CommunityView> filteredSubscriptions = accountState.subsciptions
          .where((CommunityView communityView) => !favoriteCommunityIds.contains(communityView.community.id) && !moderatedCommunityIds.contains(communityView.community.id))
          .toList();
      subscriptions = filteredSubscriptions.map((CommunityView communityView) => communityView.community).toList();
    } else {
      subscriptions = subscriptionsBloc.state.subscriptions;
    }

    return Drawer(
      width: min(MediaQuery.of(context).size.width * 0.85, 400.0),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPinnedHeader(child: UserDrawerItem(navigateToAccount: widget.navigateToAccount)),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const FeedDrawerItems(),
                  const FavoriteCommunities(),
                  const ModeratedCommunities(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 16, 8.0),
                    child: Text(l10n.subscriptions, style: theme.textTheme.titleSmall),
                  ),
                  if (subscriptions.isNotEmpty)
                    ...subscriptions.map(
                      (community) {
                        final bool isCommunitySelected = feedState.communityId == community.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: TextButton(
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
                                      sortType: authState.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderState.sortTypeForInstance,
                                      communityId: community.id,
                                      reset: true,
                                    ),
                                  );
                            },
                            child: CommunityItem(community: community, showFavoriteAction: isLoggedIn, isFavorite: false),
                          ),
                        );
                      },
                    ).toList() as List<Widget>,
                  if (subscriptions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
                      child: Text(
                        l10n.noSubscriptions,
                        style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                      ),
                    ),
                ],
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
    String? anonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1.0,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13.0, 16.0, 4.0, 0),
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
                    isLoggedIn ? authState.account?.instance ?? '' : anonymousInstance ?? '',
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
    ThunderState thunderState = context.read<ThunderBloc>().state;
    AccountState accountState = context.watch<AccountBloc>().state;

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
                  navigateToFeedPage(context, feedType: FeedType.general, postListingType: destination.listingType);
                },
                label: destination.label,
                icon: destination.icon,
              );
            },
          ).toList(),
        ),
        if (accountState.moderates.isNotEmpty || accountState.personView?.isAdmin == true)
          DrawerItem(
            label: l10n.report(2),
            onTap: () async {
              HapticFeedback.mediumImpact();
              ThunderBloc thunderBloc = context.read<ThunderBloc>();

              await Navigator.of(context).push(
                SwipeablePageRoute(
                  transitionDuration: thunderBloc.state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                  backGestureDetectionStartOffset: !kIsWeb && Platform.isAndroid ? 45 : 0,
                  backGestureDetectionWidth: 45,
                  canOnlySwipeFromEdge: true,
                  builder: (otherContext) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: feedBloc),
                        BlocProvider.value(value: thunderBloc),
                      ],
                      child: const ReportFeedPage(),
                    );
                  },
                ),
              );
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

    AuthState authState = context.watch<AuthBloc>().state;
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
                          sortType: authState.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderState.sortTypeForInstance,
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

class ModeratedCommunities extends StatelessWidget {
  const ModeratedCommunities({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    AuthState authState = context.watch<AuthBloc>().state;
    FeedState feedState = context.watch<FeedBloc>().state;
    AccountState accountState = context.watch<AccountBloc>().state;
    ThunderState thunderState = context.read<ThunderBloc>().state;

    List<CommunityModeratorView> moderatedCommunities = accountState.moderates;

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
                Community community = moderatedCommunities[index].community;

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
                            sortType: authState.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderState.sortTypeForInstance,
                            communityId: community.id,
                            reset: true,
                          ),
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
  final Widget? trailing;

  final bool disabled;
  final bool isSelected;

  const DrawerItem({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
    this.trailing,
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
                    if (trailing != null) ...[
                      const Spacer(),
                      trailing!,
                      const SizedBox(width: 16),
                    ]
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
        CommunityAvatar(community: community, radius: 16, thumbnailSize: 100, format: 'png'),
        const SizedBox(width: 16.0),
        Expanded(
          child: Tooltip(
            excludeFromSemantics: true,
            message: '${community.title}\n${generateCommunityFullName(
              context,
              community.name,
              community.title,
              fetchInstanceNameFromUrl(community.actorId),
            )}',
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
                onPressed: () async => await toggleFavoriteCommunity(context, community, isFavorite),
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  semanticLabel: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                ),
              )
            : Container(),
      ],
    );
  }
}
