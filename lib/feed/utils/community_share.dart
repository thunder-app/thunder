import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum CommunityShareOptions {
  link,
  localLink,
  lemmy,
}

/// Shows a mottom modal sheet which allows sharing the given [communityView].
Future<void> showCommunityShareSheet(BuildContext context, CommunityView communityView) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  String community = await getLemmyCommunity(communityView.community.actorId) ?? '';
  String lemmyLink = '!$community';
  String localLink = LemmyClient.instance.generateCommunityUrl(community);

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
            payload: CommunityShareOptions.link,
            subtitle: communityView.community.actorId,
            icon: Icons.link_rounded,
          ),
          if (!communityView.community.actorId.contains(LemmyClient.instance.lemmyApiV3.host))
            ListPickerItem(
              label: l10n.shareCommunityLinkLocal,
              payload: CommunityShareOptions.localLink,
              subtitle: localLink,
              icon: Icons.link_rounded,
            ),
          ListPickerItem(
            label: l10n.shareLemmyLink,
            payload: CommunityShareOptions.lemmy,
            subtitle: lemmyLink,
            icon: Icons.share_rounded,
          ),
        ],
        onSelect: (selection) async {
          switch (selection.payload) {
            case CommunityShareOptions.link:
              Share.share(communityView.community.actorId);
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
