import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';
import 'package:thunder/src/features/post/post.dart';

/// Repository contract for post reads and mutations.
abstract class PostRepository {
  /// Fetches a post by its ID. Returns the post along with moderators and cross-posts information
  Future<PostDetail?> getPost(int postId, {int? commentId});

  /// Fetches posts from the API
  Future<PostList> getPosts({
    String? cursor,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool showHidden = false,
    bool showSaved = false,
    int? personId,
    String? query,
    bool? likedOnly,
    int? feedId,
    int? topicId,
    bool? ignoreSticky,
  });

  /// Creates a new post
  Future<ThunderPost> create({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? languageId,
  });

  /// Edits an existing post
  Future<ThunderPost> edit({
    required int postId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? languageId,
  });

  /// Votes on a post
  Future<ThunderPost> vote(ThunderPost post, int score);

  /// Saves or unsaves a post
  Future<ThunderPost> save(ThunderPost post, bool save);

  /// Marks a post as read/unread
  Future<bool> read(int postId, bool read);

  /// Marks multiple posts as read/unread
  Future<List<int>> readMultiple(List<int> postIds, bool read);

  /// Marks a post as hidden/unhidden
  Future<bool> hide(int postId, bool hide);

  /// Deletes a post
  Future<bool> delete(int postId, bool delete);

  /// Locks/unlocks a post
  Future<bool> lock(int postId, bool lock);

  /// Pins/unpins a post to a community
  Future<bool> pinCommunity(int postId, bool pin);

  /// Removes/restores a post (moderator action)
  Future<bool> remove(int postId, bool remove, String reason);

  /// Reports a post
  Future<void> report(int postId, String reason);
}

/// Implementation of [PostRepository] using the unified API client
class PostRepositoryImpl implements PostRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new PostRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  PostRepositoryImpl({required this.account, ThunderApiClient? api, LocalizationService localization = const ThunderLocalizationService()})
    : _api = ResolvedApiClient(account: account, api: api),
      _localization = localization;

  @override
  Future<PostDetail?> getPost(int postId, {int? commentId}) async {
    final api = await _api.get();
    final response = await api.getPost(postId, commentId: commentId);

    final parsedPost = await parsePostWithCurrentPreferences(response.post);
    final parsedCrossPosts = await Future.wait(response.crossPosts.map(parsePostWithCurrentPreferences));

    return PostDetail(post: parsedPost, moderators: response.moderators, crossPosts: parsedCrossPosts);
  }

  @override
  Future<PostList> getPosts({
    String? cursor,
    int? limit,
    int? personId,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool? showHidden,
    bool? showSaved,
    bool? likedOnly,
    String? query,
    int? feedId,
    int? topicId,
    bool? ignoreSticky,
  }) async {
    final api = await _api.get();
    final response = await api.getPosts(
      cursor: cursor,
      limit: limit,
      feedListType: feedListType,
      postSortType: postSortType,
      communityId: communityId,
      communityName: communityName,
      query: query,
      personId: personId,
      likedOnly: likedOnly,
      feedId: feedId,
      topicId: topicId,
      ignoreSticky: ignoreSticky,
      showHidden: showHidden,
      showSaved: showSaved,
    );

    return PostList(posts: await parsePosts(response.posts), nextPage: response.nextPage);
  }

  @override
  Future<ThunderPost> create({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? languageId,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final response = await api.createPostWithMetadata(
      communityId: communityId,
      title: name,
      contents: body,
      url: url?.isEmpty == true ? null : url,
      customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
      altText: altText?.isEmpty == true ? null : altText,
      tags: tags,
      flairIds: flairIds,
      nsfw: nsfw,
      languageId: languageId,
    );

    final posts = await parsePosts([response]);
    return posts.firstOrNull!;
  }

  @override
  Future<ThunderPost> edit({
    required int postId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? languageId,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final response = await api.editPostWithMetadata(
      postId: postId,
      title: name,
      contents: body,
      url: url?.isEmpty == true ? null : url,
      customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
      altText: altText?.isEmpty == true ? null : altText,
      tags: tags,
      flairIds: flairIds,
      nsfw: nsfw,
      languageId: languageId,
    );

    final posts = await parsePosts([response]);
    return posts.firstOrNull!;
  }

  @override
  Future<ThunderPost> vote(ThunderPost post, int score) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final response = await api.votePost(postId: post.id, score: score);
    return response.copyWith(media: post.media);
  }

  @override
  Future<ThunderPost> save(ThunderPost post, bool save) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final response = await api.savePost(postId: post.id, save: save);
    return response.copyWith(media: post.media);
  }

  @override
  Future<bool> read(int postId, bool read) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.readPost(postIds: [postId], read: read);
  }

  @override
  Future<List<int>> readMultiple(List<int> postIds, bool read) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final success = await api.readPost(postIds: postIds, read: read);
    return success ? [] : List<int>.generate(postIds.length, (index) => index);
  }

  @override
  Future<bool> hide(int postId, bool hide) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.hidePost(postId: postId, hide: hide);
  }

  @override
  Future<bool> delete(int postId, bool delete) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.deletePost(postId: postId, deleted: delete);
  }

  @override
  Future<bool> lock(int postId, bool lock) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.lockPost(postId: postId, locked: lock);
  }

  @override
  Future<bool> pinCommunity(int postId, bool pin) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.pinPost(postId: postId, pinned: pin);
  }

  @override
  Future<bool> remove(int postId, bool remove, String reason) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.removePost(postId: postId, removed: remove, reason: reason);
  }

  @override
  Future<void> report(int postId, String reason) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.reportPost(postId: postId, reason: reason);
  }
}
