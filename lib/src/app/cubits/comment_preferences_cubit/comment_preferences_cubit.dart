import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/nested_comment_indicator.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/shared/utils/constants.dart';

part 'comment_preferences_state.dart';

/// Cubit for managing comment-related preferences
class CommentPreferencesCubit extends Cubit<CommentPreferencesState> {
  CommentPreferencesCubit() : super(const CommentPreferencesState()) {
    load();
  }

  /// Loads comment preferences from UserPreferences
  void load() {
    final defaultCommentSortType = CommentSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultCommentSortType) ?? DEFAULT_COMMENT_SORT_TYPE.name);
    final collapseParentCommentOnGesture = UserPreferences.getLocalSetting(LocalSettings.collapseParentCommentBodyOnGesture) ?? true;
    final showCommentButtonActions = UserPreferences.getLocalSetting(LocalSettings.showCommentActionButtons) ?? false;
    final commentShowUserInstance = UserPreferences.getLocalSetting(LocalSettings.commentShowUserInstance) ?? false;
    final commentShowUserAvatar = UserPreferences.getLocalSetting(LocalSettings.commentShowUserAvatar) ?? false;
    final combineCommentScores = UserPreferences.getLocalSetting(LocalSettings.combineCommentScores) ?? false;
    final nestedCommentIndicatorStyle =
        NestedCommentIndicatorStyle.values.byName(UserPreferences.getLocalSetting(LocalSettings.nestedCommentIndicatorStyle) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
    final nestedCommentIndicatorColor =
        NestedCommentIndicatorColor.values.byName(UserPreferences.getLocalSetting(LocalSettings.nestedCommentIndicatorColor) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);

    emit(
      CommentPreferencesState(
        defaultCommentSortType: defaultCommentSortType,
        collapseParentCommentOnGesture: collapseParentCommentOnGesture,
        showCommentButtonActions: showCommentButtonActions,
        commentShowUserInstance: commentShowUserInstance,
        commentShowUserAvatar: commentShowUserAvatar,
        combineCommentScores: combineCommentScores,
        nestedCommentIndicatorStyle: nestedCommentIndicatorStyle,
        nestedCommentIndicatorColor: nestedCommentIndicatorColor,
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
