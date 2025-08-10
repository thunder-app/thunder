import 'package:flutter/foundation.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

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
      List<ThunderPost> response = await PostRepositoryImpl(account: account).getPosts(
        page: currentPage,
        postSortType: postSortType,
        feedListType: feedListType,
        communityId: communityId,
        communityName: communityName,
        showHidden: showHidden,
        showSaved: showSaved,
      );

      // Keep the length of the original response to see if there are any additional posts to fetch
      int postResponseLength = response.length;

      // Remove deleted posts
      response = response.where((post) => post.deleted == false).toList();

      // Remove posts that contain any of the keywords in the title, body, or url
      response = response.where((post) {
        final title = post.name.toLowerCase();
        final body = post.body?.toLowerCase() ?? '';
        final url = post.url?.toLowerCase() ?? '';

        return !keywordFilters.any((keyword) => title.contains(keyword.toLowerCase()) || body.contains(keyword.toLowerCase()) || url.contains(keyword.toLowerCase()));
      }).toList();

      // Parse the posts and add in media information which is used elsewhere in the app
      List<ThunderPost> formattedPosts = await parsePosts(response);
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
      final userRepository = UserRepositoryImpl(account: account);

      Map<String, dynamic>? response = await userRepository.getUser(
        userId: userId,
        username: username,
        sort: postSortType,
        page: currentPage,
        saved: showSaved,
      );

      List<ThunderPost> responsePosts = response!['posts'];
      List<ThunderComment> responseComments = response['comments'];

      // Remove deleted posts and comments
      responsePosts = responsePosts.where((post) => post.deleted == false).toList();
      responseComments = responseComments.where((comment) => comment.deleted == false).toList();

      // Parse the posts and add in media information which is used elsewhere in the app
      List<ThunderPost> formattedPosts = await parsePosts(responsePosts);
      posts.addAll(formattedPosts);
      comments.addAll(responseComments);

      if (responsePosts.isEmpty) hasReachedPostsEnd = true;
      if (responseComments.isEmpty) hasReachedCommentsEnd = true;
      currentPage++;
    } while (feedTypeSubview == FeedTypeSubview.post ? (!hasReachedPostsEnd && posts.length < desiredPosts) : (!hasReachedCommentsEnd && comments.length < desiredPosts));
  }

  return {'posts': posts, 'comments': comments, 'hasReachedPostsEnd': hasReachedPostsEnd, 'hasReachedCommentsEnd': hasReachedCommentsEnd, 'currentPage': currentPage};
}
