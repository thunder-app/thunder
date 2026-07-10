import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/models/thunder_comment.dart';

/// Represents a page of comments returned from an API request.
class CommentPage extends Equatable {
  /// The comments returned by the API in API order for this page.
  final List<ThunderComment> comments;

  /// The cursor/page token for the next page, if available.
  final String? nextPage;

  const CommentPage({
    required this.comments,
    this.nextPage,
  });

  @override
  List<Object?> get props => [comments, nextPage];
}
