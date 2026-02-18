import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/domain/swipe_action.dart';

part 'gesture_preferences_state.dart';

/// Cubit for managing gesture-related preferences
class GesturePreferencesCubit extends Cubit<GesturePreferencesState> {
  GesturePreferencesCubit({required PreferencesStore preferencesStore})
      : _preferencesStore = preferencesStore,
        super(const GesturePreferencesState()) {
    load();
  }

  final PreferencesStore _preferencesStore;

  /// Loads gesture preferences from UserPreferences
  void load() {
    // Sidebar Gesture Settings
    final bottomNavBarSwipeGestures = _preferencesStore.getLocalSetting(LocalSettings.sidebarBottomNavBarSwipeGesture) ?? true;
    final bottomNavBarDoubleTapGestures = _preferencesStore.getLocalSetting(LocalSettings.sidebarBottomNavBarDoubleTapGesture) ?? false;

    // Post Gestures
    final enablePostGestures = _preferencesStore.getLocalSetting(LocalSettings.enablePostGestures) ?? true;
    final leftPrimaryPostGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postGestureLeftPrimary) ?? SwipeAction.upvote.name);
    final leftSecondaryPostGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postGestureLeftSecondary) ?? SwipeAction.downvote.name);
    final rightPrimaryPostGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postGestureRightPrimary) ?? SwipeAction.save.name);
    final rightSecondaryPostGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postGestureRightSecondary) ?? SwipeAction.toggleRead.name);

    // Comment Gestures
    final enableCommentGestures = _preferencesStore.getLocalSetting(LocalSettings.enableCommentGestures) ?? true;
    final leftPrimaryCommentGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.commentGestureLeftPrimary) ?? SwipeAction.upvote.name);
    final leftSecondaryCommentGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.commentGestureLeftSecondary) ?? SwipeAction.downvote.name);
    final rightPrimaryCommentGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.commentGestureRightPrimary) ?? SwipeAction.reply.name);
    final rightSecondaryCommentGesture = SwipeAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.commentGestureRightSecondary) ?? SwipeAction.save.name);

    // Navigation Gestures
    final enableFullScreenSwipeNavigationGesture = _preferencesStore.getLocalSetting(LocalSettings.enableFullScreenSwipeNavigationGesture) ?? true;

    // Image Peek Settings
    final imagePeekDuration = _preferencesStore.getLocalSetting(LocalSettings.imagePeekDuration) ?? 300;

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
