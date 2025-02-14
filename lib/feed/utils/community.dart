import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/models/favourite.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/convert.dart';

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

Future<CommunityView> followCommunity(int communityId, bool follow) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  CommunityResponse communityResponse = await lemmy.run(FollowCommunity(
    auth: account!.jwt!,
    communityId: communityId,
    follow: follow,
  ));

  return convertToCommunityView(communityResponse.communityView)!;
}

Future<GetCommunityResponse> fetchCommunityInformation({int? id, String? name}) async {
  assert(!(id == null && name == null));

  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  GetCommunityResponse fullCommunityView = await lemmy.run(GetCommunity(
    auth: account?.jwt,
    id: id,
    name: name,
  ));

  return fullCommunityView;
}

Future<void> toggleFavoriteCommunity(BuildContext context, Community community, bool isFavorite) async {
  if (isFavorite) {
    await Favorite.deleteFavorite(communityId: community.id);
    if (context.mounted) context.read<AccountBloc>().add(const RefreshAccountInformation());
    return;
  }

  Account? account = await fetchActiveProfileAccount();

  Favorite favorite = Favorite(
    id: '',
    communityId: community.id,
    accountId: account!.id,
  );

  await Favorite.insertFavorite(favorite);
  if (context.mounted) context.read<AccountBloc>().add(const RefreshAccountInformation());
}

/// Takes a list of [communities] and returns the list with any [favoriteCommunities] at the beginning of the list
/// Note that you may need to call [toList] when passing in lists that are marked as readonly.
List<CommunityView>? prioritizeFavorites(List<CommunityView>? communities, List<CommunityView>? favoriteCommunities) {
  // If either communities or favorites are empty, no reason to prioritize.
  if (communities?.isNotEmpty != true || favoriteCommunities?.isNotEmpty != true) {
    return communities;
  }

  // Create a set of the favorited community ids for filtering later
  Set<int> favoriteCommunityIds = Set<int>.from(favoriteCommunities!.map((c) => c.community.id));

  // Filters out communities that are part of the favorites, and keeps the same order
  List<CommunityView>? sortedFavorites = communities!.where((c) => favoriteCommunityIds.contains(c.community.id)).toList();

  // Filters out communities that are not a part of the favorites, and keeps the same order
  List<CommunityView>? sortedNonFavorites = communities.where((c) => !favoriteCommunityIds.contains(c.community.id)).toList();

  // Combine them together, with favorites at the top
  return List<CommunityView>.from(sortedFavorites)..addAll(sortedNonFavorites);
}
