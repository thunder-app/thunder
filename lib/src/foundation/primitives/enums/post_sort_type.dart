import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';

enum PostSortType {
  active('Active'),
  hot('Hot'),
  new_('New'),
  topHour('TopHour'),
  topSixHour('TopSixHour'),
  topTwelveHour('TopTwelveHour'),
  topDay('TopDay'),
  topWeek('TopWeek'),
  topMonth('TopMonth'),
  topThreeMonths('TopThreeMonths'),
  topSixMonths('TopSixMonths'),
  topNineMonths('TopNineMonths'),
  topYear('TopYear'),
  topAll('TopAll'),
  scaled('Scaled'),
  old('Old', platform: ThreadiversePlatform.lemmy),
  mostComments('MostComments', platform: ThreadiversePlatform.lemmy),
  newComments('NewComments', platform: ThreadiversePlatform.lemmy),
  controversial('Controversial', platform: ThreadiversePlatform.lemmy);

  /// The value of the sort type for the API.
  final String value;

  /// The platform this sort type is used on. If null, it is used on all platforms.
  final ThreadiversePlatform? platform;

  const PostSortType(this.value, {this.platform});
}
