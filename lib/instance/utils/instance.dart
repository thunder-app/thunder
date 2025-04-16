import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';

/// Logic to block a instance
Future<BlockInstanceResponse> blockInstance(int instanceId, bool block) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  BlockInstanceResponse blockedInstance = await lemmy.run(BlockInstance(
    auth: account.jwt!,
    instanceId: instanceId,
    block: block,
  ));

  return blockedInstance;
}
