class CommunityAggregates {
  final int communityId;

  final int subscribers;

  final int posts;

  final int comments;

  final DateTime published;

  final int usersActiveDay;

  final int usersActiveWeek;

  final int usersActiveMonth;

  final int usersActiveHalfYear;

  final int? subscribersLocal;

  const CommunityAggregates({
    required this.communityId, // v0.18.0
    required this.subscribers, // v0.18.0
    required this.posts, // v0.18.0
    required this.comments, // v0.18.0
    required this.published, // v0.18.0
    required this.usersActiveDay, // v0.18.0
    required this.usersActiveWeek, // v0.18.0
    required this.usersActiveMonth, // v0.18.0
    required this.usersActiveHalfYear, // v0.18.0
    this.subscribersLocal, // v0.19.4 (required)
  });
}
