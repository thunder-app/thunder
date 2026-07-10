import 'package:flutter/material.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';
import 'package:thunder/src/core/domain/models/modlog_event_item.dart';
import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';

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

  factory ModlogEventItem.fromModlogEvent(ModlogEvent event) {
    return ModlogEventItem(
      type: event.type,
      dateTime: event.dateTime,
      moderator: event.moderator,
      admin: event.admin,
      reason: event.reason,
      user: event.user,
      post: event.post,
      comment: event.comment,
      community: event.community,
      actioned: event.actioned,
    );
  }

  /// The type of the event.
  final ModlogActionType type;

  /// The date and time of the event.
  final String dateTime;

  /// The moderator who performed the action.
  final ThunderUser? moderator;

  /// The admin who performed the action.
  final ThunderUser? admin;

  /// The reason for the action.
  final String? reason;

  /// The user associated with the action.
  final ThunderUser? user;

  /// The post associated with the action.
  final ThunderPost? post;

  /// The comment associated with the action.
  final ThunderComment? comment;

  /// The community associated with the action.
  final ThunderCommunity? community;

  /// Whether the action has been performed or reverted.
  /// If `true`, the action has been performed. If `false`, the action has been reverted.
  final bool actioned;

  String getModlogEventTypeName() {
    final l10n = AppLocalizations.of(GlobalContext.context)!;

    return switch (type) {
      ModlogActionType.modRemovePost => actioned ? l10n.removedPost : l10n.restoredPost,
      ModlogActionType.modLockPost => actioned ? l10n.lockedPost : l10n.unlockedPost,
      ModlogActionType.modFeaturePost => actioned ? l10n.featuredPost : l10n.unfeaturedPost,
      ModlogActionType.modRemoveComment => actioned ? l10n.removedComment : l10n.restoredComment,
      ModlogActionType.modRemoveCommunity => actioned ? l10n.removedCommunity : l10n.restoredCommunity,
      ModlogActionType.modBanFromCommunity => actioned ? l10n.banFromCommunity : l10n.unbanFromCommunity,
      ModlogActionType.modBan => actioned ? l10n.bannedUser : l10n.unbannedUser,
      ModlogActionType.modAddCommunity => actioned ? l10n.addedModToCommunity : l10n.removedModFromCommunity,
      ModlogActionType.modTransferCommunity => l10n.transferredModToCommunity,
      ModlogActionType.modAdd => actioned ? l10n.addedInstanceMod : l10n.removedInstanceMod,
      ModlogActionType.adminPurgePerson => l10n.purgedPerson,
      ModlogActionType.adminPurgeCommunity => l10n.purgedCommunity,
      ModlogActionType.adminPurgePost => l10n.purgedPost,
      ModlogActionType.adminPurgeComment => l10n.purgedComment,
      ModlogActionType.modHideCommunity => actioned ? l10n.hidCommunity : l10n.unhidCommunity,
      _ => l10n.missingErrorMessage,
    };
  }

  /// Gets the color for the modlog event type. A positive action will be green, a negative action will be red.
  Color getModlogEventColor() {
    return switch (type) {
      ModlogActionType.modRemovePost => actioned ? Colors.red : Colors.green,
      ModlogActionType.modLockPost => actioned ? Colors.red : Colors.green,
      ModlogActionType.modFeaturePost => post!.status.featuredCommunity ? Colors.green : Colors.red,
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
