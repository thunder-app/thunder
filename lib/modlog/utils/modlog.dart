import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/modlog/modlog.dart';
import 'package:thunder/utils/global_context.dart';

/// Helper function which handles the logic of fetching modlog events from the API
Future<Map<String, dynamic>> fetchModlogEvents({
  int limit = 20,
  int page = 1,
  ModlogActionType? modlogActionType,
  int? communityId,
  int? userId,
  int? moderatorId,
  required LemmyClient lemmyClient,
}) async {
  Account? account = await fetchActiveProfileAccount();

  bool hasReachedEnd = false;

  List<ModlogEventItem> modLogEventItems = [];

  int currentPage = page;

  // Guarantee that we fetch at least x events (unless we reach the end of the feed)
  do {
    GetModlogResponse getModlogResponse =
        await lemmyClient.lemmyApiV3.run(GetModlog(
      auth: account?.jwt,
      page: currentPage,
      type: modlogActionType,
      communityId: communityId,
      otherPersonId: userId,
      modPersonId: moderatorId,
    ));

    List<ModlogEventItem> items = [];

    // Convert the response to a list of modlog events
    List<ModlogEventItem> removedPosts = getModlogResponse.removedPosts
        .map((ModRemovePostView e) =>
            parseModlogEvent(ModlogActionType.modRemovePost, e))
        .toList();
    List<ModlogEventItem> lockedPosts = getModlogResponse.lockedPosts
        .map((ModLockPostView e) =>
            parseModlogEvent(ModlogActionType.modLockPost, e))
        .toList();
    List<ModlogEventItem> featuredPosts = getModlogResponse.featuredPosts
        .map((ModFeaturePostView e) =>
            parseModlogEvent(ModlogActionType.modFeaturePost, e))
        .toList();
    List<ModlogEventItem> removedComments = getModlogResponse.removedComments
        .map((ModRemoveCommentView e) =>
            parseModlogEvent(ModlogActionType.modRemoveComment, e))
        .toList();
    List<ModlogEventItem> removedCommunities = getModlogResponse
        .removedCommunities
        .map((ModRemoveCommunityView e) =>
            parseModlogEvent(ModlogActionType.modRemoveCommunity, e))
        .toList();
    List<ModlogEventItem> bannedFromCommunity = getModlogResponse
        .bannedFromCommunity
        .map((ModBanFromCommunityView e) =>
            parseModlogEvent(ModlogActionType.modBanFromCommunity, e))
        .toList();
    List<ModlogEventItem> banned = getModlogResponse.banned
        .map((ModBanView e) => parseModlogEvent(ModlogActionType.modBan, e))
        .toList();
    List<ModlogEventItem> addedToCommunity = getModlogResponse.addedToCommunity
        .map((ModAddCommunityView e) =>
            parseModlogEvent(ModlogActionType.modAddCommunity, e))
        .toList();
    List<ModlogEventItem> transferredToCommunity = getModlogResponse
        .transferredToCommunity
        .map((ModTransferCommunityView e) =>
            parseModlogEvent(ModlogActionType.modTransferCommunity, e))
        .toList();
    List<ModlogEventItem> added = getModlogResponse.added
        .map((e) => parseModlogEvent(ModlogActionType.modAdd, e))
        .toList();
    List<ModlogEventItem> adminPurgedPersons = getModlogResponse
        .adminPurgedPersons
        .map((e) => parseModlogEvent(ModlogActionType.adminPurgePerson, e))
        .toList();
    List<ModlogEventItem> adminPurgedCommunities = getModlogResponse
        .adminPurgedCommunities
        .map((e) => parseModlogEvent(ModlogActionType.adminPurgeCommunity, e))
        .toList();
    List<ModlogEventItem> adminPurgedPosts = getModlogResponse.adminPurgedPosts
        .map((e) => parseModlogEvent(ModlogActionType.adminPurgePost, e))
        .toList();
    List<ModlogEventItem> adminPurgedComments = getModlogResponse
        .adminPurgedComments
        .map((e) => parseModlogEvent(ModlogActionType.adminPurgeComment, e))
        .toList();
    List<ModlogEventItem> hiddenCommunities = getModlogResponse
        .hiddenCommunities
        .map((e) => parseModlogEvent(ModlogActionType.modHideCommunity, e))
        .toList();

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

  return {
    'modLogEventItems': modLogEventItems,
    'hasReachedEnd': hasReachedEnd,
    'currentPage': currentPage
  };
}

/// Given a modlog event, return a normalized [ModlogEventItem]. The response from the Lemmy API returns different types of events for different actions.
/// This function parses the event to a [ModlogEventItem]
ModlogEventItem parseModlogEvent(ModlogActionType type, dynamic event) {
  final l10n = AppLocalizations.of(GlobalContext.context)!;

  switch (type) {
    case ModlogActionType.modRemovePost:
      ModRemovePostView modRemovePostView = (event as ModRemovePostView);
      return ModlogEventItem(
        type: type,
        dateTime: modRemovePostView.modRemovePost.when,
        moderator: modRemovePostView.moderator,
        reason: modRemovePostView.modRemovePost.reason,
        post: modRemovePostView.post,
        community: modRemovePostView.community,
        actioned: modRemovePostView.modRemovePost.removed,
      );
    case ModlogActionType.modLockPost:
      ModLockPostView modLockPostView = (event as ModLockPostView);
      return ModlogEventItem(
        type: type,
        dateTime: modLockPostView.modLockPost.when,
        moderator: modLockPostView.moderator,
        post: modLockPostView.post,
        community: modLockPostView.community,
        actioned: modLockPostView.modLockPost.locked,
      );
    case ModlogActionType.modFeaturePost:
      ModFeaturePostView modFeaturePostView = (event as ModFeaturePostView);
      return ModlogEventItem(
        type: type,
        dateTime: modFeaturePostView.modFeaturePost.when,
        moderator: modFeaturePostView.moderator,
        post: modFeaturePostView.post,
        community: modFeaturePostView.community,
        actioned: modFeaturePostView.modFeaturePost.featured,
      );
    case ModlogActionType.modRemoveComment:
      ModRemoveCommentView modRemoveCommentView =
          (event as ModRemoveCommentView);
      return ModlogEventItem(
        type: type,
        dateTime: modRemoveCommentView.modRemoveComment.when,
        moderator: modRemoveCommentView.moderator,
        reason: modRemoveCommentView.modRemoveComment.reason,
        user: modRemoveCommentView.commenter,
        post: modRemoveCommentView.post,
        comment: modRemoveCommentView.comment,
        community: modRemoveCommentView.community,
        actioned: modRemoveCommentView.modRemoveComment.removed,
      );
    case ModlogActionType.modRemoveCommunity:
      ModRemoveCommunityView modRemoveCommunityView =
          (event as ModRemoveCommunityView);
      return ModlogEventItem(
        type: type,
        dateTime: modRemoveCommunityView.modRemoveCommunity.when,
        moderator: modRemoveCommunityView.moderator,
        reason: modRemoveCommunityView.modRemoveCommunity.reason,
        community: modRemoveCommunityView.community,
        actioned: modRemoveCommunityView.modRemoveCommunity.removed,
      );
    case ModlogActionType.modBanFromCommunity:
      ModBanFromCommunityView modBanFromCommunityView =
          (event as ModBanFromCommunityView);
      return ModlogEventItem(
        type: type,
        dateTime: modBanFromCommunityView.modBanFromCommunity.when,
        moderator: modBanFromCommunityView.moderator,
        reason: modBanFromCommunityView.modBanFromCommunity.reason,
        user: modBanFromCommunityView.bannedPerson,
        community: modBanFromCommunityView.community,
        actioned: modBanFromCommunityView.modBanFromCommunity.banned,
      );
    case ModlogActionType.modBan:
      ModBanView modBanView = (event as ModBanView);
      return ModlogEventItem(
        type: type,
        dateTime: modBanView.modBan.when,
        moderator: modBanView.moderator,
        reason: modBanView.modBan.reason,
        user: modBanView.bannedPerson,
        actioned: modBanView.modBan.banned,
      );
    case ModlogActionType.modAddCommunity:
      ModAddCommunityView modAddCommunityView = (event as ModAddCommunityView);
      return ModlogEventItem(
        type: type,
        dateTime: modAddCommunityView.modAddCommunity.when,
        moderator: modAddCommunityView.moderator,
        user: modAddCommunityView.moddedPerson,
        community: modAddCommunityView.community,
        actioned: !modAddCommunityView.modAddCommunity.removed,
      );
    case ModlogActionType.modTransferCommunity:
      ModTransferCommunityView modTransferCommunityView =
          (event as ModTransferCommunityView);
      return ModlogEventItem(
        type: type,
        dateTime: modTransferCommunityView.modTransferCommunity.when,
        moderator: modTransferCommunityView.moderator,
        user: modTransferCommunityView.moddedPerson,
        community: modTransferCommunityView.community,
        actioned: true,
      );
    case ModlogActionType.modAdd:
      ModAddView modAddView = (event as ModAddView);
      return ModlogEventItem(
        type: type,
        dateTime: modAddView.modAdd.when,
        moderator: modAddView.moderator,
        user: modAddView.moddedPerson,
        actioned: !modAddView.modAdd.removed,
      );
    case ModlogActionType.adminPurgePerson:
      AdminPurgePersonView adminPurgePersonView =
          (event as AdminPurgePersonView);
      return ModlogEventItem(
        type: type,
        dateTime: adminPurgePersonView.adminPurgePerson.when,
        admin: adminPurgePersonView.admin,
        reason: adminPurgePersonView.adminPurgePerson.reason,
        actioned: true,
      );
    case ModlogActionType.adminPurgeCommunity:
      AdminPurgeCommunityView adminPurgeCommunityView =
          (event as AdminPurgeCommunityView);
      return ModlogEventItem(
        type: type,
        dateTime: adminPurgeCommunityView.adminPurgeCommunity.when,
        admin: adminPurgeCommunityView.admin,
        reason: adminPurgeCommunityView.adminPurgeCommunity.reason,
        actioned: true,
      );
    case ModlogActionType.adminPurgePost:
      AdminPurgePostView adminPurgePostView = (event as AdminPurgePostView);
      return ModlogEventItem(
        type: type,
        dateTime: adminPurgePostView.adminPurgePost.when,
        admin: adminPurgePostView.admin,
        reason: adminPurgePostView.adminPurgePost.reason,
        actioned: true,
      );
    case ModlogActionType.adminPurgeComment:
      AdminPurgeCommentView adminPurgeCommentView =
          (event as AdminPurgeCommentView);
      return ModlogEventItem(
        type: type,
        dateTime: adminPurgeCommentView.adminPurgeComment.when,
        admin: adminPurgeCommentView.admin,
        reason: adminPurgeCommentView.adminPurgeComment.reason,
        actioned: true,
      );
    case ModlogActionType.modHideCommunity:
      ModHideCommunityView modHideCommunityView =
          (event as ModHideCommunityView);
      return ModlogEventItem(
        type: type,
        dateTime: modHideCommunityView.modHideCommunity.when,
        admin: modHideCommunityView.admin,
        reason: modHideCommunityView.modHideCommunity.reason,
        community: modHideCommunityView.community,
        actioned: modHideCommunityView.modHideCommunity.hidden,
      );
    default:
      throw Exception(l10n.missingErrorMessage);
  }
}
