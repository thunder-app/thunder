import 'package:thunder/src/core/networking/base_api_client.dart';
import 'package:thunder/src/core/networking/lemmy_api_client_defaults.dart';
import 'package:thunder/src/core/networking/lemmy_private_message_utils.dart';
import 'package:thunder/src/core/networking/modlog_parsers.dart';
import 'package:thunder/src/core/networking/mappers/primitive_mappers.dart';
import 'package:thunder/src/core/networking/mappers/site_response_mapper.dart';
import 'package:thunder/src/core/networking/thunder_api_client.dart';
import 'package:thunder/src/core/networking/upload_image_utils.dart';
import 'package:thunder/src/core/domain/enums/comment_sort_type.dart';
import 'package:thunder/src/core/domain/enums/feed_list_type.dart';
import 'package:thunder/src/core/domain/enums/meta_search_type.dart';
import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';
import 'package:thunder/src/core/domain/enums/post_sort_type.dart';
import 'package:thunder/src/core/domain/enums/search_sort_type.dart';
import 'package:thunder/src/core/domain/models/modlog_event_item.dart';
import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_content_item.dart';
import 'package:thunder/src/core/domain/models/thunder_flair.dart';
import 'package:thunder/src/core/domain/models/thunder_link_metadata.dart';
import 'package:thunder/src/core/domain/models/thunder_page.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_private_message.dart';
import 'package:thunder/src/core/domain/models/thunder_report.dart';
import 'package:thunder/src/core/domain/models/thunder_site.dart';
import 'package:thunder/src/core/domain/models/thunder_site_response.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';
import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';
import 'package:thunder/src/core/networking/instance_uri.dart';

/// Lemmy API client for Lemmy 1.0+ (`/api/v4`).
///
/// This class intentionally implements v4 endpoints directly so an old v3 path
/// cannot accidentally be called under the v4 base path.
class LemmyV4ApiClient extends BaseApiClient with LemmyApiClientDefaults {
  static const _mapper = LemmyV4PrimitiveMapper();

  LemmyV4ApiClient({required super.account, super.debug, required super.version, super.httpClient});

  @override
  String get platformName => 'Lemmy';

  @override
  String get basePath => '/api/v4';

  // =============================================================
  // Authentication & Site
  // =============================================================

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    final json = await request(HttpMethod.post, '$basePath/account/auth/login', {'username_or_email': username, 'password': password, 'totp_2fa_token': totp, 'stay_logged_in': true});
    return json['jwt'] as String?;
  }

  @override
  Future<void> logout() async {
    await request(HttpMethod.post, '$basePath/account/auth/logout', {});
  }

  @override
  Future<ThunderSiteResponse> site() async {
    final siteJson = await request(HttpMethod.get, '$basePath/site', {});
    Map<String, dynamic>? accountJson;
    if (account.jwt != null) {
      accountJson = await request(HttpMethod.get, '$basePath/account', {});
    }
    return lemmyV4SiteAndAccountResponse(siteResponse: siteJson, accountResponse: accountJson);
  }

  // =============================================================
  // Posts
  // =============================================================

  @override
  Future<GetPostResponse> getPost(int postId, {int? commentId}) async {
    final json = await request(HttpMethod.get, '$basePath/post', {'id': postId, 'comment_id': commentId});

    return (
      post: _mapper.postView(json['post_view']),
      moderators: const <ThunderUser>[],
      crossPosts: (json['cross_posts'] as List? ?? const []).map<ThunderPost>((cp) => _mapper.postView(cp)).toList(),
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
    if (showSaved == true) {
      final page = await _contentPage('$basePath/account/saved', cursor: cursor, limit: limit, type: 'posts', searchTerm: query);
      return (posts: page.items.whereType<ThunderPost>().toList(), nextPage: page.nextPage);
    }

    if (likedOnly == true) {
      final page = await _contentPage('$basePath/account/liked', cursor: cursor, limit: limit, type: 'posts');
      return (posts: page.items.whereType<ThunderPost>().toList(), nextPage: page.nextPage);
    }

    final sort = _v4PostSort(postSortType);
    final json = await request(HttpMethod.get, '$basePath/post/list', {
      'type_': feedListType?.value.toLowerCase(),
      'sort': sort.sort,
      'time_range_seconds': sort.timeRangeSeconds,
      'page_cursor': cursor,
      'limit': limit,
      'community_name': communityName,
      'community_id': communityId,
      'creator_id': personId,
      'search_term': query,
      'show_hidden': showHidden,
    });

    final items = (json['items'] as List? ?? const []).map<ThunderPost>((pv) => _mapper.postView(pv)).toList();
    return (posts: items, nextPage: json['next_page']?.toString());
  }

  @override
  Future<ThunderPost> createPost({required String title, required int communityId, String? url, String? contents, bool? nsfw, int? languageId, String? customThumbnail, String? altText}) async {
    final json = await request(HttpMethod.post, '$basePath/post', {
      'name': title,
      'community_id': communityId,
      'url': url,
      'body': contents,
      'alt_text': altText,
      'nsfw': nsfw,
      'language_id': languageId,
      'custom_thumbnail': customThumbnail,
    });
    return _mapper.postView(json['post_view']);
  }

  @override
  Future<ThunderPost> editPost({required int postId, required String title, String? url, String? contents, String? altText, String? tags, bool? nsfw, int? languageId, String? customThumbnail}) async {
    final json = await request(HttpMethod.put, '$basePath/post', {
      'post_id': postId,
      'name': title,
      'url': url,
      'body': contents,
      'alt_text': altText,
      'nsfw': nsfw,
      'language_id': languageId,
      'custom_thumbnail': customThumbnail,
    });
    return _mapper.postView(json['post_view']);
  }

  @override
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/post/like', {
      'post_id': postId,
      'is_upvote': switch (score) {
        1 => true,
        -1 => false,
        _ => null,
      },
    });
    return _mapper.postView(json['post_view']);
  }

  @override
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/post/save', {'post_id': postId, 'save': save});
    return _mapper.postView(json['post_view']);
  }

  @override
  Future<bool> readPost({required List<int> postIds, required bool read}) async {
    if (postIds.length == 1) {
      await request(HttpMethod.post, '$basePath/post/mark_as_read', {'post_id': postIds.single, 'read': read});
      return true;
    }
    final json = await request(HttpMethod.post, '$basePath/post/mark_as_read/many', {'post_ids': postIds, 'read': read});
    return json['success'] as bool? ?? true;
  }

  @override
  Future<bool> hidePost({required int postId, required bool hide}) async {
    await request(HttpMethod.post, '$basePath/post/hide', {'post_id': postId, 'hide': hide});
    return true;
  }

  @override
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    final json = await request(HttpMethod.delete, '$basePath/post', {'post_id': postId, 'deleted': deleted});
    return _mapper.postView(json['post_view']).status.deleted == deleted;
  }

  @override
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final json = await request(HttpMethod.post, '$basePath/post/lock', {'post_id': postId, 'locked': locked, 'reason': ''});
    return _mapper.postView(json['post_view']).status.locked == locked;
  }

  @override
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final json = await request(HttpMethod.post, '$basePath/post/feature', {'post_id': postId, 'featured': pinned, 'feature_type': 'community'});
    return _mapper.postView(json['post_view']).status.featuredCommunity == pinned;
  }

  @override
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final json = await request(HttpMethod.post, '$basePath/post/remove', {'post_id': postId, 'removed': removed, 'reason': reason});
    return _mapper.postView(json['post_view']).status.removed == removed;
  }

  @override
  Future<void> reportPost({required int postId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/post/report', {'post_id': postId, 'reason': reason});
  }

  @override
  Future<ThunderPage<ThunderReport>> getReports({ReportKind? kind, int? postId, int? commentId, int page = 1, String? cursor, int limit = 20, bool unresolved = false, int? communityId}) async {
    final json = await request(HttpMethod.get, '$basePath/report/list', {
      'post_id': postId,
      'page_cursor': cursor,
      'limit': limit,
      'unresolved_only': unresolved,
      'community_id': communityId,
      'type_': _reportType(kind),
    });
    return ThunderPage(
      items: (json['items'] as List? ?? const []).whereType<Map<String, dynamic>>().map<ThunderReport>(_mapper.reportView).toList(),
      nextPage: json['next_page']?.toString(),
      previousPage: json['prev_page']?.toString(),
    );
  }

  @override
  Future<ThunderReport> resolveReport({required int reportId, required ReportKind kind, required bool resolved}) async {
    final endpoint = switch (kind) {
      ReportKind.post => '$basePath/post/report/resolve',
      ReportKind.comment => '$basePath/comment/report/resolve',
      ReportKind.privateMessage => '$basePath/private_message/report/resolve',
      ReportKind.community => '$basePath/community/report/resolve',
    };
    final json = await request(HttpMethod.put, endpoint, {'report_id': reportId, 'resolved': resolved});
    return switch (kind) {
      ReportKind.post => _mapper.postReportView(json['post_report_view']),
      ReportKind.comment => _mapper.commentReportView(json['comment_report_view']),
      ReportKind.privateMessage => _mapper.reportView({'type_': 'private_message', ...(json['private_message_report_view'] as Map<String, dynamic>)}),
      ReportKind.community => _mapper.reportView({'type_': 'community', ...(json['community_report_view'] as Map<String, dynamic>)}),
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
  Future<GetCommentsResponse> getComments({required int postId, int? page, String? cursor, int? limit, int? maxDepth, int? communityId, int? parentId, CommentSortType? commentSortType}) async {
    final json = await request(HttpMethod.get, '$basePath/comment/list', {
      'sort': commentSortType?.value.toLowerCase(),
      'max_depth': maxDepth,
      'page_cursor': cursor,
      'limit': limit,
      'community_id': communityId,
      'post_id': postId,
      'parent_id': parentId,
      'type_': 'all',
    });

    final comments = (json['items'] as List? ?? const []).map<ThunderComment>((cv) => _mapper.commentView(cv)).toList();
    return (comments: comments, nextPage: json['next_page']?.toString());
  }

  @override
  Future<ThunderComment> createComment({required int postId, required String content, int? parentId, int? languageId}) async {
    final json = await request(HttpMethod.post, '$basePath/comment', {'post_id': postId, 'content': content, 'parent_id': parentId, 'language_id': languageId});
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> editComment({required int commentId, required String content, int? languageId}) async {
    final json = await request(HttpMethod.put, '$basePath/comment', {'comment_id': commentId, 'content': content, 'language_id': languageId});
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/like', {
      'comment_id': commentId,
      'is_upvote': switch (score) {
        1 => true,
        -1 => false,
        _ => null,
      },
    });
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/save', {'comment_id': commentId, 'save': save});
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final json = await request(HttpMethod.delete, '$basePath/comment', {'comment_id': commentId, 'deleted': deleted});
    return _mapper.commentView(json['comment_view']);
  }

  @override
  Future<void> reportComment({required int commentId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/comment/report', {'comment_id': commentId, 'reason': reason});
  }

  // =============================================================
  // Communities
  // =============================================================

  @override
  Future<GetCommunityResponse> getCommunity({int? id, String? name}) async {
    final json = await request(HttpMethod.get, '$basePath/community', {'id': id, 'name': name});
    return (
      community: _mapper.communityView(json['community_view']),
      site: json['site'] != null ? ThunderSite.fromLemmyV4Site(json['site']) : null,
      moderators: (json['moderators'] as List? ?? const []).map<ThunderUser>((cmv) => _mapper.user(cmv['moderator'])).toList(),
      discussionLanguages: (json['discussion_languages'] as List? ?? const []).cast<int>(),
      flairs: const <ThunderFlair>[],
    );
  }

  @override
  Future<List<ThunderCommunity>> getCommunities({int? page, int? limit, FeedListType? feedListType, PostSortType? postSortType}) async {
    final json = await request(HttpMethod.get, '$basePath/community/list', {'limit': limit, 'type_': feedListType?.value.toLowerCase(), 'sort': postSortType?.value.toLowerCase()});
    return (json['items'] as List? ?? const []).map<ThunderCommunity>((cv) => _mapper.communityView(cv)).toList();
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final json = await request(HttpMethod.post, '$basePath/community/follow', {'community_id': communityId, 'follow': follow});
    return _mapper.communityView(json['community_view']);
  }

  @override
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/account/block/community', {'community_id': communityId, 'block': block});
    return _mapper.communityView(json['community_view']);
  }

  // =============================================================
  // Users
  // =============================================================

  @override
  Future<GetUserResponse> getUser({int? userId, String? username, PostSortType? sort, int? page, String? cursor, int? limit, bool? saved, bool? includeContent}) async {
    final details = await request(HttpMethod.get, '$basePath/person', {'person_id': userId, 'username': username});

    final content = includeContent == false
        ? <String, dynamic>{'items': const []}
        : saved == true
        ? await request(HttpMethod.get, '$basePath/account/saved', {'page_cursor': cursor, 'limit': limit, 'type_': 'all'})
        : await request(HttpMethod.get, '$basePath/person/content', {'person_id': userId, 'username': username, 'page_cursor': cursor, 'limit': limit, 'type_': 'all'});

    final items = (content['items'] as List? ?? const []).map((item) => _mapper.contentItem(item)).toList();

    return (
      user: _mapper.userView(details['person_view']),
      site: details['site'] != null ? ThunderSite.fromLemmyV4Site(details['site']) : null,
      posts: items.whereType<ThunderPostItem>().map((item) => item.post).toList(),
      comments: items.whereType<ThunderCommentItem>().map((item) => item.comment).toList(),
      moderates: (details['moderates'] as List? ?? const []).map<ThunderCommunity>((cmv) => _mapper.community(cmv['community'])).toList(),
      nextPage: content['next_page']?.toString(),
    );
  }

  @override
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/account/block/person', {'person_id': userId, 'block': block});
    return _mapper.userView(json['person_view']);
  }

  @override
  Future<ThunderUser> banUserFromCommunity({required int userId, required int communityId, required bool ban, bool? removeData, String? reason, int? expires}) async {
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
  Future<List<ThunderUser>> addModerator({required int userId, required int communityId, required bool added}) async {
    final json = await request(HttpMethod.post, '$basePath/community/mod', {'person_id': userId, 'community_id': communityId, 'added': added});
    return (json['moderators'] as List? ?? const []).map<ThunderUser>((cmv) => _mapper.user(cmv['moderator'])).toList();
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
      'search_term': query,
      'community_id': communityId,
      'community_name': communityName,
      'creator_id': creatorId,
      'type_': type?.searchType?.toLowerCase(),
      'listing_type': listingType?.value.toLowerCase(),
      'limit': limit,
      'show_nsfw': nsfw,
    });

    return (
      type: type ?? MetaSearchType.all,
      posts: (json['posts'] as List?)?.map<ThunderPost>((pv) => _mapper.postView(pv)).toList() ?? [],
      comments: (json['comments'] as List?)?.map<ThunderComment>((cv) => _mapper.commentView(cv)).toList() ?? [],
      communities: (json['communities'] as List?)?.map<ThunderCommunity>((cv) => _mapper.communityView(cv)).toList() ?? [],
      users: (json['persons'] as List?)?.map<ThunderUser>((pv) => _mapper.userView(pv)).toList() ?? [],
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
    final json = await request(HttpMethod.get, '$basePath/account/unread_counts', {});
    final count = (json['notification_count'] as num?)?.toInt() ?? 0;
    return (replies: count, mentions: 0, privateMessages: 0);
  }

  @override
  Future<List<ThunderComment>> getCommentReplies({int? page, int? limit, CommentSortType? sort, bool unread = false}) async {
    final notifications = await _notifications(type: 'reply', page: page, limit: limit, unread: unread);
    return notifications.map((notification) {
      final data = notification['data'] as Map<String, dynamic>;
      return _mapper.commentView(data, notification: _mapper.notificationRef(notification));
    }).toList();
  }

  @override
  Future<void> markCommentReplyAsRead({required int replyId, required bool read}) async {
    await _markNotificationAsRead(notificationId: replyId, read: read);
  }

  @override
  Future<List<ThunderComment>> getCommentMentions({int? page, int? limit, CommentSortType? sort, bool unread = false}) async {
    final notifications = await _notifications(type: 'mention', page: page, limit: limit, unread: unread);
    return notifications.map((notification) {
      final data = notification['data'] as Map<String, dynamic>;
      return _mapper.commentView(data, notification: _mapper.notificationRef(notification));
    }).toList();
  }

  @override
  Future<void> markCommentMentionAsRead({required int mentionId, required bool read}) async {
    await _markNotificationAsRead(notificationId: mentionId, read: read);
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await request(HttpMethod.post, '$basePath/account/notification/mark_as_read/all', {});
  }

  // =============================================================
  // Private Messages
  // =============================================================

  @override
  Future<List<ThunderPrivateMessage>> getPrivateMessages({int? page, int? limit, bool unread = false, int? creatorId}) async {
    final notifications = await _notifications(type: 'private_message', page: page, limit: limit, unread: unread, creatorId: creatorId);
    return notifications.map((notification) {
      final data = notification['data'] as Map<String, dynamic>;
      return _mapper.privateMessageView(data, notification: _mapper.notificationRef(notification));
    }).toList();
  }

  @override
  Future<void> markPrivateMessageAsRead({required int notificationId, required bool read}) async {
    await _markNotificationAsRead(notificationId: notificationId, read: read);
  }

  @override
  Future<ThunderPrivateMessage> createPrivateMessage({required int recipientId, required String content}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message', {'recipient_id': recipientId, 'content': content});
    return _mapper.privateMessageView(json['private_message_view']);
  }

  Future<ThunderPrivateMessage> editPrivateMessage({required int privateMessageId, required String content}) async {
    final json = await request(HttpMethod.put, '$basePath/private_message', {'private_message_id': privateMessageId, 'content': content});
    return _mapper.privateMessageView(json['private_message_view']);
  }

  Future<ThunderPrivateMessage> deletePrivateMessage({required int privateMessageId, required bool deleted}) async {
    final json = await request(HttpMethod.delete, '$basePath/private_message', {'private_message_id': privateMessageId, 'deleted': deleted});
    return _mapper.privateMessageView(json['private_message_view']);
  }

  /// Lemmy 1.0 has no dedicated PM conversation endpoint; filter the inbox list.
  @override
  Future<List<ThunderPrivateMessage>> getPrivateMessageConversation({required int personId, int? conversationId, int? page, int? limit}) async {
    final messages = await getPrivateMessages(page: page, limit: limit);
    return filterPrivateMessageConversation(messages: messages, personId: personId, currentUserId: account.userId);
  }
  // =============================================================
  // Account Settings
  // =============================================================

  @override
  Future<void> saveUserSettings(AccountSettingsUpdate update) async {
    await request(HttpMethod.put, '$basePath/account/settings/save', {
      'display_name': update.displayName,
      'bio': update.bio,
      'default_listing_type': update.defaultFeedListType?.value.toLowerCase(),
      'default_post_sort_type': update.defaultPostSortType?.value.toLowerCase(),
      'show_nsfw': update.showNsfw,
      'show_read_posts': update.showReadPosts,
      'show_bot_accounts': update.showBotAccounts,
      'discussion_languages': update.discussionLanguages,
    });
  }

  @override
  Future<bool> importSettings(String settings) async {
    final json = await request(HttpMethod.post, '$basePath/account/settings/import', {'data': settings});
    return json['success'] as bool? ?? true;
  }

  @override
  Future<dynamic> exportSettings() async {
    return await request(HttpMethod.get, '$basePath/account/settings/export', {});
  }

  @override
  Future<ThunderPage<AccountMediaItem>> media({int? page, int? limit}) async {
    final json = await request(HttpMethod.get, '$basePath/account/media/list', {'limit': limit});
    return ThunderPage(
      items: (json['items'] as List? ?? const []).whereType<Map<String, dynamic>>().map((image) => _accountMediaItemFromLemmyV4(image, account.instance)).toList(),
      nextPage: json['next_page']?.toString(),
      previousPage: json['prev_page']?.toString(),
    );
  }

  // =============================================================
  // Modlog
  // =============================================================

  @override
  Future<List<ModlogEvent>> getModlog({int? page, int? limit, ModlogActionType? modlogActionType, int? communityId, int? userId, int? moderatorId, int? commentId}) async {
    final json = await request(HttpMethod.get, '$basePath/modlog', {
      'limit': limit,
      'type_': modlogActionType?.value.toLowerCase(),
      'community_id': communityId,
      'other_person_id': userId,
      'mod_person_id': moderatorId,
      'comment_id': commentId,
    });

    return (json['items'] as List? ?? const []).map((raw) => modlogEventFromV4(raw, _mapper)).nonNulls.toList();
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
    final communities = await request(HttpMethod.post, '$basePath/account/block/instance/communities', {'instance_id': instanceId, 'block': block});
    final persons = await request(HttpMethod.post, '$basePath/account/block/instance/persons', {'instance_id': instanceId, 'block': block});
    return (communities['success'] as bool? ?? true) && (persons['success'] as bool? ?? true) ? block : !block;
  }

  // =============================================================
  // Media
  // =============================================================

  @override
  Future<String> uploadImage(String filePath) async {
    final decoded = await uploadMultipartImage(
      httpClient: httpClient,
      uri: buildInstanceUri(account.instance, '$basePath/image'),
      headers: buildHeaders(),
      fieldName: 'image',
      filePath: filePath,
      platformName: platformName,
    );
    return parseUploadImageUrl(decoded, instance: account.instance, platformName: platformName);
  }

  @override
  Future<void> deleteImage({required String file, String? token}) async {
    await request(HttpMethod.delete, '$basePath/account/media', {'filename': file});
  }

  @override
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url}) async {
    final response = await request(HttpMethod.get, '$basePath/post/site_metadata', {'url': url});
    final metadata = response['metadata'];
    if (metadata is! Map<String, dynamic>) return null;
    return ThunderLinkMetadata.fromLemmySiteMetadata(metadata, url: url);
  }

  Future<ThunderPage<dynamic>> _contentPage(String endpoint, {String? cursor, int? limit, String? type, String? searchTerm}) async {
    final json = await request(HttpMethod.get, endpoint, {'page_cursor': cursor, 'limit': limit, 'search_term': searchTerm, 'type_': type});
    final items = (json['items'] as List? ?? const []).map((item) => _mapper.contentItem(item)).map((item) {
      return switch (item) {
        ThunderPostItem(:final post) => post,
        ThunderCommentItem(:final comment) => comment,
      };
    }).toList();
    return ThunderPage(items: items, nextPage: json['next_page']?.toString(), previousPage: json['prev_page']?.toString());
  }

  Future<List<Map<String, dynamic>>> _notifications({String? type, int? page, int? limit, bool unread = false, int? creatorId}) async {
    final json = await request(HttpMethod.get, '$basePath/account/notification/list', {'limit': limit, 'creator_id': creatorId, 'unread_only': unread, 'type_': type});
    return (json['items'] as List? ?? const []).whereType<Map<String, dynamic>>().toList();
  }

  Future<void> _markNotificationAsRead({required int notificationId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/account/notification/mark_as_read', {'notification_id': notificationId, 'read': read});
  }
}

({String? sort, int? timeRangeSeconds}) _v4PostSort(PostSortType? sort) {
  return switch (sort) {
    PostSortType.topHour => (sort: 'top', timeRangeSeconds: 3600),
    PostSortType.topSixHour => (sort: 'top', timeRangeSeconds: 21600),
    PostSortType.topTwelveHour => (sort: 'top', timeRangeSeconds: 43200),
    PostSortType.topDay => (sort: 'top', timeRangeSeconds: 86400),
    PostSortType.topWeek => (sort: 'top', timeRangeSeconds: 604800),
    PostSortType.topMonth => (sort: 'top', timeRangeSeconds: 2592000),
    PostSortType.topThreeMonths => (sort: 'top', timeRangeSeconds: 7776000),
    PostSortType.topSixMonths => (sort: 'top', timeRangeSeconds: 15552000),
    PostSortType.topNineMonths => (sort: 'top', timeRangeSeconds: 23328000),
    PostSortType.topYear => (sort: 'top', timeRangeSeconds: 31536000),
    PostSortType.topAll => (sort: 'top', timeRangeSeconds: null),
    null => (sort: null, timeRangeSeconds: null),
    _ => (sort: sort.value.toLowerCase(), timeRangeSeconds: null),
  };
}

String? _reportType(ReportKind? kind) {
  return switch (kind) {
    ReportKind.post => 'posts',
    ReportKind.comment => 'comments',
    ReportKind.privateMessage => 'private_messages',
    ReportKind.community => 'communities',
    null => null,
  };
}

AccountMediaItem _accountMediaItemFromLemmyV4(Map<String, dynamic> image, String instance) {
  final localImage = image['local_image'] as Map<String, dynamic>? ?? image;
  final alias = localImage['pictrs_alias']?.toString() ?? '';
  return AccountMediaItem(
    alias: alias,
    url: buildInstanceUrl(instance, '/pictrs/image/$alias'),
    uploadedAt: DateTime.tryParse((localImage['published_at'] ?? '').toString()),
    thumbnailForPostId: localImage['thumbnail_for_post_id'] as int?,
  );
}
