import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/enums/full_name_separator.dart';

import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';

/// Represents a modlog event based on [ModlogActionType].
/// This class is used to display modlog events in the UI.
class ModlogEventItem {
  ModlogEventItem({
    required this.type,
    required this.dateTime,
    this.moderator,
    this.admin,
    this.reason,
    this.user,
    this.post,
    this.comment,
    this.community,
    required this.actioned,
  });

  /// The type of the event.
  final ModlogActionType type;

  /// The date and time of the event.
  final String dateTime;

  /// The moderator who performed the action.
  final Person? moderator;

  /// The admin who performed the action.
  final Person? admin;

  /// The reason for the action.
  final String? reason;

  /// The user associated with the action.
  final Person? user;

  /// The post associated with the action.
  final Post? post;

  /// The comment associated with the action.
  final Comment? comment;

  /// The community associated with the action.
  final Community? community;

  /// Whether the action has been performed or reverted.
  /// If `true`, the action has been performed. If `false`, the action has been reverted.
  final bool actioned;

  String getModlogEventTypeName() {
    final l10n = AppLocalizations.of(GlobalContext.context)!;

    return switch (type) {
      ModlogActionType.modRemovePost => actioned ? 'Removed Post' : 'Restored Post',
      ModlogActionType.modLockPost => actioned ? 'Locked Post' : 'Unlocked Post',
      ModlogActionType.modFeaturePost => actioned ? 'Featured Post' : 'Unfeatured Post',
      ModlogActionType.modRemoveComment => actioned ? 'Removed Comment' : 'Restored Comment',
      ModlogActionType.modRemoveCommunity => actioned ? 'Removed Community' : 'Restored Community',
      ModlogActionType.modBanFromCommunity => actioned ? 'Banned User from Community' : 'Unbanned User from Community',
      ModlogActionType.modBan => actioned ? 'Banned User' : 'Unbanned User',
      ModlogActionType.modAddCommunity => actioned ? 'Added Mod to Community' : 'Removed Mod from Community',
      ModlogActionType.modTransferCommunity => 'Transferred Mod to Community',
      ModlogActionType.modAdd => actioned ? 'Added Mod' : 'Removed Mod',
      ModlogActionType.adminPurgePerson => 'Purged Person',
      ModlogActionType.adminPurgeCommunity => 'Purged Community',
      ModlogActionType.adminPurgePost => 'Purged Post',
      ModlogActionType.adminPurgeComment => 'Purged Comment',
      ModlogActionType.modHideCommunity => actioned ? 'Hid Community' : 'Unhid Community',
      _ => 'Unknown Modlog Event Type',
    };
  }

  /// Generates a short description of the modlog event.
  String getModlogEventTypeDescription() {
    final l10n = AppLocalizations.of(GlobalContext.context)!;

    String? moderatorName = moderator?.displayName ?? moderator?.name ?? 'Moderator';
    String? userName = user?.displayName ?? user?.name ?? 'User';

    String? communityFullName = community != null
        ? community?.title != null
            ? '"${community?.title}"'
            : generateCommunityFullName(null, community!.name, fetchInstanceNameFromUrl(community!.actorId), communitySeparator: FullNameSeparator.at)
        : 'Community';

    return switch (type) {
      ModlogActionType.modRemovePost => actioned ? l10n.modRemovePostDescription(communityFullName, moderatorName) : l10n.modRestorePostDescription(communityFullName, moderatorName),
      ModlogActionType.modLockPost => actioned ? l10n.modLockPostDescription(communityFullName, moderatorName) : l10n.modUnlockPostDescription(communityFullName, moderatorName),
      ModlogActionType.modFeaturePost => actioned ? l10n.modFeaturedPostDescription(communityFullName, moderatorName) : l10n.modUnfeaturedPostDescription(communityFullName, moderatorName),
      ModlogActionType.modRemoveComment =>
        actioned ? l10n.modRemoveCommentDescription(moderatorName, '"${post!.name}"', userName) : l10n.modRestoreCommentDescription(moderatorName, '"${post!.name}"', userName),
      ModlogActionType.modRemoveCommunity => l10n.modRemoveCommunityDescription(communityFullName, moderatorName),
      ModlogActionType.modBanFromCommunity =>
        actioned ? l10n.modBanFromCommunityDescription(communityFullName, moderatorName, userName) : l10n.modUnbanFromCommunityDescription(communityFullName, moderatorName, userName),
      ModlogActionType.modBan => actioned ? l10n.modBanDescription(moderatorName, userName) : l10n.modUnbanDescription(moderatorName, userName),
      ModlogActionType.modAddCommunity => l10n.modAddCommunityDescription(communityFullName, moderatorName, userName),
      ModlogActionType.modTransferCommunity => l10n.modTransferCommunityDescription(moderatorName, communityFullName, userName),
      ModlogActionType.modAdd => actioned ? l10n.modAddDescription(moderatorName, userName) : l10n.modRemoveDescription(moderatorName, userName),
      ModlogActionType.adminPurgePerson => l10n.adminPurgePersonDescription,
      ModlogActionType.adminPurgeCommunity => l10n.adminPurgeCommunityDescription,
      ModlogActionType.adminPurgePost => l10n.adminPurgePostDescription,
      ModlogActionType.adminPurgeComment => l10n.adminPurgeCommentDescription,
      ModlogActionType.modHideCommunity => actioned ? l10n.modHideCommunityDescription(moderatorName, communityFullName) : l10n.modUnhideCommunityDescription(moderatorName, communityFullName),
      _ => 'Unknown Modlog Event Type',
    };
  }

  /// Gets the color for the modlog event type. A positive action will be green, a negative action will be red.
  Color getModlogEventColor() {
    return switch (type) {
      ModlogActionType.modRemovePost => actioned ? Colors.red : Colors.green,
      ModlogActionType.modLockPost => actioned ? Colors.red : Colors.green,
      ModlogActionType.modFeaturePost => post!.featuredCommunity ? Colors.green : Colors.red,
      ModlogActionType.modRemoveComment => actioned ? Colors.red : Colors.green,
      ModlogActionType.modRemoveCommunity => actioned ? Colors.red : Colors.green,
      ModlogActionType.modBanFromCommunity => actioned ? Colors.red : Colors.green,
      ModlogActionType.modBan => actioned ? Colors.red : Colors.green,
      ModlogActionType.modAddCommunity => actioned ? Colors.green : Colors.red,
      ModlogActionType.modTransferCommunity => Colors.green,
      ModlogActionType.modAdd => actioned ? Colors.green : Colors.red,
      ModlogActionType.adminPurgePerson => Colors.red,
      ModlogActionType.adminPurgeCommunity => Colors.red,
      ModlogActionType.adminPurgePost => Colors.red,
      ModlogActionType.adminPurgeComment => Colors.red,
      ModlogActionType.modHideCommunity => actioned ? Colors.red : Colors.green,
      _ => Colors.grey,
    };
  }

  /// Get the icon for the modlog event
  IconData getModlogEventIcon() {
    return switch (type) {
      ModlogActionType.modRemovePost => Icons.delete_rounded,
      ModlogActionType.modLockPost => Icons.lock_person_rounded,
      ModlogActionType.modFeaturePost => Icons.push_pin_rounded,
      ModlogActionType.modRemoveComment => Icons.comments_disabled_rounded,
      ModlogActionType.modRemoveCommunity => Icons.domain_disabled_rounded,
      ModlogActionType.modBanFromCommunity => Icons.person_off_rounded,
      ModlogActionType.modBan => Icons.person_off_rounded,
      ModlogActionType.modAddCommunity => Icons.person_add_alt_1_rounded,
      ModlogActionType.modTransferCommunity => Icons.swap_horiz_rounded,
      ModlogActionType.modAdd => Icons.person_add_alt_1_rounded,
      ModlogActionType.adminPurgePerson => Icons.person_off_rounded,
      ModlogActionType.adminPurgeCommunity => Icons.domain_disabled_rounded,
      ModlogActionType.adminPurgePost => Icons.delete_forever_rounded,
      ModlogActionType.adminPurgeComment => Icons.comments_disabled_rounded,
      ModlogActionType.modHideCommunity => Icons.disabled_visible_rounded,
      _ => Icons.question_mark_rounded,
    };
  }
}
