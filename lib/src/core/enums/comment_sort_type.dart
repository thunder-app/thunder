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
