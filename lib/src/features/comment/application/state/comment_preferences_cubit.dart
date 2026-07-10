import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/config/config.dart';

part 'comment_preferences_state.dart';

/// Cubit for managing comment-related preferences
class CommentPreferencesCubit extends Cubit<CommentPreferencesState> {
  CommentPreferencesCubit({required PreferencesStore preferences})
      : _preferences = preferences,
        super(const CommentPreferencesState()) {
    load();
  }

  final PreferencesStore _preferences;

  /// Loads comment preferences from UserPreferences
  void load() {
    final defaultCommentSortType = _preferences.getLocalSetting(LocalSettings.defaultCommentSortType) ?? DEFAULT_COMMENT_SORT_TYPE.name;
    final collapseParentCommentOnGesture = _preferences.getLocalSetting(LocalSettings.collapseParentCommentBodyOnGesture) ?? true;
    final showCommentButtonActions = _preferences.getLocalSetting(LocalSettings.showCommentActionButtons) ?? false;
    final commentShowUserInstance = _preferences.getLocalSetting(LocalSettings.commentShowUserInstance) ?? false;
    final commentShowUserAvatar = _preferences.getLocalSetting(LocalSettings.commentShowUserAvatar) ?? false;
    final combineCommentScores = _preferences.getLocalSetting(LocalSettings.combineCommentScores) ?? false;
    final nestedCommentIndicatorStyle = _preferences.getLocalSetting(LocalSettings.nestedCommentIndicatorStyle) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name;
    final nestedCommentIndicatorColor = _preferences.getLocalSetting(LocalSettings.nestedCommentIndicatorColor) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name;

    emit(
      CommentPreferencesState(
        defaultCommentSortType: CommentSortType.values.byName(defaultCommentSortType),
        collapseParentCommentOnGesture: collapseParentCommentOnGesture,
        showCommentButtonActions: showCommentButtonActions,
        commentShowUserInstance: commentShowUserInstance,
        commentShowUserAvatar: commentShowUserAvatar,
        combineCommentScores: combineCommentScores,
        nestedCommentIndicatorStyle: NestedCommentIndicatorStyle.values.byName(nestedCommentIndicatorStyle),
        nestedCommentIndicatorColor: NestedCommentIndicatorColor.values.byName(nestedCommentIndicatorColor),
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
