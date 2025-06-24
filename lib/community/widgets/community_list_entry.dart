import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/view/feed_page.dart';
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
        context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(urls: {widget.community.url}));
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
      community = subscriptions.firstWhereOrNull((c) => c.url == widget.community.url) ?? widget.community;
    } else {
      final subscriptions = context.select<AnonymousSubscriptionsBloc, List<ThunderCommunity>>((bloc) => bloc.state.subscriptions);
      community = subscriptions.firstWhereOrNull((c) => c.url == widget.community.url) ?? widget.community;
    }

    final favourited = context.select<ProfileBloc, bool>((bloc) => bloc.state.favorites.any((c) => c.url == community.url));

    String subscriptionButtonLabel = switch (community.subscribed) {
      SubscribedType.notSubscribed => l10n.subscribe,
      SubscribedType.pending => l10n.unsubscribePending,
      SubscribedType.subscribed => l10n.unsubscribe,
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
          fetchInstanceNameFromUrl(widget.community.url),
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
                  fetchInstanceNameFromUrl(widget.community.url),
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
              if (widget.indicateFavorites && favourited && community.subscribed == SubscribedType.subscribed) ...const [
                Text(' · '),
                Icon(Icons.star_rounded, size: 15),
              ]
            ],
          ),
          trailing: widget.resolutionInstance == null
              ? IconButton(
                  onPressed: () {
                    onSubscribe(community.subscribed != SubscribedType.notSubscribed, isUserLoggedIn);
                    showSnackbar(community.subscribed == SubscribedType.notSubscribed ? l10n.addedCommunityToSubscriptions : l10n.removedCommunityFromSubscriptions);
                  },
                  icon: Semantics(
                    label: subscriptionButtonLabel,
                    child: Icon(
                      switch (community.subscribed) {
                        SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                        SubscribedType.pending => Icons.pending_outlined,
                        SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                        _ => Icons.add_circle_outline_rounded,
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
                final lemmy = (LemmyClient()..changeBaseUrl(widget.resolutionInstance!)).lemmyApiV3;
                final response = await lemmy.run(ResolveObject(q: widget.community.url));

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
