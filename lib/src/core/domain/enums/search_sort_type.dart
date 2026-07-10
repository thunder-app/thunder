import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

enum SearchSortType {
  new_('New'),
  old('Old'),
  controversial('Controversial'),
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
  topAll('TopAll');

  /// The value of the sort type for the API.
  final String value;

  /// The platform this sort type is used on. If null, it is used on all platforms.
  final ThreadiversePlatform? platform = null;

  const SearchSortType(this.value);
}
