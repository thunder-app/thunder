import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/presentation/models/feed_share_options.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/core/networking/instance_uri.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Shows a bottom modal sheet which allows sharing the given [community].
Future<void> showCommunityShareSheet(BuildContext context, ThunderCommunity community) async {
  final l10n = AppLocalizations.of(context)!;
  final account = resolveEffectiveAccount(context);

  final communityLink = await getLemmyCommunity(community.actorId) ?? '';
  final lemmyLink = '!$communityLink';
  final localLink = buildInstanceUrl(account.instance, '/c/$communityLink');

  if (context.mounted) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (builderContext) => ThunderBottomSheetListPicker(
        title: l10n.shareCommunity,
        items: [
          ThunderListPickerItem(
            label: l10n.shareCommunityLink,
            icon: Icons.link_rounded,
            subtitle: community.actorId,
            payload: CommunityShareOptions.link,
          ),
          if (!community.actorId.contains(account.instance))
            ThunderListPickerItem(
              label: l10n.shareCommunityLinkLocal,
              icon: Icons.link_rounded,
              subtitle: localLink,
              payload: CommunityShareOptions.localLink,
            ),
          ThunderListPickerItem(
            label: l10n.shareLemmyLink,
            icon: Icons.share_rounded,
            subtitle: lemmyLink,
            payload: CommunityShareOptions.lemmy,
          ),
        ],
        onSelect: (selection) async {
          switch (selection.payload) {
            case CommunityShareOptions.link:
              SharePlus.instance.share(ShareParams(
                uri: Uri.parse(community.actorId),
                sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
              ));
            case CommunityShareOptions.localLink:
              SharePlus.instance.share(ShareParams(
                uri: Uri.parse(localLink),
                sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
              ));
            case CommunityShareOptions.lemmy:
              SharePlus.instance.share(ShareParams(
                text: lemmyLink,
                sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
              ));
          }
        },
      ),
    );
  }
}

/// Shows a bottom modal sheet which allows sharing the given [person].
Future<void> showUserShareSheet(BuildContext context, ThunderUser person) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final account = resolveEffectiveAccount(context);

  String user = await getLemmyUser(person.actorId) ?? '';
  String lemmyLink = '@$user';
  String localLink = buildInstanceUrl(account.instance, '/u/$user');

  if (context.mounted) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (builderContext) => ThunderBottomSheetListPicker(
        title: l10n.shareUser,
        items: [
          ThunderListPickerItem(
            label: l10n.shareUserLink,
            payload: UserShareOptions.link,
            subtitle: person.actorId,
            icon: Icons.link_rounded,
          ),
          if (!person.actorId.contains(account.instance))
            ThunderListPickerItem(
              label: l10n.shareUserLinkLocal,
              payload: UserShareOptions.localLink,
              subtitle: localLink,
              icon: Icons.link_rounded,
            ),
          ThunderListPickerItem(
            label: l10n.shareLemmyLink,
            payload: UserShareOptions.lemmy,
            subtitle: lemmyLink,
            icon: Icons.share_rounded,
          ),
        ],
        onSelect: (selection) async {
          switch (selection.payload) {
            case UserShareOptions.link:
              SharePlus.instance.share(ShareParams(
                uri: Uri.parse(person.actorId),
                sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
              ));
            case UserShareOptions.localLink:
              SharePlus.instance.share(ShareParams(
                uri: Uri.parse(localLink),
                sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
              ));
            case UserShareOptions.lemmy:
              SharePlus.instance.share(ShareParams(
                text: lemmyLink,
                sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
              ));
          }
        },
      ),
    );
  }
}
