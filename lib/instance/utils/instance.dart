import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/utils/global_context.dart';

/// Logic to block a instance
Future<BlockInstanceResponse> blockInstance(int instanceId, bool block) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyApiV3(account.instance, debug: kDebugMode);

  BlockInstanceResponse blockedInstance = await lemmy.run(BlockInstance(
    auth: account.jwt!,
    instanceId: instanceId,
    block: block,
  ));

  return blockedInstance;
}
