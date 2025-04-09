import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityListEntry extends StatelessWidget {
  /// The community to display.
  final ThunderCommunity community;

  /// Whether the user is logged in.
  final bool isUserLoggedIn;

  /// The current user subscriptions.
  final Set<int>? currentSubscriptions;

  /// Whether to indicate that the community is a favorite.
  final bool indicateFavorites;

  /// Callback function that occurs when the favorite status is requested.
  final bool Function(BuildContext context, ThunderCommunity community)? getFavoriteStatus;

  /// Callback function that occurs when the subscription status is requested.
  final SubscribedType Function(bool isUserLoggedIn, ThunderCommunity community, Set<int>? currentSubscriptions)? getCurrentSubscriptionStatus;

  /// Callback function that occurs when the subscribe icon is pressed.
  final void Function(bool isUserLoggedIn, BuildContext context, ThunderCommunity community)? onSubscribeIconPressed;

  /// Whether the community should be resolved to a different instance
  final String? resolutionInstance;

  const CommunityListEntry({
    super.key,
    required this.community,
    required this.isUserLoggedIn,
    this.currentSubscriptions,
    this.indicateFavorites = true,
    this.resolutionInstance,
    this.getFavoriteStatus,
    this.getCurrentSubscriptionStatus,
    this.onSubscribeIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    assert(community.subscribers != null);

    String subscriptionButtonLabel = switch (getCurrentSubscriptionStatus!(isUserLoggedIn, community, currentSubscriptions)) {
      SubscribedType.notSubscribed => l10n.subscribe,
      SubscribedType.pending => l10n.unsubscribePending,
      SubscribedType.subscribed => l10n.unsubscribe,
    };

    return Tooltip(
      excludeFromSemantics: true,
      message: '${community.title}\n${generateCommunityFullName(
        context,
        community.communityName,
        community.title,
        fetchInstanceNameFromUrl(community.url),
      )}',
      preferBelow: false,
      child: ListTile(
        leading: CommunityAvatar(community: community, radius: 25),
        title: Text(community.title, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Flexible(
              child: CommunityFullNameWidget(
                context,
                community.communityName,
                community.title,
                fetchInstanceNameFromUrl(community.url),
                // Override because we're showing display name above
                useDisplayName: false,
              ),
            ),
            Text(
              ' · ${formatLongNumber(community.subscribers!)}',
              semanticsLabel: l10n.countSubscribers(community.subscribers!),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.people_rounded, size: 16.0),
            if (indicateFavorites &&
                getFavoriteStatus?.call(context, community) == true &&
                getCurrentSubscriptionStatus?.call(isUserLoggedIn, community, currentSubscriptions) == SubscribedType.subscribed) ...const [
              Text(' · '),
              Icon(Icons.star_rounded, size: 15),
            ]
          ],
        ),
        trailing: getCurrentSubscriptionStatus == null
            ? null
            : IconButton(
                onPressed: () {
                  SubscribedType? subscriptionStatus = getCurrentSubscriptionStatus!(isUserLoggedIn, community, currentSubscriptions);
                  onSubscribeIconPressed?.call(isUserLoggedIn, context, community);
                  showSnackbar(subscriptionStatus == SubscribedType.notSubscribed ? l10n.addedCommunityToSubscriptions : l10n.removedCommunityFromSubscriptions);
                  context.read<AccountBloc>().add(const GetAccountSubscriptions());
                },
                icon: Semantics(
                  label: subscriptionButtonLabel,
                  child: Icon(
                    switch (getCurrentSubscriptionStatus!(isUserLoggedIn, community, currentSubscriptions)) {
                      SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                      SubscribedType.pending => Icons.pending_outlined,
                      SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                    },
                  ),
                ),
                tooltip: subscriptionButtonLabel,
                visualDensity: VisualDensity.compact,
              ),
        onTap: () async {
          int? communityId = community.id;

          if (resolutionInstance != null) {
            try {
              final lemmy = (LemmyClient()..changeBaseUrl(resolutionInstance!)).lemmyApiV3;
              final response = await lemmy.run(ResolveObject(q: community.url));

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
    );
  }
}
