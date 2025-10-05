import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/subscription_status.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

class ThunderComment {
  /// The comment's ID
  final int id;

  /// The comment's creator ID
  final int creatorId;

  /// The comment reply/mention ID (for replies/mentions)
  final int? replyMentionId;

  /// The comment's post ID
  final int postId;

  /// The comment's content
  final String content;

  /// Whether the comment is removed
  final bool removed;

  /// The comment's published date
  final DateTime published;

  /// The comment's updated date
  final DateTime? updated;

  /// Whether the comment is deleted
  final bool deleted;

  /// The comment's AP ID
  final String apId;

  /// Whether the comment is local
  final bool local;

  /// The comment's path
  final String path;

  /// Whether the comment is distinguished
  final bool distinguished;

  /// The comment's language ID
  final int languageId;

  /// The comment's recipient (for replies/mentions)
  final ThunderUser? recipient;

  /// The comment's creator
  final ThunderUser? creator;

  /// The comment's post
  final ThunderPost? post;

  /// The comment's community
  final ThunderCommunity? community;

  /// The comment's score
  final int? score;

  /// The comment's upvotes
  final int? upvotes;

  /// The comment's downvotes
  final int? downvotes;

  /// The comment's child count
  final int? childCount;

  /// Whether the creator of the comment is banned from the community
  final bool? creatorBannedFromCommunity;

  /// Whether the current user is banned from the community
  final bool? bannedFromCommunity;

  /// Whether the creator of the comment is a moderator
  final bool? creatorIsModerator;

  /// Whether the creator of the comment is an admin
  final bool? creatorIsAdmin;

  /// The comment's subscribed status
  final SubscriptionStatus? subscribed;

  /// Whether the comment is saved by the current user
  final bool? saved;

  /// Whether the creator of the comment is blocked
  final bool? creatorBlocked;

  /// The comment's vote status
  final int? myVote;

  /// Whether the comment is read (comment reply/mention)
  final bool? read;

  ThunderComment({
    required this.id,
    required this.creatorId,
    this.replyMentionId,
    required this.postId,
    required this.content,
    required this.removed,
    required this.published,
    this.updated,
    required this.deleted,
    required this.apId,
    required this.local,
    required this.path,
    required this.distinguished,
    required this.languageId,
    this.recipient,
    this.creator,
    this.post,
    this.community,
    this.score,
    this.upvotes,
    this.downvotes,
    this.childCount,
    this.creatorBannedFromCommunity,
    this.bannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.subscribed,
    this.saved,
    this.creatorBlocked,
    this.myVote,
    this.read,
  });

  ThunderComment copyWith({
    int? id,
    int? creatorId,
    int? replyMentionId,
    int? postId,
    String? content,
    bool? removed,
    DateTime? published,
    DateTime? updated,
    bool? deleted,
    String? apId,
    bool? local,
    String? path,
    bool? distinguished,
    int? languageId,
    ThunderUser? recipient,
    ThunderUser? creator,
    ThunderPost? post,
    ThunderCommunity? community,
    int? score,
    int? upvotes,
    int? downvotes,
    int? childCount,
    bool? creatorBannedFromCommunity,
    bool? bannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    SubscriptionStatus? subscribed,
    bool? saved,
    bool? creatorBlocked,
    int? myVote,
    bool? read,
  }) {
    return ThunderComment(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      replyMentionId: replyMentionId ?? this.replyMentionId,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      removed: removed ?? this.removed,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      deleted: deleted ?? this.deleted,
      apId: apId ?? this.apId,
      local: local ?? this.local,
      path: path ?? this.path,
      distinguished: distinguished ?? this.distinguished,
      languageId: languageId ?? this.languageId,
      recipient: recipient ?? this.recipient,
      creator: creator ?? this.creator,
      post: post ?? this.post,
      community: community ?? this.community,
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      childCount: childCount ?? this.childCount,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      bannedFromCommunity: bannedFromCommunity ?? this.bannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      myVote: myVote ?? this.myVote,
      read: read ?? this.read,
    );
  }

  factory ThunderComment.fromLemmyComment(Map<String, dynamic> comment) {
    return ThunderComment(
      id: comment['id'],
      creatorId: comment['creator_id'],
      postId: comment['post_id'],
      content: comment['content'],
      removed: comment['removed'],
      published: DateTime.parse(comment['published']),
      updated: comment['updated'] != null ? DateTime.parse(comment['updated']) : null,
      deleted: comment['deleted'],
      apId: comment['ap_id'],
      local: comment['local'],
      path: comment['path'],
      distinguished: comment['distinguished'],
      languageId: comment['language_id'],
    );
  }

  factory ThunderComment.fromLemmyCommentView(Map<String, dynamic> commentView, {int? replyMentionId}) {
    final comment = commentView['comment'];
    final creator = commentView['creator'];
    final post = commentView['post'];
    final community = commentView['community'];
    final counts = commentView['counts'];

    return ThunderComment(
      id: comment['id'],
      creatorId: comment['creator_id'],
      replyMentionId: replyMentionId,
      postId: comment['post_id'],
      content: comment['content'],
      removed: comment['removed'],
      published: DateTime.parse(comment['published']),
      updated: comment['updated'] != null ? DateTime.parse(comment['updated']) : null,
      deleted: comment['deleted'],
      apId: comment['ap_id'],
      local: comment['local'],
      path: comment['path'],
      distinguished: comment['distinguished'],
      languageId: comment['language_id'],
      creator: ThunderUser.fromLemmyUser(creator),
      post: ThunderPost.fromLemmyPost(post),
      community: ThunderCommunity.fromLemmyCommunity(community),
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      childCount: counts['child_count'],
      creatorBannedFromCommunity: commentView['creator_banned_from_community'],
      bannedFromCommunity: commentView['banned_from_community'],
      creatorIsModerator: commentView['creator_is_moderator'],
      creatorIsAdmin: commentView['creator_is_admin'],
      subscribed: commentView['subscribed'] != null ? SubscriptionStatus.values.firstWhere((e) => e.name == commentView['subscribed']) : null,
      saved: commentView['saved'],
      creatorBlocked: commentView['creator_blocked'],
      myVote: commentView['my_vote'],
    );
  }

  factory ThunderComment.fromPiefedCommentView(Map<String, dynamic> commentView, {ThunderPost? post, ThunderCommunity? community}) {
    final comment = commentView['comment'];
    final creator = commentView['creator'];
    final counts = commentView['counts'];

    final subscribed = commentView['subscribed'] != null ? SubscriptionStatus.values.firstWhere((e) => e.name == commentView['subscribed']) : null;

    return ThunderComment(
      id: comment['id'],
      creatorId: comment['user_id'],
      postId: comment['post_id'],
      content: comment['body'],
      removed: comment['removed'],
      published: DateTime.parse(comment['published']),
      updated: comment['updated'] != null ? DateTime.parse(comment['updated']) : null,
      deleted: comment['deleted'],
      apId: comment['ap_id'],
      local: comment['local'],
      path: comment['path'],
      distinguished: comment['distinguished'] ?? false,
      languageId: comment['language_id'],
      creator: ThunderUser.fromPiefedUser(creator),
      post: post ?? ThunderPost.fromPiefedPost(commentView['post']),
      community: community ?? ThunderCommunity.fromPiefedCommunity(commentView['community']),
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      childCount: counts['child_count'],
      creatorBannedFromCommunity: commentView['creator_banned_from_community'],
      bannedFromCommunity: commentView['banned_from_community'],
      creatorIsModerator: commentView['creator_is_moderator'],
      creatorIsAdmin: commentView['creator_is_admin'],
      subscribed: subscribed,
      saved: commentView['saved'],
      creatorBlocked: commentView['creator_blocked'],
      myVote: commentView['my_vote'],
    );
  }
}
