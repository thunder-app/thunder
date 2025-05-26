import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/comment/comment.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/utils/global_context.dart';

// Optimistically updates a comment
CommentView optimisticallyVoteComment(CommentView commentView, int voteType) {
  int newScore = commentView.counts.score;
  int newUpvotes = commentView.counts.upvotes;
  int newDownvotes = commentView.counts.downvotes;
  int? existingVoteType = commentView.myVote;

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

  return commentView.copyWith(
    myVote: voteType,
    counts: commentView.counts.copyWith(
      score: newScore,
      upvotes: newUpvotes,
      downvotes: newDownvotes,
    ),
  );
}

/// Logic to vote on a comment
Future<CommentView> voteComment(int commentId, int score) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  CommentResponse commentResponse = await lemmy.run(CreateCommentLike(
    auth: account.jwt!,
    commentId: commentId,
    score: score,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Optimistically saves a comment without sending the network request
CommentView optimisticallySaveComment(CommentView commentView, bool saved) {
  return commentView.copyWith(saved: saved);
}

/// Logic to save a comment
Future<CommentView> saveComment(int commentId, bool save) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  CommentResponse commentResponse = await lemmy.run(SaveComment(
    auth: account.jwt!,
    commentId: commentId,
    save: save,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Optimistically deletes a comment without sending the network request
CommentView optimisticallyDeleteComment(CommentView commentView, bool deleted) {
  return commentView.copyWith(comment: commentView.comment.copyWith(deleted: deleted));
}

/// Logic to delete a comment
Future<CommentView> deleteComment(int commentId, bool deleted) async {
  final l10n = AppLocalizations.of(GlobalContext.context)!;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  CommentResponse commentResponse = await lemmy.run(DeleteComment(
    auth: account.jwt!,
    commentId: commentId,
    deleted: deleted,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Builds a tree of [CommentView] given a flattened list [CommentView].
///
/// We need to associate replies to the proper parent comment since we cannot guarantee order in the flattened list from the API.
CommentNode buildCommentTree(List<CommentView> comments, {bool flatten = false}) {
  CommentNode root = CommentNode(commentView: null, replies: []);

  for (CommentView commentView in comments) {
    List<String> commentPath = commentView.comment.path.split('.');
    String parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    CommentNode commentNode = CommentNode(commentView: commentView, replies: []);
    CommentNode.insertCommentNode(root, parentId, commentNode);
  }

  return root;
}

String cleanCommentContent(Comment comment) => cleanComment(comment.content, comment.removed, comment.deleted);

String cleanComment(String commentContent, bool commentRemoved, bool commentDeleted) {
  String deletedByModerator = "deleted by moderator";
  String deletedByCreator = "deleted by creator";

  try {
    // Try to load these strings from localizations
    final AppLocalizations l10n = AppLocalizations.of(GlobalContext.context)!;
    deletedByModerator = l10n.deletedByModerator;
    deletedByCreator = l10n.deletedByCreator;
  } catch (e) {
    // Ignore the error and move on with the default strings
  }

  if (commentRemoved) {
    return '_${deletedByModerator}_';
  }

  if (commentDeleted) {
    return '_${deletedByCreator}_';
  }

  return commentContent;
}

/// Creates a placeholder comment from the given parameters. This is mainly used to display a preview of the comment
/// with the applied settings on Settings -> Appearance -> Comments page.
CommentView createExampleComment({
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
  return CommentView(
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
    subscribed: SubscribedType.notSubscribed,
    saved: saved ?? false,
    creatorBlocked: false,
  );
}
