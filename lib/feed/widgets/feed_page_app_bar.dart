import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';

import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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
      pinned: true,
      floating: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      title: FeedAppBarTitle(visible: showAppBarTitle),
      leading: IconButton(
        icon: Navigator.of(context).canPop() && feedBloc.state.feedType == FeedType.community
            ? (!kIsWeb && Platform.isIOS
                ? Icon(
                    Icons.arrow_back_ios_new_rounded,
                    semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip))
            : Icon(Icons.menu, semanticLabel: MaterialLocalizations.of(context).openAppDrawerTooltip),
        onPressed: () {
          HapticFeedback.mediumImpact();
          (Navigator.of(context).canPop() && feedBloc.state.feedType == FeedType.community) ? Navigator.of(context).maybePop() : scaffoldStateKey?.currentState?.openDrawer();
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
              if (feedState.feedType == FeedType.community)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => triggerRefresh(context),
                      child: ListTile(
                        dense: true,
                        horizontalTitleGap: 5,
                        leading: const Icon(Icons.refresh_rounded, size: 20),
                        title: Text(l10n.refresh),
                      ),
                    ),
                    if (_getSubscriptionStatus(context) == SubscribedType.subscribed)
                      PopupMenuItem(
                        onTap: () async {
                          final Community community = context.read<FeedBloc>().state.fullCommunityView!.communityView.community;
                          bool isFavorite = _getFavoriteStatus(context);
                          await toggleFavoriteCommunity(context, community, isFavorite);
                        },
                        child: ListTile(
                          dense: true,
                          horizontalTitleGap: 5,
                          leading: Icon(_getFavoriteStatus(context) ? Icons.star_rounded : Icons.star_border_rounded, size: 20),
                          title: Text(_getFavoriteStatus(context) ? l10n.removeFromFavorites : l10n.addToFavorites),
                        ),
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
    showSnackbar(context, AppLocalizations.of(context)!.unsubscribed);
  } else {
    context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {community}));
    showSnackbar(context, AppLocalizations.of(context)!.subscribed);
  }
}
