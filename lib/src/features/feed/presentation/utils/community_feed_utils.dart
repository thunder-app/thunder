import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/api.dart';

import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar, showThunderDialog;

Future<void> toggleFavoriteCommunity(BuildContext context, ThunderCommunity community, bool isFavorite) async {
  try {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = resolveEffectiveAccount(context);
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (isFavorite) {
      await Favorite.deleteFavorite(communityId: community.id);
      if (context.mounted) {
        context.read<ProfileBloc>().add(const FetchProfileFavorites());
      }
      return;
    }

    Favorite favorite = Favorite(
      id: '',
      communityId: community.id,
      accountId: account.id,
    );

    await Favorite.insertFavorite(favorite);
    if (context.mounted) {
      context.read<ProfileBloc>().add(const FetchProfileFavorites());
    }
  } catch (e) {
    showSnackbar(getExceptionErrorMessage(e));
  }
}

/// Takes a list of [communities] and returns the list with any [favoriteCommunities] at the beginning of the list
/// Note that you may need to call [toList] when passing in lists that are marked as readonly.
List<ThunderCommunity>? prioritizeFavorites(List<ThunderCommunity>? communities, List<ThunderCommunity>? favoriteCommunities) {
  // If either communities or favorites are empty, no reason to prioritize.
  if (communities?.isNotEmpty != true || favoriteCommunities?.isNotEmpty != true) {
    return communities;
  }

  // Create a set of the favorited community ids for filtering later
  Set<int> favoriteCommunityIds = Set<int>.from(favoriteCommunities!.map((c) => c.id));

  // Filters out communities that are part of the favorites, and keeps the same order
  List<ThunderCommunity>? sortedFavorites = communities!.where((c) => favoriteCommunityIds.contains(c.id)).toList();

  // Filters out communities that are not a part of the favorites, and keeps the same order
  List<ThunderCommunity>? sortedNonFavorites = communities.where((c) => !favoriteCommunityIds.contains(c.id)).toList();

  // Combine them together, with favorites at the top
  return List<ThunderCommunity>.from(sortedFavorites)..addAll(sortedNonFavorites);
}

/// Handles the subscription/unsubscription process for authenticated users.
/// Requires a [CommunityBloc] to be provided in the context.
///
/// When subcribed, shows a confirmation dialog for unsubscription.
Future<ThunderCommunity?> handleSubscription(BuildContext context, ThunderCommunity community) async {
  final l10n = GlobalContext.l10n;
  final isSubscribed = community.subscribed != SubscriptionStatus.notSubscribed;

  if (isSubscribed) {
    bool shouldUnsubscribe = false;

    await showThunderDialog<void>(
      context: context,
      title: l10n.confirm,
      contentText: l10n.confirmUnsubscription,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
      secondaryButtonText: l10n.cancel,
      onPrimaryButtonPressed: (dialogContext, _) async {
        Navigator.of(dialogContext).pop();
        shouldUnsubscribe = true;
      },
      primaryButtonText: l10n.confirm,
    );

    if (!shouldUnsubscribe) return null;
  }

  final account = resolveEffectiveAccount(context);
  final repository = CommunityRepositoryImpl(account: account);
  return await repository.subscribe(community.id, !isSubscribed);
}
