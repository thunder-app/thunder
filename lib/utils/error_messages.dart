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
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  return switch (lemmyApiErrorCode) {
    "cant_block_admin" => l10n.cantBlockAdmin,
    "cant_block_yourself" => l10n.cantBlockYourself,
    "only_mods_can_post_in_community" => l10n.onlyModsCanPostInCommunity,
    "couldnt_create_report" => l10n.couldntCreateReport,
    "language_not_allowed" => l10n.languageNotAllowed,
    _ => lemmyApiErrorCode,
  };
}
