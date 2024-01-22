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

List<PostCardMetadataItem> DEFAULT_COMPACT_POST_CARD_METADATA = [
  PostCardMetadataItem.score,
  PostCardMetadataItem.commentCount,
  PostCardMetadataItem.dateTime,
  PostCardMetadataItem.url,
];

List<PostCardMetadataItem> DEFAULT_CARD_POST_CARD_METADATA = [
  PostCardMetadataItem.score,
  PostCardMetadataItem.commentCount,
  PostCardMetadataItem.dateTime,
  PostCardMetadataItem.url,
];
