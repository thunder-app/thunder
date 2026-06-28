import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Represents a page of posts returned from an API request.
class PostFeedPage extends Equatable {
  /// The posts returned by the API in API order for this page.
  final List<ThunderPost> posts;

  /// The cursor/page token for the next page, if available.
  final String? nextPage;

  const PostFeedPage({
    required this.posts,
    this.nextPage,
  });

  @override
  List<Object?> get props => [posts, nextPage];
}
