import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' as lemmy;

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
    final client = lemmy.LemmyApiV3(account.instance, debug: kDebugMode);

    final response = await client.run(lemmy.GetModlog(
      auth: account.jwt,
      page: currentPage,
      type: lemmy.ModlogActionType.values.firstWhere(
        (type) => type.name.toLowerCase() == modlogActionType?.name.toLowerCase(),
        orElse: () => lemmy.ModlogActionType.all,
      ),
      communityId: communityId,
      otherPersonId: userId,
      modPersonId: moderatorId,
      commentId: commentId,
    ));

    List<ModlogEventItem> items = [];

    // Convert the response to a list of modlog events
    List<ModlogEventItem> removedPosts = response.removedPosts.map((e) => parseModlogEvent(ModlogActionType.modRemovePost, e)).toList();
    List<ModlogEventItem> lockedPosts = response.lockedPosts.map((e) => parseModlogEvent(ModlogActionType.modLockPost, e)).toList();
    List<ModlogEventItem> featuredPosts = response.featuredPosts.map((e) => parseModlogEvent(ModlogActionType.modFeaturePost, e)).toList();
    List<ModlogEventItem> removedComments = response.removedComments.map((e) => parseModlogEvent(ModlogActionType.modRemoveComment, e)).toList();
    List<ModlogEventItem> removedCommunities = response.removedCommunities.map((e) => parseModlogEvent(ModlogActionType.modRemoveCommunity, e)).toList();
    List<ModlogEventItem> bannedFromCommunity = response.bannedFromCommunity.map((e) => parseModlogEvent(ModlogActionType.modBanFromCommunity, e)).toList();
    List<ModlogEventItem> banned = response.banned.map((e) => parseModlogEvent(ModlogActionType.modBan, e)).toList();
    List<ModlogEventItem> addedToCommunity = response.addedToCommunity.map((e) => parseModlogEvent(ModlogActionType.modAddCommunity, e)).toList();
    List<ModlogEventItem> transferredToCommunity = response.transferredToCommunity.map((e) => parseModlogEvent(ModlogActionType.modTransferCommunity, e)).toList();
    List<ModlogEventItem> added = response.added.map((e) => parseModlogEvent(ModlogActionType.modAdd, e)).toList();
    List<ModlogEventItem> adminPurgedPersons = response.adminPurgedPersons.map((e) => parseModlogEvent(ModlogActionType.adminPurgePerson, e)).toList();
    List<ModlogEventItem> adminPurgedCommunities = response.adminPurgedCommunities.map((e) => parseModlogEvent(ModlogActionType.adminPurgeCommunity, e)).toList();
    List<ModlogEventItem> adminPurgedPosts = response.adminPurgedPosts.map((e) => parseModlogEvent(ModlogActionType.adminPurgePost, e)).toList();
    List<ModlogEventItem> adminPurgedComments = response.adminPurgedComments.map((e) => parseModlogEvent(ModlogActionType.adminPurgeComment, e)).toList();
    List<ModlogEventItem> hiddenCommunities = response.hiddenCommunities.map((e) => parseModlogEvent(ModlogActionType.modHideCommunity, e)).toList();

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
        dateTime: event.modRemovePost.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        reason: event.modRemovePost.reason,
        post: ThunderPost.fromLemmyPost(event.post.toJson()),
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modRemovePost.removed,
      );
    case ModlogActionType.modLockPost:
      return ModlogEventItem(
        type: type,
        dateTime: event.modLockPost.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        post: ThunderPost.fromLemmyPost(event.post.toJson()),
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modLockPost.locked,
      );
    case ModlogActionType.modFeaturePost:
      return ModlogEventItem(
        type: type,
        dateTime: event.modFeaturePost.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        post: ThunderPost.fromLemmyPost(event.post.toJson()),
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modFeaturePost.featured,
      );
    case ModlogActionType.modRemoveComment:
      return ModlogEventItem(
        type: type,
        dateTime: event.modRemoveComment.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        reason: event.modRemoveComment.reason,
        user: event.commenter != null ? ThunderUser.fromLemmyUser(event.commenter.toJson()) : null,
        post: ThunderPost.fromLemmyPost(event.post.toJson()),
        comment: ThunderComment.fromLemmyComment(event.comment.toJson()),
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modRemoveComment.removed,
      );
    case ModlogActionType.modRemoveCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event.modRemoveCommunity.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        reason: event.modRemoveCommunity.reason,
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modRemoveCommunity.removed,
      );
    case ModlogActionType.modBanFromCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event.modBanFromCommunity.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        reason: event.modBanFromCommunity.reason,
        user: event.bannedPerson != null ? ThunderUser.fromLemmyUser(event.bannedPerson.toJson()) : null,
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modBanFromCommunity.banned,
      );
    case ModlogActionType.modBan:
      return ModlogEventItem(
        type: type,
        dateTime: event.modBan.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        reason: event.modBan.reason,
        user: event.bannedPerson != null ? ThunderUser.fromLemmyUser(event.bannedPerson.toJson()) : null,
        actioned: event.modBan.banned,
      );
    case ModlogActionType.modAddCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event.modAddCommunity.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        user: event.moddedPerson != null ? ThunderUser.fromLemmyUser(event.moddedPerson.toJson()) : null,
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: !event.modAddCommunity.removed,
      );
    case ModlogActionType.modTransferCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event.modTransferCommunity.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        user: event.moddedPerson != null ? ThunderUser.fromLemmyUser(event.moddedPerson.toJson()) : null,
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: true,
      );
    case ModlogActionType.modAdd:
      return ModlogEventItem(
        type: type,
        dateTime: event.modAdd.when,
        moderator: event.moderator != null ? ThunderUser.fromLemmyUser(event.moderator.toJson()) : null,
        user: event.moddedPerson != null ? ThunderUser.fromLemmyUser(event.moddedPerson.toJson()) : null,
        actioned: !event.modAdd.removed,
      );
    case ModlogActionType.adminPurgePerson:
      return ModlogEventItem(
        type: type,
        dateTime: event.adminPurgePerson.when,
        admin: event.admin != null ? ThunderUser.fromLemmyUser(event.admin.toJson()) : null,
        reason: event.adminPurgePerson.reason,
        actioned: true,
      );
    case ModlogActionType.adminPurgeCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event.adminPurgeCommunity.when,
        admin: event.admin != null ? ThunderUser.fromLemmyUser(event.admin.toJson()) : null,
        reason: event.adminPurgeCommunity.reason,
        actioned: true,
      );
    case ModlogActionType.adminPurgePost:
      return ModlogEventItem(
        type: type,
        dateTime: event.adminPurgePost.when,
        admin: event.admin != null ? ThunderUser.fromLemmyUser(event.admin.toJson()) : null,
        reason: event.adminPurgePost.reason,
        actioned: true,
      );
    case ModlogActionType.adminPurgeComment:
      return ModlogEventItem(
        type: type,
        dateTime: event.adminPurgeComment.when,
        admin: event.admin != null ? ThunderUser.fromLemmyUser(event.admin.toJson()) : null,
        reason: event.adminPurgeComment.reason,
        actioned: true,
      );
    case ModlogActionType.modHideCommunity:
      return ModlogEventItem(
        type: type,
        dateTime: event.modHideCommunity.when,
        admin: event.admin != null ? ThunderUser.fromLemmyUser(event.admin.toJson()) : null,
        reason: event.modHideCommunity.reason,
        community: ThunderCommunity.fromLemmyCommunity(event.community.toJson()),
        actioned: event.modHideCommunity.hidden,
      );
    default:
      throw Exception(l10n.missingErrorMessage);
  }
}
