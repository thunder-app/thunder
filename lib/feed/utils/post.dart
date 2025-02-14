import 'package:flutter/foundation.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/enums/feed_type_subview.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/convert.dart';

/// Helper function which handles the logic of fetching items for the feed from the API
/// This includes posts and user information (posts/comments)
Future<Map<String, dynamic>> fetchFeedItems({
  int page = 1,
  ListingType? postListingType,
  SortType? sortType,
  int? communityId,
  String? communityName,
  int? userId,
  String? username,
  FeedTypeSubview feedTypeSubview = FeedTypeSubview.post,
  bool showHidden = false,
  bool showSaved = false,
  void Function()? notifyExcessiveApiCalls,
}) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  List<String> keywordFilters = prefs.getStringList(LocalSettings.keywordFilters.name) ?? [];

  int desiredPosts = 20;
  bool hasReachedPostsEnd = false;
  bool hasReachedCommentsEnd = false;

  List<PostViewMedia> postViewMedias = [];
  List<CommentView> commentViews = [];

  int startingPage = page, currentPage = page;

  // Guarantee that we fetch at least x posts (unless we reach the end of the feed)
  if (communityId != null || communityName != null || postListingType != null) {
    do {
      GetPostsResponse getPostsResponse = await lemmy.run(GetPosts(
        auth: account?.jwt,
        page: currentPage,
        sort: sortType,
        type: postListingType,
        communityId: communityId,
        communityName: communityName,
        showHidden: showHidden,
        savedOnly: showSaved,
      ));

      // Keep the length of the original response to see if there are any additional posts to fetch
      int postResponseLength = getPostsResponse.posts.length;

      // Remove deleted posts
      List<PostView> posts = getPostsResponse.posts.map((p) => convertToPostView(p)!).toList();
      posts = posts.where((PostView postView) => postView.post.deleted == false).toList();

      // Remove posts that contain any of the keywords in the title, body, or url
      posts = posts.where((postView) {
        final title = postView.post.name.toLowerCase();
        final body = postView.post.body?.toLowerCase() ?? '';
        final url = postView.post.url?.toLowerCase() ?? '';

        return !keywordFilters.any((keyword) => title.contains(keyword.toLowerCase()) || body.contains(keyword.toLowerCase()) || url.contains(keyword.toLowerCase()));
      }).toList();

      // Parse the posts and add in media information which is used elsewhere in the app
      List<PostViewMedia> formattedPosts = await parsePostViews(posts);
      postViewMedias.addAll(formattedPosts);

      if (keywordFilters.isNotEmpty) {
        // Add some debugging logging so we can see what's going on when we're loading a feed with filters.
        debugPrint('postViewMedias.length is ${postViewMedias.length} and postResponseLength is $postResponseLength and currentPage is $currentPage');
      }

      if (postResponseLength == 0) hasReachedPostsEnd = true;
      currentPage++;

      // If we've been searching for enough posts to satisfy the desired number
      // and we've already made 20 API requests,
      // and the user has some filters defined,
      // then tell the user the feed is loading slowly due to their filters
      if (keywordFilters.isNotEmpty && currentPage - startingPage > 20) {
        notifyExcessiveApiCalls?.call();
        notifyExcessiveApiCalls = null;
      }
    } while (!hasReachedPostsEnd && postViewMedias.length < desiredPosts);
  }

  // Guarantee that we fetch at least x posts/comments (unless we reach the end of the feed)
  if (userId != null || username != null) {
    do {
      GetPersonDetailsResponse getPersonDetailsResponse = await lemmy.run(GetPersonDetails(
        auth: account?.jwt,
        personId: userId,
        username: username,
        page: currentPage,
        sort: sortType,
        savedOnly: showSaved,
      ));

      // Remove deleted posts and comments
      List<PostView> posts = getPersonDetailsResponse.posts.map((p) => convertToPostView(p)!).toList();
      posts = posts.where((PostView postView) => postView.post.deleted == false).toList();

      getPersonDetailsResponse = getPersonDetailsResponse.copyWith(
        comments: getPersonDetailsResponse.comments.where((CommentView commentView) => commentView.comment.deleted == false).toList(),
      );

      // Parse the posts and add in media information which is used elsewhere in the app
      List<PostViewMedia> formattedPosts = await parsePostViews(posts);
      postViewMedias.addAll(formattedPosts);

      commentViews.addAll(getPersonDetailsResponse.comments);

      if (getPersonDetailsResponse.posts.isEmpty) hasReachedPostsEnd = true;
      if (getPersonDetailsResponse.comments.isEmpty) hasReachedCommentsEnd = true;
      currentPage++;
    } while (feedTypeSubview == FeedTypeSubview.post ? (!hasReachedPostsEnd && postViewMedias.length < desiredPosts) : (!hasReachedCommentsEnd && commentViews.length < desiredPosts));
  }

  return {'postViewMedias': postViewMedias, 'commentViews': commentViews, 'hasReachedPostsEnd': hasReachedPostsEnd, 'hasReachedCommentsEnd': hasReachedCommentsEnd, 'currentPage': currentPage};
}

/// Logic to create a post
Future<PostView> createPost({
  required int communityId,
  required String name,
  String? body,
  String? url,
  String? customThumbnail,
  String? altText,
  bool? nsfw,
  int? postIdBeingEdited,
  int? languageId,
}) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse;
  if (postIdBeingEdited != null) {
    postResponse = await lemmy.run(EditPost(
      auth: account!.jwt!,
      name: name,
      body: body,
      url: url?.isEmpty == true ? null : url,
      customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
      altText: altText?.isEmpty == true ? null : altText,
      nsfw: nsfw,
      postId: postIdBeingEdited,
      languageId: languageId,
    ));
  } else {
    postResponse = await lemmy.run(CreatePost(
      auth: account!.jwt!,
      communityId: communityId,
      name: name,
      body: body,
      url: url?.isEmpty == true ? null : url,
      customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
      altText: altText?.isEmpty == true ? null : altText,
      nsfw: nsfw,
      languageId: languageId,
    ));
  }

  return convertToPostView(postResponse.postView)!;
}

/// Creates a placeholder post from the given parameters. This is mainly used to display a preview of the post
/// with the applied settings on Settings -> Appearance -> Posts page.
Future<PostViewMedia?> createExamplePost({
  String? postTitle,
  String? postUrl,
  String? postBody,
  String? postThumbnailUrl,
  String? postAltText,
  bool? locked,
  bool? nsfw,
  bool? pinned,
  String? personName,
  String? personDisplayName,
  String? personInstance,
  String? communityName,
  String? instanceUrl,
  int? commentCount,
  int? scoreCount,
  bool? saved,
  bool? read,
}) async {
  return null;

  // PostView postView = PostView(
  //   post: Post(
  //     id: 1,
  //     name: postTitle ?? 'Example Title',
  //     url: postUrl,
  //     body: postBody,
  //     thumbnailUrl: postThumbnailUrl,
  //     altText: postAltText,
  //     creatorId: 1,
  //     communityId: 1,
  //     removed: false,
  //     locked: locked ?? false,
  //     published: DateTime.now(),
  //     deleted: false,
  //     nsfw: nsfw ?? false,
  //     apId: '',
  //     local: false,
  //     languageId: 0,
  //     featuredCommunity: pinned ?? false,
  //     featuredLocal: false,
  //   ),
  //   creator: Person(
  //     id: 1,
  //     name: personName ?? 'Example Username',
  //     displayName: personDisplayName ?? 'Example Name',
  //     banned: false,
  //     published: DateTime.now(),
  //     actorId: 'https://$personInstance/u/$personName',
  //     local: false,
  //     deleted: false,
  //     botAccount: false,
  //     instanceId: 1,
  //   ),
  //   community: Community(
  //     id: 1,
  //     name: communityName ?? 'Example Community',
  //     title: '',
  //     removed: false,
  //     published: DateTime.now(),
  //     deleted: false,
  //     nsfw: false,
  //     actorId: instanceUrl ?? 'https://thunder.lemmy',
  //     local: false,
  //     hidden: false,
  //     postingRestrictedToMods: false,
  //     instanceId: 1,
  //   ),
  //   creatorBannedFromCommunity: false,
  //   counts: PostAggregates(
  //     id: 1,
  //     postId: 1,
  //     comments: commentCount ?? 0,
  //     score: scoreCount ?? 0,
  //     upvotes: 0,
  //     downvotes: 0,
  //     published: DateTime.now(),
  //   ),
  //   subscribed: SubscribedType.notSubscribed,
  //   saved: saved ?? false,
  //   read: read ?? false,
  //   creatorBlocked: false,
  //   unreadComments: 0,
  // );

  // List<PostViewMedia> postViewMedias = await parsePostViews([postView]);

  // return Future.value(postViewMedias.firstOrNull);
}
