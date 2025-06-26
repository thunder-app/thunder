import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/localizations/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';

/// Logic to block a user
Future<BlockPersonResponse> blockUser(int userId, bool block) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  BlockPersonResponse blockPersonResponse = await lemmy.run(BlockPerson(
    auth: account.jwt!,
    personId: userId,
    block: block,
  ));

  return blockPersonResponse;
}
