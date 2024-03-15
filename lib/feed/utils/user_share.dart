import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum UserShareOptions {
  link,
  localLink,
  lemmy,
}

/// Shows a mottom modal sheet which allows sharing the given [personView].
Future<void> showUserShareSheet(BuildContext context, PersonView personView) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  String user = await getLemmyUser(personView.person.actorId) ?? '';
  String lemmyLink = '@$user';
  String localLink = LemmyClient.instance.generateUserUrl(user);

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
            subtitle: personView.person.actorId,
            icon: Icons.link_rounded,
          ),
          if (!personView.person.actorId.contains(LemmyClient.instance.lemmyApiV3.host))
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
        onSelect: (selection) {
          switch (selection.payload) {
            case UserShareOptions.link:
              Share.share(personView.person.actorId);
            case UserShareOptions.localLink:
              Share.share(localLink);
            case UserShareOptions.lemmy:
              Share.share(lemmyLink);
          }
        },
      ),
    );
  }
}
