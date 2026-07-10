import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

enum FeedListType {
  all('All'),
  local('Local'),
  subscribed('Subscribed'),
  moderatorView('ModeratorView'),
  moderating('Moderating', platform: ThreadiversePlatform.piefed),
  popular('Popular', platform: ThreadiversePlatform.piefed);

  /// The value of the enum. This corresponds to the value used in the request.
  final String value;

  /// The platform this feed list type is used on. If null, it is used on all platforms.
  final ThreadiversePlatform? platform;

  const FeedListType(this.value, {this.platform});
}
