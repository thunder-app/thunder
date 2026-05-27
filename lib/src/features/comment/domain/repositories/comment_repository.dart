import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/comment/comment.dart';

/// Interface for a comment repository
abstract class CommentRepository {
  /// Fetches a comment by its ID
  Future<ThunderComment> getComment(int commentId);

  /// Fetches comments for a post
  Future<CommentPage> getComments({
    required int postId,
    int? parentId,
    int? page,
    String? cursor,
    CommentSortType? commentSortType,
    int? maxDepth,
    int? limit,
    int? communityId,
  });

  /// Creates a new comment
  Future<ThunderComment> create({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  });

  /// Edits an existing comment
  Future<ThunderComment> edit({
    required int commentId,
    required String content,
    int? languageId,
  });

  /// Votes on a comment
  Future<ThunderComment> vote(ThunderComment comment, int score);

  /// Saves or unsaves a comment
  Future<ThunderComment> save(ThunderComment comment, bool save);

  /// Deletes a comment
  Future<ThunderComment> delete(ThunderComment comment, bool deleted);

  /// Reports a comment
  Future<void> report(int commentId, String reason);

  /// Creates a placeholder comment from the given parameters. This is mainly used to display a preview of the comment
  /// with the applied settings on Settings -> Appearance -> Comments page.
  Future<ThunderComment> createExample({
    int? id,
    String? path,
    String? commentContent,
    int? commentCreatorId,
    int? commentScore,
    int? commentUpvotes,
    int? commentDownvotes,
    DateTime? commentPublished,
    int? commentChildCount,
    String? personName,
    bool? isPersonAdmin,
    bool? isBotAccount,
    bool? saved,
  });
}
