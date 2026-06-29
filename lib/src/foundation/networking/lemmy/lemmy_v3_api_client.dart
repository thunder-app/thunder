import 'package:thunder/src/foundation/networking/utils/upload_image_utils.dart';
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
import 'package:thunder/src/foundation/errors/api_exception.dart';
import 'package:thunder/src/foundation/networking/base_api_client.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_api_client_defaults.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_private_message_utils.dart';
import 'package:thunder/src/foundation/networking/lemmy/modlog_parsers.dart';
import 'package:thunder/src/foundation/networking/mappers/primitive_mappers.dart';
import 'package:thunder/src/foundation/networking/thunder_api_client.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/enums/modlog_action_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_flair.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';
import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';

/// Lemmy API client for version 0.19.x (v3 API).
///
/// This client uses the `/api/v3` endpoints and the original JSON schema
/// with field names like `actor_id`, `published`, etc.
class LemmyV3ApiClient extends BaseApiClient with LemmyApiClientDefaults {
  static const _mapper = LemmyV3PrimitiveMapper();

  LemmyV3ApiClient({
    required super.account,
    super.debug,
    required super.version,
    super.httpClient,
  });

  @override
  String get platformName => 'Lemmy';

  @override
  String get basePath => '/api/v3';

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
    return ThunderSiteResponse.fromLemmySiteResponse(json);
  }

  @override
  Future<void> logout() async {
    await request(HttpMethod.post, '$basePath/user/logout', {});
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

    final post = _mapper.postView(json['post_view']);
    final moderators = (json['moderators'] as List).map<ThunderUser>((mu) => _mapper.user(mu['moderator'])).toList();
    final crossPosts = (json['cross_posts'] as List).map<ThunderPost>((cp) => _mapper.postView(cp)).toList();

    return (
      post: post,
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

    final posts = (json['posts'] as List).map<ThunderPost>((pv) => _mapper.postView(pv)).toList();
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
    return _mapper.postView(json['post_view']);
  }

  @override
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
    return _mapper.postView(json['post_view']);
  }

  @override
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/post/like', {
      'post_id': postId,
      'score': score,
    });
    return _mapper.postView(json['post_view']);
  }

  @override
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/post/save', {
      'post_id': postId,
      'save': save,
    });
    return _mapper.postView(json['post_view']);
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
    final post = _mapper.postView(json['post_view']);
    return post.status.deleted == deleted;
  }

  @override
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final json = await request(HttpMethod.post, '$basePath/post/lock', {
      'post_id': postId,
      'locked': locked,
    });
    final post = _mapper.postView(json['post_view']);
    return post.status.locked == locked;
  }

  @override
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final json = await request(HttpMethod.post, '$basePath/post/feature', {
      'post_id': postId,
      'featured': pinned,
      'feature_type': 'Community',
    });
    final post = _mapper.postView(json['post_view']);
    return post.status.featuredCommunity == pinned;
  }

  @override
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final json = await request(HttpMethod.post, '$basePath/post/remove', {
      'post_id': postId,
      'removed': removed,
      'reason': reason,
    });
    final post = _mapper.postView(json['post_view']);
    return post.status.removed == removed;
  }

  @override
  Future<void> reportPost({required int postId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/post/report', {
      'post_id': postId,
      'reason': reason,
    });
  }

  @override
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url}) async {
    final response = await request(HttpMethod.get, '$basePath/post/site_metadata', {
      'url': url,
    });

    final metadata = response['metadata'];
    if (metadata is! Map<String, dynamic>) return null;

    return ThunderLinkMetadata.fromLemmySiteMetadata(metadata, url: url);
  }

  @override
  Future<ThunderPage<ThunderReport>> getReports({
    ReportKind? kind,
    int? postId,
    int? commentId,
    int page = 1,
    String? cursor,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    final pageNumber = cursor != null ? int.tryParse(cursor) ?? page : page;
    final reports = switch (kind) {
      ReportKind.comment => await _getCommentReports(commentId: commentId, page: pageNumber, limit: limit, unresolved: unresolved, communityId: communityId),
      ReportKind.privateMessage || ReportKind.community => <ThunderReport>[],
      _ => await _getPostReports(postId: postId, page: pageNumber, limit: limit, unresolved: unresolved, communityId: communityId),
    };

    return ThunderPage(
      items: reports,
      nextPage: reports.length < limit ? null : (pageNumber + 1).toString(),
    );
  }

  Future<List<ThunderReport>> _getPostReports({
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
    return (json['post_reports'] as List).map<ThunderReport>((pr) => _mapper.postReportView(pr)).toList();
  }

  @override
  Future<ThunderReport> resolveReport({required int reportId, required ReportKind kind, required bool resolved}) async {
    final endpoint = switch (kind) {
      ReportKind.post => '$basePath/post/report/resolve',
      ReportKind.comment => '$basePath/comment/report/resolve',
      _ => throw UnsupportedFeatureException('${kind.name} reports', platformName: platformName),
    };
    final json = await request(HttpMethod.put, endpoint, {
      'report_id': reportId,
      'resolved': resolved,
    });
    return switch (kind) {
      ReportKind.post => _mapper.postReportView(json['post_report_view']),
      ReportKind.comment => _mapper.commentReportView(json['comment_report_view']),
      _ => throw UnsupportedFeatureException('${kind.name} reports', platformName: platformName),
    };
  }

  // =============================================================
  // Comments
  // =============================================================

  @override
  Future<ThunderComment> getComment(int commentId) async {
    final json = await request(HttpMethod.get, '$basePath/comment', {'id': commentId});
    return _mapper.commentView(json['comment_view']);
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

    final comments = (json['comments'] as List).map<ThunderComment>((cv) => _mapper.commentView(cv)).toList();
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
    return _mapper.commentView(json['comment_view']);
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
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/like', {
      'comment_id': commentId,
      'score': score,
    });
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/save', {
      'comment_id': commentId,
      'save': save,
    });
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/delete', {
      'comment_id': commentId,
      'deleted': deleted,
    });
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<void> reportComment({required int commentId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/comment/report', {
      'comment_id': commentId,
      'reason': reason,
    });
  }

  Future<List<ThunderReport>> _getCommentReports({
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
    return (json['comment_reports'] as List).map<ThunderReport>((cr) => _mapper.commentReportView(cr)).toList();
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
      community: _mapper.communityView(json['community_view']),
      site: json['site'] != null ? ThunderSite.fromLemmySite(json['site']) : null,
      moderators: (json['moderators'] as List).map<ThunderUser>((cmv) => _mapper.user(cmv['moderator'])).toList(),
      discussionLanguages: (json['discussion_languages'] as List).cast<int>(),
      flairs: const <ThunderFlair>[],
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
    return (json['communities'] as List).map<ThunderCommunity>((cv) => _mapper.communityView(cv)).toList();
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final json = await request(HttpMethod.post, '$basePath/community/follow', {
      'community_id': communityId,
      'follow': follow,
    });
    return _mapper.communityView(json['community_view']);
  }

  @override
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/community/block', {
      'community_id': communityId,
      'block': block,
    });
    return _mapper.communityView(json['community_view']);
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
    String? cursor,
    int? limit,
    bool? saved,
    bool? includeContent,
  }) async {
    final pageNumber = page ?? int.tryParse(cursor ?? '') ?? 1;
    final json = await request(HttpMethod.get, '$basePath/user', {
      'person_id': userId,
      'username': username,
      'sort': sort?.value,
      'page': pageNumber,
      'limit': limit,
      'saved_only': saved,
    });
    final posts = (json['posts'] as List).map<ThunderPost>((pv) => _mapper.postView(pv)).toList();
    final comments = (json['comments'] as List).map<ThunderComment>((cv) => _mapper.commentView(cv)).toList();

    return (
      user: _mapper.userView(json['person_view']),
      site: json['site'] != null ? ThunderSite.fromLemmySite(json['site']) : null,
      posts: posts,
      comments: comments,
      moderates: (json['moderates'] as List).map<ThunderCommunity>((cmv) => _mapper.community(cmv['community'])).toList(),
      nextPage: (limit != null && posts.length < limit && comments.length < limit) ? null : (pageNumber + 1).toString(),
    );
  }

  @override
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/user/block', {
      'person_id': userId,
      'block': block,
    });
    return _mapper.userView(json['person_view']);
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
    return _mapper.userView(json['person_view']);
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
    return (json['moderators'] as List).map<ThunderUser>((cmv) => _mapper.user(cmv['moderator'])).toList();
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
      posts: (json['posts'] as List?)?.map<ThunderPost>((pv) => _mapper.postView(pv)).toList() ?? [],
      comments: (json['comments'] as List?)?.map<ThunderComment>((cv) => _mapper.commentView(cv)).toList() ?? [],
      communities: (json['communities'] as List?)?.map<ThunderCommunity>((cv) => _mapper.communityView(cv)).toList() ?? [],
      users: (json['users'] as List?)?.map<ThunderUser>((pv) => _mapper.userView(pv)).toList() ?? [],
    );
  }

  @override
  Future<ResolveResponse> resolve({required String query}) async {
    final json = await request(HttpMethod.get, '$basePath/resolve_object', {'q': query});

    return (
      community: json['community'] != null ? _mapper.communityView(json['community']) : null,
      post: json['post'] != null ? _mapper.postView(json['post']) : null,
      comment: json['comment'] != null ? _mapper.commentView(json['comment']) : null,
      user: json['person'] != null ? _mapper.userView(json['person']) : null,
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
      final comment = _mapper.commentView(crv);

      return comment.copyWith(
        recipient: _mapper.user(crv['recipient']),
        notification: NotificationRef(
          id: crv['comment_reply']['id'],
          kind: NotificationKind.reply,
          read: crv['comment_reply']['read'] ?? false,
          createdAt: DateTime.tryParse(crv['comment_reply']['published'] ?? '') ?? comment.published,
        ),
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
      final comment = _mapper.commentView(mention);

      return comment.copyWith(
        recipient: _mapper.user(mention['recipient']),
        notification: NotificationRef(
          id: mention['person_mention']['id'],
          kind: NotificationKind.mention,
          read: mention['person_mention']['read'] ?? false,
          createdAt: DateTime.tryParse(mention['person_mention']['published'] ?? '') ?? comment.published,
        ),
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
    return (json['private_messages'] as List).map<ThunderPrivateMessage>((pm) => LemmyV3ApiClient._mapper.privateMessageView(pm)).toList();
  }

  @override
  Future<void> markPrivateMessageAsRead({required int notificationId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/private_message/mark_as_read', {
      'private_message_id': notificationId,
      'read': read,
    });
  }

  @override
  Future<List<ThunderPrivateMessage>> getPrivateMessageConversation({
    required int personId,
    int? conversationId,
    int? page,
    int? limit,
  }) async {
    final messages = await getPrivateMessages(page: page, limit: limit);
    return filterPrivateMessageConversation(
      messages: messages,
      personId: personId,
      currentUserId: account.userId,
    );
  }

  @override
  Future<ThunderPrivateMessage> createPrivateMessage({required int recipientId, required String content}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message', {
      'recipient_id': recipientId,
      'content': content,
    });
    return _mapper.privateMessageView(json['private_message_view']);
  }

  // =============================================================
  // Account Settings
  // =============================================================

  @override
  Future<void> saveUserSettings(AccountSettingsUpdate update) async {
    await request(HttpMethod.put, '$basePath/user/save_user_settings', {
      'display_name': update.displayName,
      'bio': update.bio,
      'default_listing_type': update.defaultFeedListType?.value,
      'default_sort_type': update.defaultPostSortType?.value,
      'show_nsfw': update.showNsfw,
      'show_read_posts': update.showReadPosts,
      'show_bot_accounts': update.showBotAccounts,
      'discussion_languages': update.discussionLanguages,
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
  Future<ThunderPage<AccountMediaItem>> media({int? page, int? limit}) async {
    final json = await request(HttpMethod.get, '$basePath/account/list_media', {
      'page': page,
      'limit': limit,
    });
    final items = (json['images'] as List? ?? const []).whereType<Map<String, dynamic>>().map((image) => _accountMediaItemFromLegacy(image, account.instance)).toList();
    return ThunderPage(
      items: items,
      nextPage: limit != null && items.length < limit ? null : ((page ?? 1) + 1).toString(),
    );
  }

  // =============================================================
  // Modlog
  // =============================================================

  @override
  Future<List<ModlogEvent>> getModlog({
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

    return modlogEventsFromV3Response(response, _mapper);
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
  Future<String> uploadImage(String filePath) async {
    final decoded = await uploadMultipartImage(
      httpClient: httpClient,
      uri: Uri.https(account.instance, '/pictrs/image'),
      headers: buildHeaders(),
      fieldName: 'images[]',
      filePath: filePath,
      platformName: platformName,
      stripContentType: false,
      successStatusCode: 201,
    );
    return parseUploadImageUrl(
      decoded,
      instance: account.instance,
      platformName: platformName,
    );
  }

  @override
  Future<void> deleteImage({required String file, String? token}) async {
    if (token == null || token.isEmpty) throw ApiErrorException('Missing delete token', platformName: platformName);
    await request(HttpMethod.get, '/pictrs/image/delete/$token/$file', {});
  }
}

AccountMediaItem _accountMediaItemFromLegacy(Map<String, dynamic> image, String instance) {
  final localImage = image['local_image'] as Map<String, dynamic>? ?? image;
  final alias = localImage['pictrs_alias']?.toString() ?? localImage['file']?.toString() ?? '';
  final url = image['url']?.toString() ?? Uri.https(instance, '/pictrs/image/$alias').toString();

  return AccountMediaItem(
    alias: alias,
    url: url,
    uploadedAt: DateTime.tryParse((localImage['published'] ?? localImage['published_at'] ?? '').toString()),
    thumbnailForPostId: localImage['thumbnail_for_post_id'] as int?,
    deleteToken: localImage['pictrs_delete_token']?.toString() ?? image['delete_token']?.toString(),
  );
}
