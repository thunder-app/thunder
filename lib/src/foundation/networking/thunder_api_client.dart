import 'package:thunder/src/foundation/primitives/enums/comment_sort_type.dart';
import 'package:thunder/src/foundation/primitives/enums/feed_list_type.dart';
import 'package:thunder/src/foundation/primitives/enums/meta_search_type.dart';
import 'package:thunder/src/foundation/primitives/enums/post_sort_type.dart';
import 'package:thunder/src/foundation/primitives/enums/search_sort_type.dart';
import 'package:thunder/src/foundation/primitives/models/modlog_event_item.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_link_metadata.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_page.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_site.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_site_response.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/enums/modlog_action_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_flair.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';
import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';

/// Result for a single post lookup.
typedef GetPostResponse = ({
  ThunderPost post,
  List<ThunderUser> moderators,
  List<ThunderPost> crossPosts,
});

/// Result for a post list.
typedef GetPostsResponse = ({
  List<ThunderPost> posts,
  String? nextPage,
});

/// Result for a comment list.
typedef GetCommentsResponse = ({
  List<ThunderComment> comments,
  String? nextPage,
});

/// Result for a community lookup.
typedef GetCommunityResponse = ({
  ThunderCommunity community,
  ThunderSite? site,
  List<ThunderUser> moderators,
  List<int> discussionLanguages,
  List<ThunderFlair> flairs,
});

/// Result for a user lookup.
typedef GetUserResponse = ({
  ThunderUser user,
  ThunderSite? site,
  List<ThunderPost> posts,
  List<ThunderComment> comments,
  List<ThunderCommunity> moderates,
  String? nextPage,
});

/// Result for resolving a link or handle.
typedef ResolveResponse = ({
  ThunderCommunity? community,
  ThunderPost? post,
  ThunderComment? comment,
  ThunderUser? user,
});

/// Unread inbox counts.
typedef UnreadCountResponse = ({
  int replies,
  int mentions,
  int privateMessages,
});

/// Search results grouped by content type.
typedef SearchResponse = ({
  MetaSearchType type,
  List<ThunderPost> posts,
  List<ThunderComment> comments,
  List<ThunderCommunity> communities,
  List<ThunderUser> users,
});

/// Shared contract for talking to Lemmy and PieFed.
///
/// Each platform client turns its own responses into the Thunder models used by the rest of the app.
abstract class ThunderApiClient {
  // =============================================================
  // Platform Identification
  // =============================================================

  /// Platform name used in errors and logs.
  String get platformName;

  // =============================================================
  // Authentication & Site
  // =============================================================

  /// Login to the instance.
  ///
  /// Returns the JWT token on success, or null if login failed.
  Future<String?> login({required String username, required String password, String? totp});

  /// Logout the current authenticated session.
  Future<void> logout();

  /// Get instance details and, when signed in, the current account details.
  Future<ThunderSiteResponse> site();

  // =============================================================
  // Posts
  // =============================================================

  /// Fetch a single post by ID.
  Future<GetPostResponse> getPost(int postId, {int? commentId});

  /// Fetch a list of posts.
  ///
  /// Pass [cursor] from the previous response's `nextPage`, when loading more.
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
  });

  /// Fetch preview details for an external URL.
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url});

  /// Create a new post.
  Future<ThunderPost> createPost({
    required String title,
    required int communityId,
    String? url,
    String? contents,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
    String? altText,
  });

  /// Edit an existing post.
  Future<ThunderPost> editPost({
    required int postId,
    required String title,
    String? url,
    String? contents,
    String? altText,
    String? tags,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
  });

  /// Create a new post with any extra tags or flair the platform supports.
  Future<ThunderPost> createPostWithMetadata({
    required String title,
    required int communityId,
    String? url,
    String? contents,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
  }) async {
    return createPost(
      title: title,
      communityId: communityId,
      url: url,
      contents: contents,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
      altText: altText,
    );
  }

  /// Edit an existing post with any extra tags or flair the platform supports.
  ///
  /// For lists, `null` keeps the existing values, an empty list clears them, and a non-empty list applies the new values.
  Future<ThunderPost> editPostWithMetadata({
    required int postId,
    required String title,
    String? url,
    String? contents,
    String? altText,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
    List<String>? tags,
    List<int>? flairIds,
  }) async {
    return editPost(
      postId: postId,
      title: title,
      url: url,
      contents: contents,
      altText: altText,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
    );
  }

  /// Vote on a post.
  Future<ThunderPost> votePost({required int postId, required int score});

  /// Save or unsave a post.
  Future<ThunderPost> savePost({required int postId, required bool save});

  /// Mark posts as read/unread.
  Future<bool> readPost({required List<int> postIds, required bool read});

  /// Hide or unhide a post.
  Future<bool> hidePost({required int postId, required bool hide});

  /// Delete or restore a post.
  Future<bool> deletePost({required int postId, required bool deleted});

  /// Lock or unlock a post.
  Future<bool> lockPost({required int postId, required bool locked});

  /// Pin or unpin a post to a community.
  Future<bool> pinPost({required int postId, required bool pinned});

  /// Remove a post (moderator action).
  Future<bool> removePost({required int postId, required bool removed, required String reason});

  /// Report a post.
  Future<void> reportPost({required int postId, required String reason});

  /// Get reports using Thunder's report model.
  ///
  /// Pass [cursor] from the previous page, when the platform provides one.
  Future<ThunderPage<ThunderReport>> getReports({
    ReportKind? kind,
    int? postId,
    int? commentId,
    int page = 1,
    String? cursor,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  });

  /// Mark a report of the given [kind] as resolved or unresolved.
  Future<ThunderReport> resolveReport({required int reportId, required ReportKind kind, required bool resolved});

  // =============================================================
  // Comments
  // =============================================================

  /// Fetch a single comment by ID.
  Future<ThunderComment> getComment(int commentId);

  /// Fetch comments for a post.
  ///
  /// Pass [cursor] from the previous response's `nextPage`, when loading more.
  Future<GetCommentsResponse> getComments({
    required int postId,
    int? page,
    String? cursor,
    int? limit,
    int? maxDepth,
    int? communityId,
    int? parentId,
    CommentSortType? commentSortType,
  });

  /// Create a new comment.
  Future<ThunderComment> createComment({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  });

  /// Edit an existing comment.
  Future<ThunderComment> editComment({
    required int commentId,
    required String content,
    int? languageId,
  });

  /// Vote on a comment.
  Future<ThunderComment> voteComment({required int commentId, required int score});

  /// Save or unsave a comment.
  Future<ThunderComment> saveComment({required int commentId, required bool save});

  /// Delete or restore a comment.
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted});

  /// Report a comment.
  Future<void> reportComment({required int commentId, required String reason});

  // =============================================================
  // Communities
  // =============================================================

  /// Fetch a single community.
  Future<GetCommunityResponse> getCommunity({int? id, String? name});

  /// Fetch a list of communities.
  Future<List<ThunderCommunity>> getCommunities({
    int? page,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
  });

  /// Subscribe or unsubscribe from a community.
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow});

  /// Block or unblock a community.
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block});

  // =============================================================
  // Users
  // =============================================================

  /// Fetch a user profile and their content.
  ///
  /// Pass [cursor] from the previous response's `nextPage`, when loading more.
  Future<GetUserResponse> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    String? cursor,
    int? limit,
    bool? saved,
    bool? includeContent,
  });

  /// Block or unblock a user.
  Future<ThunderUser> blockUser({required int userId, required bool block});

  /// Ban a user from a community.
  Future<ThunderUser> banUserFromCommunity({
    required int userId,
    required int communityId,
    required bool ban,
    bool? removeData,
    String? reason,
    int? expires,
  });

  /// Add or remove a moderator from a community.
  Future<List<ThunderUser>> addModerator({
    required int userId,
    required int communityId,
    required bool added,
  });

  // =============================================================
  // Search
  // =============================================================

  /// Search for content.
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
  });

  /// Resolve an ActivityPub URL or Webfinger address.
  Future<ResolveResponse> resolve({required String query});

  // =============================================================
  // Notifications
  // =============================================================

  /// Get unread notification counts.
  Future<UnreadCountResponse> unreadCount();

  /// Get comment replies.
  Future<List<ThunderComment>> getCommentReplies({
    int? page,
    int? limit,
    CommentSortType? sort,
    bool unread = false,
  });

  /// Mark a comment reply as read.
  Future<void> markCommentReplyAsRead({required int replyId, required bool read});

  /// Get comment mentions.
  Future<List<ThunderComment>> getCommentMentions({
    int? page,
    int? limit,
    CommentSortType? sort,
    bool unread = false,
  });

  /// Mark a comment mention as read.
  Future<void> markCommentMentionAsRead({required int mentionId, required bool read});

  /// Mark all notifications as read.
  Future<void> markAllNotificationsAsRead();

  // =============================================================
  // Private Messages
  // =============================================================

  /// Get private messages.
  Future<List<ThunderPrivateMessage>> getPrivateMessages({
    int? page,
    int? limit,
    bool unread = false,
    int? creatorId,
  });

  /// Mark a private-message notification as read.
  ///
  /// Use `ThunderPrivateMessage.notification?.id` here; that can be different rom the private message id.
  Future<void> markPrivateMessageAsRead({required int notificationId, required bool read});

  /// Create a private message.
  Future<ThunderPrivateMessage> createPrivateMessage({
    required int recipientId,
    required String content,
  });

  /// Get private messages for a conversation with a user.
  Future<List<ThunderPrivateMessage>> getPrivateMessageConversation({
    required int personId,
    int? conversationId,
    int? page,
    int? limit,
  });

  // =============================================================
  // Account Settings
  // =============================================================

  /// Save user settings.
  Future<void> saveUserSettings(AccountSettingsUpdate update);

  /// Import settings from a backup.
  Future<bool> importSettings(String settings);

  /// Export settings.
  Future<dynamic> exportSettings();

  /// Get media uploaded by the signed-in account.
  Future<ThunderPage<AccountMediaItem>> media({int? page, int? limit});

  // =============================================================
  // Modlog
  // =============================================================

  /// Get modlog entries.
  Future<List<ModlogEvent>> getModlog({
    int? page,
    int? limit,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  });

  // =============================================================
  // Instance
  // =============================================================

  /// Get federated instances.
  Future<Map<String, dynamic>> federated();

  /// Block or unblock an instance.
  Future<bool> blockInstance({required int instanceId, required bool block});

  // =============================================================
  // Media
  // =============================================================

  /// Upload an image.
  Future<Map<String, dynamic>> uploadImage(String filePath);

  /// Delete an uploaded image.
  Future<void> deleteImage({required String file, String? token});

  // =============================================================
  // Feature Flags
  // =============================================================

  /// Whether the platform supports hiding posts.
  bool get supportsHidePosts => true;

  /// Whether the platform supports post reports.
  bool get supportsPostReports => true;

  /// Whether the platform supports comment reports.
  bool get supportsCommentReports => true;

  /// Whether the platform supports private messages.
  bool get supportsPrivateMessages => true;

  /// Whether the platform supports modlog.
  bool get supportsModlog => true;

  /// Whether the platform supports settings import/export.
  bool get supportsSettingsImportExport => true;

  /// Whether the platform supports media management.
  bool get supportsMedia => true;

  /// Whether the platform supports TOTP for login.
  bool get supportsTOTP => true;

  /// Whether the platform supports instance blocking.
  bool get supportsInstanceBlock => true;

  // =============================================================
  // Lifecycle
  // =============================================================

  /// Clean up resources.
  void dispose();
}
