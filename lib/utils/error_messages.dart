import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/utils/global_context.dart';

/// Generates a user-friendly error message from an exception (or any thrown object)
String getExceptionErrorMessage(Object e) {
  if (e is LemmyApiException) {
    return getErrorMessage(GlobalContext.context, e.message) ?? e.toString();
  }

  if (e is TimeoutException) {
    return AppLocalizations.of(GlobalContext.context)!.timeoutErrorMessage;
  }

  return e.toString();
}

/// Attempts to retrieve a localized error message for the given [lemmyApiErrorCode].
/// Returns null if not found.
String? getErrorMessage(BuildContext context, String lemmyApiErrorCode) {
  return switch (lemmyApiErrorCode) {
    "cant_block_admin" => AppLocalizations.of(context)!.cantBlockAdmin,
    "cant_block_yourself" => AppLocalizations.of(context)!.cantBlockYourself,
    "only_mods_can_post_in_community" => AppLocalizations.of(context)!.onlyModsCanPostInCommunity,
    "couldnt_create_report" => AppLocalizations.of(context)!.couldntCreateReport,
    _ => lemmyApiErrorCode,
  };
}
