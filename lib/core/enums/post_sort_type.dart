import 'package:lemmy_api_client/v3.dart' as lemmy;

enum PostSortType {
  active('Active'),
  hot('Hot'),
  new_('New'),
  old('Old'),
  topDay('TopDay'),
  topWeek('TopWeek'),
  topMonth('TopMonth'),
  topYear('TopYear'),
  topAll('TopAll'),
  mostComments('MostComments'),
  newComments('NewComments'),
  topHour('TopHour'),
  topSixHour('TopSixHour'),
  topTwelveHour('TopTwelveHour'),
  topThreeMonths('TopThreeMonths'),
  topSixMonths('TopSixMonths'),
  topNineMonths('TopNineMonths'),
  controversial('Controversial'),
  scaled('Scaled');

  final String value;

  const PostSortType(this.value);
}

extension PostSortTypeMapping on PostSortType {
  /// Converts a local PostSortType to lemmy API SortType
  lemmy.SortType toLemmyType() {
    switch (this) {
      case PostSortType.active:
        return lemmy.SortType.active;
      case PostSortType.hot:
        return lemmy.SortType.hot;
      case PostSortType.new_:
        return lemmy.SortType.new_;
      case PostSortType.old:
        return lemmy.SortType.old;
      case PostSortType.topDay:
        return lemmy.SortType.topDay;
      case PostSortType.topWeek:
        return lemmy.SortType.topWeek;
      case PostSortType.topMonth:
        return lemmy.SortType.topMonth;
      case PostSortType.topYear:
        return lemmy.SortType.topYear;
      case PostSortType.topAll:
        return lemmy.SortType.topAll;
      case PostSortType.mostComments:
        return lemmy.SortType.mostComments;
      case PostSortType.newComments:
        return lemmy.SortType.newComments;
      case PostSortType.topHour:
        return lemmy.SortType.topHour;
      case PostSortType.topSixHour:
        return lemmy.SortType.topSixHour;
      case PostSortType.topTwelveHour:
        return lemmy.SortType.topTwelveHour;
      case PostSortType.topThreeMonths:
        return lemmy.SortType.topThreeMonths;
      case PostSortType.topSixMonths:
        return lemmy.SortType.topSixMonths;
      case PostSortType.topNineMonths:
        return lemmy.SortType.topNineMonths;
      case PostSortType.controversial:
        return lemmy.SortType.controversial;
      case PostSortType.scaled:
        return lemmy.SortType.scaled;
    }
  }

  /// Converts a lemmy API SortType to local PostSortType
  static PostSortType? fromLemmyType(lemmy.SortType? lemmyType) {
    switch (lemmyType) {
      case lemmy.SortType.active:
        return PostSortType.active;
      case lemmy.SortType.hot:
        return PostSortType.hot;
      case lemmy.SortType.new_:
        return PostSortType.new_;
      case lemmy.SortType.old:
        return PostSortType.old;
      case lemmy.SortType.topDay:
        return PostSortType.topDay;
      case lemmy.SortType.topWeek:
        return PostSortType.topWeek;
      case lemmy.SortType.topMonth:
        return PostSortType.topMonth;
      case lemmy.SortType.topYear:
        return PostSortType.topYear;
      case lemmy.SortType.topAll:
        return PostSortType.topAll;
      case lemmy.SortType.mostComments:
        return PostSortType.mostComments;
      case lemmy.SortType.newComments:
        return PostSortType.newComments;
      case lemmy.SortType.topHour:
        return PostSortType.topHour;
      case lemmy.SortType.topSixHour:
        return PostSortType.topSixHour;
      case lemmy.SortType.topTwelveHour:
        return PostSortType.topTwelveHour;
      case lemmy.SortType.topThreeMonths:
        return PostSortType.topThreeMonths;
      case lemmy.SortType.topSixMonths:
        return PostSortType.topSixMonths;
      case lemmy.SortType.topNineMonths:
        return PostSortType.topNineMonths;
      case lemmy.SortType.controversial:
        return PostSortType.controversial;
      case lemmy.SortType.scaled:
        return PostSortType.scaled;
      default:
        return null;
    }
  }
}
