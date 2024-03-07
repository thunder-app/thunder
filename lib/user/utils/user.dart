import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

/// Logic to block a user
Future<BlockPersonResponse> blockUser(int userId, bool block) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  BlockPersonResponse blockPersonResponse = await lemmy.run(BlockPerson(
    auth: account!.jwt!,
    personId: userId,
    block: block,
  ));

  return blockPersonResponse;
}
