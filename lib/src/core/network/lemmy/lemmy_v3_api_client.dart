import 'dart:convert';

import 'package:http/http.dart' as http;

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
import 'package:thunder/src/core/network/api_exception.dart';
import 'package:thunder/src/core/network/base_api_client.dart';
import 'package:thunder/src/core/network/lemmy/base_lemmy_api_client.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

/// Lemmy API client for version 0.19.x (v3 API).
///
/// This client uses the `/api/v3` endpoints and the original JSON schema
/// with field names like `actor_id`, `published`, etc.
class LemmyV3ApiClient extends BaseLemmyApiClient {
  LemmyV3ApiClient({
    required super.account,
    super.debug,
    required super.version,
    super.httpClient,
  });

  @override
  String get basePath => '/api/v3';

  // =============================================================
  // Version-specific parsing methods
  // =============================================================

  @override
  ThunderPost parsePost(Map<String, dynamic> json) {
    return ThunderPost.fromLemmyPostView(json);
  }

  @override
  ThunderComment parseComment(Map<String, dynamic> json) {
    return ThunderComment.fromLemmyCommentView(json);
  }

  @override
  ThunderUser parseUser(Map<String, dynamic> json) {
    return ThunderUser.fromLemmyUser(json);
  }

  @override
  ThunderUser parseUserView(Map<String, dynamic> json) {
    return ThunderUser.fromLemmyUserView(json);
  }

  @override
  ThunderCommunity parseCommunity(Map<String, dynamic> json) {
    return ThunderCommunity.fromLemmyCommunity(json);
  }

  @override
  ThunderCommunity parseCommunityView(Map<String, dynamic> json) {
    return ThunderCommunity.fromLemmyCommunityView(json);
  }

  @override
  ThunderSiteResponse parseSiteResponse(Map<String, dynamic> json) {
    return ThunderSiteResponse.fromLemmySiteResponse(json);
  }

  // =============================================================
  // Authentication & Site
  // =============================================================

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    final body = {
      'username_or_email': username,
      'password': password,
      'totp_2fa_token': totp,
    };

    final json = await request(HttpMethod.post, '$basePath/user/login', body);
    return json['jwt'] as String?;
  }

  @override
  Future<ThunderSiteResponse> site() async {
    final json = await request(HttpMethod.get, '$basePath/site', {});
    return parseSiteResponse(json);
  }

  // =============================================================
  // Posts
  // =============================================================

  @override
  Future<GetPostResponse> getPost(int postId, {int? commentId}) async {
    final json = await request(HttpMethod.get, '$basePath/post', {
      'id': postId,
      'comment_id': commentId,
    });

    final posts = await parsePosts([parsePost(json['post_view'])]);
    final moderators = (json['moderators'] as List).map<ThunderUser>((mu) => parseUser(mu['moderator'])).toList();
    final crossPosts = (json['cross_posts'] as List).map<ThunderPost>((cp) => parsePost(cp)).toList();

    return (
      post: posts.first,
      moderators: moderators,
      crossPosts: crossPosts,
    );
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
    // Use page-based pagination for Lemmy 0.19.x instances
    // See https://github.com/LemmyNet/lemmy/issues/6171
    final page = cursor != null ? int.tryParse(cursor) ?? 1 : 1;

    final Map<String, dynamic> queryParams = {
      'type_': feedListType?.value,
      'sort': postSortType?.value,
      'page': page,
      'limit': limit,
      'community_name': communityName,
      'community_id': communityId,
    };

    if (showSaved == true) queryParams['saved_only'] = showSaved;
    if (showHidden == true) queryParams['show_hidden'] = showHidden;

    final json = await request(HttpMethod.get, '$basePath/post/list', queryParams);

    final posts = (json['posts'] as List).map<ThunderPost>((pv) => parsePost(pv)).toList();
    final nextPage = posts.isNotEmpty ? (page + 1).toString() : null;

    return (posts: posts, nextPage: nextPage);
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
    final body = {
      'name': title,
      'community_id': communityId,
      'url': url,
      'body': contents,
      'alt_text': altText,
      'nsfw': nsfw,
      'language_id': languageId,
      'custom_thumbnail': customThumbnail,
    };

    final json = await request(HttpMethod.post, '$basePath/post', body);
    return parsePost(json['post_view']);
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
    final body = {
      'post_id': postId,
      'name': title,
      'url': url,
      'body': contents,
      'alt_text': altText,
      'nsfw': nsfw,
      'language_id': languageId,
      'custom_thumbnail': customThumbnail,
    };

    final json = await request(HttpMethod.put, '$basePath/post', body);
    return parsePost(json['post_view']);
  }

  @override
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/post/like', {
      'post_id': postId,
      'score': score,
    });
    return parsePost(json['post_view']);
  }

  @override
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/post/save', {
      'post_id': postId,
      'save': save,
    });
    return parsePost(json['post_view']);
  }

  @override
  Future<bool> readPost({required List<int> postIds, required bool read}) async {
    final json = await request(HttpMethod.post, '$basePath/post/mark_as_read', {
      'post_ids': postIds,
      'read': read,
    });
    return json['success'] as bool;
  }

  @override
  Future<bool> hidePost({required int postId, required bool hide}) async {
    final json = await request(HttpMethod.post, '$basePath/post/hide', {
      'post_ids': [postId],
      'hide': hide,
    });
    return json['success'] as bool;
  }

  @override
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/post/delete', {
      'post_id': postId,
      'deleted': deleted,
    });
    final post = parsePost(json['post_view']);
    return post.deleted == deleted;
  }

  @override
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final json = await request(HttpMethod.post, '$basePath/post/lock', {
      'post_id': postId,
      'locked': locked,
    });
    final post = parsePost(json['post_view']);
    return post.locked == locked;
  }

  @override
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final json = await request(HttpMethod.post, '$basePath/post/feature', {
      'post_id': postId,
      'featured': pinned,
      'feature_type': 'Community',
    });
    final post = parsePost(json['post_view']);
    return post.featuredCommunity == pinned;
  }

  @override
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final json = await request(HttpMethod.post, '$basePath/post/remove', {
      'post_id': postId,
      'removed': removed,
      'reason': reason,
    });
    final post = parsePost(json['post_view']);
    return post.removed == removed;
  }

  @override
  Future<void> reportPost({required int postId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/post/report', {
      'post_id': postId,
      'reason': reason,
    });
  }

  @override
  Future<List<ThunderPostReport>> getPostReports({
    int? postId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    final json = await request(HttpMethod.get, '$basePath/post/report/list', {
      'post_id': postId,
      'page': page,
      'limit': limit,
      'unresolved_only': unresolved,
      'community_id': communityId,
    });
    return (json['post_reports'] as List).map<ThunderPostReport>((pr) => ThunderPostReport.fromLemmyPostReportView(pr)).toList();
  }

  @override
  Future<ThunderPostReport> resolvePostReport({required int reportId, required bool resolved}) async {
    final json = await request(HttpMethod.put, '$basePath/post/report/resolve', {
      'report_id': reportId,
      'resolved': resolved,
    });
    return ThunderPostReport.fromLemmyPostReportView(json['post_report_view']);
  }

  // =============================================================
  // Comments
  // =============================================================

  @override
  Future<ThunderComment> getComment(int commentId) async {
    final json = await request(HttpMethod.get, '$basePath/comment', {'id': commentId});
    return parseComment(json['comment_view']);
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
    final json = await request(HttpMethod.get, '$basePath/comment/list', {
      'sort': commentSortType?.value,
      'max_depth': maxDepth,
      'page': page,
      'limit': limit,
      'community_id': communityId,
      'post_id': postId,
      'parent_id': parentId,
      'depth_first': true,
      'type_': 'All',
    });

    final comments = (json['comments'] as List).map<ThunderComment>((cv) => parseComment(cv)).toList();
    final nextPage = (limit != null && comments.length < limit) ? null : ((page ?? 0) + 1).toString();

    return (comments: comments, nextPage: nextPage);
  }

  @override
  Future<ThunderComment> createComment({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  }) async {
    final json = await request(HttpMethod.post, '$basePath/comment', {
      'post_id': postId,
      'content': content,
      'parent_id': parentId,
      'language_id': languageId,
    });
    return parseComment(json['comment_view']);
  }

  @override
  Future<ThunderComment> editComment({
    required int commentId,
    required String content,
    int? languageId,
  }) async {
    final json = await request(HttpMethod.put, '$basePath/comment', {
      'comment_id': commentId,
      'content': content,
      'language_id': languageId,
    });
    return parseComment(json['comment_view']);
  }

  @override
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/like', {
      'comment_id': commentId,
      'score': score,
    });
    return parseComment(json['comment_view']);
  }

  @override
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/save', {
      'comment_id': commentId,
      'save': save,
    });
    return parseComment(json['comment_view']);
  }

  @override
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/delete', {
      'comment_id': commentId,
      'deleted': deleted,
    });
    return parseComment(json['comment_view']);
  }

  @override
  Future<void> reportComment({required int commentId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/comment/report', {
      'comment_id': commentId,
      'reason': reason,
    });
  }

  @override
  Future<List<ThunderCommentReport>> getCommentReports({
    int? commentId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    final json = await request(HttpMethod.get, '$basePath/comment/report/list', {
      'comment_id': commentId,
      'page': page,
      'limit': limit,
      'unresolved_only': unresolved,
      'community_id': communityId,
    });
    return (json['comment_reports'] as List).map<ThunderCommentReport>((cr) => ThunderCommentReport.fromLemmyCommentReportView(cr)).toList();
  }

  @override
  Future<ThunderCommentReport> resolveCommentReport({required int reportId, required bool resolved}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/report/resolve', {
      'report_id': reportId,
      'resolved': resolved,
    });
    return ThunderCommentReport.fromLemmyCommentReportView(json['comment_report_view']);
  }

  // =============================================================
  // Communities
  // =============================================================

  @override
  Future<GetCommunityResponse> getCommunity({int? id, String? name}) async {
    final json = await request(HttpMethod.get, '$basePath/community', {
      'id': id,
      'name': name,
    });

    return (
      community: parseCommunityView(json['community_view']),
      site: json['site'] != null ? ThunderSite.fromLemmySite(json['site']) : null,
      moderators: (json['moderators'] as List).map<ThunderUser>((cmv) => parseUser(cmv['moderator'])).toList(),
      discussionLanguages: (json['discussion_languages'] as List).cast<int>(),
    );
  }

  @override
  Future<List<ThunderCommunity>> getCommunities({
    int? page,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
  }) async {
    final json = await request(HttpMethod.get, '$basePath/community/list', {
      'page': page,
      'limit': limit,
      'type_': feedListType?.value,
      'sort': postSortType?.value,
    });
    return (json['communities'] as List).map<ThunderCommunity>((cv) => parseCommunityView(cv)).toList();
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final json = await request(HttpMethod.post, '$basePath/community/follow', {
      'community_id': communityId,
      'follow': follow,
    });
    return parseCommunityView(json['community_view']);
  }

  @override
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/community/block', {
      'community_id': communityId,
      'block': block,
    });
    return parseCommunityView(json['community_view']);
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
    final json = await request(HttpMethod.get, '$basePath/user', {
      'person_id': userId,
      'username': username,
      'sort': sort?.value,
      'page': page,
      'limit': limit,
      'saved_only': saved,
    });

    return (
      user: parseUserView(json['person_view']),
      site: json['site'] != null ? ThunderSite.fromLemmySite(json['site']) : null,
      posts: (json['posts'] as List).map<ThunderPost>((pv) => parsePost(pv)).toList(),
      comments: (json['comments'] as List).map<ThunderComment>((cv) => parseComment(cv)).toList(),
      moderates: (json['moderates'] as List).map<ThunderCommunity>((cmv) => parseCommunity(cmv['community'])).toList(),
    );
  }

  @override
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/user/block', {
      'person_id': userId,
      'block': block,
    });
    return parseUserView(json['person_view']);
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
    final json = await request(HttpMethod.post, '$basePath/community/ban_user', {
      'person_id': userId,
      'community_id': communityId,
      'ban': ban,
      'remove_data': removeData,
      'reason': reason,
      'expires': expires,
    });
    return parseUserView(json['person_view']);
  }

  @override
  Future<List<ThunderUser>> addModerator({
    required int userId,
    required int communityId,
    required bool added,
  }) async {
    final json = await request(HttpMethod.post, '$basePath/community/mod', {
      'person_id': userId,
      'community_id': communityId,
      'added': added,
    });
    return (json['moderators'] as List).map<ThunderUser>((cmv) => parseUser(cmv['moderator'])).toList();
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
    final json = await request(HttpMethod.get, '$basePath/search', {
      'q': query,
      'community_id': communityId,
      'community_name': communityName,
      'creator_id': creatorId,
      'type_': type?.searchType,
      'sort': sort?.value,
      'listing_type': listingType?.value,
      'page': page,
      'limit': limit,
    });

    return (
      type: MetaSearchType.values.firstWhere((e) => e.searchType == json['type_']),
      posts: (json['posts'] as List?)?.map<ThunderPost>((pv) => parsePost(pv)).toList() ?? [],
      comments: (json['comments'] as List?)?.map<ThunderComment>((cv) => parseComment(cv)).toList() ?? [],
      communities: (json['communities'] as List?)?.map<ThunderCommunity>((cv) => parseCommunityView(cv)).toList() ?? [],
      users: (json['users'] as List?)?.map<ThunderUser>((pv) => parseUserView(pv)).toList() ?? [],
    );
  }

  @override
  Future<ResolveResponse> resolve({required String query}) async {
    final json = await request(HttpMethod.get, '$basePath/resolve_object', {'q': query});

    return (
      community: json['community'] != null ? parseCommunityView(json['community']) : null,
      post: json['post'] != null ? parsePost(json['post']) : null,
      comment: json['comment'] != null ? parseComment(json['comment']) : null,
      user: json['person'] != null ? parseUserView(json['person']) : null,
    );
  }

  // =============================================================
  // Notifications
  // =============================================================

  @override
  Future<UnreadCountResponse> unreadCount() async {
    final json = await request(HttpMethod.get, '$basePath/user/unread_count', {});
    return (
      replies: json['replies'] as int,
      mentions: json['mentions'] as int,
      privateMessages: json['private_messages'] as int,
    );
  }

  @override
  Future<List<ThunderComment>> getCommentReplies({
    int? page,
    int? limit,
    CommentSortType? sort,
    bool unread = false,
  }) async {
    final response = await request(HttpMethod.get, '$basePath/user/replies', {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    });

    return (response['replies'] as List).map<ThunderComment>((crv) {
      // Parse the full comment reply view (includes post, creator info, etc.)
      final comment = parseComment(crv);

      return comment.copyWith(
        recipient: parseUser(crv['recipient']),
        replyMentionId: crv['comment_reply']['id'],
        read: crv['comment_reply']['read'],
      );
    }).toList();
  }

  @override
  Future<void> markCommentReplyAsRead({required int replyId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/comment/mark_as_read', {
      'comment_reply_id': replyId,
      'read': read,
    });
  }

  @override
  Future<List<ThunderComment>> getCommentMentions({
    int? page,
    int? limit,
    CommentSortType? sort,
    bool unread = false,
  }) async {
    final response = await request(HttpMethod.get, '$basePath/user/mention', {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    });

    return (response['mentions'] as List).map<ThunderComment>((mention) {
      // Parse the full mention view (includes post, creator info, etc.)
      final comment = parseComment(mention);

      return comment.copyWith(
        recipient: parseUser(mention['recipient']),
        replyMentionId: mention['person_mention']['id'],
        read: mention['person_mention']['read'],
      );
    }).toList();
  }

  @override
  Future<void> markCommentMentionAsRead({required int mentionId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/user/mention/mark_as_read', {
      'person_mention_id': mentionId,
      'read': read,
    });
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await request(HttpMethod.post, '$basePath/user/mark_all_as_read', {});
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
    final json = await request(HttpMethod.get, '$basePath/private_message/list', {
      'page': page,
      'limit': limit,
      'unread_only': unread,
      'creator_id': creatorId,
    });
    return (json['private_messages'] as List).map<ThunderPrivateMessage>((pm) => ThunderPrivateMessage.fromLemmyPrivateMessageView(pm)).toList();
  }

  @override
  Future<void> markPrivateMessageAsRead({required int messageId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/private_message/mark_as_read', {
      'private_message_id': messageId,
      'read': read,
    });
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
    await request(HttpMethod.put, '$basePath/user/save_user_settings', {
      'bio': bio,
      'email': email,
      'matrix_user_id': matrixUserId,
      'display_name': displayName,
      'default_listing_type': defaultFeedListType?.value,
      'default_sort_type': defaultPostSortType?.value,
      'show_nsfw': showNsfw,
      'show_read_posts': showReadPosts,
      'show_scores': showScores,
      'bot_account': botAccount,
      'show_bot_accounts': showBotAccounts,
      'discussion_languages': discussionLanguages,
    });
  }

  @override
  Future<bool> importSettings(String settings) async {
    final json = await request(HttpMethod.post, '$basePath/user/import_settings', {
      'data': settings,
    });
    return json['success'] as bool;
  }

  @override
  Future<dynamic> exportSettings() async {
    return await request(HttpMethod.get, '$basePath/user/export_settings', {});
  }

  @override
  Future<Map<String, dynamic>> media({int? page, int? limit}) async {
    return await request(HttpMethod.get, '$basePath/account/list_media', {
      'page': page,
      'limit': limit,
    });
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
    final response = await request(HttpMethod.get, '$basePath/modlog', {
      'page': page,
      'limit': limit,
      'type_': modlogActionType?.value,
      'community_id': communityId,
      'other_person_id': userId,
      'mod_person_id': moderatorId,
      'comment_id': commentId,
    });

    List<ModlogEventItem> items = [];

    // Convert the response to a list of modlog events
    List<ModlogEventItem> removedPosts = (response['removed_posts'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modRemovePost, e)).toList();
    List<ModlogEventItem> lockedPosts = (response['locked_posts'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modLockPost, e)).toList();
    List<ModlogEventItem> featuredPosts = (response['featured_posts'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modFeaturePost, e)).toList();
    List<ModlogEventItem> removedComments = (response['removed_comments'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modRemoveComment, e)).toList();
    List<ModlogEventItem> removedCommunities = (response['removed_communities'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modRemoveCommunity, e)).toList();
    List<ModlogEventItem> bannedFromCommunity = (response['banned_from_community'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modBanFromCommunity, e)).toList();
    List<ModlogEventItem> banned = (response['banned'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modBan, e)).toList();
    List<ModlogEventItem> addedToCommunity = (response['added_to_community'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modAddCommunity, e)).toList();
    List<ModlogEventItem> transferredToCommunity = (response['transferred_to_community'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modTransferCommunity, e)).toList();
    List<ModlogEventItem> added = (response['added'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modAdd, e)).toList();
    List<ModlogEventItem> adminPurgedPersons = (response['admin_purged_persons'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgePerson, e)).toList();
    List<ModlogEventItem> adminPurgedCommunities = (response['admin_purged_communities'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgeCommunity, e)).toList();
    List<ModlogEventItem> adminPurgedPosts = (response['admin_purged_posts'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgePost, e)).toList();
    List<ModlogEventItem> adminPurgedComments = (response['admin_purged_comments'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.adminPurgeComment, e)).toList();
    List<ModlogEventItem> hiddenCommunities = (response['hidden_communities'] as List).map<ModlogEventItem>((e) => parseModlogEvent(ModlogActionType.modHideCommunity, e)).toList();

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

    return items;
  }

  /// Given a modlog event, return a normalized [ModlogEventItem].
  @override
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
    return await request(HttpMethod.get, '$basePath/federated_instances', {});
  }

  @override
  Future<bool> blockInstance({required int instanceId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/site/block', {
      'instance_id': instanceId,
      'block': block,
    });
    return json['blocked'] as bool;
  }

  // =============================================================
  // Media
  // =============================================================

  @override
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.https(account.instance, '/pictrs/image'),
      );
      uploadRequest.headers.addAll(buildHeaders());
      uploadRequest.files.add(await http.MultipartFile.fromPath('images[]', filePath));

      final response = await uploadRequest.send();
      if (response.statusCode != 201) {
        throw ApiErrorException(
          'Failed to upload image: ${response.statusCode} ${response.reasonPhrase}',
          statusCode: response.statusCode,
          platformName: platformName,
        );
      }

      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiErrorException('Failed to upload image: $e', platformName: platformName);
    }
  }

  @override
  Future<void> deleteImage({required String file, required String token}) async {
    await request(HttpMethod.get, '/pictrs/image/delete/$token/$file', {});
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

  // =============================================================
  // Additional Lemmy v3 endpoints (0.19.11 spec)
  // =============================================================

  // Admin
  Future<Map<String, dynamic>> addAdmin({required int personId, required bool added}) async {
    return await request(HttpMethod.post, '$basePath/admin/add', {
      'person_id': personId,
      'added': added,
    });
  }

  Future<Map<String, dynamic>> listAllMedia({int? page, int? limit}) async {
    return await request(HttpMethod.post, '$basePath/admin/list_all_media', {
      'page': page,
      'limit': limit,
    });
  }

  Future<void> purgeComment({required int commentId, String? reason}) async {
    await request(HttpMethod.post, '$basePath/admin/purge/comment', {
      'comment_id': commentId,
      'reason': reason,
    });
  }

  Future<void> purgeCommunity({required int communityId, String? reason}) async {
    await request(HttpMethod.post, '$basePath/admin/purge/community', {
      'community_id': communityId,
      'reason': reason,
    });
  }

  Future<void> purgePerson({required int personId, String? reason}) async {
    await request(HttpMethod.post, '$basePath/admin/purge/person', {
      'person_id': personId,
      'reason': reason,
    });
  }

  Future<void> purgePost({required int postId, String? reason}) async {
    await request(HttpMethod.post, '$basePath/admin/purge/post', {
      'post_id': postId,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> getRegistrationApplication({required int id}) async {
    return await request(HttpMethod.post, '$basePath/admin/registration_application', {
      'id': id,
    });
  }

  Future<Map<String, dynamic>> approveRegistrationApplication({required int id, required bool approve}) async {
    return await request(HttpMethod.post, '$basePath/admin/registration_application/approve', {
      'id': id,
      'approve': approve,
    });
  }

  Future<Map<String, dynamic>> getRegistrationApplicationCount() async {
    return await request(HttpMethod.get, '$basePath/admin/registration_application/count', {});
  }

  Future<Map<String, dynamic>> listRegistrationApplications({bool? unreadOnly, int? page, int? limit}) async {
    return await request(HttpMethod.get, '$basePath/admin/registration_application/list', {
      'unread_only': unreadOnly,
      'page': page,
      'limit': limit,
    });
  }

  // Comments
  Future<ThunderComment> distinguishComment({required int commentId, required bool distinguished}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/distinguish', {
      'comment_id': commentId,
      'distinguished': distinguished,
    });
    return parseComment(json['comment_view']);
  }

  Future<Map<String, dynamic>> listCommentLikes({required int commentId, int? page, int? limit}) async {
    return await request(HttpMethod.post, '$basePath/comment/like/list', {
      'comment_id': commentId,
      'page': page,
      'limit': limit,
    });
  }

  Future<ThunderComment> removeComment({required int commentId, required bool removed, String? reason}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/remove', {
      'comment_id': commentId,
      'removed': removed,
      'reason': reason,
    });
    return parseComment(json['comment_view']);
  }

  // Communities
  Future<ThunderCommunity> deleteCommunity({required int communityId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/community/delete', {
      'community_id': communityId,
      'deleted': deleted,
    });
    return parseCommunityView(json['community_view']);
  }

  Future<void> hideCommunity({required int communityId, required bool hide}) async {
    await request(HttpMethod.post, '$basePath/community/hide', {
      'community_id': communityId,
      'hide': hide,
    });
  }

  Future<ThunderCommunity> removeCommunity({required int communityId, required bool removed, String? reason}) async {
    final json = await request(HttpMethod.post, '$basePath/community/remove', {
      'community_id': communityId,
      'removed': removed,
      'reason': reason,
    });
    return parseCommunityView(json['community_view']);
  }

  Future<ThunderCommunity> transferCommunity({required int communityId, required int personId}) async {
    final json = await request(HttpMethod.post, '$basePath/community/transfer', {
      'community_id': communityId,
      'person_id': personId,
    });
    return parseCommunityView(json['community_view']);
  }

  // Custom Emoji
  Future<Map<String, dynamic>> createCustomEmoji({
    required String category,
    required String shortcode,
    required String imageUrl,
    required String altText,
    required List<String> keywords,
  }) async {
    return await request(HttpMethod.post, '$basePath/custom_emoji', {
      'category': category,
      'shortcode': shortcode,
      'image_url': imageUrl,
      'alt_text': altText,
      'keywords': keywords,
    });
  }

  Future<Map<String, dynamic>> editCustomEmoji({
    required int id,
    required String category,
    required String imageUrl,
    required String altText,
    required List<String> keywords,
  }) async {
    return await request(HttpMethod.put, '$basePath/custom_emoji', {
      'id': id,
      'category': category,
      'image_url': imageUrl,
      'alt_text': altText,
      'keywords': keywords,
    });
  }

  Future<void> deleteCustomEmoji({required int id}) async {
    await request(HttpMethod.post, '$basePath/custom_emoji/delete', {
      'id': id,
    });
  }

  // Posts
  Future<Map<String, dynamic>> listPostLikes({required int postId, int? page, int? limit}) async {
    return await request(HttpMethod.post, '$basePath/post/like/list', {
      'post_id': postId,
      'page': page,
      'limit': limit,
    });
  }

  Future<Map<String, dynamic>> getSiteMetadata({required String url}) async {
    return await request(HttpMethod.get, '$basePath/post/site_metadata', {
      'url': url,
    });
  }

  // Private messages
  Future<ThunderPrivateMessage> createPrivateMessage({required int recipientId, required String content}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message', {
      'recipient_id': recipientId,
      'content': content,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  Future<ThunderPrivateMessage> editPrivateMessage({required int privateMessageId, required String content}) async {
    final json = await request(HttpMethod.put, '$basePath/private_message', {
      'private_message_id': privateMessageId,
      'content': content,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  Future<ThunderPrivateMessage> deletePrivateMessage({required int privateMessageId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message/delete', {
      'private_message_id': privateMessageId,
      'deleted': deleted,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  Future<Map<String, dynamic>> reportPrivateMessage({required int privateMessageId, required String reason}) async {
    return await request(HttpMethod.post, '$basePath/private_message/report', {
      'private_message_id': privateMessageId,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> listPrivateMessageReports() async {
    return await request(HttpMethod.get, '$basePath/private_message/report/list', {});
  }

  Future<Map<String, dynamic>> resolvePrivateMessageReport({required int reportId, required bool resolved}) async {
    return await request(HttpMethod.post, '$basePath/private_message/report/resolve', {
      'report_id': reportId,
      'resolved': resolved,
    });
  }

  // Users
  Future<ThunderUser> banPerson({
    required int personId,
    required bool ban,
    bool? removeData,
    String? reason,
    int? expires,
  }) async {
    final json = await request(HttpMethod.post, '$basePath/user/ban', {
      'person_id': personId,
      'ban': ban,
      'remove_data': removeData,
      'reason': reason,
      'expires': expires,
    });
    return parseUserView(json['person_view']);
  }

  Future<Map<String, dynamic>> listBannedPersons() async {
    return await request(HttpMethod.get, '$basePath/user/banned', {});
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordVerify,
  }) async {
    return await request(HttpMethod.post, '$basePath/user/change_password', {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_verify': newPasswordVerify,
    });
  }

  Future<void> deleteAccount({required String password}) async {
    await request(HttpMethod.post, '$basePath/user/delete_account', {
      'password': password,
    });
  }

  Future<void> markDonationDialogShown() async {
    await request(HttpMethod.get, '$basePath/user/donation_dialog_shown', {});
  }

  Future<Map<String, dynamic>> getCaptcha() async {
    return await request(HttpMethod.get, '$basePath/user/get_captcha', {});
  }

  Future<Map<String, dynamic>> leaveAdmin() async {
    return await request(HttpMethod.post, '$basePath/user/leave_admin', {});
  }

  Future<List<Map<String, dynamic>>> listLogins() async {
    final headers = buildHeaders();
    final uri = Uri.https(account.instance, '$basePath/user/list_logins');
    final response = await httpClient.get(uri, headers: headers);
    final data = await handleResponse(uri, response);
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<void> logout() async {
    await request(HttpMethod.post, '$basePath/user/logout', {});
  }

  Future<void> passwordChangeAfterReset({required String token, required String password, required String passwordVerify}) async {
    await request(HttpMethod.post, '$basePath/user/password_change', {
      'token': token,
      'password': password,
      'password_verify': passwordVerify,
    });
  }

  Future<void> passwordReset({required String email}) async {
    await request(HttpMethod.post, '$basePath/user/password_reset', {
      'email': email,
    });
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    return await request(HttpMethod.post, '$basePath/user/register', payload);
  }

  Future<Map<String, dynamic>> getReportCount({int? communityId}) async {
    return await request(HttpMethod.get, '$basePath/user/report_count', {
      'community_id': communityId,
    });
  }

  Future<Map<String, dynamic>> generateTotpSecret() async {
    return await request(HttpMethod.get, '$basePath/user/totp/generate', {});
  }

  Future<Map<String, dynamic>> updateTotp({required String totpToken, required bool enabled}) async {
    return await request(HttpMethod.post, '$basePath/user/totp/update', {
      'totp_token': totpToken,
      'enabled': enabled,
    });
  }

  Future<void> validateAuth() async {
    await request(HttpMethod.get, '$basePath/user/validate_auth', {});
  }

  Future<void> verifyEmail(String token) async {
    await request(HttpMethod.post, '$basePath/user/verify_email', {
      'token': token,
    });
  }

  ThunderPrivateMessage _parsePrivateMessageView(Map<String, dynamic> privateMessageView) {
    return ThunderPrivateMessage.fromLemmyPrivateMessageView(privateMessageView);
  }
}
