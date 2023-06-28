import 'package:lemmy_api_client/v3.dart';

class CommentViewTree {
  CommentView? comment;
  List<CommentViewTree> replies;

  CommentViewTree({
    this.comment,
    this.replies = const [],
  });
}
