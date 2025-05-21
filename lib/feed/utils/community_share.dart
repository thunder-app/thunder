import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';
import 'package:thunder/localizations/app_localizations.dart';

import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/instance.dart';

enum CommunityShareOptions { link, localLink, lemmy }

/// Shows a bottom modal sheet which allows sharing the given [community].
Future<void> showCommunityShareSheet(BuildContext context, ThunderCommunity community) async {
  final l10n = AppLocalizations.of(context)!;

  final communityLink = await getLemmyCommunity(community.url) ?? '';
  final lemmyLink = '!$communityLink';
  final localLink = LemmyClient.instance.generateCommunityUrl(communityLink);

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
            subtitle: community.url,
            payload: CommunityShareOptions.link,
          ),
          if (!community.url.contains(LemmyClient.instance.lemmyApiV3.host))
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
              Share.share(community.url);
            case CommunityShareOptions.localLink:
              Share.share(localLink);
            case CommunityShareOptions.lemmy:
              Share.share(lemmyLink);
          }
        },
      ),
    );
  }
}
