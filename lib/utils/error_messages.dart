import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Attempts to retrieve a localized error message for the given [lemmyApiErrorCode].
/// Returns null if not found.
String? getErrorMessage(BuildContext context, String lemmyApiErrorCode) {
  return switch (lemmyApiErrorCode) {
    "cant_block_admin" => AppLocalizations.of(context)!.cantBlockAdmin,
    "cant_block_yourself" => AppLocalizations.of(context)!.cantBlockYourself,
    "only_mods_can_post_in_community" => AppLocalizations.of(context)!.onlyModsCanPostInCommunity,
    _ => lemmyApiErrorCode,
  };
}
