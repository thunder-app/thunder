import 'package:thunder/src/features/comment/data/models/comment_node.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/features/comment/presentation/utils/comment_utils.dart';

/// Deterministic representation of API and UI comment ordering.
///
/// `api` represents the merged API order (first-seen order, latest values).
/// `uiComments` is the DFS-flattened tree order shown in the UI.
class CommentList {
  /// The comments returned by the API in API order for this page.
  final List<ThunderComment> api;

  /// The tree of comments in the UI.
  final CommentNode tree;

  const CommentList._({
    required this.api,
    required this.tree,
  });

  factory CommentList.empty() {
    return CommentList._(
      api: const [],
      tree: CommentNode(comment: null, replies: []),
    );
  }

  factory CommentList.fromApi(List<ThunderComment> comments) {
    final mergedComments = mergeComments(const [], comments);
    return CommentList._(
      api: mergedComments,
      tree: buildCommentTree(mergedComments),
    );
  }

  CommentList merge(List<ThunderComment> incomingComments) {
    if (incomingComments.isEmpty) return this;

    final mergedComments = mergeComments(api, incomingComments);
    return CommentList._(
      api: mergedComments,
      tree: buildCommentTree(mergedComments),
    );
  }

  List<CommentNode> get comments => tree.flatten();

  List<int> get apiCommentIds => List<int>.unmodifiable(api.map((comment) => comment.id));

  List<int> get uiCommentIds => List<int>.unmodifiable(comments.map((node) => node.comment?.id).whereType<int>());
}
