import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/models/models.dart';

class ThunderComment {
  /// The Lemmy API model for the comment.
  final Comment _comment;

  /// The Lemmy API model for the comment view.
  final CommentView? _commentView;

  ThunderComment({required Comment comment, CommentView? commentView})
      : _comment = comment,
        _commentView = commentView;

  /// Creates a new instance of [ThunderComment] with the given fields replaced with the new values.
  ThunderComment copyWith({
    Comment? comment,
    CommentView? commentView,
  }) {
    return ThunderComment(
      comment: comment ?? _comment,
      commentView: commentView ?? _commentView,
    );
  }

  /// The internal comment model. ONLY use this in special cases where the raw model is required.
  Comment get internalComment => _comment;

  /// The internal comment view model. ONLY use this in special cases where the raw model is required.
  CommentView? get internalCommentView => _commentView;

  /// The ID of the comment
  int get id => _comment.id;

  /// The ID of the post
  int get postId => _comment.postId;

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

  /// Whether the comment is removed
  bool get removed => _comment.removed;

  /// Whether the comment is deleted
  bool get deleted => _comment.deleted;

  /// The language ID of the comment
  int get languageId => _comment.languageId;

  /// The number of child comments
  int? get childCount => _commentView?.counts.childCount;

  /// Whether the creator of the comment is a moderator
  bool get creatorIsModerator => _commentView?.creatorIsModerator ?? false;

  /// Whether the creator of the comment is an admin
  bool get creatorIsAdmin => _commentView?.creatorIsAdmin ?? false;

  /// The URL of the comment
  String get url => _comment.apId;

  /// The community of the comment
  ThunderCommunity? get community => _commentView?.community != null ? ThunderCommunity(_commentView!.community) : null;

  /// The post of the comment
  ThunderPost? get post => _commentView?.post != null ? ThunderPost(_commentView!.post) : null;

  /// Whether the creator of the comment is banned from the community
  bool get creatorBannedFromCommunity => _commentView?.creatorBannedFromCommunity ?? false;
}
