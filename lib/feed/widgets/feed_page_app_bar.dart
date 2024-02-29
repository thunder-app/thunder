import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';

import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/modlog/view/modlog_page.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

class FeedPageAppBar extends StatelessWidget {
  const FeedPageAppBar({super.key, this.showAppBarTitle = true, this.scaffoldStateKey});

  /// Whether to show the app bar title
  final bool showAppBarTitle;

  /// The scaffold key of the parent scaffold holding the drawer.
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final ThunderBloc thunderBloc = context.read<ThunderBloc>();
    final FeedBloc feedBloc = context.read<FeedBloc>();
    final FeedState feedState = feedBloc.state;

    return SliverAppBar(
      pinned: !thunderBloc.state.hideTopBarOnScroll,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      surfaceTintColor: thunderBloc.state.hideTopBarOnScroll ? Colors.transparent : null,
      title: FeedAppBarTitle(visible: showAppBarTitle),
      leading: IconButton(
        icon: scaffoldStateKey == null
            ? (!kIsWeb && Platform.isIOS
                ? Icon(
                    Icons.arrow_back_ios_new_rounded,
                    semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip))
            : Icon(Icons.menu, semanticLabel: MaterialLocalizations.of(context).openAppDrawerTooltip),
        onPressed: () {
          HapticFeedback.mediumImpact();
          (scaffoldStateKey == null && feedBloc.state.feedType == FeedType.community) ? Navigator.of(context).maybePop() : scaffoldStateKey?.currentState?.openDrawer();
        },
      ),
      actions: feedState.status != FeedStatus.failureLoadingCommunity
          ? [
              if (feedState.feedType == FeedType.community) ...[
                BlocListener<CommunityBloc, CommunityState>(
                  listener: (context, state) {
                    if (state.status == CommunityStatus.success && state.communityView != null) {
                      feedBloc.add(FeedCommunityViewUpdatedEvent(communityView: state.communityView!));
                    }
                  },
                  child: IconButton(
                    icon: Icon(
                        switch (_getSubscriptionStatus(context)) {
                          SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                          SubscribedType.pending => Icons.pending_outlined,
                          SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                          _ => Icons.add_circle_outline_rounded,
                        },
                        semanticLabel: (_getSubscriptionStatus(context) == SubscribedType.notSubscribed) ? AppLocalizations.of(context)!.subscribe : AppLocalizations.of(context)!.unsubscribe),
                    tooltip: switch (_getSubscriptionStatus(context)) {
                      SubscribedType.notSubscribed => AppLocalizations.of(context)!.subscribe,
                      SubscribedType.pending => AppLocalizations.of(context)!.unsubscribePending,
                      SubscribedType.subscribed => AppLocalizations.of(context)!.unsubscribe,
                      _ => null,
                    },
                    onPressed: () {
                      if (thunderBloc.state.isFabOpen) thunderBloc.add(const OnFabToggle(false));

                      HapticFeedback.mediumImpact();
                      _onSubscribeIconPressed(context);
                    },
                  ),
                ),
              ],
              if (feedState.feedType != FeedType.community)
                IconButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      triggerRefresh(context);
                    },
                    icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh)),
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
                      onSelect: (selected) => feedBloc.add(FeedChangeSortTypeEvent(selected.payload)),
                      previouslySelected: feedBloc.state.sortType,
                    ),
                  );
                },
              ),
              if (feedState.feedType == FeedType.general)
                IconButton(
                  icon: Icon(Icons.shield_rounded, semanticLabel: l10n.sortBy),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();

                    AuthBloc authBloc = context.read<AuthBloc>();

                    ThunderBloc thunderBloc = context.read<ThunderBloc>();
                    final ThunderState state = context.read<ThunderBloc>().state;
                    final bool reduceAnimations = state.reduceAnimations;

                    await Navigator.of(context).push(
                      SwipeablePageRoute(
                        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                        backGestureDetectionStartOffset: !kIsWeb && Platform.isAndroid ? 45 : 0,
                        backGestureDetectionWidth: 45,
                        canOnlySwipeFromEdge:
                            disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: false) || !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                        builder: (otherContext) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: feedBloc),
                              BlocProvider.value(value: thunderBloc),
                            ],
                            child: const ModlogFeedPage(),
                          );
                        },
                      ),
                    );
                  },
                ),
              if (feedState.feedType == FeedType.community)
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
                        onTap: () => Share.share(feedBloc.state.fullCommunityView!.communityView.community.actorId),
                        icon: Icons.share_rounded,
                        title: l10n.share,
                      ),
                    if (feedBloc.state.fullCommunityView?.communityView != null)
                      ThunderPopupMenuItem(
                        onTap: () async {
                          final ThunderState state = context.read<ThunderBloc>().state;
                          final bool reduceAnimations = state.reduceAnimations;

                          await Navigator.of(context).push(
                            SwipeablePageRoute(
                              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                              backGestureDetectionWidth: 45,
                              canOnlySwipeFromEdge: true,
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  // Create a new SearchBloc so it doesn't conflict with the main one
                                  BlocProvider.value(value: SearchBloc()),
                                  BlocProvider.value(value: thunderBloc),
                                ],
                                child: SearchPage(communityToSearch: feedBloc.state.fullCommunityView!.communityView),
                              ),
                            ),
                          );
                        },
                        icon: Icons.search_rounded,
                        title: l10n.search,
                      ),
                    if (feedBloc.state.fullCommunityView?.communityView.community.id != null)
                      ThunderPopupMenuItem(
                        onTap: () async {
                          final ThunderState state = context.read<ThunderBloc>().state;
                          final bool reduceAnimations = state.reduceAnimations;

                          await Navigator.of(context).push(
                            SwipeablePageRoute(
                              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                              backGestureDetectionWidth: 45,
                              canOnlySwipeFromEdge: true,
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: feedBloc),
                                  BlocProvider.value(value: thunderBloc),
                                ],
                                child: ModlogFeedPage(communityId: feedBloc.state.fullCommunityView!.communityView.community.id),
                              ),
                            ),
                          );
                        },
                        icon: Icons.shield_rounded,
                        title: l10n.modlog,
                      ),
                  ],
                ),
            ]
          : [],
    );
  }
}

class FeedAppBarTitle extends StatelessWidget {
  const FeedAppBarTitle({super.key, this.visible = true});

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
          getCommunityName(feedBloc.state),
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

void _onSubscribeIconPressed(BuildContext context) {
  final AuthBloc authBloc = context.read<AuthBloc>();
  final FeedBloc feedBloc = context.read<FeedBloc>();

  final FeedState feedState = feedBloc.state;

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

  Community community = feedBloc.state.fullCommunityView!.communityView.community;
  Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;

  if (currentSubscriptions.contains(community.id)) {
    context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(ids: {community.id}));
    showSnackbar(AppLocalizations.of(context)!.unsubscribed);
  } else {
    context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {community}));
    showSnackbar(AppLocalizations.of(context)!.subscribed);
  }
}
