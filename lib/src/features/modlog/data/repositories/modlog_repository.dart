import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// Model representing a page of modlog events
class ModlogFeed {
  final List<ModlogEventItem> items;
  final bool hasReachedEnd;
  final int currentPage;

  ModlogFeed({
    required this.items,
    required this.hasReachedEnd,
    required this.currentPage,
  });
}

/// Interface for a modlog repository
abstract class ModlogRepository {
  Future<ModlogFeed> getModlogEvents({
    int limit = 20,
    int page = 1,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  });
}

/// Implementation of [ModlogRepository] using Lemmy API
class ModlogRepositoryImpl implements ModlogRepository {
  ModlogRepositoryImpl();

  @override
  Future<ModlogFeed> getModlogEvents({
    int limit = 20,
    int page = 1,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  }) async {
    final result = await _fetchModlogEvents(
      limit: limit,
      page: page,
      modlogActionType: modlogActionType,
      communityId: communityId,
      userId: userId,
      moderatorId: moderatorId,
      commentId: commentId,
    );
    return ModlogFeed(
      items: result['modLogEventItems'] as List<ModlogEventItem>,
      hasReachedEnd: result['hasReachedEnd'] as bool,
      currentPage: result['currentPage'] as int,
    );
  }
}

/// Helper function which handles the logic of fetching modlog events from the API
Future<Map<String, dynamic>> _fetchModlogEvents({
  int limit = 20,
  int page = 1,
  ModlogActionType? modlogActionType,
  int? communityId,
  int? userId,
  int? moderatorId,
  int? commentId,
}) async {
  final account = await fetchActiveProfile();

  bool hasReachedEnd = false;

  List<ModlogEventItem> modLogEventItems = [];

  int currentPage = page;

  // Guarantee that we fetch at least x events (unless we reach the end of the feed)
  do {
    final response = await LemmyApi(account: account).getModlog(
      page: currentPage,
      modlogActionType: modlogActionType,
      communityId: communityId,
      userId: userId,
      moderatorId: moderatorId,
      commentId: commentId,
    );

    List<ModlogEventItem> items = [];

    // Convert the response to a list of modlog events
    List<ModlogEventItem> removedPosts = response['removed_posts'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modRemovePost, e)).toList();
    List<ModlogEventItem> lockedPosts = response['locked_posts'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modLockPost, e)).toList();
    List<ModlogEventItem> featuredPosts = response['featured_posts'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modFeaturePost, e)).toList();
    List<ModlogEventItem> removedComments = response['removed_comments'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modRemoveComment, e)).toList();
    List<ModlogEventItem> removedCommunities = response['removed_communities'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modRemoveCommunity, e)).toList();
    List<ModlogEventItem> bannedFromCommunity = response['banned_from_community'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modBanFromCommunity, e)).toList();
    List<ModlogEventItem> banned = response['banned'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modBan, e)).toList();
    List<ModlogEventItem> addedToCommunity = response['added_to_community'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modAddCommunity, e)).toList();
    List<ModlogEventItem> transferredToCommunity = response['transferred_to_community'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modTransferCommunity, e)).toList();
    List<ModlogEventItem> added = response['added'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modAdd, e)).toList();
    List<ModlogEventItem> adminPurgedPersons = response['admin_purged_persons'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgePerson, e)).toList();
    List<ModlogEventItem> adminPurgedCommunities = response['admin_purged_communities'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgeCommunity, e)).toList();
    List<ModlogEventItem> adminPurgedPosts = response['admin_purged_posts'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgePost, e)).toList();
    List<ModlogEventItem> adminPurgedComments = response['admin_purged_comments'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgeComment, e)).toList();
    List<ModlogEventItem> hiddenCommunities = response['hidden_communities'].map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modHideCommunity, e)).toList();

    items.addAll(removedPosts);
    items.addAll(lockedPosts);
    items.addAll(featuredPosts);
    items.addAll(removedComments);
    items.addAll(removedCommunities);
    items.addAll(bannedFromCommunity);
    items.addAll(banned);
    items.addAll(addedToCommunity);
    items.addAll(transferredToCommunity);
    items.addAll(added);
    items.addAll(adminPurgedPersons);
    items.addAll(adminPurgedCommunities);
    items.addAll(adminPurgedPosts);
    items.addAll(adminPurgedComments);
    items.addAll(hiddenCommunities);

    modLogEventItems.addAll(items);

    if (items.isEmpty) hasReachedEnd = true;
    currentPage++;
  } while (!hasReachedEnd && modLogEventItems.length < limit);

  return {'modLogEventItems': modLogEventItems, 'hasReachedEnd': hasReachedEnd, 'currentPage': currentPage};
}

/// Given a modlog event, return a normalized [ModlogEventItem]. The response from the Lemmy API returns different types of events for different actions.
/// This function parses the event to a [ModlogEventItem]
ModlogEventItem parseModlogEvent(ModlogActionType type, dynamic event) {
  final l10n = AppLocalizations.of(GlobalContext.context)!;

  switch (type) {
    case ModlogActionType.modRemovePost:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_remove_post']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        reason: event['mod_remove_post']['reason'],
        post: ThunderPost.fromLemmyPost(event['post']),
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_remove_post']['removed'],
      );
    case ModlogActionType.modLockPost:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_lock_post']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        post: ThunderPost.fromLemmyPost(event['post']),
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_lock_post']['locked'],
      );
    case ModlogActionType.modFeaturePost:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_feature_post']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        post: ThunderPost.fromLemmyPost(event['post']),
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_feature_post']['featured'],
      );
    case ModlogActionType.modRemoveComment:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_remove_comment']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        reason: event['mod_remove_comment']['reason'],
        user: event['commenter'] != null ? ThunderUser.fromLemmyUser(event['commenter']) : null,
        post: ThunderPost.fromLemmyPost(event['post']),
        comment: ThunderComment.fromLemmyComment(event['comment']),
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_remove_comment']['removed'],
      );
    case ModlogActionType.modRemoveCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_remove_community']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        reason: event['mod_remove_community']['reason'],
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_remove_community']['removed'],
      );
    case ModlogActionType.modBanFromCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_ban_from_community']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        reason: event['mod_ban_from_community']['reason'],
        user: event['banned_person'] != null ? ThunderUser.fromLemmyUser(event['banned_person']) : null,
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_ban_from_community']['banned'],
      );
    case ModlogActionType.modBan:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_ban']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        reason: event['mod_ban']['reason'],
        user: event['banned_person'] != null ? ThunderUser.fromLemmyUser(event['banned_person']) : null,
        actioned: event['mod_ban']['banned'],
      );
    case ModlogActionType.modAddCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_add_community']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        user: event['modded_person'] != null ? ThunderUser.fromLemmyUser(event['modded_person']) : null,
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: !event['mod_add_community']['removed'],
      );
    case ModlogActionType.modTransferCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_transfer_community']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        user: event['modded_person'] != null ? ThunderUser.fromLemmyUser(event['modded_person']) : null,
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: true,
      );
    case ModlogActionType.modAdd:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_add']['when_'],
        moderator: event['moderator'] != null ? ThunderUser.fromLemmyUser(event['moderator']) : null,
        user: event['modded_person'] != null ? ThunderUser.fromLemmyUser(event['modded_person']) : null,
        actioned: !event['mod_add']['removed'],
      );
    case ModlogActionType.adminPurgePerson:
      return ModlogEventItem(
        type: type,
        dateTime: event['admin_purge_person']['when_'],
        admin: event['admin'] != null ? ThunderUser.fromLemmyUser(event['admin']) : null,
        reason: event['admin_purge_person']['reason'],
        actioned: true,
      );
    case ModlogActionType.adminPurgeCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event['admin_purge_community']['when_'],
        admin: event['admin'] != null ? ThunderUser.fromLemmyUser(event['admin']) : null,
        reason: event['admin_purge_community']['reason'],
        actioned: true,
      );
    case ModlogActionType.adminPurgePost:
      return ModlogEventItem(
        type: type,
        dateTime: event['admin_purge_post']['when_'],
        admin: event['admin'] != null ? ThunderUser.fromLemmyUser(event['admin']) : null,
        reason: event['admin_purge_post']['reason'],
        actioned: true,
      );
    case ModlogActionType.adminPurgeComment:
      return ModlogEventItem(
        type: type,
        dateTime: event['admin_purge_comment']['when_'],
        admin: event['admin'] != null ? ThunderUser.fromLemmyUser(event['admin']) : null,
        reason: event['admin_purge_comment']['reason'],
        actioned: true,
      );
    case ModlogActionType.modHideCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event['mod_hide_community']['when'],
        admin: event['admin'] != null ? ThunderUser.fromLemmyUser(event['admin']) : null,
        reason: event['mod_hide_community']['reason'],
        community: ThunderCommunity.fromLemmyCommunity(event['community']),
        actioned: event['mod_hide_community']['hidden'],
      );
    default:
      throw Exception(l10n.missingErrorMessage);
  }
}
