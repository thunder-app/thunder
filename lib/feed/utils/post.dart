import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/enums/feed_type_subview.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/post/repository/post_repository.dart';
import 'package:thunder/user/repository/user_repository.dart';

/// Helper function which handles the logic of fetching items for the feed from the API
/// This includes posts and user information (posts/comments)
Future<Map<String, dynamic>> fetchFeedItems({
  int page = 1,
  FeedListType? feedListType,
  PostSortType? postSortType,
  int? communityId,
  String? communityName,
  int? userId,
  String? username,
  FeedTypeSubview feedTypeSubview = FeedTypeSubview.post,
  bool showHidden = false,
  bool showSaved = false,
  void Function()? notifyExcessiveApiCalls,
}) async {
  final account = await fetchActiveProfile();

  List<String> keywordFilters = UserPreferences.getLocalSetting(LocalSettings.keywordFilters) ?? [];

  int desiredPosts = 20;
  bool hasReachedPostsEnd = false;
  bool hasReachedCommentsEnd = false;

  List<ThunderPost> posts = [];
  List<ThunderComment> comments = [];

  int startingPage = page, currentPage = page;

  // Guarantee that we fetch at least x posts (unless we reach the end of the feed)
  if (communityId != null || communityName != null || feedListType != null) {
    do {
      final postRepository = LemmyPostRepository(account: account);
      GetPostsResponse getPostsResponse = await postRepository.getPosts(
        page: currentPage,
        postSortType: postSortType,
        feedListType: feedListType,
        communityId: communityId,
        communityName: communityName,
        showHidden: showHidden,
        showSaved: showSaved,
      );

      // Keep the length of the original response to see if there are any additional posts to fetch
      int postResponseLength = getPostsResponse.posts.length;

      // Remove deleted posts
      getPostsResponse = getPostsResponse.copyWith(posts: getPostsResponse.posts.where((PostView postView) => postView.post.deleted == false).toList());

      // Remove posts that contain any of the keywords in the title, body, or url
      getPostsResponse = getPostsResponse.copyWith(
        posts: getPostsResponse.posts.where((postView) {
          final title = postView.post.name.toLowerCase();
          final body = postView.post.body?.toLowerCase() ?? '';
          final url = postView.post.url?.toLowerCase() ?? '';

          return !keywordFilters.any((keyword) => title.contains(keyword.toLowerCase()) || body.contains(keyword.toLowerCase()) || url.contains(keyword.toLowerCase()));
        }).toList(),
      );

      // Parse the posts and add in media information which is used elsewhere in the app
      List<ThunderPost> formattedPosts = await parsePosts(getPostsResponse.posts);
      posts.addAll(formattedPosts);

      if (keywordFilters.isNotEmpty) {
        // Add some debugging logging so we can see what's going on when we're loading a feed with filters.
        debugPrint('posts.length is ${posts.length} and postResponseLength is $postResponseLength and currentPage is $currentPage');
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
    } while (!hasReachedPostsEnd && posts.length < desiredPosts);
  }

  // Guarantee that we fetch at least x posts/comments (unless we reach the end of the feed)
  if (userId != null || username != null) {
    do {
      final userRepository = LemmyUserRepository(account: account);

      GetPersonDetailsResponse? getPersonDetailsResponse = await userRepository.getUser(
        userId: userId,
        username: username,
        sort: postSortType,
        page: currentPage,
        saved: showSaved,
      );

      // Remove deleted posts and comments
      getPersonDetailsResponse = getPersonDetailsResponse!.copyWith(
        posts: getPersonDetailsResponse.posts.where((PostView postView) => postView.post.deleted == false).toList(),
        comments: getPersonDetailsResponse.comments.where((CommentView commentView) => commentView.comment.deleted == false).toList(),
      );

      // Parse the posts and add in media information which is used elsewhere in the app
      List<ThunderPost> formattedPosts = await parsePosts(getPersonDetailsResponse.posts);
      posts.addAll(formattedPosts);

      comments.addAll(getPersonDetailsResponse.comments.map((commentView) => ThunderComment.fromLemmyCommentView(commentView.toJson())));

      if (getPersonDetailsResponse.posts.isEmpty) hasReachedPostsEnd = true;
      if (getPersonDetailsResponse.comments.isEmpty) hasReachedCommentsEnd = true;
      currentPage++;
    } while (feedTypeSubview == FeedTypeSubview.post ? (!hasReachedPostsEnd && posts.length < desiredPosts) : (!hasReachedCommentsEnd && comments.length < desiredPosts));
  }

  return {'posts': posts, 'comments': comments, 'hasReachedPostsEnd': hasReachedPostsEnd, 'hasReachedCommentsEnd': hasReachedCommentsEnd, 'currentPage': currentPage};
}
