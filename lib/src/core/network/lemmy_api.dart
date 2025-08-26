import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'package:thunder/src/core/models/thunder_comment_report.dart';
import 'package:thunder/src/core/models/thunder_post_report.dart';
import 'package:thunder/src/core/models/thunder_private_message.dart';
import 'package:thunder/src/core/models/thunder_site_response.dart';
import 'package:thunder/src/core/update/check_github_update.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/models/thunder_site.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

enum HttpMethod { get, post, put, delete }

class LemmyApiException implements Exception {
  /// The error message
  final String message;

  /// The error code
  final String errorCode;

  LemmyApiException(this.message, this.errorCode);
}

class LemmyApi {
  /// The account to use for API calls
  final Account account;

  /// Whether to show debug information
  final bool debug;

  /// The Lemmy API client
  LemmyApi({required this.account, this.debug = false});

  /// Build headers with optional JWT authorization
  Map<String, String> _buildHeaders() {
    final version = getCurrentVersion(removeInternalBuildNumber: true, trimV: true);
    final userAgent = 'Thunder/$version';

    Map<String, String> headers = {
      'User-Agent': userAgent,
      'Content-Type': 'application/json',
    };

    if (account.jwt != null) headers['Authorization'] = 'Bearer ${account.jwt}';
    return headers;
  }

  /// Handle response from the request. Throws an exception if the request fails.
  Map<String, dynamic> _handleResponse(Uri uri, Response response) {
    if (response.statusCode != 200) {
      debugPrint('Lemmy API: Failed to make request to $uri: ${response.statusCode} ${response.body}');
      throw LemmyApiException(response.body, response.statusCode.toString());
    }

    return jsonDecode(response.body);
  }

  /// Makes an HTTP request with the specified method
  Future<Map<String, dynamic>> _request(HttpMethod method, String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = _buildHeaders();

      Uri uri = Uri.https(account.instance, endpoint);
      Response response;

      data.removeWhere((key, value) => value == null);

      if (method == HttpMethod.get) {
        // Remove null values and convert values to strings
        data = data.map((key, value) => MapEntry(key, value.toString()));

        uri = Uri.https(account.instance, endpoint, data);
        if (debug) debugPrint('Lemmy API: GET $uri');

        response = await get(uri, headers: headers);
      } else {
        uri = Uri.https(account.instance, endpoint);

        switch (method) {
          case HttpMethod.post:
            if (debug) debugPrint('Lemmy API: POST $uri');
            response = await post(uri, body: jsonEncode(data), headers: headers);
            break;
          case HttpMethod.put:
            if (debug) debugPrint('Lemmy API: PUT $uri');
            response = await put(uri, body: jsonEncode(data), headers: headers);
            break;
          default:
            throw ArgumentError('Unsupported HTTP method: $method');
        }
      }

      return _handleResponse(uri, response);
    } catch (e) {
      if (debug) debugPrint('Lemmy API: Error: $e');
      rethrow;
    }
  }

  /// Login
  Future<String?> login({required String username, required String password, String? totp}) async {
    final body = {
      'username_or_email': username,
      'password': password,
      'totp_2fa_token': totp,
    };

    final json = await _request(HttpMethod.post, '/api/v3/user/login', body);
    return json['jwt'];
  }

  /// Get site info
  Future<ThunderSiteResponse> site() async {
    final json = await _request(HttpMethod.get, '/api/v3/site', {});

    final siteResponse = ThunderSiteResponse.fromLemmySiteResponse(json);
    return siteResponse;
  }

  /// Get media
  Future<Map<String, dynamic>> media({int? page, int? limit}) async {
    final json = await _request(HttpMethod.get, '/api/v3/account/list_media', {'page': page, 'limit': limit});
    return json;
  }

  /// Save user settings
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
    final body = {
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
    };

    await _request(HttpMethod.put, '/api/v3/user/save_user_settings', body);
  }

  /// Import settings
  Future<bool> importSettings(String settings) async {
    final body = {'data': settings};

    final json = await _request(HttpMethod.post, '/api/v3/user/import_settings', body);
    return json['success'];
  }

  /// Export settings
  Future<dynamic> exportSettings() async {
    final json = await _request(HttpMethod.get, '/api/v3/user/export_settings', {});
    return json;
  }

  /// Fetches a post from the Lemmy API
  Future<Map<String, dynamic>> getPost(int postId, {int? commentId}) async {
    final queryParams = {'id': postId, 'comment_id': commentId};

    final json = await _request(HttpMethod.get, '/api/v3/post', queryParams);

    final posts = await parsePosts([ThunderPost.fromLemmyPostView(json['post_view'])]);
    final moderators = json['moderators'].map<ThunderUser>((mu) => ThunderUser.fromLemmyUser(mu['moderator'])).toList();
    final crossPosts = json['cross_posts'].map<ThunderPost>((cp) => ThunderPost.fromLemmyPostView(cp)).toList();

    return {
      'post': posts.first,
      'moderators': moderators,
      'crossPosts': crossPosts,
    };
  }

  /// Fetches a list of posts from the Lemmy API
  Future<List<ThunderPost>> getPosts({
    int page = 1,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool? showHidden,
    bool? showSaved,
  }) async {
    final queryParams = {
      'type_': feedListType?.value,
      'sort': postSortType?.value,
      'page': page,
      'limit': limit,
      'community_name': communityName,
      'community_id': communityId,
      'saved_only': showSaved,
      'show_hidden': showHidden,
    };

    final json = await _request(HttpMethod.get, '/api/v3/post/list', queryParams);
    return json['posts'].map<ThunderPost>((pv) => ThunderPost.fromLemmyPostView(pv)).toList();
  }

  /// Creates a post
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

    final json = await _request(HttpMethod.post, '/api/v3/post', body);
    return ThunderPost.fromLemmyPostView(json['post_view']);
  }

  /// Edits a post
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

    final json = await _request(HttpMethod.put, '/api/v3/post', body);
    return ThunderPost.fromLemmyPostView(json['post_view']);
  }

  /// Votes on a post
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final body = {'post_id': postId, 'score': score};

    final json = await _request(HttpMethod.post, '/api/v3/post/like', body);
    return ThunderPost.fromLemmyPostView(json['post_view']);
  }

  /// Saves a post
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final body = {'post_id': postId, 'save': save};

    final json = await _request(HttpMethod.put, '/api/v3/post/save', body);
    return ThunderPost.fromLemmyPostView(json['post_view']);
  }

  /// Marks a set of posts as read
  Future<bool> readPost({required List<int> postIds, required bool read}) async {
    Map<String, dynamic> body = {'post_ids': postIds, 'read': read};

    final json = await _request(HttpMethod.post, '/api/v3/post/mark_as_read', body);
    return json['success'];
  }

  /// Hides a post
  Future<bool> hidePost({required int postId, required bool hide}) async {
    final body = {
      'post_ids': [postId],
      'hide': hide
    };

    final json = await _request(HttpMethod.post, '/api/v3/post/hide', body);
    return json['success'];
  }

  /// Deletes a post
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    final body = {'post_id': postId, 'deleted': deleted};

    final json = await _request(HttpMethod.post, '/api/v3/post/delete', body);
    final post = ThunderPost.fromLemmyPostView(json['post_view']);
    return post.deleted == deleted;
  }

  /// Locks a post
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final body = {'post_id': postId, 'locked': locked};

    final json = await _request(HttpMethod.post, '/api/v3/post/lock', body);
    final post = ThunderPost.fromLemmyPostView(json['post_view']);
    return post.locked == locked;
  }

  /// Pins a post to the community
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final body = {'post_id': postId, 'featured': pinned, 'feature_type': 'Community'};

    final json = await _request(HttpMethod.post, '/api/v3/post/feature', body);
    final post = ThunderPost.fromLemmyPostView(json['post_view']);
    return post.featuredCommunity == pinned;
  }

  /// Removes a post
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final body = {'post_id': postId, 'removed': removed, 'reason': reason};

    final json = await _request(HttpMethod.post, '/api/v3/post/remove', body);
    final post = ThunderPost.fromLemmyPostView(json['post_view']);
    return post.removed == removed;
  }

  /// Reports a post
  Future<void> reportPost({required int postId, required String reason}) async {
    final body = {'post_id': postId, 'reason': reason};

    await _request(HttpMethod.post, '/api/v3/post/report', body);
  }

  /// Fetches a list of post reports from the Lemmy API
  Future<List<ThunderPostReport>> getPostReports({int? postId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final body = {
      'post_id': postId,
      'page': page,
      'limit': limit,
      'unresolved_only': unresolved,
      'community_id': communityId,
    };

    final json = await _request(HttpMethod.get, '/api/v3/post/report/list', body);
    return json['post_reports'].map<ThunderPostReport>((pr) => ThunderPostReport.fromLemmyPostReportView(pr)).toList();
  }

  /// Resolves a post report
  Future<ThunderPostReport> resolvePostReport({required int reportId, required bool resolved}) async {
    final body = {'report_id': reportId, 'resolved': resolved};

    final json = await _request(HttpMethod.put, '/api/v3/post/report/resolve', body);
    return ThunderPostReport.fromLemmyPostReportView(json['post_report_view']);
  }

  /// Fetches a comment from the Lemmy API
  Future<ThunderComment> getComment(int commentId) async {
    final queryParams = {'id': commentId};

    final json = await _request(HttpMethod.get, '/api/v3/comment', queryParams);
    return ThunderComment.fromLemmyCommentView(json['comment_view']);
  }

  /// Fetches a list of comments from the Lemmy API
  Future<List<ThunderComment>> getComments({
    required int postId,
    int? page,
    int? limit,
    int? maxDepth,
    int? communityId,
    int? parentId,
    CommentSortType? commentSortType,
  }) async {
    Map<String, dynamic> body = {
      'sort': commentSortType?.value,
      'max_depth': maxDepth,
      'page': page,
      'limit': limit,
      'community_id': communityId,
      'post_id': postId,
      'parent_id': parentId,
      'depth_first': true,
      'type_': 'All',
    };

    final json = await _request(HttpMethod.get, '/api/v3/comment/list', body);
    return json['comments'].map<ThunderComment>((cv) => ThunderComment.fromLemmyCommentView(cv)).toList();
  }

  /// Creates a comment
  Future<ThunderComment> createComment({required int postId, required String content, int? parentId, int? languageId}) async {
    final body = {
      'post_id': postId,
      'content': content,
      'parent_id': parentId,
      'language_id': languageId,
    };

    final json = await _request(HttpMethod.post, '/api/v3/comment', body);
    return ThunderComment.fromLemmyCommentView(json['comment_view']);
  }

  /// Edits a comment
  Future<ThunderComment> editComment({required int commentId, required String content, int? languageId}) async {
    final body = {'comment_id': commentId, 'content': content, 'language_id': languageId};

    final json = await _request(HttpMethod.put, '/api/v3/comment', body);
    return ThunderComment.fromLemmyCommentView(json['comment_view']);
  }

  /// Votes on a comment
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final body = {'comment_id': commentId, 'score': score};

    final json = await _request(HttpMethod.post, '/api/v3/comment/like', body);
    return ThunderComment.fromLemmyCommentView(json['comment_view']);
  }

  /// Saves a comment
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final body = {'comment_id': commentId, 'save': save};

    final json = await _request(HttpMethod.put, '/api/v3/comment/save', body);
    return ThunderComment.fromLemmyCommentView(json['comment_view']);
  }

  /// Deletes a comment
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final body = {'comment_id': commentId, 'deleted': deleted};

    final json = await _request(HttpMethod.post, '/api/v3/comment/delete', body);
    return ThunderComment.fromLemmyCommentView(json['comment_view']);
  }

  /// Reports a comment
  Future<void> reportComment({required int commentId, required String reason}) async {
    final body = {'comment_id': commentId, 'reason': reason};

    await _request(HttpMethod.post, '/api/v3/comment/report', body);
  }

  /// Fetches a list of comment reports from the Lemmy API
  Future<List<ThunderCommentReport>> getCommentReports({int? commentId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final body = {
      'comment_id': commentId,
      'page': page,
      'limit': limit,
      'unresolved_only': unresolved,
      'community_id': communityId,
    };

    final json = await _request(HttpMethod.get, '/api/v3/comment/report/list', body);
    return json['comment_reports'].map<ThunderCommentReport>((cr) => ThunderCommentReport.fromLemmyCommentReportView(cr)).toList();
  }

  /// Resolves a comment report
  Future<ThunderCommentReport> resolveCommentReport({required int reportId, required bool resolved}) async {
    final body = {'report_id': reportId, 'resolved': resolved};

    final json = await _request(HttpMethod.put, '/api/v3/comment/report/resolve', body);
    return ThunderCommentReport.fromLemmyCommentReportView(json['comment_report_view']);
  }

  /// Searches for posts, comments, communities, and users
  Future<Map<String, dynamic>> search({
    required String query,
    int? communityId,
    String? communityName,
    int? creatorId,
    MetaSearchType? type,
    PostSortType? sort,
    FeedListType? listingType,
    int? page,
    int? limit,
  }) async {
    final body = {
      'q': query,
      'community_id': communityId,
      'community_name': communityName,
      'creator_id': creatorId,
      'type_': type?.searchType,
      'sort': sort?.value,
      'listing_type': listingType?.value,
      'page': page,
      'limit': limit,
    };

    final json = await _request(HttpMethod.get, '/api/v3/search', body);
    return json;
  }

  /// Resolves a given query
  Future<Map<String, dynamic>> resolve({required String query}) async {
    final body = {'q': query};
    final json = await _request(HttpMethod.get, '/api/v3/resolve_object', body);

    return {
      'community': json['community'] != null ? ThunderCommunity.fromLemmyCommunityView(json['community']) : null,
      'post': json['post'] != null ? ThunderPost.fromLemmyPostView(json['post']) : null,
      'comment': json['comment'] != null ? ThunderComment.fromLemmyCommentView(json['comment']) : null,
      'user': json['user'] != null ? ThunderUser.fromLemmyUserView(json['user']) : null,
    };
  }

  /// Fetches the unread count for the current user
  Future<Map<String, dynamic>> unreadCount() async {
    final json = await _request(HttpMethod.get, '/api/v3/user/unread_count', {});
    return json;
  }

  /// Fetches comment replies
  Future<Map<String, dynamic>> getCommentReplies({int? page, int? limit, CommentSortType? sort, bool unread = false}) async {
    final body = {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    };

    final json = await _request(HttpMethod.get, '/api/v3/user/replies', body);
    return json;
  }

  /// Mark comment reply as read
  Future<void> markCommentReplyAsRead({required int replyId, required bool read}) async {
    final body = {'comment_reply_id': replyId, 'read': read};
    await _request(HttpMethod.post, '/api/v3/comment/mark_as_read', body);
  }

  /// Get comment mentions
  Future<Map<String, dynamic>> getCommentMentions({int? page, int? limit, CommentSortType? sort, bool unread = false}) async {
    final body = {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    };

    final json = await _request(HttpMethod.get, '/api/v3/user/mention', body);
    return json;
  }

  /// Mark comment mention as read
  Future<void> markCommentMentionAsRead({required int mentionId, required bool read}) async {
    final body = {'person_mention_id': mentionId, 'read': read};
    await _request(HttpMethod.post, '/api/v3/user/mention/mark_as_read', body);
  }

  /// Fetches any private messages
  Future<List<ThunderPrivateMessage>> getPrivateMessages({int? page, int? limit, bool unread = false, int? creatorId}) async {
    final body = {
      'page': page,
      'limit': limit,
      'unread_only': unread,
      'creator_id': creatorId,
    };

    final json = await _request(HttpMethod.get, '/api/v3/private_message/list', body);
    return json['private_messages'].map<ThunderPrivateMessage>((pm) => ThunderPrivateMessage.fromLemmyPrivateMessageView(pm)).toList();
  }

  /// Mark private message as read
  Future<void> markPrivateMessageAsRead({required int messageId, required bool read}) async {
    final body = {'private_message_id': messageId, 'read': read};
    await _request(HttpMethod.post, '/api/v3/private_message/mark_as_read', body);
  }

  /// Marks all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    await _request(HttpMethod.post, '/api/v3/user/mark_all_as_read', {});
  }

  /// Get a community
  Future<Map<String, dynamic>> getCommunity({int? id, String? name}) async {
    final body = {'id': id, 'name': name};

    final json = await _request(HttpMethod.get, '/api/v3/community', body);

    return {
      'community': ThunderCommunity.fromLemmyCommunityView(json['community_view']),
      'site': json['site'] != null ? ThunderSite.fromLemmySite(json['site']) : null,
      'moderators': json['moderators'].map<ThunderUser>((cmv) => ThunderUser.fromLemmyUser(cmv['moderator'])).toList(),
      'discussion_languages': json['discussion_languages'],
    };
  }

  /// Get a list of communities
  Future<List<ThunderCommunity>> getCommunities({
    int? page,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
  }) async {
    final body = {
      'page': page,
      'limit': limit,
      'type_': feedListType?.value,
      'sort': postSortType?.value,
    };

    final json = await _request(HttpMethod.get, '/api/v3/community/list', body);
    return json['communities'].map<ThunderCommunity>((cv) => ThunderCommunity.fromLemmyCommunityView(cv)).toList();
  }

  /// Subscribe to a community
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final body = {'community_id': communityId, 'follow': follow};

    final json = await _request(HttpMethod.post, '/api/v3/community/follow', body);
    return ThunderCommunity.fromLemmyCommunityView(json['community_view']);
  }

  /// Block a community
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final body = {'community_id': communityId, 'block': block};

    final json = await _request(HttpMethod.post, '/api/v3/community/block', body);
    return ThunderCommunity.fromLemmyCommunityView(json['community_view']);
  }

  /// Ban a user from a community
  Future<ThunderUser> banUserFromCommunity({
    required int userId,
    required int communityId,
    required bool ban,
    bool? removeData,
    String? reason,
    int? expires,
  }) async {
    final body = {'person_id': userId, 'community_id': communityId, 'reason': reason, 'expires': expires, 'remove_data': removeData, 'ban': ban};

    final json = await _request(HttpMethod.post, '/api/v3/community/ban_user', body);
    return ThunderUser.fromLemmyUserView(json['person_view']);
  }

  /// Add a moderator to a community
  Future<List<ThunderUser>> addModerator({required int userId, required int communityId, required bool added}) async {
    final body = {'person_id': userId, 'community_id': communityId, 'added': added};

    final json = await _request(HttpMethod.post, '/api/v3/community/mod', body);
    return json['moderators'].map<ThunderUser>((cmv) => ThunderUser.fromLemmyUser(cmv['moderator'])).toList();
  }

  /// Get a user
  Future<Map<String, dynamic>> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  }) async {
    final body = {
      'person_id': userId,
      'username': username,
      'sort': sort?.value,
      'page': page,
      'limit': limit,
      'saved_only': saved,
    };

    final json = await _request(HttpMethod.get, '/api/v3/user', body);

    return {
      'user': ThunderUser.fromLemmyUserView(json['person_view']),
      'site': json['site'] != null ? ThunderSite.fromLemmySite(json['site']) : null,
      'posts': json['posts'].map<ThunderPost>((pv) => ThunderPost.fromLemmyPostView(pv)).toList(),
      'comments': json['comments'].map<ThunderComment>((cv) => ThunderComment.fromLemmyCommentView(cv)).toList(),
      'moderates': json['moderates'].map<ThunderCommunity>((cmv) => ThunderCommunity.fromLemmyCommunity(cmv['community'])).toList(),
    };
  }

  /// Block a user
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final body = {'person_id': userId, 'block': block};

    final json = await _request(HttpMethod.post, '/api/v3/user/block', body);
    return ThunderUser.fromLemmyUserView(json['person_view']);
  }

  /// Block an instance
  Future<bool> blockInstance({required int instanceId, required bool block}) async {
    final body = {'instance_id': instanceId, 'block': block};

    final json = await _request(HttpMethod.post, '/api/v3/site/block', body);
    return json['blocked'];
  }

  /// Get federated instances
  Future<Map<String, dynamic>> federated() async {
    final json = await _request(HttpMethod.get, '/api/v3/federated_instances', {});
    return json;
  }

  /// Upload an image using multipart form data
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      final request = MultipartRequest('POST', Uri.https(account.instance, '/pictrs/image'));
      request.headers.addAll(_buildHeaders());
      request.files.add(await MultipartFile.fromPath('images[]', filePath));

      final response = await request.send();
      if (response.statusCode != 201) throw Exception('Failed to upload image: ${response.statusCode} ${response.reasonPhrase}');

      final json = await jsonDecode(await response.stream.bytesToString());
      return json;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete an image
  Future<void> deleteImage({required String file, required String token}) async {
    await _request(HttpMethod.get, '/pictrs/image/delete/$token/$file', {});
  }

  /// Get modlog
  Future<Map<String, dynamic>> getModlog({
    int? page,
    int? limit,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  }) async {
    final body = {
      'page': page,
      'type_': modlogActionType?.value,
      'community_id': communityId,
      'other_person_id': userId,
      'mod_person_id': moderatorId,
      'comment_id': commentId,
    };

    final json = await _request(HttpMethod.get, '/api/v3/modlog', body);
    return json;
  }
}
