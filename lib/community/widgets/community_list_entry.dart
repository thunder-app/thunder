import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class CommunityListEntry extends StatelessWidget {
  final CommunityView communityView;
  final bool isUserLoggedIn;
  final Set<int>? currentSubscriptions;
  final bool indicateFavorites;
  final bool Function(BuildContext context, Community community)?
      getFavoriteStatus;
  final SubscribedType Function(
      bool isUserLoggedIn,
      CommunityView communityView,
      Set<int>? currentSubscriptions)? getCurrentSubscriptionStatus;
  final void Function(bool isUserLoggedIn, BuildContext context,
      CommunityView communityView)? onSubscribeIconPressed;

  /// Whether the community should be resolved to a different instance
  final String? resolutionInstance;

  const CommunityListEntry({
    super.key,
    required this.communityView,
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Tooltip(
      excludeFromSemantics: true,
      message: '${communityView.community.title}\n${generateCommunityFullName(
        context,
        communityView.community.name,
        communityView.community.title,
        fetchInstanceNameFromUrl(communityView.community.actorId),
      )}',
      preferBelow: false,
      child: ListTile(
        leading:
            CommunityAvatar(community: communityView.community, radius: 25),
        title: Text(
          communityView.community.title,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(children: [
          Flexible(
            child: CommunityFullNameWidget(
              context,
              communityView.community.name,
              communityView.community.title,
              fetchInstanceNameFromUrl(communityView.community.actorId),
              // Override because we're showing display name above
              useDisplayName: false,
            ),
          ),
          Text(
            ' · ${formatLongNumber(communityView.counts.subscribers)}',
            semanticsLabel:
                l10n.countSubscribers(communityView.counts.subscribers),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.people_rounded, size: 16.0),
          if (indicateFavorites &&
              getFavoriteStatus?.call(context, communityView.community) ==
                  true &&
              getCurrentSubscriptionStatus?.call(
                      isUserLoggedIn, communityView, currentSubscriptions) ==
                  SubscribedType.subscribed) ...const [
            Text(' · '),
            Icon(Icons.star_rounded, size: 15),
          ]
        ]),
        trailing: getCurrentSubscriptionStatus == null
            ? null
            : IconButton(
                onPressed: () {
                  SubscribedType? subscriptionStatus =
                      getCurrentSubscriptionStatus!(
                          isUserLoggedIn, communityView, currentSubscriptions);
                  onSubscribeIconPressed?.call(
                      isUserLoggedIn, context, communityView);
                  showSnackbar(
                      subscriptionStatus == SubscribedType.notSubscribed
                          ? l10n.addedCommunityToSubscriptions
                          : l10n.removedCommunityFromSubscriptions);
                  context
                      .read<AccountBloc>()
                      .add(const GetAccountSubscriptions());
                },
                icon: Icon(
                  switch (getCurrentSubscriptionStatus!(
                      isUserLoggedIn, communityView, currentSubscriptions)) {
                    SubscribedType.notSubscribed =>
                      Icons.add_circle_outline_rounded,
                    SubscribedType.pending => Icons.pending_outlined,
                    SubscribedType.subscribed =>
                      Icons.remove_circle_outline_rounded,
                    _ => null,
                  },
                ),
                tooltip: switch (getCurrentSubscriptionStatus!(
                    isUserLoggedIn, communityView, currentSubscriptions)) {
                  SubscribedType.notSubscribed => l10n.subscribe,
                  SubscribedType.pending => l10n.unsubscribePending,
                  SubscribedType.subscribed => l10n.unsubscribe,
                  _ => null,
                },
                visualDensity: VisualDensity.compact,
              ),
        onTap: () async {
          int? communityId = communityView.community.id;
          if (resolutionInstance != null) {
            final LemmyApiV3 lemmy =
                (LemmyClient()..changeBaseUrl(resolutionInstance!)).lemmyApiV3;
            try {
              final ResolveObjectResponse resolveObjectResponse = await lemmy
                  .run(ResolveObject(q: communityView.community.actorId));
              communityId = resolveObjectResponse.community?.community.id;
            } catch (e) {
              // If we can't find it, then we'll get a standard error message about communityId being un-navigable
            }
          }

          if (context.mounted) {
            navigateToFeedPage(context,
                feedType: FeedType.community, communityId: communityId);
          }
        },
      ),
    );
  }
}
