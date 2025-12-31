import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/feed_card_divider_thickness.dart';
import 'package:thunder/src/core/enums/post_body_view_type.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/features/post/post.dart';

part 'feed_preferences_state.dart';

/// Cubit for managing feed-related preferences. This includes settings for the feed list, post cards, and post body.
class FeedPreferencesCubit extends Cubit<FeedPreferencesState> {
  FeedPreferencesCubit() : super(const FeedPreferencesState()) {
    load();
  }

  /// Loads feed preferences from UserPreferences
  void load() {
    // Default Listing/Sort Settings
    FeedListType defaultFeedListType = DEFAULT_LISTING_TYPE;
    PostSortType defaultPostSortType = DEFAULT_POST_SORT_TYPE;

    try {
      defaultFeedListType = FeedListType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultFeedListType) ?? DEFAULT_LISTING_TYPE.name);
      defaultPostSortType = PostSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultFeedPostSortType) ?? DEFAULT_POST_SORT_TYPE.name);
    } catch (e) {
      defaultFeedListType = FeedListType.values.byName(DEFAULT_LISTING_TYPE.name);
      defaultPostSortType = PostSortType.values.byName(DEFAULT_POST_SORT_TYPE.name);
    }

    // NSFW Settings
    final hideNsfwPosts = UserPreferences.getLocalSetting(LocalSettings.hideNsfwPosts) ?? false;
    final hideNsfwPreviews = UserPreferences.getLocalSetting(LocalSettings.hideNsfwPreviews) ?? true;

    // General Settings
    final markPostReadOnMediaView = UserPreferences.getLocalSetting(LocalSettings.markPostAsReadOnMediaView) ?? false;
    final markPostReadOnScroll = UserPreferences.getLocalSetting(LocalSettings.markPostAsReadOnScroll) ?? false;
    final showHiddenPosts = UserPreferences.getLocalSetting(LocalSettings.showHiddenPosts) ?? false;
    final showExpandedTaglines = UserPreferences.getLocalSetting(LocalSettings.showExpandedTaglines) ?? false;

    /// -------------------------- Feed Post Related Settings --------------------------
    // Compact Related Settings
    final useCompactView = UserPreferences.getLocalSetting(LocalSettings.useCompactView) ?? false;
    final showTitleFirst = UserPreferences.getLocalSetting(LocalSettings.showPostTitleFirst) ?? false;
    final hideThumbnails = UserPreferences.getLocalSetting(LocalSettings.hideThumbnails) ?? false;
    final showThumbnailPreviewOnRight = UserPreferences.getLocalSetting(LocalSettings.showThumbnailPreviewOnRight) ?? false;
    final showTextPostIndicator = UserPreferences.getLocalSetting(LocalSettings.showTextPostIndicator) ?? false;
    final tappableAuthorCommunity = UserPreferences.getLocalSetting(LocalSettings.tappableAuthorCommunity) ?? false;

    // General Settings
    final showVoteActions = UserPreferences.getLocalSetting(LocalSettings.showPostVoteActions) ?? true;
    final showSaveAction = UserPreferences.getLocalSetting(LocalSettings.showPostSaveAction) ?? true;
    final showCommunityIcons = UserPreferences.getLocalSetting(LocalSettings.showPostCommunityIcons) ?? false;
    final showFullHeightImages = UserPreferences.getLocalSetting(LocalSettings.showPostFullHeightImages) ?? true;
    final showEdgeToEdgeImages = UserPreferences.getLocalSetting(LocalSettings.showPostEdgeToEdgeImages) ?? false;
    final showTextContent = UserPreferences.getLocalSetting(LocalSettings.showPostTextContentPreview) ?? false;
    final showPostAuthor = UserPreferences.getLocalSetting(LocalSettings.showPostAuthor) ?? false;
    final postShowUserInstance = UserPreferences.getLocalSetting(LocalSettings.postShowUserInstance) ?? false;
    final dimReadPosts = UserPreferences.getLocalSetting(LocalSettings.dimReadPosts) ?? true;
    final showFullPostDate = UserPreferences.getLocalSetting(LocalSettings.showFullPostDate) ?? false;
    final dateFormat = DateFormat(UserPreferences.getLocalSetting(LocalSettings.dateFormat) ?? DateFormat.yMMMMd(Intl.systemLocale).add_jm().pattern);
    final feedCardDividerThickness = FeedCardDividerThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.feedCardDividerThickness) ?? FeedCardDividerThickness.compact.name);
    final feedCardDividerColor = UserPreferences.getLocalSetting(LocalSettings.feedCardDividerColor) != null ? Color(UserPreferences.getLocalSetting(LocalSettings.feedCardDividerColor)!) : null;
    final compactPostCardMetadataItems =
        UserPreferences.getLocalSetting<List<String>>(LocalSettings.compactPostCardMetadataItems)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_COMPACT_POST_CARD_METADATA;
    final cardPostCardMetadataItems =
        UserPreferences.getLocalSetting<List<String>>(LocalSettings.cardPostCardMetadataItems)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_CARD_POST_CARD_METADATA;

    // Post body settings
    final showCrossPosts = UserPreferences.getLocalSetting(LocalSettings.showCrossPosts) ?? true;
    final postBodyViewType = PostBodyViewType.values.byName(UserPreferences.getLocalSetting(LocalSettings.postBodyViewType) ?? PostBodyViewType.expanded.name);
    final postBodyShowUserInstance = UserPreferences.getLocalSetting(LocalSettings.postBodyShowUserInstance) ?? false;
    final postBodyShowCommunityInstance = UserPreferences.getLocalSetting(LocalSettings.postBodyShowCommunityInstance) ?? false;
    final postBodyShowCommunityAvatar = UserPreferences.getLocalSetting(LocalSettings.postBodyShowCommunityAvatar) ?? false;

    final keywordFilters = (UserPreferences.getLocalSetting(LocalSettings.keywordFilters) as List<dynamic>?)?.cast<String>().toList() ?? <String>[];

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
        hideThumbnails: hideThumbnails,
        showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
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
