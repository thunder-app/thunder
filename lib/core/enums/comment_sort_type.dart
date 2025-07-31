import 'package:lemmy_api_client/v3.dart' as lemmy;

enum CommentSortType {
  hot,
  top,
  new_,
  old,
  controversial,
}

extension CommentSortTypeMapping on CommentSortType {
  /// Converts a local CommentSortType to lemmy API CommentSortType
  lemmy.CommentSortType toLemmyType() {
    switch (this) {
      case CommentSortType.hot:
        return lemmy.CommentSortType.hot;
      case CommentSortType.top:
        return lemmy.CommentSortType.top;
      case CommentSortType.new_:
        return lemmy.CommentSortType.new_;
      case CommentSortType.old:
        return lemmy.CommentSortType.old;
      case CommentSortType.controversial:
        return lemmy.CommentSortType.controversial;
    }
  }

  /// Converts a lemmy API CommentSortType to local CommentSortType
  static CommentSortType? fromLemmyType(lemmy.CommentSortType? lemmyType) {
    switch (lemmyType) {
      case lemmy.CommentSortType.hot:
        return CommentSortType.hot;
      case lemmy.CommentSortType.top:
        return CommentSortType.top;
      case lemmy.CommentSortType.new_:
        return CommentSortType.new_;
      case lemmy.CommentSortType.old:
        return CommentSortType.old;
      case lemmy.CommentSortType.controversial:
        return CommentSortType.controversial;
      default:
        return null;
    }
  }
}
