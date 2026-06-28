import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Creates a placeholder comment for appearance settings previews.
ThunderComment createExampleComment({
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
  String? personAvatar,
  bool? isPersonAdmin,
  bool? isBotAccount,
  bool? saved,
}) {
  return ThunderComment(
    id: id ?? 1,
    creatorId: commentCreatorId ?? 1,
    postId: 1,
    content: commentContent ?? 'Example Comment',
    published: commentPublished ?? DateTime.now(),
    apId: 'https://example.com/comment/$id',
    path: path ?? '',
    languageId: 0,
    status: const CommentStatus(deleted: false, removed: false, local: false, distinguished: false),
    counts: CommentCounts(score: commentScore ?? 0, upvotes: commentUpvotes ?? 0, downvotes: commentDownvotes ?? 0, childCount: commentChildCount ?? 0),
    context: CommentContext(
      creatorBannedFromCommunity: false,
      bannedFromCommunity: false,
      creatorIsModerator: false,
      creatorIsAdmin: isPersonAdmin ?? false,
      saved: saved ?? false,
    ),
    creator: ThunderUser(
      id: 1,
      name: personName ?? 'Example Username',
      published: DateTime.now(),
      actorId: 'https://example.com/user/$personName',
      instanceId: 1,
      avatar: personAvatar,
      status: UserStatus(banned: false, local: false, deleted: false, botAccount: isBotAccount ?? false),
    ),
  );
}
