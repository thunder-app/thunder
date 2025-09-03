import 'package:thunder/src/features/comment/comment.dart';

/// A node representing a single comment. This node can be part of a [CommentNode] tree.
///
/// The root node is defined by having a null [comment]
class CommentNode {
  /// The comment information associated with this node. If this is the root node, this will be null
  final ThunderComment? comment;

  /// The replies to this comment
  final List<CommentNode> replies;

  /// Gets the depth/level of the comment in the tree. A depth of 0 indicates a root comment.
  /// The [comment.path] is a dot-separated string of comment ids starting from 0 (post). For example: `0.103315`
  int get depth {
    if (comment == null) return 0;

    List<String> pathSegments = comment!.path.split('.');
    int depth = pathSegments.length > 2 ? pathSegments.length - 2 : 0;

    return depth;
  }

  CommentNode({this.comment, List<CommentNode>? replies}) : replies = replies ?? [];

  /// Inserts a reply to this comment node. There is a constraint where the comment [id] must be unique.
  /// If there exists a comment that has the same [id], we will replace it with the new comment.
  void insert(CommentNode reply) {
    if (reply.comment?.id == comment?.id) return;

    // Add the comment only if theres no other comment with the same id
    int existingCommentNodeIndex = replies.indexWhere((node) => node.comment?.id == reply.comment?.id);

    if (existingCommentNodeIndex != -1) {
      // Replace the comment with the new comment
      replies[existingCommentNodeIndex] = reply;
      return;
    }

    replies.add(reply);
  }

  /// Searches the tree for a comment node with the given [id].
  CommentNode? search(int id) {
    // Return the current node if we are searching for the root node. The root node is defined by having a null [comment].
    if (id == 0 && comment == null) {
      return this;
    }

    // Return the current node if it matches the [id].
    if (id == comment?.id) {
      return this;
    }

    // Recursively search for the target node
    for (final child in replies) {
      final node = child.search(id);
      if (node != null) return node;
    }

    return null;
  }

  /// Flattens the tree into a list of nodes using DFS.
  /// Using DFS allows us to preserve the order of the comments in the tree.
  List<CommentNode> flatten() {
    final result = <CommentNode>[];

    void dfs(CommentNode node) {
      if (node.comment != null) result.add(node); // visit the node

      if (node.replies.isNotEmpty) {
        for (final child in node.replies) {
          dfs(child); // recurse on children
        }
      }
    }

    dfs(this);
    return result;
  }
}
