import 'package:lemmy_api_client/v3.dart';

/// A node representing a single comment. This node can be part of a [CommentNode] tree.
///
/// The root node is defined by having a null [commentView]
class CommentNode {
  /// The comment information associated with this node. If this is the root node, this will be null
  final CommentView? commentView;

  /// The replies to this comment
  final List<CommentNode> replies;

  /// Gets the depth/level of the comment in the tree. A depth of 0 indicates a root comment.
  /// The [commentView.comment.path] is a dot-separated string of comment ids starting from 0 (post). For example: `0.103315`
  int get depth {
    if (commentView == null) return 0;

    List<String> pathSegments = commentView!.comment.path.split('.');
    int depth = pathSegments.length > 2 ? pathSegments.length - 2 : 0;

    return depth;
  }

  /// Gets the total number of replies
  get totalReplies => replies.length;

  CommentNode({this.commentView, this.replies = const []});

  /// Adds a reply to this comment node
  /// There is a constraint where the comment [id] must be unique. If there exists a comment that has the same [id], we will replace it with the new comment.
  void addReply(CommentNode reply) {
    // Add the comment only if theres no other comment with the same id
    int existingCommentNodeIndex = replies.indexWhere((node) => node.commentView?.comment.id == reply.commentView?.comment.id);

    if (existingCommentNodeIndex != -1) {
      // Replace the comment with the new comment
      replies[existingCommentNodeIndex] = reply;
      return;
    }

    replies.add(reply);
  }

  /// A static helper method to insert a comment node into the tree.
  /// If the parent node is not found, the comment node is added to the root node.
  static void insertCommentNode(CommentNode root, String parentId, CommentNode commentNode) {
    CommentNode? parent = findCommentNode(root, parentId);

    if (parent == null) {
      return root.addReply(commentNode);
    }

    parent.addReply(commentNode);
  }

  /// A static helper method to find a comment node in the tree given its [id]. The [id] comes from [comment.path]
  /// Returns null if the node is not found.
  static CommentNode? findCommentNode(CommentNode node, String id) {
    String? nodeId = node.commentView?.comment.path.split('.').last;

    // Return the current node if it's the target
    if (nodeId == id) return node;

    // Recursively search for the target node
    for (CommentNode child in node.replies) {
      CommentNode? found = findCommentNode(child, id);
      if (found != null) return found;
    }

    return null;
  }

  /// A static helper method to flatten a [CommentNode] tree. This flattens the tree using DFS.
  /// DFS allows us to preserve the order of the comments in the tree.
  ///
  /// Returns a list of flattened nodes.
  static List<CommentNode> flattenCommentTree(CommentNode? root) {
    List<CommentNode> flattenedCommentNodes = [];
    if (root == null) return flattenedCommentNodes;

    void flatten(CommentNode node) {
      if (node.commentView != null) flattenedCommentNodes.add(node);

      for (CommentNode child in node.replies) {
        flatten(child);
      }
    }

    flatten(root);
    return flattenedCommentNodes;
  }
}
