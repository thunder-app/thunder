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
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

/// PieFed API client for the `/api/alpha` endpoints.
class PiefedApiClient extends BaseApiClient implements ThunderApiClient {
  PiefedApiClient({
    required super.account,
    super.debug,
    required super.version,
    super.httpClient,
  });

  @override
  String get basePath => '/api/alpha';

  @override
  String get platformName => 'PieFed';

  // =============================================================
  // Feature Flags - PieFed has limited support
  // =============================================================

  @override
  bool get supportsHidePosts => false;

  @override
  bool get supportsPostReports => false;

  @override
  bool get supportsCommentReports => false;

  @override
  bool get supportsPrivateMessages => false;

  @override
  bool get supportsModlog => false;

  @override
  bool get supportsSettingsImportExport => false;

  @override
  bool get supportsMedia => false;

  @override
  bool get supportsTOTP => false;

  @override
  bool get supportsInstanceBlock => false;

  // =============================================================
  // Authentication & Site
  // =============================================================

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    // PieFed doesn't support TOTP
    if (totp != null) {
      throw UnsupportedFeatureException('TOTP authentication', platformName: platformName);
    }

    final json = await request(HttpMethod.post, '$basePath/user/login', {
      'username_or_email': username,
      'password': password,
    });
    return json['jwt'] as String?;
  }

  @override
  Future<ThunderSiteResponse> site() async {
    final json = await request(HttpMethod.get, '$basePath/site', {});
    return ThunderSiteResponse.fromPiefedSiteResponse(json);
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

    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    final posts = await parsePosts([post]);
    final moderators = (json['moderators'] as List).map<ThunderUser>((mu) => ThunderUser.fromPiefedUser(mu['moderator'])).toList();

    return (
      post: posts.first,
      moderators: moderators,
      crossPosts: <ThunderPost>[], // PieFed doesn't return cross posts
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
    bool? showHidden,
    bool? showSaved,
  }) async {
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

    final json = await request(HttpMethod.get, '$basePath/post/list', queryParams);

    final posts = (json['posts'] as List).map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList();
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
    final json = await request(HttpMethod.post, '$basePath/post', {
      'name': title,
      'community_id': communityId,
      'url': url,
      'body': contents,
      'nsfw': nsfw,
      'language_id': languageId,
    });
    return ThunderPost.fromPiefedPostView(json['post_view']);
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
    final json = await request(HttpMethod.put, '$basePath/post', {
      'post_id': postId,
      'name': title,
      'url': url,
      'body': contents,
      'nsfw': nsfw,
      'language_id': languageId,
    });
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  @override
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/post/like', {
      'post_id': postId,
      'score': score,
    });
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  @override
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/post/save', {
      'post_id': postId,
      'save': save,
    });
    return ThunderPost.fromPiefedPostView(json['post_view']);
  }

  @override
  Future<bool> readPost({required List<int> postIds, required bool read}) async {
    for (final postId in postIds) {
      await request(HttpMethod.post, '$basePath/post/mark_as_read', {
        'post_id': postId,
        'read': read,
      });
    }
    return true;
  }

  @override
  Future<bool> hidePost({required int postId, required bool hide}) {
    throw UnsupportedFeatureException('Hiding posts', platformName: platformName);
  }

  @override
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/post/delete', {
      'post_id': postId,
      'deleted': deleted,
    });
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.deleted == deleted;
  }

  @override
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final json = await request(HttpMethod.post, '$basePath/post/lock', {
      'post_id': postId,
      'locked': locked,
    });
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.locked == locked;
  }

  @override
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final json = await request(HttpMethod.post, '$basePath/post/feature', {
      'post_id': postId,
      'featured': pinned,
      'feature_type': 'Community',
    });
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
    return post.featuredCommunity == pinned;
  }

  @override
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final json = await request(HttpMethod.post, '$basePath/post/remove', {
      'post_id': postId,
      'removed': removed,
      'reason': reason,
    });
    final post = ThunderPost.fromPiefedPostView(json['post_view']);
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
  }) {
    throw UnsupportedFeatureException('Post reports', platformName: platformName);
  }

  @override
  Future<ThunderPostReport> resolvePostReport({required int reportId, required bool resolved}) {
    throw UnsupportedFeatureException('Post reports', platformName: platformName);
  }

  // =============================================================
  // Comments
  // =============================================================

  @override
  Future<ThunderComment> getComment(int commentId) async {
    final json = await request(HttpMethod.get, '$basePath/comment', {'id': commentId});
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  @override
  Future<GetCommentsResponse> getComments({
    required int postId,
    int? page,
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
    });

    // PieFed returns nested comments, flatten them
    final flattenedComments = _flattenComments(json['comments'] as List);
    final comments = flattenedComments.map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList();
    final nextPage = (limit != null && comments.length < limit) ? null : (page ?? 0) + 1;

    return (comments: comments, nextPage: nextPage);
  }

  /// Flattens nested PieFed comment structure.
  List<dynamic> _flattenComments(List<dynamic> comments) {
    final flattened = <dynamic>[];
    for (final comment in comments) {
      flattened.add(comment);
      if (comment['replies'] != null && (comment['replies'] as List).isNotEmpty) {
        flattened.addAll(_flattenComments(comment['replies'] as List));
      }
    }
    return flattened;
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
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
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
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/like', {
      'comment_id': commentId,
      'score': score,
    });
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/save', {
      'comment_id': commentId,
      'save': save,
    });
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/delete', {
      'comment_id': commentId,
      'deleted': deleted,
    });
    return ThunderComment.fromPiefedCommentView(json['comment_view']);
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
  }) {
    throw UnsupportedFeatureException('Comment reports', platformName: platformName);
  }

  @override
  Future<ThunderCommentReport> resolveCommentReport({required int reportId, required bool resolved}) {
    throw UnsupportedFeatureException('Comment reports', platformName: platformName);
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
      community: ThunderCommunity.fromPiefedCommunityView(json['community_view']),
      site: json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      moderators: (json['moderators'] as List).map<ThunderUser>((cmv) => ThunderUser.fromPiefedUser(cmv['moderator'])).toList(),
      discussionLanguages: (json['discussion_languages'] as List?)?.cast<int>() ?? [],
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
    return (json['communities'] as List).map<ThunderCommunity>((cv) => ThunderCommunity.fromPiefedCommunityView(cv)).toList();
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final json = await request(HttpMethod.post, '$basePath/community/follow', {
      'community_id': communityId,
      'follow': follow,
    });
    // The API response should include the updated subscription status
    return ThunderCommunity.fromPiefedCommunityView(json['community_view']);
  }

  @override
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/community/block', {
      'community_id': communityId,
      'block': block,
    });
    return ThunderCommunity.fromPiefedCommunityView(json['community_view']);
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
      user: ThunderUser.fromPiefedUserView(json['person_view']),
      site: json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      posts: (json['posts'] as List?)?.map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList() ?? [],
      comments: (json['comments'] as List?)?.map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList() ?? [],
      moderates: (json['moderates'] as List?)?.map<ThunderCommunity>((cmv) => ThunderCommunity.fromPiefedCommunity(cmv['community'])).toList() ?? [],
    );
  }

  @override
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/user/block', {
      'person_id': userId,
      'block': block,
    });
    return ThunderUser.fromPiefedUserView(json['person_view']);
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
    return ThunderUser.fromPiefedUserView(json['person_view']);
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
    return (json['moderators'] as List).map<ThunderUser>((cmv) => ThunderUser.fromPiefedUser(cmv['moderator'])).toList();
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
      posts: (json['posts'] as List?)?.map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList() ?? [],
      comments: (json['comments'] as List?)?.map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList() ?? [],
      communities: (json['communities'] as List?)?.map<ThunderCommunity>((cv) => ThunderCommunity.fromPiefedCommunityView(cv)).toList() ?? [],
      users: (json['users'] as List?)?.map<ThunderUser>((pv) => ThunderUser.fromPiefedUserView(pv)).toList() ?? [],
    );
  }

  @override
  Future<ResolveResponse> resolve({required String query}) async {
    final json = await request(HttpMethod.get, '$basePath/resolve_object', {'q': query});

    return (
      community: json['community'] != null ? ThunderCommunity.fromPiefedCommunityView(json['community']) : null,
      post: json['post'] != null ? ThunderPost.fromPiefedPostView(json['post']) : null,
      comment: json['comment'] != null ? ThunderComment.fromPiefedCommentView(json['comment']) : null,
      user: json['person'] != null ? ThunderUser.fromPiefedUserView(json['person']) : null,
    );
  }

  // =============================================================
  // Notifications - Limited support
  // =============================================================

  @override
  Future<UnreadCountResponse> unreadCount() async {
    final json = await request(HttpMethod.get, '$basePath/user/unread_count', {});
    return (
      replies: json['replies'] as int? ?? 0,
      mentions: json['mentions'] as int? ?? 0,
      privateMessages: 0, // PieFed doesn't support private messages
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
      final comment = ThunderComment.fromPiefedCommentView(crv);

      return comment.copyWith(
        recipient: ThunderUser.fromPiefedUser(crv['recipient']),
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

    return (response['replies'] as List).map<ThunderComment>((mention) {
      final comment = ThunderComment.fromPiefedCommentView(mention);

      return comment.copyWith(
        recipient: ThunderUser.fromPiefedUser(mention['recipient']),
        replyMentionId: mention['comment_reply']['id'],
        read: mention['comment_reply']['read'],
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
  // Private Messages - Not supported
  // =============================================================

  @override
  Future<List<ThunderPrivateMessage>> getPrivateMessages({
    int? page,
    int? limit,
    bool unread = false,
    int? creatorId,
  }) {
    throw UnsupportedFeatureException('Private messages', platformName: platformName);
  }

  @override
  Future<void> markPrivateMessageAsRead({required int messageId, required bool read}) {
    throw UnsupportedFeatureException('Private messages', platformName: platformName);
  }

  // =============================================================
  // Account Settings - Limited support
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
      'show_nsfw': showNsfw,
      'show_read_posts': showReadPosts,
    });
  }

  @override
  Future<bool> importSettings(String settings) {
    throw UnsupportedFeatureException('Settings import', platformName: platformName);
  }

  @override
  Future<dynamic> exportSettings() {
    throw UnsupportedFeatureException('Settings export', platformName: platformName);
  }

  @override
  Future<Map<String, dynamic>> media({int? page, int? limit}) {
    throw UnsupportedFeatureException('Media management', platformName: platformName);
  }

  // =============================================================
  // Modlog - Not supported
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
  }) {
    throw UnsupportedFeatureException('Modlog', platformName: platformName);
  }

  // =============================================================
  // Instance
  // =============================================================

  @override
  Future<Map<String, dynamic>> federated() async {
    return await request(HttpMethod.get, '$basePath/federated_instances', {});
  }

  @override
  Future<bool> blockInstance({required int instanceId, required bool block}) {
    throw UnsupportedFeatureException('Instance blocking', platformName: platformName);
  }

  // =============================================================
  // Media - Limited support
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
}
