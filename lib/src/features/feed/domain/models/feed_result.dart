import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/post/api.dart';

/// A class representing the result of a feed fetch.
class FeedResult {
  /// The posts in the feed.
  final List<ThunderPost> posts;

  /// The comments in the feed.
  final List<ThunderComment> comments;

  /// Whether the feed has reached the end of the posts.
  final bool hasReachedPostsEnd;

  /// Whether the feed has reached the end of the comments.
  final bool hasReachedCommentsEnd;

  /// The cursor for the next page of the feed.
  final String? cursor;

  const FeedResult({
    required this.posts,
    required this.comments,
    required this.hasReachedPostsEnd,
    required this.hasReachedCommentsEnd,
    required this.cursor,
  });
}
