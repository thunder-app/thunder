import 'package:flutter/widgets.dart';
import 'package:thunder/community/utils/post_actions.dart';
import 'package:thunder/post/utils/comment_actions.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

bool disableFullPageSwipe(
    {bool isUserLoggedIn = false,
    required ThunderState state,
    bool isPostPage = false,
    isFeedPage = false}) {
  if (isPostPage == false && isFeedPage == false) {
    return false;
  }

  DismissDirection? direction;

  if (isPostPage) {
    // If the page we are pushing is a post type page, then we check for swipe actions on comments
    direction = determineCommentSwipeDirection(isUserLoggedIn, state);
  }

  if (isFeedPage) {
    // If the page we are pushing is a feed type page (community/user page), then we check for swipe actions on posts
    direction = determinePostSwipeDirection(isUserLoggedIn, state);
  }

  if (direction == DismissDirection.none ||
      direction == DismissDirection.endToStart) {
    return false;
  }

  return true;
}
