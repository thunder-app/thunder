import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/errors/api_exception.dart';

/// Generates a user-friendly error message from an exception (or any thrown object)
String getExceptionErrorMessage(Object? e, {String? additionalInfo}) {
  if (e is ApiException) {
    return getErrorMessage(GlobalContext.context, e.message, additionalInfo: e.errorCode) ?? e.message;
  }

  if (e is TimeoutException) {
    return AppLocalizations.of(GlobalContext.context)!.timeoutErrorMessage;
  }

  return e.toString();
}

/// Attempts to retrieve a localized error message for the given [apiErrorCode].
/// Returns null if not found.
String? getErrorMessage(BuildContext context, String apiErrorCode, {String? additionalInfo}) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  return switch (apiErrorCode) {
    "cant_block_admin" => l10n.cantBlockAdmin,
    "cant_block_yourself" => l10n.cantBlockYourself,
    "only_mods_can_post_in_community" => l10n.onlyModsCanPostInCommunity,
    "couldnt_create_report" => l10n.couldntCreateReport,
    "language_not_allowed" => l10n.languageNotAllowed,
    "couldnt_find_community" => additionalInfo != null ? l10n.unableToFindCommunityName(additionalInfo) : l10n.unableToFindCommunity,
    "couldnt_find_person" => additionalInfo != null ? l10n.unableToFindUserName(additionalInfo) : l10n.unableToFindUser,
    "couldnt_find_post" => l10n.couldntFindPost,
    "network_error" => l10n.networkErrorMessage,
    "rate_limit_error" => l10n.rateLimitErrorMessage,
    _ => apiErrorCode,
  };
}
