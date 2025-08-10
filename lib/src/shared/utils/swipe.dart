import 'package:flutter/widgets.dart';

import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';

DismissDirection determinePostSwipeDirection(bool isUserLoggedIn, ThunderState state, {bool disableSwiping = false}) {
  if (!isUserLoggedIn) return DismissDirection.none;

  if (state.enablePostGestures == false) return DismissDirection.none;

  if (disableSwiping) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (state.leftPrimaryPostGesture == SwipeAction.none &&
      state.leftSecondaryPostGesture == SwipeAction.none &&
      state.rightPrimaryPostGesture == SwipeAction.none &&
      state.rightSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.none;
  }

  // If there is at least 1 action on either side, then allow swiping from both sides
  if ((state.leftPrimaryPostGesture != SwipeAction.none || state.leftSecondaryPostGesture != SwipeAction.none) &&
      (state.rightPrimaryPostGesture != SwipeAction.none || state.rightSecondaryPostGesture != SwipeAction.none)) {
    return DismissDirection.horizontal;
  }

  // If there is no action on left side, disable left side swiping
  if (state.leftPrimaryPostGesture == SwipeAction.none && state.leftSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.endToStart;
  }

  // If there is no action on the right side, disable right side swiping
  if (state.rightPrimaryPostGesture == SwipeAction.none && state.rightSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.startToEnd;
  }

  return DismissDirection.none;
}

DismissDirection determineCommentSwipeDirection(bool isUserLoggedIn, ThunderState state) {
  if (!isUserLoggedIn) return DismissDirection.none;

  if (state.enableCommentGestures == false) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (state.leftPrimaryCommentGesture == SwipeAction.none &&
      state.leftSecondaryCommentGesture == SwipeAction.none &&
      state.rightPrimaryCommentGesture == SwipeAction.none &&
      state.rightSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.none;
  }

  // If there is at least 1 action on either side, then allow swiping from both sides
  if ((state.leftPrimaryCommentGesture != SwipeAction.none || state.leftSecondaryCommentGesture != SwipeAction.none) &&
      (state.rightPrimaryCommentGesture != SwipeAction.none || state.rightSecondaryCommentGesture != SwipeAction.none)) {
    return DismissDirection.horizontal;
  }

  // If there is no action on left side, disable left side swiping
  if (state.leftPrimaryCommentGesture == SwipeAction.none && state.leftSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.endToStart;
  }

  // If there is no action on the right side, disable right side swiping
  if (state.rightPrimaryCommentGesture == SwipeAction.none && state.rightSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.startToEnd;
  }

  return DismissDirection.none;
}

bool disableFullPageSwipe({bool isUserLoggedIn = false, required ThunderState state, bool isPostPage = false, isFeedPage = false}) {
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

  if (direction == DismissDirection.none || direction == DismissDirection.endToStart) {
    return false;
  }

  return true;
}
