import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/core/enums/meta_search_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/user/models/thunder_user.dart';

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
    if (account.jwt == null) return {};
    return {'Authorization': 'Bearer ${account.jwt}'};
  }

  /// Handle response from the request. Throws an exception if the request fails.
  Map<String, dynamic> _handleResponse(Uri uri, Response response) {
    if (response.statusCode != 200) throw Exception('Failed to make request to $uri: ${response.statusCode} ${response.body}');
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

      return _handleResponse(uri, response);
    } catch (e) {
      if (debug) debugPrint('PieFed API: Error: $e');
      rethrow;
    }
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

  /// Fetches a comment from the Piefed API
  Future<Map<String, dynamic>> getComment(int commentId) async {
    final queryParams = {'id': commentId};
    final json = await _request(HttpMethod.get, '/api/alpha/comment', queryParams);
    return json;
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

  /// Edits a comment
  Future<ThunderComment> editComment({required int commentId, required String content, int? languageId}) async {
    final body = {'comment_id': commentId, 'body': content, 'language_id': languageId};

    final json = await _request(HttpMethod.put, '/api/alpha/comment', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Votes on a post
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final body = {'post_id': postId, 'score': score};

    final json = await _request(HttpMethod.post, '/api/alpha/post/like', body);
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  /// Votes on a comment
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final body = {'comment_id': commentId, 'score': score};

    final json = await _request(HttpMethod.post, '/api/alpha/comment/like', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  /// Saves a post
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final body = {'post_id': postId, 'save': save};

    final json = await _request(HttpMethod.put, '/api/alpha/post/save', body);
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  /// Saves a comment
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final body = {'comment_id': commentId, 'save': save};

    final json = await _request(HttpMethod.put, '/api/alpha/comment/save', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
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

  /// Deletes a comment
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final body = {'comment_id': commentId, 'deleted': deleted};

    final json = await _request(HttpMethod.post, '/api/alpha/comment/delete', body);
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
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
}
