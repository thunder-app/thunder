import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

enum UserShareOptions {
  link,
  localLink,
  lemmy,
}

/// Shows a mottom modal sheet which allows sharing the given [person].
Future<void> showUserShareSheet(BuildContext context, ThunderUser person) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final account = await fetchActiveProfile();

  String user = await getLemmyUser(person.actorId) ?? '';
  String lemmyLink = '@$user';
  String localLink = 'https://${account.instance}/u/$user';

  if (context.mounted) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (builderContext) => BottomSheetListPicker(
        title: l10n.shareUser,
        items: [
          ListPickerItem(
            label: l10n.shareUserLink,
            payload: UserShareOptions.link,
            subtitle: person.actorId,
            icon: Icons.link_rounded,
          ),
          if (!person.actorId.contains(account.instance))
            ListPickerItem(
              label: l10n.shareUserLinkLocal,
              payload: UserShareOptions.localLink,
              subtitle: localLink,
              icon: Icons.link_rounded,
            ),
          ListPickerItem(
            label: l10n.shareLemmyLink,
            payload: UserShareOptions.lemmy,
            subtitle: lemmyLink,
            icon: Icons.share_rounded,
          ),
        ],
        onSelect: (selection) async {
          switch (selection.payload) {
            case UserShareOptions.link:
              SharePlus.instance.share(ShareParams(uri: Uri.parse(person.actorId)));
            case UserShareOptions.localLink:
              SharePlus.instance.share(ShareParams(uri: Uri.parse(localLink)));
            case UserShareOptions.lemmy:
              SharePlus.instance.share(ShareParams(text: lemmyLink));
          }
        },
      ),
    );
  }
}
