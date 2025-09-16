import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

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
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

enum HttpMethod { get, post, put, delete }

class PiefedApi {
  /// The account to use for API calls
  final Account account;

  /// Whether to show debug information
  final bool debug;

  /// The Piefed API client
  PiefedApi({required this.account, this.debug = false});

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
  Future _handleResponse(Uri uri, Response response) {
    if (response.statusCode != 200) {
      debugPrint('PieFed API: Failed to make request to $uri: ${response.statusCode} ${response.body}');
      throw Exception(response.body);
    }

    return compute(jsonDecode, response.body);
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
        if (debug) debugPrint('PieFed API: GET $uri');

        response = await get(uri, headers: headers);
      } else {
        uri = Uri.https(account.instance, endpoint);

        switch (method) {
          case HttpMethod.post:
            if (debug) debugPrint('PieFed API: POST $uri');
            response = await post(uri, body: jsonEncode(data), headers: headers);
            break;
          case HttpMethod.put:
            if (debug) debugPrint('PieFed API: PUT $uri');
            response = await put(uri, body: jsonEncode(data), headers: headers);
            break;
          default:
            throw ArgumentError('Unsupported HTTP method: $method');
        }
      }

      return await _handleResponse(uri, response);
    } catch (e) {
      if (debug) debugPrint('PieFed API: Error: $e');
      rethrow;
    }
  }

  /// Login
  Future<String?> login({required String username, required String password}) async {
    final body = {
      'username': username,
      'password': password,
    };

    final json = await _request(HttpMethod.post, '/api/alpha/user/login', body);
    return json['jwt'];
  }

  /// Get site info
  Future<ThunderSiteResponse> site() async {
    final json = await _request(HttpMethod.get, '/api/alpha/site', {});

    final siteResponse = ThunderSiteResponse.fromPiefedSiteResponse(json);
    return siteResponse;
  }

  /// Save user settings
  Future<void> saveUserSettings({
    String? bio,
    bool? showNsfw,
    bool? showReadPosts,
  }) async {
    final body = {
      'bio': bio,
      'show_nsfw': showNsfw,
      'show_read_posts': showReadPosts,
    };

    await _request(HttpMethod.put, '/api/alpha/user/save_user_settings', body);
  }

  /// Fetches a post from the Piefed API
  Future<Map<String, dynamic>> getPost(int postId, {int? commentId}) async {
    final queryParams = {'id': postId, 'comment_id': commentId};

    final json = await _request(HttpMethod.get, '/api/alpha/post', queryParams);

    final posts = await parsePosts([ThunderPost.fromPiefedPostView(json['post_view'])]);
    final moderators = json['moderators'].map<ThunderUser>((mu) => ThunderUser.fromPiefedUser(mu['moderator'])).toList();
    final crossPosts = json['cross_posts'].map<ThunderPost>((cp) => ThunderPost.fromPiefedPostView(cp)).toList();

    return {
      'post': posts.first,
      'moderators': moderators,
      'crossPosts': crossPosts,
    };
  }

  /// Fetches a list of posts from the Piefed API
  Future<List<ThunderPost>> getPosts({
    int page = 1,
    int? limit,
    int? personId,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool? showSaved,
    bool? likedOnly,
  }) async {
    final queryParams = {
      'type_': feedListType?.value,
      'sort': postSortType?.value,
      'page_cursor': page.toString(), // Page cursor is the page number in string format
      'limit': limit,
      'community_name': communityName,
      'community_id': communityId,
      'person_id': personId,
      'saved_only': showSaved,
      'liked_only': likedOnly,
    };

    final json = await _request(HttpMethod.get, '/api/alpha/post/list', queryParams);
    return json['posts'].map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList();
  }

  /// Creates a post
  Future<ThunderPost> createPost({
    required String title,
    required int communityId,
    String? url,
    String? contents,
    bool? nsfw,
    int? languageId,
  }) async {
    final body = {
      'title': title,
      'community_id': communityId,
      'url': url,
      'body': contents,
      'nsfw': nsfw,
      'language_id': languageId,
    };

    final json = await _request(HttpMethod.post, '/api/alpha/post', body);
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  /// Edits a post
  Future<ThunderPost> editPost({
    required int postId,
    required String title,
    String? url,
    String? contents,
    bool? nsfw,
    int? languageId,
  }) async {
    final body = {
      'post_id': postId,
      'title': title,
      'url': url,
      'body': contents,
      'nsfw': nsfw,
      'language_id': languageId,
    };

    final json = await _request(HttpMethod.put, '/api/alpha/post', body);
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  /// Votes on a post
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final body = {'post_id': postId, 'score': score};

    final json = await _request(HttpMethod.post, '/api/alpha/post/like', body);
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  /// Saves a post
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final body = {'post_id': postId, 'save': save};

    final json = await _request(HttpMethod.put, '/api/alpha/post/save', body);
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  /// Marks a set of posts as read
  Future<bool> readPost({required List<int> postIds, required bool read}) async {
    Map<String, dynamic> body = {'read': read};

    if (postIds.length > 1) {
      body['post_ids'] = postIds;
    } else {
      body['post_id'] = postIds.first;
    }

    final json = await _request(HttpMethod.post, '/api/alpha/post/mark_as_read', body);
    return json['success'];
  }

  /// Deletes a post
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    final body = {'post_id': postId, 'deleted': deleted};

    final json = await _request(HttpMethod.post, '/api/alpha/post/delete', body);
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.deleted == deleted;
  }

  /// Locks a post
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final body = {'post_id': postId, 'locked': locked};

    final json = await _request(HttpMethod.post, '/api/alpha/post/lock', body);
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.locked == locked;
  }

  /// Pins a post to the community
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final body = {'post_id': postId, 'featured': pinned, 'feature_type': 'Community'};

    final json = await _request(HttpMethod.post, '/api/alpha/post/feature', body);
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.featuredCommunity == pinned;
  }

  /// Removes a post
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final body = {'post_id': postId, 'removed': removed, 'reason': reason};

    final json = await _request(HttpMethod.post, '/api/alpha/post/remove', body);
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.removed == removed;
  }

  /// Reports a post
  Future<void> reportPost({required int postId, required String reason}) async {
    final body = {'post_id': postId, 'reason': reason};

    await _request(HttpMethod.post, '/api/alpha/post/report', body);
  }

  /// Fetches a comment from the Piefed API
  Future<ThunderComment> getComment(int commentId) async {
    final queryParams = {'id': commentId};

    final json = await _request(HttpMethod.get, '/api/alpha/comment', queryParams);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Fetches a list of comments from the Piefed API
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
    };

    final json = await _request(HttpMethod.get, '/api/alpha/comment/list', body);
    return json['comments'].map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList();
  }

  /// Creates a comment
  Future<ThunderComment> createComment({required int postId, required String content, int? parentId, int? languageId}) async {
    final body = {
      'post_id': postId,
      'body': content,
      'parent_id': parentId,
      'language_id': languageId,
    };

    final json = await _request(HttpMethod.post, '/api/alpha/comment', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Edits a comment
  Future<ThunderComment> editComment({required int commentId, required String content, int? languageId}) async {
    final body = {'comment_id': commentId, 'body': content, 'language_id': languageId};

    final json = await _request(HttpMethod.put, '/api/alpha/comment', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Votes on a comment
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final body = {'comment_id': commentId, 'score': score};

    final json = await _request(HttpMethod.post, '/api/alpha/comment/like', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Saves a comment
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final body = {'comment_id': commentId, 'save': save};

    final json = await _request(HttpMethod.put, '/api/alpha/comment/save', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Deletes a comment
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final body = {'comment_id': commentId, 'deleted': deleted};

    final json = await _request(HttpMethod.post, '/api/alpha/comment/delete', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Reports a comment
  Future<void> reportComment({required int commentId, required String reason}) async {
    final body = {'comment_id': commentId, 'reason': reason};

    await _request(HttpMethod.post, '/api/alpha/comment/report', body);
  }

  /// Searches for posts, comments, communities, and users
  Future<Map<String, dynamic>> search({
    required String query,
    MetaSearchType? type,
    PostSortType? sort,
    FeedListType? listingType,
    int? page,
    int? limit,
  }) async {
    final body = {
      'q': query,
      'type_': type?.searchType,
      'sort': sort?.value,
      'listing_type': listingType?.value,
      'page': page,
      'limit': limit,
    };

    final json = await _request(HttpMethod.get, '/api/alpha/search', body);
    return json;
  }

  /// Resolves a given query
  Future<Map<String, dynamic>> resolve({required String query}) async {
    final body = {'q': query};
    final json = await _request(HttpMethod.get, '/api/alpha/resolve_object', body);

    return {
      'community': json['community'] != null ? ThunderCommunity.fromPiefedCommunityView(json['community']) : null,
      'post': json['post'] != null ? ThunderPost.fromPiefedPostView(json['post']) : null,
      'comment': json['comment'] != null ? ThunderComment.fromPiefedCommentView(json['comment']) : null,
      'user': json['user'] != null ? ThunderUser.fromPiefedUserView(json['user']) : null,
    };
  }

  /// Fetches the unread count for the current user
  Future<Map<String, dynamic>> unreadCount() async {
    final json = await _request(HttpMethod.get, '/api/alpha/user/unread_count', {});
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

    final json = await _request(HttpMethod.get, '/api/alpha/user/replies', body);
    return json;
  }

  /// Mark comment reply as read
  Future<void> markCommentReplyAsRead({required int replyId, required bool read}) async {
    final body = {'comment_reply_id': replyId, 'read': read};
    await _request(HttpMethod.post, '/api/alpha/comment/mark_as_read', body);
  }

  /// Get comment mentions
  Future<Map<String, dynamic>> getCommentMentions({int? page, int? limit, CommentSortType? sort, bool unread = false}) async {
    final body = {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    };

    final json = await _request(HttpMethod.get, '/api/alpha/user/mentions', body);
    return json;
  }

  /// Mark private message as read
  Future<void> markPrivateMessageAsRead({required int messageId, required bool read}) async {
    final body = {'private_message_id': messageId, 'read': read};
    await _request(HttpMethod.post, '/api/alpha/private_message/mark_as_read', body);
  }

  /// Marks all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    await _request(HttpMethod.post, '/api/alpha/user/mark_all_as_read', {});
  }

  /// Get a community
  Future<Map<String, dynamic>> getCommunity({int? id, String? name}) async {
    final body = {'id': id, 'name': name};

    final json = await _request(HttpMethod.get, '/api/alpha/community', body);

    return {
      'community': ThunderCommunity.fromPiefedCommunityView(json['community_view']),
      'site': json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      'moderators': json['moderators'].map<ThunderUser>((cmv) => ThunderUser.fromPiefedUser(cmv['moderator'])).toList(),
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

    final json = await _request(HttpMethod.get, '/api/alpha/community/list', body);
    return json['communities'].map<ThunderCommunity>((cv) => ThunderCommunity.fromPiefedCommunityView(cv)).toList();
  }

  /// Subscribe to a community
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final body = {'community_id': communityId, 'follow': follow};

    final json = await _request(HttpMethod.post, '/api/alpha/community/follow', body);
    return ThunderCommunity.fromPiefedCommunityView(json['community_view']);
  }

  /// Block a community
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final body = {'community_id': communityId, 'block': block};

    final json = await _request(HttpMethod.post, '/api/alpha/community/block', body);
    return ThunderCommunity.fromPiefedCommunityView(json['community_view']);
  }

  /// Ban a user from a community
  Future<ThunderUser> banUserFromCommunity({
    required int userId,
    required int communityId,
    required bool ban,
    String? reason,
    int? expires,
  }) async {
    if (ban) {
      final body = {'user_id': userId, 'community_id': communityId, 'reason': reason, 'expiredAt': expires};

      final json = await _request(HttpMethod.post, '/api/alpha/community/moderate/ban', body);
      return ThunderUser.fromPiefedUser(json['bannedUser']);
    } else {
      final body = {'user_id': userId, 'community_id': communityId};

      final json = await _request(HttpMethod.put, '/api/alpha/community/moderate/unban', body);
      return ThunderUser.fromPiefedUser(json['bannedUser']);
    }
  }

  /// Add a moderator to a community
  Future<List<ThunderUser>> addModerator({required int userId, required int communityId, required bool added}) async {
    final body = {'person_id': userId, 'community_id': communityId, 'added': added};

    final json = await _request(HttpMethod.post, '/api/alpha/community/mod', body);
    return json['moderators'].map<ThunderUser>((cmv) => ThunderUser.fromPiefedUser(cmv['moderator'])).toList();
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
      'include_content': true,
    };

    final json = await _request(HttpMethod.get, '/api/alpha/user', body);

    return {
      'user': ThunderUser.fromPiefedUserView(json['person_view']),
      'site': json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      'posts': json['posts'].map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList(),
      'comments': json['comments'].map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList(),
      'moderates': json['moderates'].map<ThunderCommunity>((cmv) => ThunderCommunity.fromPiefedCommunity(cmv['community'])).toList(),
    };
  }

  /// Block a user
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final body = {'person_id': userId, 'block': block};

    final json = await _request(HttpMethod.post, '/api/alpha/user/block', body);
    return ThunderUser.fromPiefedUser(json['person_view']);
  }

  /// Block an instance
  Future<bool> blockInstance({required int instanceId, required bool block}) async {
    final body = {'instance_id': instanceId, 'block': block};

    final json = await _request(HttpMethod.post, '/api/alpha/site/block', body);
    return json['blocked'];
  }

  /// Upload an image using multipart form data
  Future<String> uploadImage(String filePath) async {
    try {
      final request = MultipartRequest('POST', Uri.https(account.instance, '/api/alpha/upload/image'));
      request.headers.addAll(_buildHeaders());
      request.files.add(await MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      if (response.statusCode != 200) throw Exception('Failed to upload image: ${response.statusCode} ${response.reasonPhrase}');

      final json = await compute(jsonDecode, await response.stream.bytesToString());
      return json['url'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
