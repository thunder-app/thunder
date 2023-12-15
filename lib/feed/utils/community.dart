import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/models/favourite.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:uuid/uuid.dart';

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

  return communityResponse.communityView;
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
    if (context.mounted) context.read<AccountBloc>().add(GetFavoritedCommunities());
    return;
  }

  Account? account = await fetchActiveProfileAccount();

  Uuid uuid = const Uuid();
  String id = uuid.v4().replaceAll('-', '').substring(0, 13);

  Favorite favorite = Favorite(
    id: id,
    communityId: community.id,
    accountId: account!.id,
  );

  await Favorite.insertFavorite(favorite);
  if (context.mounted) context.read<AccountBloc>().add(GetFavoritedCommunities());
}
