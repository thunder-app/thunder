import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays a given community's information. This widget is generally used in a list.
class CommunityListEntry extends StatefulWidget {
  /// The community to display.
  final ThunderCommunity community;

  /// Whether to indicate that the community is a favorite.
  final bool indicateFavorites;

  /// The account to use for resolving the community to a different instance
  final Account? resolutionAccount;

  const CommunityListEntry({
    super.key,
    required this.community,
    this.indicateFavorites = true,
    this.resolutionAccount,
  });

  @override
  State<CommunityListEntry> createState() => _CommunityListEntryState();
}

class _CommunityListEntryState extends State<CommunityListEntry> {
  void onSubscribe(bool subscribed, bool isUserLoggedIn) async {
    if (isUserLoggedIn) {
      final account = context.read<ProfileBloc>().state.account;
      final repository = CommunityRepositoryImpl(account: account);

      await repository.subscribe(widget.community.id, !subscribed);
      context.read<ProfileBloc>().add(const FetchProfileSubscriptions());
    } else {
      if (!subscribed) {
        context.read<AnonymousSubscriptionsCubit>().addSubscriptions({widget.community});
      } else {
        context.read<AnonymousSubscriptionsCubit>().removeSubscriptions({widget.community.actorId});
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
      final subscriptions = context.select<AnonymousSubscriptionsCubit, List<ThunderCommunity>>((cubit) => cubit.state.subscriptions);
      community = subscriptions.firstWhereOrNull((c) => c.actorId == widget.community.actorId) ?? widget.community;
    }

    final favourited = context.select<ProfileBloc, bool>((bloc) => bloc.state.favorites.any((c) => c.actorId == community.actorId));

    String subscriptionButtonLabel = switch (community.context.subscribed) {
      SubscriptionStatus.notSubscribed => l10n.subscribe,
      SubscriptionStatus.pending => l10n.unsubscribePending,
      SubscriptionStatus.subscribed => l10n.unsubscribe,
      _ => '',
    };

    return Tooltip(
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
                name: widget.community.name,
                displayName: widget.community.title,
                instance: fetchInstanceNameFromUrl(widget.community.actorId),
                // Override because we're showing display name above
                useDisplayName: false,
              ),
            ),
            if (widget.community.counts.subscribers != null) ...[
              Text(
                ' · ${formatLongNumber(widget.community.counts.subscribers!)}',
                semanticsLabel: l10n.countSubscribers(widget.community.counts.subscribers!),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.people_rounded, size: 16.0),
            ],
            if (widget.indicateFavorites && favourited) ...const [
              Text(' · '),
              Icon(Icons.star_rounded, size: 15),
            ]
          ],
        ),
        trailing: widget.resolutionAccount == null
            ? IconButton(
                onPressed: () {
                  onSubscribe(community.context.subscribed != SubscriptionStatus.notSubscribed, isUserLoggedIn);
                  showThunderSnackbar(community.context.subscribed == SubscriptionStatus.notSubscribed ? l10n.addedCommunityToSubscriptions : l10n.removedCommunityFromSubscriptions);
                },
                icon: Semantics(
                  label: subscriptionButtonLabel,
                  child: Icon(
                    switch (community.context.subscribed) {
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

          if (widget.resolutionAccount != null) {
            try {
              final response = await SearchRepositoryImpl(account: widget.resolutionAccount!).resolve(query: widget.community.actorId);

              communityId = response.community?.id;
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
