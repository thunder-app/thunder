import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:path/path.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/utils/constants.dart';

part 'thunder_event.dart';
part 'thunder_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class ThunderBloc extends Bloc<ThunderEvent, ThunderState> {
  ThunderBloc() : super(const ThunderState()) {
    on<InitializeAppEvent>(
      _initializeAppEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UserPreferencesChangeEvent>(
      _userPreferencesChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _initializeAppEvent(InitializeAppEvent event, Emitter<ThunderState> emit) async {
    try {
      // Load up database
      final database = await openDatabase(
        join(await getDatabasesPath(), 'thunder.db'),
        version: 1,
      );

      // Check for any updates from GitHub
      Version version = await fetchVersion();

      add(UserPreferencesChangeEvent());
      emit(state.copyWith(status: ThunderStatus.success, database: database, version: version));
    } catch (e, s) {
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.refreshing));

      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

      // Feed Settings
      bool useCompactView = prefs.getBool('setting_general_use_compact_view') ?? false;
      bool showTitleFirst = prefs.getBool('setting_general_show_title_first') ?? false;

      PostListingType defaultPostListingType = DEFAULT_LISTING_TYPE;
      SortType defaultSortType = DEFAULT_SORT_TYPE;
      try {
        defaultPostListingType = PostListingType.values.byName(prefs.getString("setting_general_default_listing_type") ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(prefs.getString("setting_general_default_sort_type") ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultPostListingType = PostListingType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      // Post Settings
      bool collapseParentCommentOnGesture = prefs.getBool('setting_comments_collapse_parent_comment_on_gesture') ?? true;
      bool disableSwipeActionsOnPost = prefs.getBool('setting_post_disable_swipe_actions') ?? false;
      bool showThumbnailPreviewOnRight = prefs.getBool('setting_compact_show_thumbnail_on_right') ?? false;
      bool showVoteActions = prefs.getBool('setting_general_show_vote_actions') ?? true;
      bool showSaveAction = prefs.getBool('setting_general_show_save_action') ?? true;
      bool showFullHeightImages = prefs.getBool('setting_general_show_full_height_images') ?? false;
      bool showEdgeToEdgeImages = prefs.getBool('setting_general_show_edge_to_edge_images') ?? false;
      bool showTextContent = prefs.getBool('setting_general_show_text_content') ?? false;
      bool hideNsfwPreviews = prefs.getBool('setting_general_hide_nsfw_previews') ?? true;
      bool useDisplayNames = prefs.getBool('setting_use_display_names_for_users') ?? true;
      bool bottomNavBarSwipeGestures = prefs.getBool('setting_general_enable_swipe_gestures') ?? true;
      bool bottomNavBarDoubleTapGestures = prefs.getBool('setting_general_enable_doubletap_gestures') ?? false;
      bool tabletMode = prefs.getBool('setting_post_tablet_mode') ?? false;
      bool markPostReadOnMediaView = prefs.getBool('setting_general_mark_post_read_on_media_view') ?? false;
      CommentSortType defaultCommentSortType = CommentSortType.values.byName(prefs.getString("setting_post_default_comment_sort_type") ?? DEFAULT_COMMENT_SORT_TYPE.name);

      // Links
      bool openInExternalBrowser = prefs.getBool('setting_links_open_in_external_browser') ?? false;
      bool showLinkPreviews = prefs.getBool('setting_general_show_link_previews') ?? true;

      // Notification Settings
      bool showInAppUpdateNotification = prefs.getBool('setting_notifications_show_inapp_update') ?? true;

      // Post Gestures
      bool enablePostGestures = prefs.getBool('setting_gesture_enable_post_gestures') ?? true;
      SwipeAction leftPrimaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_primary_gesture') ?? SwipeAction.upvote.name);
      SwipeAction leftSecondaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_secondary_gesture') ?? SwipeAction.downvote.name);
      SwipeAction rightPrimaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_primary_gesture') ?? SwipeAction.reply.name);
      SwipeAction rightSecondaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_secondary_gesture') ?? SwipeAction.save.name);

      // Comment Gestures
      bool enableCommentGestures = prefs.getBool('setting_gesture_enable_comment_gestures') ?? true;
      SwipeAction leftPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_left_primary_gesture') ?? SwipeAction.upvote.name);
      SwipeAction leftSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_left_secondary_gesture') ?? SwipeAction.downvote.name);
      SwipeAction rightPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_right_primary_gesture') ?? SwipeAction.reply.name);
      SwipeAction rightSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_right_secondary_gesture') ?? SwipeAction.save.name);

      // Theme Settings
      ThemeType themeType = ThemeType.values[prefs.getInt('setting_theme_app_theme') ?? ThemeType.system.index];
      bool useMaterialYouTheme = prefs.getBool('setting_theme_use_material_you') ?? false;

      // Font scale
      FontScale titleFontSizeScale = FontScale.values.byName(prefs.getString('setting_theme_title_font_size_scale') ?? FontScale.base.name);
      FontScale contentFontSizeScale = FontScale.values.byName(prefs.getString('setting_theme_content_font_size_scale') ?? FontScale.base.name);

      return emit(state.copyWith(
        status: ThunderStatus.success,
        useCompactView: useCompactView,
        showTitleFirst: showTitleFirst,
        defaultPostListingType: defaultPostListingType,
        defaultSortType: defaultSortType,
        defaultCommentSortType: defaultCommentSortType,
        collapseParentCommentOnGesture: collapseParentCommentOnGesture,
        disableSwipeActionsOnPost: disableSwipeActionsOnPost,
        showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
        showVoteActions: showVoteActions,
        showSaveAction: showSaveAction,
        showFullHeightImages: showFullHeightImages,
        showEdgeToEdgeImages: showEdgeToEdgeImages,
        tabletMode: tabletMode,
        showTextContent: showTextContent,
        hideNsfwPreviews: hideNsfwPreviews,
        useDisplayNames: useDisplayNames,
        bottomNavBarSwipeGestures: bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures,
        markPostReadOnMediaView: markPostReadOnMediaView,
        openInExternalBrowser: openInExternalBrowser,
        showLinkPreviews: showLinkPreviews,
        showInAppUpdateNotification: showInAppUpdateNotification,
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
        themeType: themeType,
        useMaterialYouTheme: useMaterialYouTheme,
        titleFontSizeScale: titleFontSizeScale,
        contentFontSizeScale: contentFontSizeScale,
      ));
    } catch (e, s) {
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }
}
