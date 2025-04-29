import 'package:lemmy_api_client/v3.dart';

class ThunderComment {
  /// The Lemmy API model for the comment.
  final Comment _comment;

  /// The Lemmy API model for the comment view.
  final CommentView? _commentView;

  ThunderComment({required Comment comment, CommentView? commentView})
      : _comment = comment,
        _commentView = commentView;

  /// The ID of the comment
  int get id => _comment.id;

  /// The ID of the comment creator
  int? get creatorId => _commentView?.creator.id;

  /// The ID of the post creator
  int? get postCreatorId => _commentView?.post.creatorId;

  /// The path that resolves to this comment
  String get path => _comment.path;

  /// The content of the comment
  String get body => _comment.content;

  /// The creator of the comment
  Person? get creator => _commentView?.creator;

  /// The date and time that the comment was published
  DateTime get published => _comment.published;

  /// The date and time that the comment was last updated
  DateTime? get updated => _comment.updated;

  /// The score of the comment (upvotes - downvotes)
  int? get score => _commentView?.counts.score;

  /// The number of upvotes on the comment
  int? get upvotes => _commentView?.counts.upvotes;

  /// The number of downvotes on the comment
  int? get downvotes => _commentView?.counts.downvotes;

  /// The vote status of the current user on this comment
  int? get myVote => _commentView?.myVote;

  /// Whether the comment is saved by the current user
  bool? get saved => _commentView?.saved;

  /// The number of child comments
  int? get childCount => _commentView?.counts.childCount;

  /// Whether the creator of the comment is a moderator
  bool get creatorIsModerator => _commentView?.creatorIsModerator ?? false;

  /// Whether the creator of the comment is an admin
  bool get creatorIsAdmin => _commentView?.creatorIsAdmin ?? false;
}
