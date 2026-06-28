import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:thunder/src/foundation/networking/utils/upload_image_utils.dart';
import 'package:thunder/src/foundation/primitives/enums/comment_sort_type.dart';
import 'package:thunder/src/foundation/primitives/enums/feed_list_type.dart';
import 'package:thunder/src/foundation/primitives/enums/meta_search_type.dart';
import 'package:thunder/src/foundation/primitives/enums/post_sort_type.dart';
import 'package:thunder/src/foundation/primitives/enums/search_sort_type.dart';
import 'package:thunder/src/foundation/primitives/models/modlog_event_item.dart';
import 'package:thunder/src/foundation/primitives/models/piefed_post_metadata.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_link_metadata.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_page.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_site.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_site_response.dart';
import 'package:thunder/src/foundation/networking/mappers/primitive_mappers.dart';
import 'package:thunder/src/foundation/errors/api_exception.dart';
import 'package:thunder/src/foundation/networking/base_api_client.dart';
import 'package:thunder/src/foundation/networking/thunder_api_client.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_flair.dart';
import 'package:thunder/src/foundation/primitives/enums/modlog_action_type.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';
import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';

/// PieFed API client for the `/api/alpha` endpoints.
class PiefedApiClient extends BaseApiClient implements ThunderApiClient {
  static const _mapper = PiefedPrimitiveMapper();

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
  bool get supportsHidePosts => true;

  @override
  bool get supportsPostReports => false;

  @override
  bool get supportsCommentReports => false;

  @override
  bool get supportsPrivateMessages => true;

  @override
  bool get supportsModlog => false;

  @override
  bool get supportsSettingsImportExport => false;

  @override
  bool get supportsMedia => true;

  @override
  bool get supportsTOTP => false;

  @override
  bool get supportsInstanceBlock => true;

  // =============================================================
  // Authentication & Site
  // =============================================================

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    // PieFed doesn't support TOTP
    if (totp?.isNotEmpty == true) {
      throw UnsupportedFeatureException('TOTP authentication', platformName: platformName);
    }

    final json = await request(HttpMethod.post, '$basePath/user/login', {
      'username': username,
      'password': password,
    });
    return json['jwt'] as String?;
  }

  @override
  Future<void> logout() async {
    // TODO: Implement logout when API is available.
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
    });

    final post = PiefedApiClient._mapper.postView(json['post_view']);
    final moderators = (json['moderators'] as List).map<ThunderUser>((mu) => PiefedApiClient._mapper.user(mu['moderator'])).toList();

    return (
      post: post,
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
    String? query,
    int? personId,
    bool? likedOnly,
    int? feedId,
    int? topicId,
    bool? ignoreSticky,
    bool? showHidden,
    bool? showSaved,
  }) async {
    final page = cursor != null ? int.tryParse(cursor) ?? 1 : 1;

    final Map<String, dynamic> queryParams = {
      'q': query,
      'type_': feedListType?.value,
      'sort': postSortType?.value,
      'page': page,
      'limit': limit,
      'community_name': communityName,
      'community_id': communityId,
      'person_id': personId,
      'liked_only': likedOnly,
      'feed_id': feedId,
      'topic_id': topicId,
      'ignore_sticky': ignoreSticky,
    };

    if (showSaved == true) queryParams['saved_only'] = showSaved;

    final json = await request(HttpMethod.get, '$basePath/post/list', queryParams);

    final posts = (json['posts'] as List).map<ThunderPost>((pv) => PiefedApiClient._mapper.postView(pv)).toList();
    final nextPage = (json['next_cursor'] ?? json['next_page'])?.toString();

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
      'title': title,
      'community_id': communityId,
      'url': url,
      'body': contents,
      'alt_text': altText,
      'nsfw': nsfw,
      'language_id': languageId,
    });
    return PiefedApiClient._mapper.postView(json['post_view']);
  }

  @override
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
    ThunderPost post = await createPost(
      title: title,
      communityId: communityId,
      url: url,
      contents: contents,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
      altText: altText,
    );

    return _applyPostMetadata(
      post: post,
      title: title,
      url: url,
      contents: contents,
      altText: altText,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
      tags: tags,
      flairIds: flairIds,
    );
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
    final json = await request(HttpMethod.put, '$basePath/post', {
      'post_id': postId,
      'title': title,
      'url': url,
      'body': contents,
      'alt_text': altText,
      'tags': tags,
      'nsfw': nsfw,
      'language_id': languageId,
    });
    return PiefedApiClient._mapper.postView(json['post_view']);
  }

  @override
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
    ThunderPost post = await editPost(
      postId: postId,
      title: title,
      url: url,
      contents: contents,
      altText: altText,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
    );

    return _applyPostMetadata(
      post: post,
      title: title,
      url: url,
      contents: contents,
      altText: altText,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
      tags: tags,
      flairIds: flairIds,
    );
  }

  @override
  Future<ThunderPost> votePost({required int postId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/post/like', {
      'post_id': postId,
      'score': score,
    });
    return PiefedApiClient._mapper.postView(json['post_view']);
  }

  @override
  Future<ThunderPost> savePost({required int postId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/post/save', {
      'post_id': postId,
      'save': save,
    });
    return PiefedApiClient._mapper.postView(json['post_view']);
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
  Future<bool> hidePost({required int postId, required bool hide}) async {
    final json = await request(HttpMethod.post, '$basePath/post/hide', {
      'post_id': postId,
      'hidden': hide,
    });
    final post = PiefedApiClient._mapper.postView(json['post_view']);
    return post.context.hidden == hide;
  }

  @override
  Future<bool> deletePost({required int postId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/post/delete', {
      'post_id': postId,
      'deleted': deleted,
    });
    final post = PiefedApiClient._mapper.postView(json['post_view']);
    return post.status.deleted == deleted;
  }

  @override
  Future<bool> lockPost({required int postId, required bool locked}) async {
    final json = await request(HttpMethod.post, '$basePath/post/lock', {
      'post_id': postId,
      'locked': locked,
    });
    final post = PiefedApiClient._mapper.postView(json['post_view']);
    return post.status.locked == locked;
  }

  @override
  Future<bool> pinPost({required int postId, required bool pinned}) async {
    final json = await request(HttpMethod.post, '$basePath/post/feature', {
      'post_id': postId,
      'featured': pinned,
      'feature_type': 'Community',
    });
    final post = PiefedApiClient._mapper.postView(json['post_view']);
    return post.status.featuredCommunity == pinned;
  }

  @override
  Future<bool> removePost({required int postId, required bool removed, required String reason}) async {
    final json = await request(HttpMethod.post, '$basePath/post/remove', {
      'post_id': postId,
      'removed': removed,
      'reason': reason,
    });
    final post = PiefedApiClient._mapper.postView(json['post_view']);
    return post.status.removed == removed;
  }

  @override
  Future<void> reportPost({required int postId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/post/report', {
      'post_id': postId,
      'reason': reason,
    });
  }

  /// Fetch a list of likes for a post.
  Future<Map<String, dynamic>> listPostLikes({required int postId, int? page, int? limit}) async {
    return await request(HttpMethod.get, '$basePath/post/like/list', {
      'post_id': postId,
      'page': page,
      'limit': limit,
    });
  }

  /// Alternate posts list endpoint (list2).
  Future<GetPostsResponse> listPosts2({
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
  }) async {
    final page = cursor != null ? int.tryParse(cursor) ?? 1 : 1;

    final Map<String, dynamic> queryParams = {
      'q': query,
      'type_': feedListType?.value,
      'sort': postSortType?.value,
      'page': page,
      'limit': limit,
      'community_name': communityName,
      'community_id': communityId,
      'person_id': personId,
      'liked_only': likedOnly,
      'feed_id': feedId,
      'topic_id': topicId,
      'ignore_sticky': ignoreSticky,
    };

    final json = await request(HttpMethod.get, '$basePath/post/list2', queryParams);

    final posts = (json['posts'] as List).map<ThunderPost>((pv) => PiefedApiClient._mapper.postView(pv)).toList();
    final nextPage = json['next_page'] as String?;

    return (posts: posts, nextPage: nextPage);
  }

  /// Assign flair to a post.
  Future<ThunderPost> setPostFlair({required int postId, List<int>? flairIds}) async {
    final json = await request(HttpMethod.post, '$basePath/post/assign_flair', {
      'post_id': postId,
      'flair_id_list': flairIds,
    });
    return PiefedApiClient._mapper.postView(json);
  }

  /// Subscribe or unsubscribe from a post.
  Future<ThunderPost> subscribePost({required int postId, required bool subscribe}) async {
    final json = await request(HttpMethod.put, '$basePath/post/subscribe', {
      'post_id': postId,
      'subscribe': subscribe,
    });
    return PiefedApiClient._mapper.postView(json['post_view']);
  }

  /// Vote on a poll attached to a post.
  Future<Map<String, dynamic>> voteInPoll({required int postId, required List<int> choiceId}) async {
    return await request(HttpMethod.post, '$basePath/post/poll_vote', {
      'post_id': postId,
      'choice_id': choiceId,
    });
  }

  /// Get site metadata for a URL.
  @override
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url}) async {
    final response = await request(HttpMethod.get, '$basePath/post/site_metadata', {
      'url': url,
    });

    final metadata = response['metadata'];
    if (metadata is! Map<String, dynamic>) return null;

    return ThunderLinkMetadata.fromPiefedSiteMetadata(metadata, url: url);
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
  }) {
    throw UnsupportedFeatureException('Reports', platformName: platformName);
  }

  @override
  Future<ThunderReport> resolveReport({required int reportId, required ReportKind kind, required bool resolved}) {
    throw UnsupportedFeatureException('Reports', platformName: platformName);
  }

  // =============================================================
  // Comments
  // =============================================================

  @override
  Future<ThunderComment> getComment(int commentId) async {
    final json = await request(HttpMethod.get, '$basePath/comment', {'id': commentId});
    return PiefedApiClient._mapper.commentView(json['comment_view']);
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
    final json = await request(HttpMethod.get, '$basePath/post/replies', {
      'sort': commentSortType?.value,
      'max_depth': maxDepth,
      'page': cursor ?? page?.toString(),
      'limit': limit,
      'post_id': postId,
      'parent_id': parentId,
    });

    // PieFed returns nested replies for a post; flatten them in-order and inherit post/community.
    final flattenedComments = _flattenReplies(json['comments'] as List);
    final comments = flattenedComments.map<ThunderComment>((cv) => PiefedApiClient._mapper.commentView(cv)).toList();
    final nextPage = json['next_page']?.toString();

    return (comments: comments, nextPage: nextPage);
  }

  /// List comments using the comment list endpoint.
  Future<GetCommentsResponse> listComments({
    int? page,
    String? cursor,
    int? limit,
    CommentSortType? commentSortType,
    bool? likedOnly,
    bool? savedOnly,
    int? personId,
    int? communityId,
    int? postId,
    int? parentId,
    int? maxDepth,
    bool? depthFirst,
  }) async {
    final json = await request(HttpMethod.get, '$basePath/comment/list', {
      'sort': commentSortType?.value,
      'page': cursor ?? page,
      'limit': limit,
      'liked_only': likedOnly,
      'saved_only': savedOnly,
      'person_id': personId,
      'community_id': communityId,
      'post_id': postId,
      'parent_id': parentId,
      'max_depth': maxDepth,
      'depth_first': depthFirst,
    });

    final comments = (json['comments'] as List).map<ThunderComment>((cv) => PiefedApiClient._mapper.commentView(cv)).toList();
    final nextPage = json['next_page']?.toString();

    return (comments: comments, nextPage: nextPage);
  }

  /// Flattens nested PieFed reply structure, ensuring nested replies inherit post/community.
  List<dynamic> _flattenReplies(
    List<dynamic> comments, {
    Map<String, dynamic>? fallbackPost,
    Map<String, dynamic>? fallbackCommunity,
  }) {
    final flattened = <dynamic>[];
    for (final comment in comments) {
      if (comment is! Map) continue;
      final commentMap = Map<String, dynamic>.from(comment);
      final post = commentMap['post'] as Map<String, dynamic>? ?? fallbackPost;
      final community = commentMap['community'] as Map<String, dynamic>? ?? fallbackCommunity;

      if (post != null && commentMap['post'] == null) {
        commentMap['post'] = post;
      }
      if (community != null && commentMap['community'] == null) {
        commentMap['community'] = community;
      }

      flattened.add(commentMap);

      if (commentMap['replies'] is List && (commentMap['replies'] as List).isNotEmpty) {
        flattened.addAll(
          _flattenReplies(
            commentMap['replies'] as List,
            fallbackPost: post,
            fallbackCommunity: community,
          ),
        );
      }
    }
    return flattened;
  }

  /// Fetch a list of likes for a comment.
  Future<Map<String, dynamic>> listCommentLikes({required int commentId, int? page, int? limit}) async {
    return await request(HttpMethod.get, '$basePath/comment/like/list', {
      'comment_id': commentId,
      'page': page,
      'limit': limit,
    });
  }

  /// Lock or unlock a comment.
  Future<ThunderComment> lockComment({required int commentId, required bool locked}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/lock', {
      'comment_id': commentId,
      'locked': locked,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  /// Mark or unmark a comment reply as the answer.
  Future<Map<String, dynamic>> markCommentAsAnswer({required int commentReplyId, required bool answer}) async {
    return await request(HttpMethod.post, '$basePath/comment/mark_as_answer', {
      'comment_reply_id': commentReplyId,
      'answer': answer,
    });
  }

  /// Remove or restore a comment.
  Future<ThunderComment> removeComment({required int commentId, required bool removed, String? reason}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/remove', {
      'comment_id': commentId,
      'removed': removed,
      'reason': reason,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  /// Subscribe or unsubscribe from a comment.
  Future<ThunderComment> subscribeComment({required int commentId, required bool subscribe}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/subscribe', {
      'comment_id': commentId,
      'subscribe': subscribe,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
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
      'body': content,
      'parent_id': parentId,
      'language_id': languageId,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> editComment({
    required int commentId,
    required String content,
    int? languageId,
  }) async {
    final json = await request(HttpMethod.put, '$basePath/comment', {
      'comment_id': commentId,
      'body': content,
      'language_id': languageId,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> voteComment({required int commentId, required int score}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/like', {
      'comment_id': commentId,
      'score': score,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> saveComment({required int commentId, required bool save}) async {
    final json = await request(HttpMethod.put, '$basePath/comment/save', {
      'comment_id': commentId,
      'save': save,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  @override
  Future<ThunderComment> deleteComment({required int commentId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/comment/delete', {
      'comment_id': commentId,
      'deleted': deleted,
    });
    return PiefedApiClient._mapper.commentView(json['comment_view']);
  }

  @override
  Future<void> reportComment({required int commentId, required String reason}) async {
    await request(HttpMethod.post, '$basePath/comment/report', {
      'comment_id': commentId,
      'reason': reason,
    });
  }

  @override
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
      community: PiefedApiClient._mapper.communityView(json['community_view']),
      site: json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      moderators: (json['moderators'] as List).map<ThunderUser>((cmv) => PiefedApiClient._mapper.user(cmv['moderator'])).toList(),
      discussionLanguages: (json['discussion_languages'] as List?)?.cast<int>() ?? [],
      flairs: ThunderFlair.parsePiefedList(json['community_view']?['flair_list']),
    );
  }

  Future<ThunderPost> _applyPostMetadata({
    required ThunderPost post,
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
    ThunderPost updatedPost = post;

    if (tags != null) {
      updatedPost = await editPost(
        postId: post.id,
        title: title,
        url: url,
        contents: contents,
        altText: altText,
        tags: encodePiefedTags(tags),
        nsfw: nsfw,
        languageId: languageId,
        customThumbnail: customThumbnail,
      );
    }

    if (flairIds != null) {
      updatedPost = await setPostFlair(
        postId: post.id,
        flairIds: normalizePiefedFlairIds(flairIds),
      );
    }

    return updatedPost;
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
    return (json['communities'] as List).map<ThunderCommunity>((cv) => PiefedApiClient._mapper.communityView(cv)).toList();
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final json = await request(HttpMethod.post, '$basePath/community/follow', {
      'community_id': communityId,
      'follow': follow,
    });
    // The API response should include the updated subscription status
    return PiefedApiClient._mapper.communityView(json['community_view']);
  }

  @override
  Future<ThunderCommunity> blockCommunity({required int communityId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/community/block', {
      'community_id': communityId,
      'block': block,
    });
    return PiefedApiClient._mapper.communityView(json['community_view']);
  }

  /// Delete or restore a community.
  Future<ThunderCommunity> deleteCommunity({required int communityId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/community/delete', {
      'community_id': communityId,
      'deleted': deleted,
    });
    return PiefedApiClient._mapper.communityView(json['community_view']);
  }

  /// Create a flair for a community.
  Future<Map<String, dynamic>> createCommunityFlair({
    required int communityId,
    required String flairTitle,
    String? textColor,
    String? backgroundColor,
    bool? blurImages,
  }) async {
    return await request(HttpMethod.post, '$basePath/community/flair', {
      'community_id': communityId,
      'flair_title': flairTitle,
      'text_color': textColor,
      'background_color': backgroundColor,
      'blur_images': blurImages,
    });
  }

  /// Edit a community flair.
  Future<Map<String, dynamic>> editCommunityFlair({
    required int flairId,
    String? flairTitle,
    String? textColor,
    String? backgroundColor,
    bool? blurImages,
  }) async {
    return await request(HttpMethod.put, '$basePath/community/flair', {
      'flair_id': flairId,
      'flair_title': flairTitle,
      'text_color': textColor,
      'background_color': backgroundColor,
      'blur_images': blurImages,
    });
  }

  /// Delete a community flair.
  Future<Map<String, dynamic>> deleteCommunityFlair({required int flairId}) async {
    return await request(HttpMethod.post, '$basePath/community/flair/delete', {
      'flair_id': flairId,
    });
  }

  /// Leave all communities.
  Future<Map<String, dynamic>> leaveAllCommunities() async {
    return await request(HttpMethod.post, '$basePath/community/leave_all', {});
  }

  /// List bans for a community.
  Future<Map<String, dynamic>> listCommunityBans({required int communityId, int? page, int? limit}) async {
    return await request(HttpMethod.get, '$basePath/community/moderate/bans', {
      'community_id': communityId,
      'page': page,
      'limit': limit,
    });
  }

  /// Update a post's NSFW status in a community.
  Future<ThunderPost> setCommunityPostNsfw({required int postId, required bool nsfw}) async {
    final json = await request(HttpMethod.post, '$basePath/community/moderate/post/nsfw', {
      'post_id': postId,
      'nsfw_status': nsfw,
    });
    return PiefedApiClient._mapper.postView(json);
  }

  /// Subscribe or unsubscribe to a community.
  Future<ThunderCommunity> subscribeCommunity({required int communityId, required bool subscribe}) async {
    final json = await request(HttpMethod.put, '$basePath/community/subscribe', {
      'community_id': communityId,
      'subscribe': subscribe,
    });
    return PiefedApiClient._mapper.communityView(json['community_view']);
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
      'include_content': includeContent,
    });
    final posts = (json['posts'] as List?)?.map<ThunderPost>((pv) => PiefedApiClient._mapper.postView(pv)).toList() ?? [];
    final comments = (json['comments'] as List?)?.map<ThunderComment>((cv) => PiefedApiClient._mapper.commentView(cv)).toList() ?? [];

    return (
      user: PiefedApiClient._mapper.userView(json['person_view']),
      site: json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      posts: posts,
      comments: comments,
      moderates: (json['moderates'] as List?)?.map<ThunderCommunity>((cmv) => PiefedApiClient._mapper.community(cmv['community'])).toList() ?? [],
      nextPage: json['next_page']?.toString() ?? ((limit != null && posts.length < limit && comments.length < limit) ? null : (pageNumber + 1).toString()),
    );
  }

  @override
  Future<ThunderUser> blockUser({required int userId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/user/block', {
      'person_id': userId,
      'block': block,
    });
    return PiefedApiClient._mapper.userView(json['person_view']);
  }

  /// Ban a user instance-wide.
  Future<ThunderUser> banUser({
    required int userId,
    required bool banIpAddress,
    required bool purgeContent,
    String? reason,
  }) async {
    final json = await request(HttpMethod.post, '$basePath/user/ban', {
      'person_id': userId,
      'ban_ip_address': banIpAddress,
      'purge_content': purgeContent,
      'reason': reason,
    });
    return PiefedApiClient._mapper.userView(json['person_view']);
  }

  /// Unban a user instance-wide.
  Future<ThunderUser> unbanUser({required int userId}) async {
    final json = await request(HttpMethod.post, '$basePath/user/unban', {
      'person_id': userId,
    });
    return PiefedApiClient._mapper.userView(json['person_view']);
  }

  /// Subscribe or unsubscribe from a user.
  Future<Map<String, dynamic>> subscribeUser({required int userId, required bool subscribe}) async {
    return await request(HttpMethod.put, '$basePath/user/subscribe', {
      'person_id': userId,
      'subscribe': subscribe,
    });
  }

  /// Set a note on a user.
  Future<Map<String, dynamic>> setUserNote({required int userId, String? note}) async {
    return await request(HttpMethod.post, '$basePath/user/note', {
      'person_id': userId,
      'note': note,
    });
  }

  /// Set user flair in a community.
  Future<Map<String, dynamic>> setUserFlair({required int communityId, String? flairText}) async {
    return await request(HttpMethod.post, '$basePath/user/set_flair', {
      'community_id': communityId,
      'flair_text': flairText,
    });
  }

  /// Fetch the current user's profile.
  Future<Map<String, dynamic>> getUserMe() async {
    return await request(HttpMethod.get, '$basePath/user/me', {});
  }

  /// Verify credentials.
  Future<void> verifyCredentials({required String username, required String password}) async {
    await request(HttpMethod.post, '$basePath/user/verify_credentials', {
      'username': username,
      'password': password,
    });
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
    if (!ban) {
      final json = await request(HttpMethod.put, '$basePath/community/moderate/unban', {
        'community_id': communityId,
        'user_id': userId,
      });
      return PiefedApiClient._mapper.user(json['banned_user']);
    }

    String? expiresAt;
    bool? permanent;
    if (expires != null) {
      final millis = expires > 1000000000000 ? expires : expires * 1000;
      expiresAt = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toIso8601String();
      permanent = false;
    } else {
      permanent = true;
    }

    final json = await request(HttpMethod.post, '$basePath/community/moderate/ban', {
      'community_id': communityId,
      'user_id': userId,
      'reason': reason ?? '',
      'expires_at': expiresAt,
      'permanent': permanent,
    });
    return PiefedApiClient._mapper.user(json['banned_user']);
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
    return (json['moderators'] as List).map<ThunderUser>((cmv) => PiefedApiClient._mapper.user(cmv['moderator'])).toList();
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
      'type_': type?.searchType,
      'sort': sort?.value,
      'listing_type': listingType?.value,
      'page': page,
      'limit': limit,
      'minimum_upvotes': minimumUpvotes,
      'nsfw': nsfw,
    });

    return (
      type: MetaSearchType.values.firstWhere((e) => e.searchType == json['type_']),
      posts: (json['posts'] as List?)?.map<ThunderPost>((pv) => PiefedApiClient._mapper.postView(pv)).toList() ?? [],
      comments: (json['comments'] as List?)?.map<ThunderComment>((cv) => PiefedApiClient._mapper.commentView(cv)).toList() ?? [],
      communities: (json['communities'] as List?)?.map<ThunderCommunity>((cv) => PiefedApiClient._mapper.communityView(cv)).toList() ?? [],
      users: (json['users'] as List?)?.map<ThunderUser>((pv) => PiefedApiClient._mapper.userView(pv)).toList() ?? [],
    );
  }

  @override
  Future<ResolveResponse> resolve({required String query}) async {
    final json = await request(HttpMethod.get, '$basePath/resolve_object', {'q': query});

    return (
      community: json['community'] != null ? PiefedApiClient._mapper.communityView(json['community']) : null,
      post: json['post'] != null ? PiefedApiClient._mapper.postView(json['post']) : null,
      comment: json['comment'] != null ? PiefedApiClient._mapper.commentView(json['comment']) : null,
      user: json['person'] != null ? PiefedApiClient._mapper.userView(json['person']) : null,
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
      privateMessages: json['private_messages'] as int? ?? 0,
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
      final comment = PiefedApiClient._mapper.commentView(crv);

      return comment.copyWith(
        recipient: PiefedApiClient._mapper.user(crv['recipient']),
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
    final response = await request(HttpMethod.get, '$basePath/user/mentions', {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    });

    return (response['replies'] as List).map<ThunderComment>((mention) {
      final comment = PiefedApiClient._mapper.commentView(mention);

      return comment.copyWith(
        recipient: PiefedApiClient._mapper.user(mention['recipient']),
        notification: NotificationRef(
          id: mention['comment_reply']['id'],
          kind: NotificationKind.mention,
          read: mention['comment_reply']['read'] ?? false,
          createdAt: DateTime.tryParse(mention['comment_reply']['published'] ?? '') ?? comment.published,
        ),
      );
    }).toList();
  }

  @override
  Future<void> markCommentMentionAsRead({required int mentionId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/comment/mark_as_read', {
      'comment_reply_id': mentionId,
      'read': read,
    });
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await request(HttpMethod.post, '$basePath/user/mark_all_as_read', {});
  }

  /// Mark all notifications as read using the notifications endpoint.
  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    return await request(HttpMethod.put, '$basePath/user/mark_all_notifications_read', {});
  }

  /// Update a notification's read state.
  Future<Map<String, dynamic>> setNotificationState({required int notificationId, required bool read}) async {
    return await request(HttpMethod.put, '$basePath/user/notification_state', {
      'notif_id': notificationId,
      'read_state': read,
    });
  }

  /// List notifications with a given status.
  Future<Map<String, dynamic>> listNotifications({required String status, int? page, int? limit}) async {
    return await request(HttpMethod.get, '$basePath/user/notifications', {
      'status': status,
      'page': page,
      'limit': limit,
    });
  }

  /// Get notification counts.
  Future<Map<String, dynamic>> getNotificationsCount() async {
    return await request(HttpMethod.get, '$basePath/user/notifications_count', {});
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
  }) async {
    final response = await request(HttpMethod.get, '$basePath/private_message/list', {
      'page': page,
      'limit': limit,
      'unread_only': unread,
    });

    return (response['private_messages'] as List).map<ThunderPrivateMessage>((pmv) => _parsePrivateMessageView(pmv)).toList();
  }

  @override
  Future<void> markPrivateMessageAsRead({required int notificationId, required bool read}) async {
    await request(HttpMethod.post, '$basePath/private_message/mark_as_read', {
      'private_message_id': notificationId,
      'read': read,
    });
  }

  /// Create a private message.
  @override
  Future<ThunderPrivateMessage> createPrivateMessage({required int recipientId, required String content}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message', {
      'recipient_id': recipientId,
      'content': content,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  /// Edit a private message.
  Future<ThunderPrivateMessage> editPrivateMessage({required int messageId, required String content}) async {
    final json = await request(HttpMethod.put, '$basePath/private_message', {
      'private_message_id': messageId,
      'content': content,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  /// Delete or restore a private message.
  Future<ThunderPrivateMessage> deletePrivateMessage({required int messageId, required bool deleted}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message/delete', {
      'private_message_id': messageId,
      'deleted': deleted,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  /// Report a private message.
  Future<ThunderPrivateMessage> reportPrivateMessage({required int messageId, required String reason}) async {
    final json = await request(HttpMethod.post, '$basePath/private_message/report', {
      'private_message_id': messageId,
      'reason': reason,
    });
    return _parsePrivateMessageView(json['private_message_view']);
  }

  /// Get private message conversation.
  @override
  Future<List<ThunderPrivateMessage>> getPrivateMessageConversation({
    required int personId,
    int? conversationId,
    int? page,
    int? limit,
  }) async {
    final response = await request(HttpMethod.get, '$basePath/private_message/conversation', {
      'person_id': personId,
      'conversation_id': conversationId,
      'page': page,
      'limit': limit,
    });
    return (response['private_messages'] as List).map<ThunderPrivateMessage>((pmv) => _parsePrivateMessageView(pmv)).toList();
  }

  /// Leave a private message conversation.
  Future<void> leavePrivateMessageConversation({required int conversationId}) async {
    await request(HttpMethod.post, '$basePath/private_message/conversation/leave', {
      'conversation_id': conversationId,
    });
  }

  // =============================================================
  // Account Settings - Limited support
  // =============================================================

  @override
  Future<void> saveUserSettings(AccountSettingsUpdate update) async {
    await request(HttpMethod.put, '$basePath/user/save_user_settings', {
      'bio': update.bio,
      'default_sort_type': update.defaultPostSortType?.value,
      'bot_visibility': update.showBotAccounts == null ? null : (update.showBotAccounts! ? 'Show' : 'Hide'),
      'show_nsfw': update.showNsfw,
      'show_nsfl': update.showNsfl,
      'show_read_posts': update.showReadPosts,
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
  Future<ThunderPage<AccountMediaItem>> media({int? page, int? limit}) async {
    final json = await request(HttpMethod.get, '$basePath/user/media', {
      'page': page,
      'limit': limit,
    });
    final rawItems = (json['images'] as List?) ?? (json['items'] as List?) ?? const [];
    final items = rawItems.whereType<Map<String, dynamic>>().map((image) => _accountMediaItemFromPiefed(image, account.instance)).toList();
    return ThunderPage(
      items: items,
      nextPage: limit != null && items.length < limit ? null : ((page ?? 1) + 1).toString(),
    );
  }

  /// List user media with additional filters.
  Future<Map<String, dynamic>> listUserMedia({int? page, int? limit, String? sort, bool? unreadOnly}) async {
    return await request(HttpMethod.get, '$basePath/user/media', {
      'page': page,
      'limit': limit,
      'sort': sort,
      'unread_only': unreadOnly,
    });
  }

  // =============================================================
  // Modlog - Not supported
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
  Future<bool> blockInstance({required int instanceId, required bool block}) async {
    final json = await request(HttpMethod.post, '$basePath/site/block', {
      'instance_id': instanceId,
      'block': block,
    });
    return json['blocked'] as bool? ?? block;
  }

  /// Fetch instance chooser data.
  Future<Map<String, dynamic>> getInstanceChooser() async {
    return await request(HttpMethod.get, '$basePath/site/instance_chooser', {});
  }

  /// Search instance chooser data.
  Future<Map<String, dynamic>> searchInstanceChooser({
    String? query,
    bool? nsfw,
    String? language,
    bool? newbie,
  }) async {
    return await request(HttpMethod.get, '$basePath/site/instance_chooser_search', {
      'q': query,
      'nsfw': nsfw,
      'language': language,
      'newbie': newbie,
    });
  }

  /// Get site version information.
  Future<Map<String, dynamic>> getSiteVersion() async {
    return await request(HttpMethod.get, '$basePath/site/version', {});
  }

  /// Block or unblock a domain.
  Future<Map<String, dynamic>> blockDomain({required String domain, required bool block}) async {
    return await request(HttpMethod.post, '$basePath/domain/block', {
      'domain': domain,
      'block': block,
    });
  }

  // =============================================================
  // Feeds & Topics
  // =============================================================

  /// Get a feed by id or name.
  Future<Map<String, dynamic>> getFeed({int? id, String? name}) async {
    return await request(HttpMethod.get, '$basePath/feed', {
      'id': id,
      'name': name,
    });
  }

  /// List feeds.
  Future<Map<String, dynamic>> listFeeds({bool? includeCommunities, bool? mineOnly}) async {
    return await request(HttpMethod.get, '$basePath/feed/list', {
      'include_communities': includeCommunities,
      'mine_only': mineOnly,
    });
  }

  /// List topics.
  Future<Map<String, dynamic>> listTopics({bool? includeCommunities}) async {
    return await request(HttpMethod.get, '$basePath/topic/list', {
      'include_communities': includeCommunities,
    });
  }

  /// Suggest completion for a query.
  Future<Map<String, dynamic>> suggestCompletion({String? query}) async {
    return await request(HttpMethod.get, '$basePath/suggest_completion', {
      'q': query,
    });
  }

  // =============================================================
  // Media - Limited support
  // =============================================================

  @override
  Future<String> uploadImage(String filePath) async {
    return _uploadImageTo('$basePath/upload/image', filePath);
  }

  /// Upload a user image.
  Future<String> uploadUserImage(String filePath) async {
    return _uploadImageTo('$basePath/upload/user_image', filePath);
  }

  /// Upload a community image.
  Future<String> uploadCommunityImage(String filePath) async {
    return _uploadImageTo('$basePath/upload/community_image', filePath);
  }

  @override
  Future<void> deleteImage({required String file, String? token}) async {
    await request(HttpMethod.post, '$basePath/image/delete', {
      'file': file,
    });
  }

  ThunderPrivateMessage _parsePrivateMessageView(Map<String, dynamic> privateMessageView) {
    final privateMessage = privateMessageView['private_message'] as Map<String, dynamic>;
    final recipient = privateMessageView['recipient'] as Map<String, dynamic>?;
    final creator = privateMessageView['creator'] as Map<String, dynamic>?;

    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      conversationId: privateMessageView['conversation_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      published: DateTime.parse(privateMessage['published']),
      notification: NotificationRef(
        id: privateMessage['id'],
        kind: NotificationKind.privateMessage,
        read: privateMessage['read'] ?? false,
        createdAt: DateTime.parse(privateMessage['published']),
      ),
      recipient: recipient != null ? PiefedApiClient._mapper.user(recipient) : null,
      creator: creator != null ? PiefedApiClient._mapper.user(creator) : null,
    );
  }

  Future<String> _uploadImageTo(String endpoint, String filePath) async {
    try {
      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.https(account.instance, endpoint),
      );
      final headers = Map<String, String>.from(buildHeaders())..remove('Content-Type');
      uploadRequest.headers.addAll(headers);
      uploadRequest.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await uploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 429) {
        throw RateLimitException(
          'Rate limit exceeded',
          platformName: platformName,
        );
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiErrorException(
          'Failed to upload image: ${response.statusCode} ${response.reasonPhrase}',
          statusCode: response.statusCode,
          platformName: platformName,
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return parseUploadImageUrl(
            decoded,
            instance: account.instance,
            platformName: platformName,
          );
        }
        if (decoded is String && decoded.isNotEmpty) {
          return decoded;
        }
      } catch (_) {
        // Fall through to handle non-JSON responses.
      }

      throw ApiErrorException(
        'Failed to upload image: Invalid response ${response.body}',
        statusCode: response.statusCode,
        platformName: platformName,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiErrorException('Failed to upload image: $e', platformName: platformName);
    }
  }
}

AccountMediaItem _accountMediaItemFromPiefed(Map<String, dynamic> image, String instance) {
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
