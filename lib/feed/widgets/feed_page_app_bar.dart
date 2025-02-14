import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/feed/utils/community_share.dart';
import 'package:thunder/feed/utils/user_share.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/modlog/utils/navigate_modlog.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/convert.dart';

/// Holds the app bar for the feed page. The app bar actions changes depending on the type of feed (general, community, user)
class FeedPageAppBar extends StatefulWidget {
  const FeedPageAppBar({super.key, this.showAppBarTitle = true, this.scaffoldStateKey});

  /// Whether to show the app bar title
  final bool showAppBarTitle;

  /// The scaffold key of the parent scaffold holding the drawer.
  /// This is used to determine if we are in a pushed navigation stack.
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  @override
  State<FeedPageAppBar> createState() => _FeedPageAppBarState();
}

class _FeedPageAppBarState extends State<FeedPageAppBar> {
  Person? person;

  @override
  Widget build(BuildContext context) {
    final feedBloc = context.read<FeedBloc>();
    final thunderBloc = context.read<ThunderBloc>();
    final AuthState authState = context.read<AuthBloc>().state;
    final AccountState accountState = context.read<AccountBloc>().state;

    person = accountState.reload ? accountState.personView?.person : person;

    return SliverAppBar(
      pinned: !thunderBloc.state.hideTopBarOnScroll,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      surfaceTintColor: thunderBloc.state.hideTopBarOnScroll ? Colors.transparent : null,
      title: FeedAppBarTitle(visible: widget.showAppBarTitle),
      leadingWidth: widget.scaffoldStateKey != null && thunderBloc.state.useProfilePictureForDrawer && authState.isLoggedIn ? 50 : null,
      leading: feedBloc.state.status == FeedStatus.initial
          ? null
          : widget.scaffoldStateKey != null && thunderBloc.state.useProfilePictureForDrawer && authState.isLoggedIn
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Semantics(
                    label: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: UserAvatar(
                            person: person,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _openDrawerOrGoBack(context, feedBloc),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : IconButton(
                  icon: widget.scaffoldStateKey == null
                      ? (!kIsWeb && Platform.isIOS
                          ? Icon(
                              Icons.arrow_back_ios_new_rounded,
                              semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                            )
                          : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip))
                      : Icon(Icons.menu, semanticLabel: MaterialLocalizations.of(context).openAppDrawerTooltip),
                  onPressed: () => _openDrawerOrGoBack(context, feedBloc),
                ),
      actions: (feedBloc.state.status != FeedStatus.initial && feedBloc.state.status != FeedStatus.failureLoadingCommunity && feedBloc.state.status != FeedStatus.failureLoadingUser)
          ? [
              if (feedBloc.state.feedType == FeedType.general) const FeedAppBarGeneralActions(),
              if (feedBloc.state.feedType == FeedType.community) const FeedAppBarCommunityActions(),
              if (feedBloc.state.feedType == FeedType.user) const FeedAppBarUserActions(),
            ]
          : [],
    );
  }

  void _openDrawerOrGoBack(BuildContext context, FeedBloc feedBloc) {
    HapticFeedback.mediumImpact();
    (widget.scaffoldStateKey == null && (feedBloc.state.feedType == FeedType.community || feedBloc.state.feedType == FeedType.user))
        ? Navigator.of(context).maybePop()
        : widget.scaffoldStateKey?.currentState?.openDrawer();
  }
}

/// The title of the app bar. This shows the title (feed type, community, user) and the sort type
class FeedAppBarTitle extends StatelessWidget {
  const FeedAppBarTitle({super.key, this.visible = true});

  /// Whether to show the title. When the user scrolls down the title will be hidden
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

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
        subtitle: Row(
          children: [
            Icon(getSortIcon(feedBloc.state), size: 13),
            const SizedBox(width: 4),
            Text(getSortName(feedBloc.state)),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}

/// The actions of the app bar for the community feed.
class FeedAppBarCommunityActions extends StatelessWidget {
  const FeedAppBarCommunityActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final feedBloc = context.read<FeedBloc>();
    final thunderBloc = context.read<ThunderBloc>();

    return Row(
      children: [
        BlocConsumer<CommunityBloc, CommunityState>(
          listener: (context, state) {
            if (state.status == CommunityStatus.success && state.communityView != null) {
              feedBloc.add(FeedCommunityViewUpdatedEvent(communityView: state.communityView!));
            }
          },
          builder: (context, state) => IconButton(
            icon: Icon(
                switch (_getSubscriptionStatus(context)) {
                  SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                  SubscribedType.pending => Icons.pending_outlined,
                  SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                  _ => Icons.add_circle_outline_rounded,
                },
                semanticLabel: (_getSubscriptionStatus(context) == SubscribedType.notSubscribed) ? l10n.subscribe : l10n.unsubscribe),
            tooltip: switch (_getSubscriptionStatus(context)) {
              SubscribedType.notSubscribed => l10n.subscribe,
              SubscribedType.pending => l10n.unsubscribePending,
              SubscribedType.subscribed => l10n.unsubscribe,
              _ => null,
            },
            onPressed: () {
              if (thunderBloc.state.isFabOpen) thunderBloc.add(const OnFabToggle(false));

              HapticFeedback.mediumImpact();
              _onSubscribeIconPressed(context);
            },
          ),
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
            if (_getSubscriptionStatus(context) == SubscribedType.subscribed)
              ThunderPopupMenuItem(
                onTap: () async {
                  final Community community = context.read<FeedBloc>().state.fullCommunityView!.communityView.community;
                  bool isFavorite = _getFavoriteStatus(context);
                  await toggleFavoriteCommunity(context, community, isFavorite);
                },
                icon: _getFavoriteStatus(context) ? Icons.star_rounded : Icons.star_border_rounded,
                title: _getFavoriteStatus(context) ? l10n.removeFromFavorites : l10n.addToFavorites,
              ),
            if (feedBloc.state.fullCommunityView?.communityView.community.actorId != null)
              ThunderPopupMenuItem(
                onTap: () => showCommunityShareSheet(context, convertToCommunityView(feedBloc.state.fullCommunityView!.communityView)!),
                icon: Icons.share_rounded,
                title: l10n.share,
              ),
            if (feedBloc.state.fullCommunityView?.communityView != null)
              ThunderPopupMenuItem(
                onTap: () async {
                  final ThunderState state = context.read<ThunderBloc>().state;
                  final bool reduceAnimations = state.reduceAnimations;
                  final SearchBloc searchBloc = SearchBloc();

                  await Navigator.of(context).push(
                    SwipeablePageRoute(
                      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                      backGestureDetectionWidth: 45,
                      canOnlySwipeFromEdge: true,
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          // Create a new SearchBloc so it doesn't conflict with the main one
                          BlocProvider.value(value: searchBloc),
                          BlocProvider.value(value: thunderBloc),
                        ],
                        child: SearchPage(communityToSearch: convertToCommunityView(feedBloc.state.fullCommunityView!.communityView), isInitiallyFocused: true),
                      ),
                    ),
                  );
                },
                icon: Icons.search_rounded,
                title: l10n.search,
              ),
            ThunderPopupMenuItem(
              onTap: () async {
                await navigateToModlogPage(
                  context,
                  feedBloc: feedBloc,
                  communityId: feedBloc.state.fullCommunityView!.communityView.community.id,
                );
              },
              icon: Icons.shield_rounded,
              title: l10n.modlog,
            ),
          ],
        ),
      ],
    );
  }
}

/// The actions of the app bar for the user feed.
class FeedAppBarUserActions extends StatelessWidget {
  const FeedAppBarUserActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedBloc = context.read<FeedBloc>();

    return Row(
      children: [
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
            if (feedBloc.state.fullPersonView?.personView.person.actorId != null)
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

/// The actions of the app bar for the general feed.
class FeedAppBarGeneralActions extends StatelessWidget {
  const FeedAppBarGeneralActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedBloc = context.read<FeedBloc>();

    return Row(
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            triggerRefresh(context);
          },
          icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
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
          onOpened: () => HapticFeedback.mediumImpact(),
          itemBuilder: (context) => [
            ThunderPopupMenuItem(
              onTap: () async {
                HapticFeedback.mediumImpact();
                await navigateToModlogPage(context, feedBloc: feedBloc);
              },
              icon: Icons.shield_rounded,
              title: l10n.modlog,
            ),
          ],
        ),
      ],
    );
  }
}

/// Get the subscription status for the current user and community
/// The logic works for anonymous accounts and for logged in accounts
SubscribedType? _getSubscriptionStatus(BuildContext context) {
  final AuthBloc authBloc = context.read<AuthBloc>();
  final FeedBloc feedBloc = context.read<FeedBloc>();
  final AnonymousSubscriptionsBloc anonymousSubscriptionsBloc = context.read<AnonymousSubscriptionsBloc>();

  if (authBloc.state.isLoggedIn) {
    return feedBloc.state.fullCommunityView?.communityView.subscribed;
  }

  return anonymousSubscriptionsBloc.state.ids.contains(feedBloc.state.fullCommunityView?.communityView.community.id) ? SubscribedType.subscribed : SubscribedType.notSubscribed;
}

/// Checks whether the current community is a favorite of the current user
bool _getFavoriteStatus(BuildContext context) {
  final AccountState accountState = context.read<AccountBloc>().state;
  final FeedBloc feedBloc = context.read<FeedBloc>();
  return accountState.favorites.any((communityView) => communityView.community.id == feedBloc.state.fullCommunityView!.communityView.community.id);
}

void _onSubscribeIconPressed(BuildContext context) async {
  final AuthBloc authBloc = context.read<AuthBloc>();
  final FeedBloc feedBloc = context.read<FeedBloc>();
  final FeedState feedState = feedBloc.state;

  final Community community = feedBloc.state.fullCommunityView!.communityView.community;
  final Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;

  final AppLocalizations l10n = AppLocalizations.of(context)!;

  if ((authBloc.state.isLoggedIn && feedState.fullCommunityView?.communityView.subscribed != SubscribedType.notSubscribed) || // If we're logged in and subscribed
      currentSubscriptions.contains(community.id)) // Or this is an anonymous subscription
  {
    bool result = false;

    await showThunderDialog<void>(
      context: context,
      title: l10n.confirm,
      contentText: l10n.confirmUnsubscription,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
      secondaryButtonText: l10n.cancel,
      onPrimaryButtonPressed: (dialogContext, _) async {
        Navigator.of(dialogContext).pop();
        result = true;
      },
      primaryButtonText: l10n.confirm,
    );

    if (!result) return;
  }

  if (authBloc.state.isLoggedIn) {
    context.read<CommunityBloc>().add(
          CommunityActionEvent(
            communityId: feedBloc.state.fullCommunityView!.communityView.community.id,
            communityAction: CommunityAction.follow,
            value: (feedState.fullCommunityView?.communityView.subscribed == SubscribedType.notSubscribed ? true : false),
          ),
        );
    return;
  }

  if (currentSubscriptions.contains(community.id)) {
    context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(ids: {community.id}));
    showSnackbar(AppLocalizations.of(context)!.unsubscribed);
  } else {
    context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {community}));
    showSnackbar(AppLocalizations.of(context)!.subscribed);
  }
}
