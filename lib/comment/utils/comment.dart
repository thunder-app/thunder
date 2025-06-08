import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';

// Optimistically updates a comment
ThunderComment optimisticallyVoteComment(ThunderComment comment, int voteType) {
  assert(comment.score != null && comment.upvotes != null && comment.downvotes != null, 'Comment must have score, upvotes and downvotes');

  int newScore = comment.score!;
  int newUpvotes = comment.upvotes!;
  int newDownvotes = comment.downvotes!;
  int? existingVoteType = comment.myVote;

  switch (voteType) {
    case -1:
      newScore--;
      newDownvotes++;
      if (existingVoteType == 1) newUpvotes--;
      break;
    case 1:
      newScore++;
      newUpvotes++;
      if (existingVoteType == -1) newDownvotes--;
      break;
    case 0:
      // Determine score from existing
      if (existingVoteType == -1) {
        newScore++;
        newDownvotes--;
      } else if (existingVoteType == 1) {
        newScore--;
        newUpvotes--;
      }
      break;
  }

  return comment.copyWith(
    commentView: comment.internalCommentView?.copyWith(
      myVote: voteType,
      counts: comment.internalCommentView!.counts.copyWith(
        score: newScore,
        upvotes: newUpvotes,
        downvotes: newDownvotes,
      ),
    ),
  );
}

/// Logic to vote on a comment
Future<ThunderComment> voteComment(int commentId, int score) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(CreateCommentLike(
    auth: account.jwt!,
    commentId: commentId,
    score: score,
  ));

  return ThunderComment(comment: response.commentView.comment, commentView: response.commentView);
}

/// Optimistically saves a comment without sending the network request
ThunderComment optimisticallySaveComment(ThunderComment comment, bool saved) {
  return comment.copyWith(
    commentView: comment.internalCommentView?.copyWith(
      saved: saved,
    ),
  );
}

/// Logic to save a comment
Future<ThunderComment> saveComment(int commentId, bool save) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(SaveComment(
    auth: account.jwt!,
    commentId: commentId,
    save: save,
  ));

  return ThunderComment(comment: response.commentView.comment, commentView: response.commentView);
}

/// Optimistically deletes a comment without sending the network request
ThunderComment optimisticallyDeleteComment(ThunderComment comment, bool deleted) {
  return comment.copyWith(
    comment: comment.internalComment.copyWith(deleted: deleted),
  );
}

/// Logic to delete a comment
Future<ThunderComment> deleteComment(int commentId, bool deleted) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(DeleteComment(
    auth: account.jwt!,
    commentId: commentId,
    deleted: deleted,
  ));

  return ThunderComment(comment: response.commentView.comment, commentView: response.commentView);
}

/// Logic to create a comment
Future<ThunderComment> createComment(int postId, String content, int? parentCommentId, int? languageId) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(CreateComment(
    postId: postId,
    content: content,
    parentId: parentCommentId,
    languageId: languageId,
    auth: account.jwt!,
  ));

  return ThunderComment(comment: response.commentView.comment, commentView: response.commentView);
}

/// Logic to edit a comment
Future<ThunderComment> editComment(int commentId, String content, int? languageId) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(EditComment(
    commentId: commentId,
    content: content,
    languageId: languageId,
    auth: account.jwt!,
  ));

  return ThunderComment(comment: response.commentView.comment, commentView: response.commentView);
}

/// Builds a tree of [ThunderComment]s given a flattened list of [ThunderComment]s.
///
/// We need to associate replies to the proper parent comment since we cannot guarantee order in the flattened list from the API.
CommentNode buildCommentTree(List<ThunderComment> comments, {bool flatten = false}) {
  CommentNode root = CommentNode(comment: null, replies: []);

  for (final comment in comments) {
    List<String> commentPath = comment.path.split('.');
    String parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    CommentNode commentNode = CommentNode(comment: comment, replies: []);
    CommentNode.insertCommentNode(root, parentId, commentNode);
  }

  return root;
}

String cleanCommentContent(ThunderComment comment) => cleanComment(comment.body, comment.removed, comment.deleted);

String cleanComment(String commentContent, bool? commentRemoved, bool? commentDeleted) {
  String deletedByModerator = "deleted by moderator";
  String deletedByCreator = "deleted by creator";

  try {
    // Try to load these strings from localizations
    final l10n = GlobalContext.l10n;

    deletedByModerator = l10n.deletedByModerator;
    deletedByCreator = l10n.deletedByCreator;
  } catch (e) {
    // Ignore the error and move on with the default strings
  }

  if (commentRemoved == true) {
    return '_${deletedByModerator}_';
  }

  if (commentDeleted == true) {
    return '_${deletedByCreator}_';
  }

  return commentContent;
}

/// Creates a placeholder comment from the given parameters. This is mainly used to display a preview of the comment
/// with the applied settings on Settings -> Appearance -> Comments page.
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
  bool? isPersonAdmin,
  bool? isBotAccount,
  bool? saved,
}) {
  CommentView commentView = CommentView(
    comment: Comment(
      id: id ?? 1,
      creatorId: commentCreatorId ?? 1,
      postId: 1,
      content: commentContent ?? 'This is an example comment',
      removed: false,
      published: commentPublished ?? DateTime.now(),
      deleted: false,
      apId: '',
      local: false,
      path: path ?? '0.1',
      distinguished: false,
      languageId: 1,
    ),
    creator: Person(
      id: 1,
      name: personName ?? 'Example Username',
      banned: false,
      published: DateTime.now(),
      actorId: 'https://lemmy.world/u/testuser',
      local: false,
      deleted: false,
      botAccount: isBotAccount ?? false,
      instanceId: 1,
      admin: isPersonAdmin ?? false,
    ),
    post: Post(
      id: 1,
      name: 'Example Title',
      creatorId: 1,
      communityId: 1,
      removed: false,
      locked: false,
      published: DateTime.now(),
      deleted: false,
      nsfw: false,
      apId: '',
      local: false,
      languageId: 1,
      featuredCommunity: false,
      featuredLocal: false,
    ),
    community: Community(
      id: 1,
      name: 'Example Community',
      removed: false,
      published: DateTime.now(),
      deleted: false,
      nsfw: false,
      local: false,
      title: '',
      actorId: '',
      hidden: false,
      postingRestrictedToMods: false,
      instanceId: 1,
    ),
    counts: CommentAggregates(
      id: 1,
      commentId: 1,
      score: commentScore ?? 1,
      upvotes: commentUpvotes ?? 1,
      downvotes: commentDownvotes ?? 1,
      published: DateTime.now(),
      childCount: commentChildCount ?? 0,
    ),
    creatorBannedFromCommunity: false,
    subscribed: SubscriptionStatus.notSubscribed.toLemmyType(),
    saved: saved ?? false,
    creatorBlocked: false,
  );

  return ThunderComment(comment: commentView.comment, commentView: commentView);
}
