import 'package:thunder/core/models/models.dart';

class CommentViewTree {
  /// The comment information
  CommentView? commentView;

  /// The list of children for this comment
  List<CommentViewTree> replies;

  /// The depth of the comment. It starts from 0, which is a direct reply to the post
  int level;

  String datePostedOrEdited;

  CommentViewTree({
    this.datePostedOrEdited = "",
    this.commentView,
    this.replies = const [],
    this.level = 0,
  });
}
