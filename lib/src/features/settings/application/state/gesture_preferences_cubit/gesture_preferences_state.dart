part of 'gesture_preferences_cubit.dart';

class GesturePreferencesState extends Equatable {
  const GesturePreferencesState({
    this.bottomNavBarSwipeGestures = true,
    this.bottomNavBarDoubleTapGestures = false,
    this.enablePostGestures = true,
    this.leftPrimaryPostGesture = SwipeAction.upvote,
    this.leftSecondaryPostGesture = SwipeAction.downvote,
    this.rightPrimaryPostGesture = SwipeAction.save,
    this.rightSecondaryPostGesture = SwipeAction.toggleRead,
    this.enableCommentGestures = true,
    this.leftPrimaryCommentGesture = SwipeAction.upvote,
    this.leftSecondaryCommentGesture = SwipeAction.downvote,
    this.rightPrimaryCommentGesture = SwipeAction.reply,
    this.rightSecondaryCommentGesture = SwipeAction.save,
    this.enableFullScreenSwipeNavigationGesture = true,
    this.imagePeekDuration = 300,
  });

  /// Whether the bottom navigation bar swipe gestures is enabled.
  /// This gesture is used to open the drawer when swiping from the bottom of the screen.
  final bool bottomNavBarSwipeGestures;

  /// Whether the bottom navigation bar double tap gestures is enabled.
  /// This gesture is used to open the drawer when double tapping the bottom of the screen.
  final bool bottomNavBarDoubleTapGestures;

  /// Whether post swipe gestures are enabled.
  final bool enablePostGestures;

  /// The primary swipe action for posts when swiping from the left of the screen.
  final SwipeAction leftPrimaryPostGesture;

  /// The secondary swipe action for posts when swiping from the left of the screen.
  final SwipeAction leftSecondaryPostGesture;

  /// The primary swipe action for posts when swiping from the right of the screen.
  final SwipeAction rightPrimaryPostGesture;

  /// The secondary swipe action for posts when swiping from the right of the screen.
  final SwipeAction rightSecondaryPostGesture;

  /// Whether comment swipe gestures are enabled.
  final bool enableCommentGestures;

  /// The primary swipe action for comments when swiping from the left of the screen.
  final SwipeAction leftPrimaryCommentGesture;

  /// The secondary swipe action for comments when swiping from the left of the screen.
  final SwipeAction leftSecondaryCommentGesture;

  /// The primary swipe action for comments when swiping from the right of the screen.
  final SwipeAction rightPrimaryCommentGesture;

  /// The secondary swipe action for comments when swiping from the right of the screen.
  final SwipeAction rightSecondaryCommentGesture;

  /// Whether full screen swipe navigation gestures are enabled. This allows navigating back to previous screen when swiping anywhere on the screen.
  final bool enableFullScreenSwipeNavigationGesture;

  /// The duration in milliseconds before image peek is triggered (default: 300ms)
  final int imagePeekDuration;

  GesturePreferencesState copyWith({
    bool? bottomNavBarSwipeGestures,
    bool? bottomNavBarDoubleTapGestures,
    bool? enablePostGestures,
    SwipeAction? leftPrimaryPostGesture,
    SwipeAction? leftSecondaryPostGesture,
    SwipeAction? rightPrimaryPostGesture,
    SwipeAction? rightSecondaryPostGesture,
    bool? enableCommentGestures,
    SwipeAction? leftPrimaryCommentGesture,
    SwipeAction? leftSecondaryCommentGesture,
    SwipeAction? rightPrimaryCommentGesture,
    SwipeAction? rightSecondaryCommentGesture,
    bool? enableFullScreenSwipeNavigationGesture,
    int? imagePeekDuration,
  }) {
    return GesturePreferencesState(
      bottomNavBarSwipeGestures: bottomNavBarSwipeGestures ?? this.bottomNavBarSwipeGestures,
      bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures ?? this.bottomNavBarDoubleTapGestures,
      enablePostGestures: enablePostGestures ?? this.enablePostGestures,
      leftPrimaryPostGesture: leftPrimaryPostGesture ?? this.leftPrimaryPostGesture,
      leftSecondaryPostGesture: leftSecondaryPostGesture ?? this.leftSecondaryPostGesture,
      rightPrimaryPostGesture: rightPrimaryPostGesture ?? this.rightPrimaryPostGesture,
      rightSecondaryPostGesture: rightSecondaryPostGesture ?? this.rightSecondaryPostGesture,
      enableCommentGestures: enableCommentGestures ?? this.enableCommentGestures,
      leftPrimaryCommentGesture: leftPrimaryCommentGesture ?? this.leftPrimaryCommentGesture,
      leftSecondaryCommentGesture: leftSecondaryCommentGesture ?? this.leftSecondaryCommentGesture,
      rightPrimaryCommentGesture: rightPrimaryCommentGesture ?? this.rightPrimaryCommentGesture,
      rightSecondaryCommentGesture: rightSecondaryCommentGesture ?? this.rightSecondaryCommentGesture,
      enableFullScreenSwipeNavigationGesture: enableFullScreenSwipeNavigationGesture ?? this.enableFullScreenSwipeNavigationGesture,
      imagePeekDuration: imagePeekDuration ?? this.imagePeekDuration,
    );
  }

  @override
  List<Object?> get props => [
        bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures,
        enablePostGestures,
        leftPrimaryPostGesture,
        leftSecondaryPostGesture,
        rightPrimaryPostGesture,
        rightSecondaryPostGesture,
        enableCommentGestures,
        leftPrimaryCommentGesture,
        leftSecondaryCommentGesture,
        rightPrimaryCommentGesture,
        rightSecondaryCommentGesture,
        enableFullScreenSwipeNavigationGesture,
        imagePeekDuration,
      ];
}
