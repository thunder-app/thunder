import 'package:flutter_launcher_icons/android.dart';
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
  PostListingType? postListingType,
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
    List<PostView> batch = await lemmy.run(GetPosts(
      auth: account?.jwt,
      page: currentPage,
      sort: sortType,
      type: postListingType,
      communityId: communityId,
      communityName: communityName,
    ));

    batch.removeWhere((PostView postView) => postView.post.deleted == true);

    // Parse the posts and add in media information which is used elsewhere in the app
    List<PostViewMedia> formattedPosts = await parsePostViews(batch);
    postViewMedias.addAll(formattedPosts);

    if (batch.isEmpty) hasReachedEnd = true;
    currentPage++;
  } while (!hasReachedEnd && postViewMedias.length < limit);

  return {'postViewMedias': postViewMedias, 'hasReachedEnd': hasReachedEnd, 'currentPage': currentPage};
}

/// Logic to create a post
Future<PostView> createPost({required int communityId, required String name, String? body, String? url, bool? nsfw, bool? isEdit, int? postId}) async {
  assert(isEdit != true || postId != null);

  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostView postView;
  if (isEdit == true) {
    postView = await lemmy.run(EditPost(
      auth: account!.jwt!,
      name: name,
      body: body,
      url: url,
      nsfw: nsfw,
      postId: postId!,
    ));
  } else {
    postView = await lemmy.run(CreatePost(
      auth: account!.jwt!,
      communityId: communityId,
      name: name,
      body: body,
      url: url,
      nsfw: nsfw,
    ));
  }

  return postView;
}
