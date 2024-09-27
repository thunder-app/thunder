import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';

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

/// Logic to ban a user from a community
///
/// Can optionally provide a reason and expiration date (in seconds)
/// If [removeData] is true, posts and comments from the user will also be deleted
Future<BanFromCommunityResponse> banUserFromCommunity(int userId, bool ban, {required int communityId, String? reason, int? expires, bool removeData = false}) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfileAccount();
  final lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception(l10n.userNotLoggedIn);

  BanFromCommunityResponse banFromCommunityResponse = await lemmy.run(BanFromCommunity(
    auth: account!.jwt!,
    communityId: communityId,
    personId: userId,
    ban: ban,
    removeData: removeData,
    reason: reason,
    expires: expires,
  ));

  return banFromCommunityResponse;
}

/// Logic to add or remove moderator for a given community (moderator action)
Future<AddModToCommunityResponse> addModerator(int userId, bool added, {required int communityId}) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfileAccount();
  final lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception(l10n.userNotLoggedIn);

  AddModToCommunityResponse addModToCommunityResponse = await lemmy.run(AddModToCommunity(
    auth: account!.jwt!,
    communityId: communityId,
    personId: userId,
    added: added,
  ));

  return addModToCommunityResponse;
}
