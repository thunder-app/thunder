import 'package:lemmy_api_client/v3.dart';

class CommentViewTree {
  /// The comment information
  CommentView? commentView;

  /// The list of children for this comment
  List<CommentViewTree> replies;

  /// The depth of the comment. It starts from 0, which is a direct reply to the post
  int level;

  CommentViewTree({
    this.commentView,
    this.replies = const [],
    this.level = 0,
  });
}
