import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/comment.dart';

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
    List<PostView> postViews = [];

    GetPostsResponse getPostsResponse = await lemmy.run(GetPosts(
      auth: account?.jwt,
      page: currentPage,
      sort: sortType,
      type: postListingType,
      communityId: communityId,
      communityName: communityName,
    ));

    // Remove deleted posts
    postViews = getPostsResponse.posts.where((PostView postView) => postView.post.deleted == false).toList();

    // Parse the posts and add in media information which is used elsewhere in the app
    List<PostViewMedia> formattedPosts = await parsePostViews(postViews);
    postViewMedias.addAll(formattedPosts);

    if (postViews.isEmpty) hasReachedEnd = true;
    currentPage++;
  } while (!hasReachedEnd && postViewMedias.length < limit);

  return {
    'postViewMedias': postViewMedias,
    'hasReachedEnd': hasReachedEnd,
    'currentPage': currentPage,
  };
}

/// Helper function which handles the logic of fetching user information from the API
Future<Map<String, dynamic>> fetchUserInformation({
  int limit = 20,
  int page = 1,
  ListingType? postListingType,
  SortType? sortType,
  int? userId,
  String? username,
}) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  bool hasReachedEnd = false;

  // User information if present
  GetPersonDetailsResponse? getPersonDetailsResponse;

  // Comment information
  List<CommentViewTree> commentViewTreeList = [];

  // Post information
  List<PostViewMedia> postViewMedias = [];

  int currentPage = page;

  // Guarantee that we fetch at least x comments (unless we reach the end of the feed)
  do {
    List<CommentView> commentViews = [];
    List<PostView> postViews = [];

    getPersonDetailsResponse = await lemmy.run(GetPersonDetails(
      auth: account?.jwt,
      page: currentPage,
      sort: sortType,
      personId: userId,
      username: username,
    ));

    // Remove deleted posts/comments
    commentViews = getPersonDetailsResponse!.comments.where((CommentView commentView) => commentView.comment.deleted == false).toList();
    postViews = getPersonDetailsResponse!.posts.where((PostView postView) => postView.post.deleted == false).toList();

    // Build the tree view from the flattened comments
    List<CommentViewTree> commentTree = buildCommentViewTree(commentViews, flatten: true);
    commentViewTreeList.addAll(commentTree);

    // Parse the posts and add in media information which is used elsewhere in the app
    List<PostViewMedia> formattedPosts = await parsePostViews(postViews);
    postViewMedias.addAll(formattedPosts);

    if (commentTree.isEmpty && postViews.isEmpty) hasReachedEnd = true;
    currentPage++;
  } while (!hasReachedEnd && (commentViewTreeList.length + postViewMedias.length) < limit);

  return {
    'postViewMedias': postViewMedias,
    'commentViewTreeList': commentViewTreeList,
    'hasReachedEnd': hasReachedEnd,
    'currentPage': currentPage,
    'getPersonDetailsResponse': getPersonDetailsResponse,
  };
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
