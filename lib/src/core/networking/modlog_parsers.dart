import 'package:collection/collection.dart';

import 'package:thunder/src/core/networking/mappers/lemmy_v4_mapper.dart';
import 'package:thunder/src/core/networking/mappers/primitive_mapper.dart';
import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';
import 'package:thunder/src/core/domain/models/modlog_event_item.dart';

/// Parses a grouped Lemmy v3 modlog response into normalized events.
List<ModlogEvent> modlogEventsFromV3Response(
  Map<String, dynamic> response,
  PrimitiveMapper mapper,
) {
  const groupedKeys = <String, ModlogActionType>{
    'removed_posts': ModlogActionType.modRemovePost,
    'locked_posts': ModlogActionType.modLockPost,
    'featured_posts': ModlogActionType.modFeaturePost,
    'removed_comments': ModlogActionType.modRemoveComment,
    'removed_communities': ModlogActionType.modRemoveCommunity,
    'banned_from_community': ModlogActionType.modBanFromCommunity,
    'banned': ModlogActionType.modBan,
    'added_to_community': ModlogActionType.modAddCommunity,
    'transferred_to_community': ModlogActionType.modTransferCommunity,
    'added': ModlogActionType.modAdd,
    'admin_purged_persons': ModlogActionType.adminPurgePerson,
    'admin_purged_communities': ModlogActionType.adminPurgeCommunity,
    'admin_purged_posts': ModlogActionType.adminPurgePost,
    'admin_purged_comments': ModlogActionType.adminPurgeComment,
    'hidden_communities': ModlogActionType.modHideCommunity,
  };

  final items = <ModlogEvent>[];
  for (final entry in groupedKeys.entries) {
    final events = response[entry.key];
    if (events is! List) continue;
    items.addAll(events.map((event) => modlogEventFromV3(entry.value, event, mapper)));
  }
  return items;
}

/// Parses a single Lemmy v3 modlog event into a normalized [ModlogEvent].
ModlogEvent modlogEventFromV3(
  ModlogActionType type,
  dynamic event,
  PrimitiveMapper mapper,
) {
  switch (type) {
    case ModlogActionType.modRemovePost:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_remove_post']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        reason: event['mod_remove_post']['reason'],
        post: mapper.post(event['post']),
        community: mapper.community(event['community']),
        actioned: event['mod_remove_post']['removed'],
      );
    case ModlogActionType.modLockPost:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_lock_post']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        post: mapper.post(event['post']),
        community: mapper.community(event['community']),
        actioned: event['mod_lock_post']['locked'],
      );
    case ModlogActionType.modFeaturePost:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_feature_post']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        post: mapper.post(event['post']),
        community: mapper.community(event['community']),
        actioned: event['mod_feature_post']['featured'],
      );
    case ModlogActionType.modRemoveComment:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_remove_comment']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        reason: event['mod_remove_comment']['reason'],
        user: event['commenter'] != null ? mapper.user(event['commenter']) : null,
        post: mapper.post(event['post']),
        comment: mapper.comment(event['comment']),
        community: mapper.community(event['community']),
        actioned: event['mod_remove_comment']['removed'],
      );
    case ModlogActionType.modRemoveCommunity:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_remove_community']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        reason: event['mod_remove_community']['reason'],
        community: mapper.community(event['community']),
        actioned: event['mod_remove_community']['removed'],
      );
    case ModlogActionType.modBanFromCommunity:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_ban_from_community']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        reason: event['mod_ban_from_community']['reason'],
        user: event['banned_person'] != null ? mapper.user(event['banned_person']) : null,
        community: mapper.community(event['community']),
        actioned: event['mod_ban_from_community']['banned'],
      );
    case ModlogActionType.modBan:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_ban']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        reason: event['mod_ban']['reason'],
        user: event['banned_person'] != null ? mapper.user(event['banned_person']) : null,
        actioned: event['mod_ban']['banned'],
      );
    case ModlogActionType.modAddCommunity:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_add_community']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        user: event['modded_person'] != null ? mapper.user(event['modded_person']) : null,
        community: mapper.community(event['community']),
        actioned: !event['mod_add_community']['removed'],
      );
    case ModlogActionType.modTransferCommunity:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_transfer_community']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        user: event['modded_person'] != null ? mapper.user(event['modded_person']) : null,
        community: mapper.community(event['community']),
        actioned: true,
      );
    case ModlogActionType.modAdd:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_add']['when_'],
        moderator: event['moderator'] != null ? mapper.user(event['moderator']) : null,
        user: event['modded_person'] != null ? mapper.user(event['modded_person']) : null,
        actioned: !event['mod_add']['removed'],
      );
    case ModlogActionType.adminPurgePerson:
      return ModlogEvent(
        type: type,
        dateTime: event['admin_purge_person']['when_'],
        admin: event['admin'] != null ? mapper.user(event['admin']) : null,
        reason: event['admin_purge_person']['reason'],
        actioned: true,
      );
    case ModlogActionType.adminPurgeCommunity:
      return ModlogEvent(
        type: type,
        dateTime: event['admin_purge_community']['when_'],
        admin: event['admin'] != null ? mapper.user(event['admin']) : null,
        reason: event['admin_purge_community']['reason'],
        actioned: true,
      );
    case ModlogActionType.adminPurgePost:
      return ModlogEvent(
        type: type,
        dateTime: event['admin_purge_post']['when_'],
        admin: event['admin'] != null ? mapper.user(event['admin']) : null,
        reason: event['admin_purge_post']['reason'],
        actioned: true,
      );
    case ModlogActionType.adminPurgeComment:
      return ModlogEvent(
        type: type,
        dateTime: event['admin_purge_comment']['when_'],
        admin: event['admin'] != null ? mapper.user(event['admin']) : null,
        reason: event['admin_purge_comment']['reason'],
        actioned: true,
      );
    case ModlogActionType.modHideCommunity:
      return ModlogEvent(
        type: type,
        dateTime: event['mod_hide_community']['when'],
        admin: event['admin'] != null ? mapper.user(event['admin']) : null,
        reason: event['mod_hide_community']['reason'],
        community: mapper.community(event['community']),
        actioned: event['mod_hide_community']['hidden'],
      );
    default:
      throw Exception('Unknown modlog type: $type');
  }
}

/// Parses a Lemmy v4 modlog item into a normalized [ModlogEvent].
ModlogEvent? modlogEventFromV4(
  dynamic raw,
  LemmyV4PrimitiveMapper mapper,
) {
  if (raw is! Map<String, dynamic>) return null;
  final modlog = raw['modlog'];
  if (modlog is! Map<String, dynamic>) return null;
  final kind = modlog['type_']?.toString();
  final type = ModlogActionType.values.firstWhereOrNull((value) => value.value.toLowerCase() == kind?.toLowerCase());
  if (type == null) return null;

  return ModlogEvent(
    type: type,
    dateTime: modlog['when_'] ?? modlog['published_at'],
    moderator: raw['moderator'] != null ? mapper.user(raw['moderator']) : null,
    reason: modlog['reason'],
    user: raw['target_person'] != null ? mapper.user(raw['target_person']) : null,
    post: raw['target_post'] != null ? mapper.post(raw['target_post']) : null,
    comment: raw['target_comment'] != null ? mapper.comment(raw['target_comment']) : null,
    community: raw['target_community'] != null ? mapper.community(raw['target_community']) : null,
    actioned: modlog['removed'] ?? modlog['locked'] ?? modlog['featured'] ?? modlog['banned'] ?? true,
  );
}
