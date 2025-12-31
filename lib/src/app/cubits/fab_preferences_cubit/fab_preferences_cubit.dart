import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/fab_action.dart';
import 'package:thunder/src/core/singletons/preferences.dart';

part 'fab_preferences_state.dart';

/// Cubit for managing floating action button (FAB) preferences
class FabPreferencesCubit extends Cubit<FabPreferencesState> {
  FabPreferencesCubit() : super(const FabPreferencesState()) {
    load();
  }

  /// Loads FAB preferences from UserPreferences
  void load() {
    final enableFeedsFab = UserPreferences.getLocalSetting(LocalSettings.enableFeedsFab) ?? true;
    final enablePostsFab = UserPreferences.getLocalSetting(LocalSettings.enablePostsFab) ?? true;

    final enableBackToTop = UserPreferences.getLocalSetting(LocalSettings.enableBackToTop) ?? true;
    final enableSubscriptions = UserPreferences.getLocalSetting(LocalSettings.enableSubscriptions) ?? true;
    final enableRefresh = UserPreferences.getLocalSetting(LocalSettings.enableRefresh) ?? true;
    final enableDismissRead = UserPreferences.getLocalSetting(LocalSettings.enableDismissRead) ?? true;
    final enableChangeSort = UserPreferences.getLocalSetting(LocalSettings.enableChangeSort) ?? true;
    final enableNewPost = UserPreferences.getLocalSetting(LocalSettings.enableNewPost) ?? true;

    final postFabEnableBackToTop = UserPreferences.getLocalSetting(LocalSettings.postFabEnableBackToTop) ?? true;
    final postFabEnableChangeSort = UserPreferences.getLocalSetting(LocalSettings.postFabEnableChangeSort) ?? true;
    final postFabEnableReplyToPost = UserPreferences.getLocalSetting(LocalSettings.postFabEnableReplyToPost) ?? true;
    final postFabEnableRefresh = UserPreferences.getLocalSetting(LocalSettings.postFabEnableRefresh) ?? true;
    final postFabEnableSearch = UserPreferences.getLocalSetting(LocalSettings.postFabEnableSearch) ?? true;

    final feedFabSinglePressAction = FeedFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.feedFabSinglePressAction) ?? FeedFabAction.newPost.name);
    final feedFabLongPressAction = FeedFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.feedFabLongPressAction) ?? FeedFabAction.openFab.name);
    final postFabSinglePressAction = PostFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postFabSinglePressAction) ?? PostFabAction.replyToPost.name);
    final postFabLongPressAction = PostFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postFabLongPressAction) ?? PostFabAction.openFab.name);

    final enableCommentNavigation = UserPreferences.getLocalSetting(LocalSettings.enableCommentNavigation) ?? true;
    final combineNavAndFab = UserPreferences.getLocalSetting(LocalSettings.combineNavAndFab) ?? true;

    emit(
      FabPreferencesState(
        enableFeedsFab: enableFeedsFab,
        enablePostsFab: enablePostsFab,
        enableBackToTop: enableBackToTop,
        enableSubscriptions: enableSubscriptions,
        enableRefresh: enableRefresh,
        enableDismissRead: enableDismissRead,
        enableChangeSort: enableChangeSort,
        enableNewPost: enableNewPost,
        postFabEnableBackToTop: postFabEnableBackToTop,
        postFabEnableChangeSort: postFabEnableChangeSort,
        postFabEnableReplyToPost: postFabEnableReplyToPost,
        postFabEnableRefresh: postFabEnableRefresh,
        postFabEnableSearch: postFabEnableSearch,
        feedFabSinglePressAction: feedFabSinglePressAction,
        feedFabLongPressAction: feedFabLongPressAction,
        postFabSinglePressAction: postFabSinglePressAction,
        postFabLongPressAction: postFabLongPressAction,
        enableCommentNavigation: enableCommentNavigation,
        combineNavAndFab: combineNavAndFab,
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
