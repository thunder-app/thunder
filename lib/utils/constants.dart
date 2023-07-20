import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';

const PostListingType DEFAULT_LISTING_TYPE = PostListingType.all;

const SortType DEFAULT_SORT_TYPE = SortType.hot;

const SortType DEFAULT_SEARCH_SORT_TYPE = SortType.topYear;

const CommentSortType DEFAULT_COMMENT_SORT_TYPE = CommentSortType.top;

const int COMMENT_MAX_DEPTH = 8;

const NestedCommentIndicatorStyle DEFAULT_NESTED_COMMENT_INDICATOR_STYLE = NestedCommentIndicatorStyle.thick;

const NestedCommentIndicatorColor DEFAULT_NESTED_COMMENT_INDICATOR_COLOR = NestedCommentIndicatorColor.colorful;
