import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

class Destination {
  const Destination(this.label, this.listingType, this.icon);

  final String label;
  final PostListingType listingType;
  final IconData icon;
}

const List<Destination> destinations = <Destination>[
  Destination('Subscriptions', PostListingType.subscribed, Icons.view_list_rounded),
  Destination('Local Posts', PostListingType.local, Icons.home_rounded),
  Destination('All Posts', PostListingType.all, Icons.grid_view_rounded),
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

class CommunityDrawer extends StatefulWidget {
  final PostListingType? currentPostListingType;
  final int? communityId;
  final String? communityName;
  final void Function()? navigateToAccount;

  const CommunityDrawer({
    super.key,
    this.currentPostListingType,
    this.communityId,
    this.communityName,
    this.navigateToAccount,
  });

  @override
  State<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends State<CommunityDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isLoggedIn = context.watch<AuthBloc>().state.isLoggedIn;
    ThunderState thunderState = context.read<ThunderBloc>().state;
    String anonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance;

    AccountStatus status = context.watch<AccountBloc>().state.status;
    AnonymousSubscriptionsBloc subscriptionsBloc = context.read<AnonymousSubscriptionsBloc>();
    subscriptionsBloc.add(GetSubscribedCommunitiesEvent());

    FeedBloc feedBloc = context.watch<FeedBloc>();

    return BlocConsumer<AnonymousSubscriptionsBloc, AnonymousSubscriptionsState>(
        listener: (c, s) {},
        builder: (context, state) {
          return Drawer(
            width: MediaQuery.of(context).size.width * 0.80,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 16, 16, 0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () => widget.navigateToAccount?.call(),
                      child: Row(
                        children: [
                          UserAvatar(
                            person: isLoggedIn ? context.read<AccountBloc>().state.personView?.person : null,
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
                                    isLoggedIn ? context.read<AccountBloc>().state.personView?.person.name ?? '' : AppLocalizations.of(context)!.anonymous,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Text(
                                isLoggedIn ? context.read<AccountBloc>().state.personView?.instanceHost ?? '' : anonymousInstance,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.more_vert_outlined,
                              color: theme.textTheme.bodyMedium?.color,
                              semanticLabel: AppLocalizations.of(context)!.openAccountSwitcher,
                            ),
                            onPressed: () => showProfileModalSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 16, 0),
                    child: Text('Feeds', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  Column(
                    children: destinations.map((Destination destination) {
                      return DrawerItem(
                        disabled: destination.listingType == PostListingType.subscribed && isLoggedIn == false,
                        isSelected: destination.listingType == feedBloc.state.postListingType,
                        onTap: () {
                          Navigator.of(context).pop();
                          navigateToFeedPage(context, feedType: FeedType.general, postListingType: destination.listingType, sortType: thunderState.defaultSortType);
                        },
                        label: destination.label,
                        icon: destination.icon,
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 16, 0),
                    child: Text(AppLocalizations.of(context)!.subscriptions, style: Theme.of(context).textTheme.titleSmall),
                  ),
                  (status != AccountStatus.success && status != AccountStatus.failure)
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ((isLoggedIn && context.read<AccountBloc>().state.subsciptions.isNotEmpty) || subscriptionsBloc.state.subscriptions.isNotEmpty)
                          ? (Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Scrollbar(
                                  controller: _scrollController,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _getSubscriptions(context).length,
                                        itemBuilder: (context, index) {
                                          CommunitySafe community = _getSubscriptions(context)[index];

                                          final bool isCommunitySelected = feedBloc.state.communityId == community.id;

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
                                            child: Row(
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
                                                          '${community.name} · ${fetchInstanceNameFromUrl(community.actorId)}',
                                                          style: theme.textTheme.bodyMedium,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ))
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
                              child: Text(
                                'No subscriptions',
                                style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                              ),
                            )
                ],
              ),
            ),
          );
        });
  }

  List<CommunitySafe> _getSubscriptions(BuildContext context) {
    if (context.read<AuthBloc>().state.isLoggedIn) {
      return context.read<AccountBloc>().state.subsciptions.map((e) => e.community).toList();
    }
    return context.read<AnonymousSubscriptionsBloc>().state.subscriptions;
  }
}
