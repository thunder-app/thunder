import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';

/// A post or comment item in a combined content feed.
///
/// Use this when a screen can show posts and comments in the same list.
sealed class ThunderContentItem {
  const ThunderContentItem();
}

/// A combined-feed item that contains a post.
class ThunderPostItem extends ThunderContentItem {
  /// The post shown by this item.
  final ThunderPost post;

  const ThunderPostItem(this.post);
}

/// A combined-feed item that contains a comment.
class ThunderCommentItem extends ThunderContentItem {
  /// The comment shown by this item.
  final ThunderComment comment;

  const ThunderCommentItem(this.comment);
}
