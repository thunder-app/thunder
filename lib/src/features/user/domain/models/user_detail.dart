import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/domain.dart';

/// Represents a user profile lookup with optional content pages.
class UserDetail extends Equatable {
  /// The requested user.
  final ThunderUser user;

  /// Site metadata associated with the user lookup, when available.
  final ThunderSite? site;

  /// Posts authored by the user for the requested page.
  final List<ThunderPost> posts;

  /// Comments authored by the user for the requested page.
  final List<ThunderComment> comments;

  /// Communities the user moderates.
  final List<ThunderCommunity> moderates;

  /// The cursor/page token for the next page, if available.
  final String? nextPage;

  const UserDetail({required this.user, this.site, this.posts = const [], this.comments = const [], this.moderates = const [], this.nextPage});

  @override
  List<Object?> get props => [user, site, posts, comments, moderates, nextPage];
}
