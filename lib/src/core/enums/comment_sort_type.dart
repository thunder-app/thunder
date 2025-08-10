import 'package:lemmy_api_client/v3.dart' as lemmy;

import 'package:thunder/src/core/enums/threadiverse_platform.dart';

enum CommentSortType {
  hot('Hot'),
  top('Top'),
  new_('New'),
  old('Old'),
  controversial('Controversial', platform: ThreadiversePlatform.lemmy);

  /// The value of the sort type for the API.
  final String value;

  /// The platform this sort type is used on. If null, it is used on all platforms.
  final ThreadiversePlatform? platform;

  const CommentSortType(this.value, {this.platform});
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
