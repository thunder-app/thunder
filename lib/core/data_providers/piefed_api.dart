import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/feed_list_type.dart';
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
    if (response.statusCode != 200) throw Exception('Failed to make request to $uri:  ${response.statusCode} ${response.body}');
    return jsonDecode(response.body);
  }

  /// Makes an HTTP request with the specified method
  Future<Map<String, dynamic>> _request(HttpMethod method, String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = _buildHeaders();

      Uri uri = Uri.https(account.instance, endpoint);
      Response response;

      if (method == HttpMethod.get) {
        // Remove null values and convert values to strings
        data.removeWhere((key, value) => value == null);
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
    final queryParams = {
      'id': postId,
      'comment_id': commentId,
    };

    final json = await _request(HttpMethod.get, '/api/alpha/post', queryParams);

    final post = (await parsePosts([ThunderPost.fromPiefedPostView(json['post_view'])])).first;
    final moderators = json['moderators'].map<ThunderUser>((mu) => ThunderUser.fromPiefedUser(mu['moderator'])).toList();
    final crossPosts = json['cross_posts'].map<ThunderPost>((cp) => ThunderPost.fromPiefedPostView(cp)).toList();

    return {
      'post': post,
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
}
