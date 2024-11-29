// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';

const ListingType DEFAULT_LISTING_TYPE = ListingType.all;

const SortType DEFAULT_SORT_TYPE = SortType.hot;

const SortType DEFAULT_SEARCH_SORT_TYPE = SortType.topYear;

const CommentSortType DEFAULT_COMMENT_SORT_TYPE = CommentSortType.top;

const int COMMENT_MAX_DEPTH = 8;

const NestedCommentIndicatorStyle DEFAULT_NESTED_COMMENT_INDICATOR_STYLE = NestedCommentIndicatorStyle.thick;

const NestedCommentIndicatorColor DEFAULT_NESTED_COMMENT_INDICATOR_COLOR = NestedCommentIndicatorColor.colorful;

/// https://developer.android.com/reference/android/content/Intent#FLAG_ACTIVITY_NEW_TASK
const int ANDROID_INTENT_FLAG_ACTIVITY_NEW_TASK = 268435456;

const String ANDROID_INTENT_ACTION_VIEW = "android.intent.action.VIEW";

///  Post card metadata
const List<PostCardMetadataItem> DEFAULT_COMPACT_POST_CARD_METADATA = [
  PostCardMetadataItem.score,
  PostCardMetadataItem.commentCount,
  PostCardMetadataItem.dateTime,
  PostCardMetadataItem.url,
];

const List<PostCardMetadataItem> DEFAULT_CARD_POST_CARD_METADATA = [
  PostCardMetadataItem.score,
  PostCardMetadataItem.commentCount,
  PostCardMetadataItem.dateTime,
  PostCardMetadataItem.url,
];

///  Settings Pages
const String SETTINGS_GENERAL_PAGE = '/settings/general';
const String SETTINGS_FILTERS_PAGE = '/settings/filters';
const String SETTINGS_APPEARANCE_PAGE = '/settings/appearance';
const String SETTINGS_GESTURES_PAGE = '/settings/gestures';
const String SETTINGS_FAB_PAGE = '/settings/fab';
const String SETTINGS_ACCESSIBILITY_PAGE = '/settings/accessibility';
const String SETTINGS_ACCOUNT_PAGE = '/settings/account';
const String SETTINGS_USER_LABELS_PAGE = '/settings/user_labels';
const String SETTINGS_ABOUT_PAGE = '/settings/about';
const String SETTINGS_DEBUG_PAGE = '/settings/debug';
const String SETTINGS_APPEARANCE_POSTS_PAGE = '/settings/appearance/posts';
const String SETTINGS_APPEARANCE_COMMENTS_PAGE = '/settings/appearance/comments';
const String SETTINGS_APPEARANCE_THEMES_PAGE = '/settings/appearance/themes';

const String SETTINGS_VIDEO_PAGE = '/settings/video';

const String THUNDER_SERVER_URL = 'https://thunderapp.dev';

const Color DARK_THEME_BACKGROUND_COLOR = Color.fromARGB(255, 50, 50, 50);
const Color LIGHT_THEME_BACKGROUND_COLOR = Color.fromARGB(255, 242, 242, 242);
