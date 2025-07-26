import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/search/repository/search_repository.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/utils/numbers.dart';

/// A widget that displays a given community's information. This widget is generally used in a list.
class CommunityListEntry extends StatefulWidget {
  /// The community to display.
  final ThunderCommunity community;

  /// Whether to indicate that the community is a favorite.
  final bool indicateFavorites;

  /// Whether the community should be resolved to a different instance
  final String? resolutionInstance;

  const CommunityListEntry({
    super.key,
    required this.community,
    this.indicateFavorites = true,
    this.resolutionInstance,
  });

  @override
  State<CommunityListEntry> createState() => _CommunityListEntryState();
}

class _CommunityListEntryState extends State<CommunityListEntry> {
  void onSubscribe(bool subscribed, bool isUserLoggedIn) {
    if (isUserLoggedIn) {
      context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.follow, communityId: widget.community.id, value: !subscribed));
    } else {
      if (!subscribed) {
        context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {widget.community}));
        context.read<AnonymousSubscriptionsBloc>().add(GetSubscribedCommunitiesEvent());
      } else {
        context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(urls: {widget.community.actorId}));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final isUserLoggedIn = context.select<ProfileBloc, bool>((bloc) => bloc.state.isLoggedIn);

    ThunderCommunity community;

    // Fetch the community from the user's subscriptions or anonymous subscriptions if possible
    if (isUserLoggedIn) {
      final subscriptions = context.select<ProfileBloc, List<ThunderCommunity>>((bloc) => bloc.state.subscriptions);
      community = subscriptions.firstWhereOrNull((c) => c.actorId == widget.community.actorId) ?? widget.community;
    } else {
      final subscriptions = context.select<AnonymousSubscriptionsBloc, List<ThunderCommunity>>((bloc) => bloc.state.subscriptions);
      community = subscriptions.firstWhereOrNull((c) => c.actorId == widget.community.actorId) ?? widget.community;
    }

    final favourited = context.select<ProfileBloc, bool>((bloc) => bloc.state.favorites.any((c) => c.actorId == community.actorId));

    String subscriptionButtonLabel = switch (community.subscribed) {
      SubscriptionStatus.notSubscribed => l10n.subscribe,
      SubscriptionStatus.pending => l10n.unsubscribePending,
      SubscriptionStatus.subscribed => l10n.unsubscribe,
      _ => '',
    };

    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state.status == CommunityStatus.success) context.read<ProfileBloc>().add(const FetchProfileSubscriptions());
      },
      child: Tooltip(
        excludeFromSemantics: true,
        message: '${widget.community.title}\n${generateCommunityFullName(
          context,
          widget.community.name,
          widget.community.title,
          fetchInstanceNameFromUrl(widget.community.actorId),
        )}',
        preferBelow: false,
        child: ListTile(
          leading: CommunityAvatar(community: widget.community, radius: 25),
          title: Text(widget.community.title, overflow: TextOverflow.ellipsis),
          subtitle: Row(
            children: [
              Flexible(
                child: CommunityFullNameWidget(
                  context,
                  widget.community.name,
                  widget.community.title,
                  fetchInstanceNameFromUrl(widget.community.actorId),
                  // Override because we're showing display name above
                  useDisplayName: false,
                ),
              ),
              Text(
                ' · ${formatLongNumber(widget.community.subscribers!)}',
                semanticsLabel: l10n.countSubscribers(widget.community.subscribers!),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.people_rounded, size: 16.0),
              if (widget.indicateFavorites && favourited && community.subscribed == SubscriptionStatus.subscribed) ...const [
                Text(' · '),
                Icon(Icons.star_rounded, size: 15),
              ]
            ],
          ),
          trailing: widget.resolutionInstance == null
              ? IconButton(
                  onPressed: () {
                    onSubscribe(community.subscribed != SubscriptionStatus.notSubscribed, isUserLoggedIn);
                    showSnackbar(community.subscribed == SubscriptionStatus.notSubscribed ? l10n.addedCommunityToSubscriptions : l10n.removedCommunityFromSubscriptions);
                  },
                  icon: Semantics(
                    label: subscriptionButtonLabel,
                    child: Icon(
                      switch (community.subscribed) {
                        SubscriptionStatus.notSubscribed => Icons.add_circle_outline_rounded,
                        SubscriptionStatus.pending => Icons.pending_outlined,
                        SubscriptionStatus.subscribed => Icons.remove_circle_outline_rounded,
                        _ => null,
                      },
                    ),
                  ),
                  tooltip: subscriptionButtonLabel,
                  visualDensity: VisualDensity.compact,
                )
              : null,
          onTap: () async {
            int? communityId = widget.community.id;

            if (widget.resolutionInstance != null) {
              try {
                // Create a temporary Account
                final account = Account(instance: widget.resolutionInstance!, id: '', index: -1);
                final response = await SearchRepositoryImpl(account: account).resolve(query: widget.community.actorId);

                communityId = response.community?.community.id;
              } catch (e) {
                // If we can't find it, then we'll get a standard error message about communityId being un-navigable
              }
            }

            if (context.mounted) {
              navigateToFeedPage(context, feedType: FeedType.community, communityId: communityId);
            }
          },
        ),
      ),
    );
  }
}
