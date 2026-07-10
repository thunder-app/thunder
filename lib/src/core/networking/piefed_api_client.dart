import 'package:thunder/src/core/networking/upload_image_utils.dart';
import 'package:thunder/src/core/domain/enums/comment_sort_type.dart';
import 'package:thunder/src/core/domain/enums/feed_list_type.dart';
import 'package:thunder/src/core/domain/enums/meta_search_type.dart';
import 'package:thunder/src/core/domain/enums/post_sort_type.dart';
import 'package:thunder/src/core/domain/enums/search_sort_type.dart';
import 'package:thunder/src/core/domain/models/modlog_event_item.dart';
import 'package:thunder/src/core/domain/models/piefed_post_metadata.dart';
import 'package:thunder/src/core/domain/models/thunder_link_metadata.dart';
import 'package:thunder/src/core/domain/models/thunder_page.dart';
import 'package:thunder/src/core/domain/models/thunder_private_message.dart';
import 'package:thunder/src/core/domain/models/thunder_report.dart';
import 'package:thunder/src/core/domain/models/thunder_site.dart';
import 'package:thunder/src/core/domain/models/thunder_site_response.dart';
import 'package:thunder/src/core/networking/mappers/primitive_mappers.dart';
import 'package:thunder/src/core/networking/mappers/site_response_mapper.dart';
import 'package:thunder/src/core/errors/api_exception.dart';
import 'package:thunder/src/core/networking/base_api_client.dart';
import 'package:thunder/src/core/networking/instance_uri.dart';
import 'package:thunder/src/core/networking/modlog_parsers.dart';
import 'package:thunder/src/core/networking/thunder_api_client.dart';
import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_flair.dart';
import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';
import 'package:thunder/src/core/domain/models/notification_ref.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
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
    // PieFed has no server logout endpoint; clearing the local JWT is sufficient.
  }

  @override
  Future<ThunderSiteResponse> site() async {
    final json = await request(HttpMethod.get, '$basePath/site', {});
    return piefedSiteResponse(json);
  }

  // =============================================================
  // Posts
  // =============================================================

  @override
  Future<GetPostResponse> getPost(int postId, {int? commentId}) async {
    final json = await request(HttpMethod.get, '$basePath/post', {
      'id': postId,
    });

    final post = _mapper.postView(json['post_view']);
    final moderators = (json['moderators'] as List).map<ThunderUser>((mu) => _mapper.user(mu['moderator'])).toList();

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

    final posts = (json['posts'] as List).map<ThunderPost>((pv) => _mapper.postView(pv)).toList();
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
    return _mapper.postView(json['post_view']);
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
    return _mapper.postView(json['post_view']);
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
    final post = _mapper.postView(json['post_view']);
    return post.context.hidden == hide;
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

  /// Assign flair to a post.
  Future<ThunderPost> setPostFlair({required int postId, List<int>? flairIds}) async {
    final json = await request(HttpMethod.post, '$basePath/post/assign_flair', {
      'post_id': postId,
      'flair_id_list': flairIds,
    });
    return _mapper.postView(json);
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
  }) async {
    final pageNumber = cursor != null ? int.tryParse(cursor) ?? page : page;
    final reports = switch (kind) {
      ReportKind.comment => await _getCommentReports(
          commentId: commentId,
          page: pageNumber,
          limit: limit,
          unresolved: unresolved,
          communityId: communityId,
        ),
      ReportKind.privateMessage || ReportKind.community => <ThunderReport>[],
      _ => await _getPostReports(
          postId: postId,
          page: pageNumber,
          limit: limit,
          unresolved: unresolved,
          communityId: communityId,
        ),
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
    return (json['post_reports'] as List).map<ThunderReport>((report) => _mapper.postReportView(report)).toList();
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
    return (json['comment_reports'] as List).map<ThunderReport>((report) => _mapper.commentReportView(report)).toList();
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
    final comments = flattenedComments.map<ThunderComment>((cv) => _mapper.commentView(cv)).toList();
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
      'body': content,
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
      site: json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      moderators: (json['moderators'] as List).map<ThunderUser>((cmv) => _mapper.user(cmv['moderator'])).toList(),
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
    return (json['communities'] as List).map<ThunderCommunity>((cv) => _mapper.communityView(cv)).toList();
  }

  @override
  Future<ThunderCommunity> subscribeToCommunity({required int communityId, required bool follow}) async {
    final json = await request(HttpMethod.post, '$basePath/community/follow', {
      'community_id': communityId,
      'follow': follow,
    });
    // The API response should include the updated subscription status
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
      'include_content': includeContent,
    });
    final posts = (json['posts'] as List?)?.map<ThunderPost>((pv) => _mapper.postView(pv)).toList() ?? [];
    final comments = (json['comments'] as List?)?.map<ThunderComment>((cv) => _mapper.commentView(cv)).toList() ?? [];

    return (
      user: _mapper.userView(json['person_view']),
      site: json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
      posts: posts,
      comments: comments,
      moderates: (json['moderates'] as List?)?.map<ThunderCommunity>((cmv) => _mapper.community(cmv['community'])).toList() ?? [],
      nextPage: json['next_page']?.toString() ?? ((limit != null && posts.length < limit && comments.length < limit) ? null : (pageNumber + 1).toString()),
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
    if (!ban) {
      final json = await request(HttpMethod.put, '$basePath/community/moderate/unban', {
        'community_id': communityId,
        'user_id': userId,
      });
      return _mapper.user(json['banned_user']);
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
    return _mapper.user(json['banned_user']);
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
    final response = await request(HttpMethod.get, '$basePath/user/mentions', {
      'page': page,
      'limit': limit,
      'sort': sort?.value,
      'unread_only': unread,
    });

    return (response['replies'] as List).map<ThunderComment>((mention) {
      final comment = _mapper.commentView(mention);

      return comment.copyWith(
        recipient: _mapper.user(mention['recipient']),
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
    return json['blocked'] as bool? ?? block;
  }

  // =============================================================
  // Media - Limited support
  // =============================================================

  @override
  Future<String> uploadImage(String filePath) async {
    return _uploadImageTo('$basePath/upload/image', filePath);
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
      recipient: recipient != null ? _mapper.user(recipient) : null,
      creator: creator != null ? _mapper.user(creator) : null,
    );
  }

  Future<String> _uploadImageTo(String endpoint, String filePath) async {
    final decoded = await uploadMultipartImage(
      httpClient: httpClient,
      uri: buildInstanceUri(account.instance, endpoint),
      headers: buildHeaders(),
      fieldName: 'file',
      filePath: filePath,
      platformName: platformName,
    );
    return parseUploadImageUrl(
      decoded,
      instance: account.instance,
      platformName: platformName,
    );
  }

  // =============================================================
  // Feature Flags
  // =============================================================

  @override
  bool get supportsListReports => true;

  @override
  bool get supportsSettingsImportExport => false;

  @override
  bool get supportsTOTP => false;
}

AccountMediaItem _accountMediaItemFromPiefed(Map<String, dynamic> image, String instance) {
  final localImage = image['local_image'] as Map<String, dynamic>? ?? image;
  final alias = localImage['pictrs_alias']?.toString() ?? localImage['file']?.toString() ?? '';
  final url = image['url']?.toString() ?? buildInstanceUrl(instance, '/pictrs/image/$alias');
  return AccountMediaItem(
    alias: alias,
    url: url,
    uploadedAt: DateTime.tryParse((localImage['published'] ?? localImage['published_at'] ?? '').toString()),
    thumbnailForPostId: localImage['thumbnail_for_post_id'] as int?,
    deleteToken: localImage['pictrs_delete_token']?.toString() ?? image['delete_token']?.toString(),
  );
}
