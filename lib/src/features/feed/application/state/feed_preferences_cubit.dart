import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/config/config.dart';

part 'feed_preferences_state.dart';

/// Cubit for managing feed-related preferences. This includes settings for the feed list, post cards, and post body.
class FeedPreferencesCubit extends Cubit<FeedPreferencesState> {
  FeedPreferencesCubit({required PreferencesStore preferencesStore})
      : _preferencesStore = preferencesStore,
        super(const FeedPreferencesState()) {
    load();
  }

  final PreferencesStore _preferencesStore;

  /// Loads feed preferences from UserPreferences
  void load() {
    // Default Listing/Sort Settings
    FeedListType defaultFeedListType = DEFAULT_LISTING_TYPE;
    PostSortType defaultPostSortType = DEFAULT_POST_SORT_TYPE;

    try {
      defaultFeedListType = FeedListType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.defaultFeedListType) ?? DEFAULT_LISTING_TYPE.name);
      defaultPostSortType = PostSortType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.defaultFeedPostSortType) ?? DEFAULT_POST_SORT_TYPE.name);
    } catch (e) {
      defaultFeedListType = FeedListType.values.byName(DEFAULT_LISTING_TYPE.name);
      defaultPostSortType = PostSortType.values.byName(DEFAULT_POST_SORT_TYPE.name);
    }

    // NSFW Settings
    final hideNsfwPosts = _preferencesStore.getLocalSetting(LocalSettings.hideNsfwPosts) ?? false;
    final hideNsfwPreviews = _preferencesStore.getLocalSetting(LocalSettings.hideNsfwPreviews) ?? true;

    // General Settings
    final markPostReadOnMediaView = _preferencesStore.getLocalSetting(LocalSettings.markPostAsReadOnMediaView) ?? false;
    final markPostReadOnScroll = _preferencesStore.getLocalSetting(LocalSettings.markPostAsReadOnScroll) ?? false;
    final showHiddenPosts = _preferencesStore.getLocalSetting(LocalSettings.showHiddenPosts) ?? false;
    final showExpandedTaglines = _preferencesStore.getLocalSetting(LocalSettings.showExpandedTaglines) ?? false;

    /// -------------------------- Feed Post Related Settings --------------------------
    // Compact Related Settings
    final useCompactView = _preferencesStore.getLocalSetting(LocalSettings.useCompactView) ?? false;
    final showPostCommunityFirst = _preferencesStore.getLocalSetting(LocalSettings.showPostCommunityFirst) ?? false;
    final showTitleFirst = _preferencesStore.getLocalSetting(LocalSettings.showPostTitleFirst) ?? false;
    final hideThumbnails = _preferencesStore.getLocalSetting(LocalSettings.hideThumbnails) ?? false;
    final showThumbnailPreviewOnRight = _preferencesStore.getLocalSetting(LocalSettings.showThumbnailPreviewOnRight) ?? false;
    final linkPostsUseCompactView = _preferencesStore.getLocalSetting(LocalSettings.linkPostsUseCompactView) ?? false;
    final pinnedPostsUseCompactView = _preferencesStore.getLocalSetting(LocalSettings.pinnedPostsUseCompactView) ?? true;
    final showTextPostIndicator = _preferencesStore.getLocalSetting(LocalSettings.showTextPostIndicator) ?? false;
    final tappableAuthorCommunity = _preferencesStore.getLocalSetting(LocalSettings.tappableAuthorCommunity) ?? false;

    // General Settings
    final showVoteActions = _preferencesStore.getLocalSetting(LocalSettings.showPostVoteActions) ?? true;
    final showSaveAction = _preferencesStore.getLocalSetting(LocalSettings.showPostSaveAction) ?? true;
    final showCommunityIcons = _preferencesStore.getLocalSetting(LocalSettings.showPostCommunityIcons) ?? false;
    final showFullHeightImages = _preferencesStore.getLocalSetting(LocalSettings.showPostFullHeightImages) ?? true;
    final showEdgeToEdgeImages = _preferencesStore.getLocalSetting(LocalSettings.showPostEdgeToEdgeImages) ?? false;
    final showTextContent = _preferencesStore.getLocalSetting(LocalSettings.showPostTextContentPreview) ?? false;
    final showPostAuthor = _preferencesStore.getLocalSetting(LocalSettings.showPostAuthor) ?? false;
    final postShowUserInstance = _preferencesStore.getLocalSetting(LocalSettings.postShowUserInstance) ?? false;
    final dimReadPosts = _preferencesStore.getLocalSetting(LocalSettings.dimReadPosts) ?? true;
    final showFullPostDate = _preferencesStore.getLocalSetting(LocalSettings.showFullPostDate) ?? false;
    final dateFormat = DateFormat(_preferencesStore.getLocalSetting(LocalSettings.dateFormat) ?? DateFormat.yMMMMd(Intl.systemLocale).add_jm().pattern);
    final feedCardDividerThickness = FeedCardDividerThickness.values.byName(_preferencesStore.getLocalSetting(LocalSettings.feedCardDividerThickness) ?? FeedCardDividerThickness.compact.name);
    final feedCardDividerColor = _preferencesStore.getLocalSetting(LocalSettings.feedCardDividerColor) != null ? Color(_preferencesStore.getLocalSetting(LocalSettings.feedCardDividerColor)!) : null;
    final compactPostCardMetadataItems =
        _preferencesStore.getLocalSetting<List<String>>(LocalSettings.compactPostCardMetadataItems)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_COMPACT_POST_CARD_METADATA;
    final cardPostCardMetadataItems =
        _preferencesStore.getLocalSetting<List<String>>(LocalSettings.cardPostCardMetadataItems)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_CARD_POST_CARD_METADATA;

    // Post body settings
    final showCrossPosts = _preferencesStore.getLocalSetting(LocalSettings.showCrossPosts) ?? true;
    final postBodyViewType = PostBodyViewType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.postBodyViewType) ?? PostBodyViewType.expanded.name);
    final postBodyShowUserInstance = _preferencesStore.getLocalSetting(LocalSettings.postBodyShowUserInstance) ?? false;
    final postBodyShowCommunityInstance = _preferencesStore.getLocalSetting(LocalSettings.postBodyShowCommunityInstance) ?? false;
    final postBodyShowCommunityAvatar = _preferencesStore.getLocalSetting(LocalSettings.postBodyShowCommunityAvatar) ?? false;

    final keywordFilters = (_preferencesStore.getLocalSetting(LocalSettings.keywordFilters) as List<dynamic>?)?.cast<String>().toList() ?? <String>[];

    emit(
      FeedPreferencesState(
        defaultFeedListType: defaultFeedListType,
        defaultPostSortType: defaultPostSortType,
        hideNsfwPosts: hideNsfwPosts,
        hideNsfwPreviews: hideNsfwPreviews,
        markPostReadOnMediaView: markPostReadOnMediaView,
        markPostReadOnScroll: markPostReadOnScroll,
        showHiddenPosts: showHiddenPosts,
        showExpandedTaglines: showExpandedTaglines,
        useCompactView: useCompactView,
        showTitleFirst: showTitleFirst,
        showPostCommunityFirst: showPostCommunityFirst,
        hideThumbnails: hideThumbnails,
        showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
        linkPostsUseCompactView: linkPostsUseCompactView,
        pinnedPostsUseCompactView: pinnedPostsUseCompactView,
        showTextPostIndicator: showTextPostIndicator,
        tappableAuthorCommunity: tappableAuthorCommunity,
        showVoteActions: showVoteActions,
        showSaveAction: showSaveAction,
        showCommunityIcons: showCommunityIcons,
        showFullHeightImages: showFullHeightImages,
        showEdgeToEdgeImages: showEdgeToEdgeImages,
        showTextContent: showTextContent,
        showPostAuthor: showPostAuthor,
        postShowUserInstance: postShowUserInstance,
        dimReadPosts: dimReadPosts,
        showFullPostDate: showFullPostDate,
        dateFormat: dateFormat,
        feedCardDividerThickness: feedCardDividerThickness,
        feedCardDividerColor: feedCardDividerColor,
        compactPostCardMetadataItems: compactPostCardMetadataItems,
        cardPostCardMetadataItems: cardPostCardMetadataItems,
        showCrossPosts: showCrossPosts,
        postBodyViewType: postBodyViewType,
        postBodyShowUserInstance: postBodyShowUserInstance,
        postBodyShowCommunityInstance: postBodyShowCommunityInstance,
        postBodyShowCommunityAvatar: postBodyShowCommunityAvatar,
        keywordFilters: keywordFilters,
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
