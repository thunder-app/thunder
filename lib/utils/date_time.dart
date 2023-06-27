/// Given an integer which represents the epoch time, format it to a given string based on the time that has passed since the specified epoch time.
///
/// The list of string representation -> meaning is as follows:
/// m - minute
/// h - hour
/// d - day
/// w - week
/// mo - month
/// y - year
String formatTimeToString({required String dateTime}) {
  DateTime date = DateTime.parse(dateTime);
  DateTime now = DateTime.now().toUtc();

  Duration difference = now.difference(date);

  int durationInMinutes = difference.inMinutes;
  int durationInHours = difference.inHours;
  int durationInDays = difference.inDays;
  double durationInWeeks = durationInDays / 7;
  double durationInMonths = durationInDays / 30.44;
  double durationInYears = durationInDays / 365.25;

  if (durationInMinutes < 60) {
    return '${durationInMinutes}m';
  } else if (durationInHours < 24) {
    return '${durationInHours}h';
  } else if (durationInWeeks < 1) {
    return '${durationInDays}d';
  } else if (durationInWeeks < 4) {
    return '${durationInWeeks.toStringAsFixed(0)}w';
  } else if (durationInMonths < 12) {
    return '${durationInMonths.toStringAsFixed(0)}mo';
  } else {
    return '${durationInYears.toStringAsFixed(0)}y';
  }
}
