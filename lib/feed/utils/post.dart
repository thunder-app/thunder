import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/utils/post.dart';

/// Helper function which handles the logic of fetching posts from the API
Future<Map<String, dynamic>> fetchPosts({
  int limit = 20,
  int page = 1,
  ListingType? postListingType,
  SortType? sortType,
  int? communityId,
  String? communityName,
  int? userId,
  String? username,
}) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  bool hasReachedEnd = false;

  List<PostViewMedia> postViewMedias = [];

  int currentPage = page;

  // Guarantee that we fetch at least x posts (unless we reach the end of the feed)
  do {
    GetPostsResponse getPostsResponse = await lemmy.run(GetPosts(
      auth: account?.jwt,
      page: currentPage,
      sort: sortType,
      type: postListingType,
      communityId: communityId,
      communityName: communityName,
    ));

    // Remove deleted posts
    getPostsResponse = getPostsResponse.copyWith(posts: getPostsResponse.posts.where((PostView postView) => postView.post.deleted == false).toList());

    // Parse the posts and add in media information which is used elsewhere in the app
    List<PostViewMedia> formattedPosts = await parsePostViews(getPostsResponse.posts);
    postViewMedias.addAll(formattedPosts);

    if (getPostsResponse.posts.isEmpty) hasReachedEnd = true;
    currentPage++;
  } while (!hasReachedEnd && postViewMedias.length < limit);

  return {'postViewMedias': postViewMedias, 'hasReachedEnd': hasReachedEnd, 'currentPage': currentPage};
}

/// Logic to create a post
Future<PostView> createPost({required int communityId, required String name, String? body, String? url, bool? nsfw}) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(CreatePost(
    auth: account!.jwt!,
    communityId: communityId,
    name: name,
    body: body,
    url: url,
    nsfw: nsfw,
  ));

  return postResponse.postView;
}

/// Creates a placeholder post from the given parameters. This is mainly used to display a preview of the post
/// with the applied settings on Settings -> Appearance -> Posts page.
Future<PostViewMedia> createExamplePost({
  String? postTitle,
  String? postUrl,
  String? postBody,
  String? postThumbnailUrl,
  bool? locked,
  bool? nsfw,
  bool? pinned,
  String? personName,
  String? personDisplayName,
  String? communityName,
  String? instanceUrl,
  int? commentCount,
  int? scoreCount,
  bool? saved,
  bool? read,
}) async {
  PostView postView = PostView(
    post: Post(
      id: 1,
      name: postTitle ?? 'Example Title',
      url: postUrl,
      body: postBody,
      thumbnailUrl: postThumbnailUrl,
      creatorId: 1,
      communityId: 1,
      removed: false,
      locked: locked ?? false,
      published: DateTime.now(),
      deleted: false,
      nsfw: nsfw ?? false,
      apId: '',
      local: false,
      languageId: 0,
      featuredCommunity: pinned ?? false,
      featuredLocal: false,
    ),
    creator: Person(
      id: 1,
      name: personName ?? 'Example Username',
      displayName: personDisplayName ?? 'Example Name',
      banned: false,
      published: DateTime.now(),
      actorId: '',
      local: false,
      deleted: false,
      botAccount: false,
      instanceId: 1,
    ),
    community: Community(
      id: 1,
      name: communityName ?? 'Example Community',
      title: '',
      removed: false,
      published: DateTime.now(),
      deleted: false,
      nsfw: false,
      actorId: instanceUrl ?? 'https://thunder.lemmy',
      local: false,
      hidden: false,
      postingRestrictedToMods: false,
      instanceId: 1,
    ),
    creatorBannedFromCommunity: false,
    counts: PostAggregates(
      id: 1,
      postId: 1,
      comments: commentCount ?? 0,
      score: scoreCount ?? 0,
      upvotes: 0,
      downvotes: 0,
      published: DateTime.now(),
    ),
    subscribed: SubscribedType.notSubscribed,
    saved: saved ?? false,
    read: read ?? false,
    creatorBlocked: false,
    unreadComments: 0,
  );

  List<PostViewMedia> postViewMedias = await parsePostViews([postView]);

  return Future.value(postViewMedias.first);
}
