import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/utils/date_time.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';

// Optimistically updates a comment
CommentView optimisticallyVoteComment(CommentViewTree commentViewTree, int voteType) {
  int newScore = commentViewTree.commentView!.counts.score;
  int? existingVoteType = commentViewTree.commentView!.myVote;

  switch (voteType) {
    case -1:
      newScore--;
      break;
    case 1:
      newScore++;
      break;
    case 0:
      // Determine score from existing
      if (existingVoteType == -1) {
        newScore++;
      } else if (existingVoteType == 1) {
        newScore--;
      }
      break;
  }

  return commentViewTree.commentView!.copyWith(myVote: voteType, counts: commentViewTree.commentView!.counts.copyWith(score: newScore));
}

/// Logic to vote on a comment
Future<CommentView> voteComment(int commentId, int score) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  CommentResponse commentResponse = await lemmy.run(CreateCommentLike(
    auth: account!.jwt!,
    commentId: commentId,
    score: score,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Logic to save a comment
Future<CommentView> saveComment(int commentId, bool save) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  CommentResponse commentResponse = await lemmy.run(SaveComment(
    auth: account!.jwt!,
    commentId: commentId,
    save: save,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Builds a tree of comments given a flattened list
List<CommentViewTree> buildCommentViewTree(List<CommentView> comments, {bool flatten = false}) {
  Map<String, CommentViewTree> commentMap = {};

  // Create a map of CommentView objects using the comment path as the key
  for (CommentView commentView in comments) {
    bool hasBeenEdited = commentView.comment.updated != null ? true : false;
    String commentTime = hasBeenEdited ? commentView.comment.updated!.toIso8601String() : commentView.comment.published.toIso8601String();

    commentMap[commentView.comment.path] = CommentViewTree(
      datePostedOrEdited: formatTimeToString(dateTime: commentTime),
      commentView: cleanDeletedCommentView(commentView),
      replies: [],
      level: commentView.comment.path.split('.').length - 2,
    );
  }

  if (flatten) {
    return commentMap.values.toList();
  }

  // Build the tree structure by assigning children to their parent comments
  for (CommentViewTree commentView in commentMap.values) {
    List<String> pathIds = commentView.commentView!.comment.path.split('.');
    String parentPath = pathIds.getRange(0, pathIds.length - 1).join('.');

    CommentViewTree? parentCommentView = commentMap[parentPath];

    if (parentCommentView != null) {
      parentCommentView.replies.add(commentView);
    }
  }

  // Return the root comments (those with an empty or "0" path)
  return commentMap.values.where((commentView) => commentView.commentView!.comment.path.isEmpty || commentView.commentView!.comment.path == '0.${commentView.commentView!.comment.id}').toList();
}

List<CommentViewTree> insertNewComment(List<CommentViewTree> comments, CommentView commentView) {
  List<String> parentIds = commentView.comment.path.split('.');
  String commentTime = commentView.comment.published.toIso8601String();

  CommentViewTree newCommentTree = CommentViewTree(
    datePostedOrEdited: formatTimeToString(dateTime: commentTime),
    commentView: commentView,
    replies: [],
    level: commentView.comment.path.split('.').length - 2,
  );

  if (parentIds[1] == commentView.comment.id.toString()) {
    comments.insert(0, newCommentTree);
    return comments;
  }

  String parentId = parentIds[parentIds.length - 2];
  CommentViewTree? parentComment = findParentComment(1, parentIds, parentId.toString(), comments);

  // TODO: surface some sort of error maybe if for some reason we fail to find parent comment
  if (parentComment != null) {
    parentComment.replies.insert(0, newCommentTree);
  }

  return comments;
}

CommentViewTree? findParentComment(int index, List<String> parentIds, String targetId, List<CommentViewTree> comments) {
  for (CommentViewTree existing in comments) {
    if (existing.commentView?.comment.id.toString() != parentIds[index]) {
      continue;
    }

    if (targetId == existing.commentView?.comment.id.toString()) {
      return existing;
    }

    return findParentComment(index + 1, parentIds, targetId, existing.replies);
  }

  return null;
}

List<int> findCommentIndexesFromCommentViewTree(List<CommentViewTree> commentTrees, int commentId, [List<int>? indexes]) {
  indexes ??= [];

  for (int i = 0; i < commentTrees.length; i++) {
    if (commentTrees[i].commentView!.comment.id == commentId) {
      return [...indexes, i]; // Return a copy of the indexes list with the current index added
    }

    indexes.add(i); // Add the current index to the indexes list

    List<int> foundIndexes = findCommentIndexesFromCommentViewTree(commentTrees[i].replies, commentId, indexes);

    if (foundIndexes.isNotEmpty) {
      return foundIndexes;
    }

    indexes.removeLast(); // Remove the last index when backtracking
  }

  return []; // Return an empty list if the target ID is not found
}

// Used for modifying the comment current comment tree so we don't have to refresh the whole thing
bool updateModifiedComment(List<CommentViewTree> commentTrees, CommentView commentView) {
  for (int i = 0; i < commentTrees.length; i++) {
    if (commentTrees[i].commentView!.comment.id == commentView.comment.id) {
      commentTrees[i].commentView = commentView;
      return true;
    }

    bool done = updateModifiedComment(commentTrees[i].replies, commentView);
    if (done) {
      return done;
    }
  }

  return false;
}

CommentView cleanDeletedCommentView(CommentView commentView) {
  if (!commentView.comment.deleted) {
    return commentView;
  }

  Comment deletedComment = convertToDeletedComment(commentView.comment);

  return CommentView(
    comment: deletedComment,
    creator: commentView.creator,
    post: commentView.post,
    community: commentView.community,
    counts: commentView.counts,
    creatorBannedFromCommunity: commentView.creatorBannedFromCommunity,
    saved: commentView.saved,
    creatorBlocked: commentView.creatorBlocked,
    subscribed: commentView.subscribed,
  );
}

Comment convertToDeletedComment(Comment comment) {
  return Comment(
    id: comment.id,
    creatorId: comment.creatorId,
    postId: comment.postId,
    content: "_deleted by creator_",
    removed: comment.removed,
    distinguished: comment.distinguished,
    published: comment.published,
    deleted: comment.deleted,
    apId: comment.apId,
    local: comment.local,
    languageId: comment.languageId,
    path: comment.path,
  );
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
