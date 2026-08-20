import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/domain.dart';

/// Represents a single post lookup with related metadata.
class PostDetail extends Equatable {
  /// The requested post.
  final ThunderPost post;

  /// Moderators for the post's community, when available.
  final List<ThunderUser> moderators;

  /// Cross-posted versions of the post, when available.
  final List<ThunderPost> crossPosts;

  const PostDetail({required this.post, this.moderators = const [], this.crossPosts = const []});

  @override
  List<Object?> get props => [post, moderators, crossPosts];
}
