import 'package:lemmy_api_client/v3.dart';

class CommentViewTree {
  CommentView? comment;
  List<CommentViewTree> replies;
  int level; // Level starts from 0, which is a direct reply to the post

  CommentViewTree({
    this.comment,
    this.replies = const [],
    this.level = 0,
  });
}
