import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/shared/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/src/shared/utils/instance.dart';

enum CommunityShareOptions { link, localLink, lemmy }

/// Shows a bottom modal sheet which allows sharing the given [community].
Future<void> showCommunityShareSheet(BuildContext context, ThunderCommunity community) async {
  final l10n = AppLocalizations.of(context)!;
  final account = await fetchActiveProfile();

  final communityLink = await getLemmyCommunity(community.actorId) ?? '';
  final lemmyLink = '!$communityLink';
  final localLink = 'https://${account.instance}/c/$communityLink';

  if (context.mounted) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (builderContext) => BottomSheetListPicker(
        title: l10n.shareCommunity,
        items: [
          ListPickerItem(
            label: l10n.shareCommunityLink,
            icon: Icons.link_rounded,
            subtitle: community.actorId,
            payload: CommunityShareOptions.link,
          ),
          if (!community.actorId.contains(account.instance))
            ListPickerItem(
              label: l10n.shareCommunityLinkLocal,
              icon: Icons.link_rounded,
              subtitle: localLink,
              payload: CommunityShareOptions.localLink,
            ),
          ListPickerItem(
            label: l10n.shareLemmyLink,
            icon: Icons.share_rounded,
            subtitle: lemmyLink,
            payload: CommunityShareOptions.lemmy,
          ),
        ],
        onSelect: (selection) async {
          switch (selection.payload) {
            case CommunityShareOptions.link:
              SharePlus.instance.share(ShareParams(uri: Uri.parse(community.actorId)));
            case CommunityShareOptions.localLink:
              SharePlus.instance.share(ShareParams(uri: Uri.parse(localLink)));
            case CommunityShareOptions.lemmy:
              SharePlus.instance.share(ShareParams(text: lemmyLink));
          }
        },
      ),
    );
  }
}
