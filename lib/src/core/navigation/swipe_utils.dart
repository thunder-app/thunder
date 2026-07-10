import 'package:flutter/widgets.dart';

import 'package:thunder/src/features/settings/api.dart';

DismissDirection determinePostSwipeDirection({
  required bool isUserLoggedIn,
  required bool enablePostGestures,
  required SwipeAction leftPrimaryPostGesture,
  required SwipeAction leftSecondaryPostGesture,
  required SwipeAction rightPrimaryPostGesture,
  required SwipeAction rightSecondaryPostGesture,
  bool disableSwiping = false,
}) {
  if (!isUserLoggedIn) return DismissDirection.none;

  if (enablePostGestures == false) return DismissDirection.none;

  if (disableSwiping) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (leftPrimaryPostGesture == SwipeAction.none && leftSecondaryPostGesture == SwipeAction.none && rightPrimaryPostGesture == SwipeAction.none && rightSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.none;
  }

  // If there is at least 1 action on either side, then allow swiping from both sides
  if ((leftPrimaryPostGesture != SwipeAction.none || leftSecondaryPostGesture != SwipeAction.none) && (rightPrimaryPostGesture != SwipeAction.none || rightSecondaryPostGesture != SwipeAction.none)) {
    return DismissDirection.horizontal;
  }

  // If there is no action on left side, disable left side swiping
  if (leftPrimaryPostGesture == SwipeAction.none && leftSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.endToStart;
  }

  // If there is no action on the right side, disable right side swiping
  if (rightPrimaryPostGesture == SwipeAction.none && rightSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.startToEnd;
  }

  return DismissDirection.none;
}

DismissDirection determineCommentSwipeDirection(bool isUserLoggedIn, bool enableCommentGestures, List<SwipeAction> leftActions, List<SwipeAction> rightActions) {
  if (!isUserLoggedIn) return DismissDirection.none;
  if (enableCommentGestures == false) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (leftActions.isEmpty && rightActions.isEmpty) return DismissDirection.none;

  // If there is at least 1 action on either side, then allow swiping from both sides
  if (leftActions.isNotEmpty && rightActions.isNotEmpty) return DismissDirection.horizontal;

  // If there is no action on left side, disable left side swiping
  if (leftActions.isEmpty) return DismissDirection.endToStart;

  // If there is no action on the right side, disable right side swiping
  if (rightActions.isEmpty) return DismissDirection.startToEnd;

  return DismissDirection.none;
}

bool disableFullPageSwipe({bool isUserLoggedIn = false, required GesturePreferencesState state, bool isPostPage = false, isFeedPage = false}) {
  if (isPostPage == false && isFeedPage == false) {
    return false;
  }

  DismissDirection? direction;

  if (isPostPage) {
    // If the page we are pushing is a post type page, then we check for swipe actions on comments
    final enableCommentGestures = state.enableCommentGestures;
    final leftActions = [state.leftPrimaryCommentGesture, state.leftSecondaryCommentGesture].where((action) => action != SwipeAction.none).toList();
    final rightActions = [state.rightPrimaryCommentGesture, state.rightSecondaryCommentGesture].where((action) => action != SwipeAction.none).toList();

    direction = determineCommentSwipeDirection(isUserLoggedIn, enableCommentGestures, leftActions, rightActions);
  }

  if (isFeedPage) {
    // If the page we are pushing is a feed type page (community/user page), then we check for swipe actions on posts
    direction = determinePostSwipeDirection(
      isUserLoggedIn: isUserLoggedIn,
      enablePostGestures: state.enablePostGestures,
      leftPrimaryPostGesture: state.leftPrimaryPostGesture,
      leftSecondaryPostGesture: state.leftSecondaryPostGesture,
      rightPrimaryPostGesture: state.rightPrimaryPostGesture,
      rightSecondaryPostGesture: state.rightSecondaryPostGesture,
    );
  }

  if (direction == DismissDirection.none || direction == DismissDirection.endToStart) {
    return false;
  }

  return true;
}
