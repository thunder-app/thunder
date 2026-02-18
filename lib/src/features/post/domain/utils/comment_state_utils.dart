import 'package:thunder/src/features/comment/comment.dart';

CommentNode clone(CommentNode root) {
  return CommentNode(
    comment: root.comment,
    replies: root.replies.map(clone).toList(),
  );
}

List<int> update({
  required List<int> current,
  required int commentId,
  required bool collapsed,
}) {
  final updated = current.toList();
  if (collapsed) {
    updated.add(commentId);
  } else {
    updated.remove(commentId);
  }
  return updated;
}
