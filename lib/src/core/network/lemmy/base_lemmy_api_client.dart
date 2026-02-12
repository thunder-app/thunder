import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/search_sort_type.dart';
import 'package:thunder/src/core/models/thunder_comment_report.dart';
import 'package:thunder/src/core/models/thunder_post_report.dart';
import 'package:thunder/src/core/models/thunder_private_message.dart';
import 'package:thunder/src/core/models/thunder_site.dart';
import 'package:thunder/src/core/models/thunder_site_response.dart';
import 'package:thunder/src/core/network/base_api_client.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

/// Base class for Lemmy API clients, containing shared parsing helpers.
/// Endpoint implementations live in version-specific clients.
abstract class BaseLemmyApiClient extends BaseApiClient implements ThunderApiClient {
  BaseLemmyApiClient({
    required super.account,
    super.debug,
    required super.version,
    super.httpClient,
  });

  @override
  String get platformName => 'Lemmy';

  // =============================================================
  // Abstract methods for version-specific parsing
  // =============================================================

  /// Parse a post from raw JSON (version-specific).
  ThunderPost parsePost(Map<String, dynamic> json);

  /// Parse a comment from raw JSON (version-specific).
  ThunderComment parseComment(Map<String, dynamic> json);

  /// Parse a user/person from raw JSON (version-specific).
  ThunderUser parseUser(Map<String, dynamic> json);

  /// Parse a user view from raw JSON (version-specific).
  ThunderUser parseUserView(Map<String, dynamic> json);

  /// Parse a community from raw JSON (version-specific).
  ThunderCommunity parseCommunity(Map<String, dynamic> json);

  /// Parse a community view from raw JSON (version-specific).
  ThunderCommunity parseCommunityView(Map<String, dynamic> json);

  /// Parse a site response from raw JSON (version-specific).
  ThunderSiteResponse parseSiteResponse(Map<String, dynamic> json);

  // =============================================================
  // Authentication & Site
  // =============================================================

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderSiteResponse> site() async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Posts
  // =============================================================

  @override
  Future<GetPostResponse> getPost(int postId, {int? commentId}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<GetPostsResponse> getPosts({
    String? cursor,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    String? query,
    int? personId,
    bool? likedOnly,
    int? feedId,
    int? topicId,
    bool? ignoreSticky,
    bool? showHidden,
    bool? showSaved,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderPost> createPost({
    required String title,
    required int communityId,
    String? url,
    String? contents,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
    String? altText,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderPost> editPost({
    required int postId,
    required String title,
    String? url,
    String? contents,
    String? altText,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> readPost({required List<int> postIds, required bool read}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> hidePost({required int postId, required bool hide}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> lockPost({required int postId, required bool locked}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> reportPost({required int postId, required String reason}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<List<ThunderPostReport>> getPostReports({
    int? postId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderPostReport> resolvePostReport({required int reportId, required bool resolved}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Comments
  // =============================================================

  @override
  Future<ThunderComment> getComment(int commentId) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<GetCommentsResponse> getComments({
    required int postId,
    int? page,
    String? cursor,
    int? limit,
    int? maxDepth,
    int? communityId,
    int? parentId,
    CommentSortType? commentSortType,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderComment> createComment({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderComment> editComment({
    required int commentId,
    required String content,
    int? languageId,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> reportComment({required int commentId, required String reason}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<List<ThunderCommentReport>> getCommentReports({
    int? commentId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderCommentReport> resolveCommentReport({required int reportId, required bool resolved}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Communities
  // =============================================================

  @override
  Future<GetCommunityResponse> getCommunity({int? id, String? name}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<List<ThunderCommunity>> getCommunities({
    int? page,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Users
  // =============================================================

  @override
  Future<GetUserResponse> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ThunderUser> banUserFromCommunity({
    required int userId,
    required int communityId,
    required bool ban,
    bool? removeData,
    String? reason,
    int? expires,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<List<ThunderUser>> addModerator({
    required int userId,
    required int communityId,
    required bool added,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Search
  // =============================================================

  @override
  Future<SearchResponse> search({
    required String query,
    int? communityId,
    String? communityName,
    int? creatorId,
    MetaSearchType? type,
    SearchSortType? sort,
    FeedListType? listingType,
    int? page,
    int? limit,
    int? minimumUpvotes,
    bool? nsfw,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<ResolveResponse> resolve({required String query}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Notifications
  // =============================================================

  @override
  Future<UnreadCountResponse> unreadCount() async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<List<ThunderComment>> getCommentReplies({
    int? page,
    int? limit,
    CommentSortType? sort,
    bool unread = false,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> markCommentReplyAsRead({required int replyId, required bool read}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<List<ThunderComment>> getCommentMentions({
    int? page,
    int? limit,
    CommentSortType? sort,
    bool unread = false,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> markCommentMentionAsRead({required int mentionId, required bool read}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Private Messages
  // =============================================================

  @override
  Future<List<ThunderPrivateMessage>> getPrivateMessages({
    int? page,
    int? limit,
    bool unread = false,
    int? creatorId,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> markPrivateMessageAsRead({required int messageId, required bool read}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Account Settings
  // =============================================================

  @override
  Future<void> saveUserSettings({
    String? bio,
    String? email,
    String? matrixUserId,
    String? displayName,
    FeedListType? defaultFeedListType,
    PostSortType? defaultPostSortType,
    bool? showNsfw,
    bool? showReadPosts,
    bool? showScores,
    bool? botAccount,
    bool? showBotAccounts,
    List<int>? discussionLanguages,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> importSettings(String settings) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<dynamic> exportSettings() async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<Map<String, dynamic>> media({int? page, int? limit}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Modlog
  // =============================================================

  @override
  Future<List<ModlogEventItem>> getModlog({
    int? page,
    int? limit,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  }) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  /// Given a modlog event, return a normalized [ModlogEventItem].
  ModlogEventItem parseModlogEvent(ModlogActionType type, dynamic event) {
    switch (type) {
      case ModlogActionType.modRemovePost:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_remove_post']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          reason: event['mod_remove_post']['reason'],
          post: ThunderPost.fromLemmyPost(event['post']),
          community: parseCommunity(event['community']),
          actioned: event['mod_remove_post']['removed'],
        );
      case ModlogActionType.modLockPost:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_lock_post']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          post: ThunderPost.fromLemmyPost(event['post']),
          community: parseCommunity(event['community']),
          actioned: event['mod_lock_post']['locked'],
        );
      case ModlogActionType.modFeaturePost:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_feature_post']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          post: ThunderPost.fromLemmyPost(event['post']),
          community: parseCommunity(event['community']),
          actioned: event['mod_feature_post']['featured'],
        );
      case ModlogActionType.modRemoveComment:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_remove_comment']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          reason: event['mod_remove_comment']['reason'],
          user: event['commenter'] != null ? parseUser(event['commenter']) : null,
          post: ThunderPost.fromLemmyPost(event['post']),
          comment: ThunderComment.fromLemmyComment(event['comment']),
          community: parseCommunity(event['community']),
          actioned: event['mod_remove_comment']['removed'],
        );
      case ModlogActionType.modRemoveCommunity:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_remove_community']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          reason: event['mod_remove_community']['reason'],
          community: parseCommunity(event['community']),
          actioned: event['mod_remove_community']['removed'],
        );
      case ModlogActionType.modBanFromCommunity:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_ban_from_community']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          reason: event['mod_ban_from_community']['reason'],
          user: event['banned_person'] != null ? parseUser(event['banned_person']) : null,
          community: parseCommunity(event['community']),
          actioned: event['mod_ban_from_community']['banned'],
        );
      case ModlogActionType.modBan:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_ban']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          reason: event['mod_ban']['reason'],
          user: event['banned_person'] != null ? parseUser(event['banned_person']) : null,
          actioned: event['mod_ban']['banned'],
        );
      case ModlogActionType.modAddCommunity:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_add_community']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          user: event['modded_person'] != null ? parseUser(event['modded_person']) : null,
          community: parseCommunity(event['community']),
          actioned: !event['mod_add_community']['removed'],
        );
      case ModlogActionType.modTransferCommunity:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_transfer_community']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          user: event['modded_person'] != null ? parseUser(event['modded_person']) : null,
          community: parseCommunity(event['community']),
          actioned: true,
        );
      case ModlogActionType.modAdd:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_add']['when_'],
          moderator: event['moderator'] != null ? parseUser(event['moderator']) : null,
          user: event['modded_person'] != null ? parseUser(event['modded_person']) : null,
          actioned: !event['mod_add']['removed'],
        );
      case ModlogActionType.adminPurgePerson:
        return ModlogEventItem(
          type: type,
          dateTime: event['admin_purge_person']['when_'],
          admin: event['admin'] != null ? parseUser(event['admin']) : null,
          reason: event['admin_purge_person']['reason'],
          actioned: true,
        );
      case ModlogActionType.adminPurgeCommunity:
        return ModlogEventItem(
          type: type,
          dateTime: event['admin_purge_community']['when_'],
          admin: event['admin'] != null ? parseUser(event['admin']) : null,
          reason: event['admin_purge_community']['reason'],
          actioned: true,
        );
      case ModlogActionType.adminPurgePost:
        return ModlogEventItem(
          type: type,
          dateTime: event['admin_purge_post']['when_'],
          admin: event['admin'] != null ? parseUser(event['admin']) : null,
          reason: event['admin_purge_post']['reason'],
          actioned: true,
        );
      case ModlogActionType.adminPurgeComment:
        return ModlogEventItem(
          type: type,
          dateTime: event['admin_purge_comment']['when_'],
          admin: event['admin'] != null ? parseUser(event['admin']) : null,
          reason: event['admin_purge_comment']['reason'],
          actioned: true,
        );
      case ModlogActionType.modHideCommunity:
        return ModlogEventItem(
          type: type,
          dateTime: event['mod_hide_community']['when'],
          admin: event['admin'] != null ? parseUser(event['admin']) : null,
          reason: event['mod_hide_community']['reason'],
          community: parseCommunity(event['community']),
          actioned: event['mod_hide_community']['hidden'],
        );
      default:
        throw Exception('Unknown modlog type: $type');
    }
  }

  // =============================================================
  // Instance
  // =============================================================

  @override
  Future<Map<String, dynamic>> federated() async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<bool> blockInstance({required int instanceId, required bool block}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Media
  // =============================================================

  @override
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  @override
  Future<void> deleteImage({required String file, required String token}) async {
    throw UnimplementedError('Lemmy endpoints are implemented in version-specific clients.');
  }

  // =============================================================
  // Feature Flags
  // =============================================================

  @override
  bool get supportsHidePosts => true;

  @override
  bool get supportsPostReports => true;

  @override
  bool get supportsCommentReports => true;

  @override
  bool get supportsPrivateMessages => true;

  @override
  bool get supportsModlog => true;

  @override
  bool get supportsSettingsImportExport => true;

  @override
  bool get supportsMedia => true;

  @override
  bool get supportsTOTP => true;

  @override
  bool get supportsInstanceBlock => true;
}
