import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/feed/domain/enums/fab_action.dart';

part 'fab_preferences_state.dart';

/// Cubit for managing floating action button (FAB) preferences
class FabPreferencesCubit extends Cubit<FabPreferencesState> {
  FabPreferencesCubit({required PreferencesStore preferencesStore}) : _preferencesStore = preferencesStore, super(const FabPreferencesState()) {
    load();
  }

  final PreferencesStore _preferencesStore;

  /// Loads FAB preferences from UserPreferences
  void load() {
    final enableFeedsFab = _preferencesStore.getLocalSetting(LocalSettings.enableFeedsFab) ?? true;
    final enablePostsFab = _preferencesStore.getLocalSetting(LocalSettings.enablePostsFab) ?? true;

    final enableBackToTop = _preferencesStore.getLocalSetting(LocalSettings.enableBackToTop) ?? true;
    final enableSubscriptions = _preferencesStore.getLocalSetting(LocalSettings.enableSubscriptions) ?? true;
    final enableRefresh = _preferencesStore.getLocalSetting(LocalSettings.enableRefresh) ?? true;
    final enableDismissRead = _preferencesStore.getLocalSetting(LocalSettings.enableDismissRead) ?? true;
    final enableChangeSort = _preferencesStore.getLocalSetting(LocalSettings.enableChangeSort) ?? true;
    final enableNewPost = _preferencesStore.getLocalSetting(LocalSettings.enableNewPost) ?? true;

    final postFabEnableBackToTop = _preferencesStore.getLocalSetting(LocalSettings.postFabEnableBackToTop) ?? true;
    final postFabEnableChangeSort = _preferencesStore.getLocalSetting(LocalSettings.postFabEnableChangeSort) ?? true;
    final postFabEnableReplyToPost = _preferencesStore.getLocalSetting(LocalSettings.postFabEnableReplyToPost) ?? true;
    final postFabEnableRefresh = _preferencesStore.getLocalSetting(LocalSettings.postFabEnableRefresh) ?? true;
    final postFabEnableSearch = _preferencesStore.getLocalSetting(LocalSettings.postFabEnableSearch) ?? true;

    final feedFabSinglePressAction = FeedFabAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.feedFabSinglePressAction) ?? FeedFabAction.newPost.name);
    final feedFabLongPressAction = FeedFabAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.feedFabLongPressAction) ?? FeedFabAction.openFab.name);
    final postFabSinglePressAction = PostFabAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postFabSinglePressAction) ?? PostFabAction.replyToPost.name);
    final postFabLongPressAction = PostFabAction.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postFabLongPressAction) ?? PostFabAction.openFab.name);

    final enableCommentNavigation = _preferencesStore.getLocalSetting(LocalSettings.enableCommentNavigation) ?? true;
    final combineNavAndFab = _preferencesStore.getLocalSetting(LocalSettings.combineNavAndFab) ?? true;

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
