import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/src/core/singletons/preferences.dart';

part 'gesture_preferences_state.dart';

/// Cubit for managing gesture-related preferences
class GesturePreferencesCubit extends Cubit<GesturePreferencesState> {
  GesturePreferencesCubit() : super(const GesturePreferencesState()) {
    load();
  }

  /// Loads gesture preferences from UserPreferences
  void load() {
    // Sidebar Gesture Settings
    final bottomNavBarSwipeGestures = UserPreferences.getLocalSetting(LocalSettings.sidebarBottomNavBarSwipeGesture) ?? true;
    final bottomNavBarDoubleTapGestures = UserPreferences.getLocalSetting(LocalSettings.sidebarBottomNavBarDoubleTapGesture) ?? false;

    // Post Gestures
    final enablePostGestures = UserPreferences.getLocalSetting(LocalSettings.enablePostGestures) ?? true;
    final leftPrimaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureLeftPrimary) ?? SwipeAction.upvote.name);
    final leftSecondaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureLeftSecondary) ?? SwipeAction.downvote.name);
    final rightPrimaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureRightPrimary) ?? SwipeAction.save.name);
    final rightSecondaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureRightSecondary) ?? SwipeAction.toggleRead.name);

    // Comment Gestures
    final enableCommentGestures = UserPreferences.getLocalSetting(LocalSettings.enableCommentGestures) ?? true;
    final leftPrimaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureLeftPrimary) ?? SwipeAction.upvote.name);
    final leftSecondaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureLeftSecondary) ?? SwipeAction.downvote.name);
    final rightPrimaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureRightPrimary) ?? SwipeAction.reply.name);
    final rightSecondaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureRightSecondary) ?? SwipeAction.save.name);

    // Navigation Gestures
    final enableFullScreenSwipeNavigationGesture = UserPreferences.getLocalSetting(LocalSettings.enableFullScreenSwipeNavigationGesture) ?? true;

    // Image Peek Settings
    final imagePeekDuration = UserPreferences.getLocalSetting(LocalSettings.imagePeekDuration) ?? 300;

    emit(
      GesturePreferencesState(
        bottomNavBarSwipeGestures: bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures,
        enablePostGestures: enablePostGestures,
        leftPrimaryPostGesture: leftPrimaryPostGesture,
        leftSecondaryPostGesture: leftSecondaryPostGesture,
        rightPrimaryPostGesture: rightPrimaryPostGesture,
        rightSecondaryPostGesture: rightSecondaryPostGesture,
        enableCommentGestures: enableCommentGestures,
        leftPrimaryCommentGesture: leftPrimaryCommentGesture,
        leftSecondaryCommentGesture: leftSecondaryCommentGesture,
        rightPrimaryCommentGesture: rightPrimaryCommentGesture,
        rightSecondaryCommentGesture: rightSecondaryCommentGesture,
        enableFullScreenSwipeNavigationGesture: enableFullScreenSwipeNavigationGesture,
        imagePeekDuration: imagePeekDuration,
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
