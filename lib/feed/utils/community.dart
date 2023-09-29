import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

/// Logic to block a community
Future<BlockedCommunity> blockCommunity(int communityId, bool block) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  BlockedCommunity blockedCommunity = await lemmy.run(BlockCommunity(
    auth: account!.jwt!,
    communityId: communityId,
    block: block,
  ));

  return blockedCommunity;
}
