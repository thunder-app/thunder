import 'package:thunder/src/features/comment/comment.dart';

/// Creates a deep copy of a comment tree while preserving comment values.
CommentNode clone(CommentNode root) {
  return CommentNode(
    comment: root.comment,
    replies: root.replies.map(clone).toList(),
  );
}

/// Returns a new collapsed-comment set after applying a single collapse toggle.
Set<int> update({
  required Set<int> current,
  required int commentId,
  required bool collapsed,
}) {
  if (collapsed == current.contains(commentId)) return current;

  final updated = current.toSet();
  if (collapsed) {
    updated.add(commentId);
  } else {
    updated.remove(commentId);
  }
  return updated;
}

/// Returns a copy of [root] with the node matching [comment] replaced.
CommentNode replaceComment(CommentNode root, ThunderComment comment) {
  return CommentNode(
    comment: root.comment?.id == comment.id ? comment : root.comment,
    replies: root.replies.map((reply) => replaceComment(reply, comment)).toList(),
  );
}

/// Computes comments hidden by collapsed ancestors.
Set<int> hiddenCommentIds({
  required Iterable<CommentNode> comments,
  required Set<int> collapsedCommentIds,
}) {
  if (collapsedCommentIds.isEmpty) return const <int>{};

  final hiddenIds = <int>{};
  for (final node in comments) {
    final comment = node.comment;
    if (comment == null) continue;
    if (isHiddenByCollapsedAncestor(comment.path, comment.id, collapsedCommentIds)) {
      hiddenIds.add(comment.id);
    }
  }
  return hiddenIds;
}

/// Whether [commentId] has a collapsed ancestor in its dot-separated path.
bool isHiddenByCollapsedAncestor(String path, int commentId, Set<int> collapsedCommentIds) {
  for (final ancestorId in _ancestorIds(path)) {
    if (ancestorId != commentId && collapsedCommentIds.contains(ancestorId)) {
      return true;
    }
  }
  return false;
}

Iterable<int> _ancestorIds(String path) sync* {
  for (final segment in path.split('.')) {
    final id = int.tryParse(segment);
    if (id != null) yield id;
  }
}
