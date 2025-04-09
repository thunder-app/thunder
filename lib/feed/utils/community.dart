import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/community/models/favourite.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

/// Logic to block a community
Future<BlockCommunityResponse> blockCommunity(int communityId, bool block) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  BlockCommunityResponse blockedCommunity = await lemmy.run(BlockCommunity(
    auth: account!.jwt!,
    communityId: communityId,
    block: block,
  ));

  return blockedCommunity;
}

Future<ThunderCommunity> followCommunity(int communityId, bool follow) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfileAccount();
  if (account?.jwt == null) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;
  final response = await lemmy.run(FollowCommunity(auth: account!.jwt!, communityId: communityId, follow: follow));

  return ThunderCommunity(response.communityView.community, communityView: response.communityView);
}

Future<Map<String, dynamic>> fetchCommunityInformation({int? id, String? name}) async {
  assert(!(id == null && name == null));

  final account = await fetchActiveProfileAccount();
  final lemmy = LemmyClient.instance.lemmyApiV3;
  final response = await lemmy.run(GetCommunity(auth: account?.jwt, id: id, name: name));

  return {
    "community": ThunderCommunity(response.communityView.community, communityView: response.communityView),
    "instance": response.site != null ? ThunderInstance(response.site!) : null,
    "moderators": response.moderators.map((mod) => ThunderUser(mod.moderator)).toList(),
  };
}

Future<void> toggleFavoriteCommunity(BuildContext context, ThunderCommunity community, bool isFavorite) async {
  try {
    if (isFavorite) {
      await Favorite.deleteFavorite(communityId: community.id);
      if (context.mounted) context.read<AccountBloc>().add(const GetFavoritedCommunities());
      return;
    }

    Account? account = await fetchActiveProfileAccount();

    Favorite favorite = Favorite(
      id: '',
      communityId: community.id,
      accountId: account!.id,
    );

    await Favorite.insertFavorite(favorite);
    if (context.mounted) context.read<AccountBloc>().add(const GetFavoritedCommunities());
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
