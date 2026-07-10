import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/enums/subscription_status.dart';
import 'package:thunder/src/core/domain/models/notification_ref.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
import 'package:thunder/src/core/domain/models/vote_state.dart';

class ThunderComment extends Equatable {
  /// The comment id on its home instance.
  final int id;

  /// ID of the comment creator.
  final int creatorId;

  /// ID of the post this comment belongs to.
  final int postId;

  /// Markdown comment content.
  final String content;

  /// When the comment was created.
  final DateTime published;

  /// When the comment was last edited, when available.
  final DateTime? updated;

  /// Canonical ActivityPub URL for the comment.
  final String apId;

  /// Tree path used to place the comment in a thread.
  final String path;

  /// Language selected for the comment.
  final int languageId;

  /// User who was mentioned or replied to, when included.
  final ThunderUser? recipient;

  /// Creator details, when they were included with the response.
  final ThunderUser? creator;

  /// Post details, when they were included with the response.
  final ThunderPost? post;

  /// Community details, when they were included with the response.
  final ThunderCommunity? community;

  /// What has happened to the comment itself, such as deletion or removal.
  final CommentStatus status;

  /// Scores and reply counts for the comment.
  final CommentCounts counts;

  /// How the signed-in account relates to this comment.
  final CommentContext context;

  /// Inbox details when this comment came from a notification.
  final NotificationRef? notification;

  const ThunderComment({
    required this.id,
    required this.creatorId,
    required this.postId,
    required this.content,
    required this.published,
    this.updated,
    required this.apId,
    required this.path,
    required this.languageId,
    this.recipient,
    this.creator,
    this.post,
    this.community,
    required this.status,
    this.counts = const CommentCounts(),
    this.context = const CommentContext(),
    this.notification,
  });

  @override
  List<Object?> get props => [
        id,
        creatorId,
        postId,
        content,
        published,
        updated,
        apId,
        path,
        languageId,
        recipient,
        creator,
        post,
        community,
        status,
        counts,
        context,
        notification,
      ];

  ThunderComment copyWith({
    int? id,
    int? creatorId,
    int? postId,
    String? content,
    DateTime? published,
    DateTime? updated,
    String? apId,
    String? path,
    int? languageId,
    ThunderUser? recipient,
    ThunderUser? creator,
    ThunderPost? post,
    ThunderCommunity? community,
    CommentStatus? status,
    CommentCounts? counts,
    CommentContext? context,
    NotificationRef? notification,
  }) {
    return ThunderComment(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      apId: apId ?? this.apId,
      path: path ?? this.path,
      languageId: languageId ?? this.languageId,
      recipient: recipient ?? this.recipient,
      creator: creator ?? this.creator,
      post: post ?? this.post,
      community: community ?? this.community,
      status: status ?? this.status,
      counts: counts ?? this.counts,
      context: context ?? this.context,
      notification: notification ?? this.notification,
    );
  }
}

class CommentStatus extends Equatable {
  /// Whether the creator deleted it.
  final bool deleted;

  /// Whether moderators removed it.
  final bool removed;

  /// Whether it comes from the current instance.
  final bool local;

  /// Whether moderators distinguished the comment.
  final bool distinguished;

  /// Whether replies are locked for the comment.
  final bool locked;

  const CommentStatus({
    required this.deleted,
    required this.removed,
    required this.local,
    required this.distinguished,
    this.locked = false,
  });

  @override
  List<Object?> get props => [deleted, removed, local, distinguished, locked];

  CommentStatus copyWith({bool? deleted, bool? removed, bool? local, bool? distinguished, bool? locked}) {
    return CommentStatus(
      deleted: deleted ?? this.deleted,
      removed: removed ?? this.removed,
      local: local ?? this.local,
      distinguished: distinguished ?? this.distinguished,
      locked: locked ?? this.locked,
    );
  }
}

class CommentCounts extends Equatable {
  /// Net score, when available.
  final int? score;

  /// Number of upvotes, when available.
  final int? upvotes;

  /// Number of downvotes, when available.
  final int? downvotes;

  /// Number of known child comments.
  final int? childCount;

  const CommentCounts({this.score, this.upvotes, this.downvotes, this.childCount});

  @override
  List<Object?> get props => [score, upvotes, downvotes, childCount];

  CommentCounts copyWith({int? score, int? upvotes, int? downvotes, int? childCount}) {
    return CommentCounts(
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      childCount: childCount ?? this.childCount,
    );
  }
}

class CommentContext extends Equatable {
  /// Subscription state for the comment's community.
  final SubscriptionStatus? subscribed;

  /// Whether the signed-in account saved it.
  final bool? saved;

  /// Whether the signed-in account blocked the creator.
  final bool? creatorBlocked;

  /// Whether the creator is banned from the community.
  final bool? creatorBannedFromCommunity;

  /// Whether the signed-in account is banned from the community.
  final bool? bannedFromCommunity;

  /// Whether the creator moderates the community.
  final bool? creatorIsModerator;

  /// Whether the creator is an instance admin.
  final bool? creatorIsAdmin;

  /// Whether the signed-in account can moderate this comment.
  final bool? canModerate;

  /// The signed-in account's vote.
  final VoteState vote;

  const CommentContext({
    this.subscribed,
    this.saved,
    this.creatorBlocked,
    this.creatorBannedFromCommunity,
    this.bannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.canModerate,
    this.vote = VoteState.none,
  });

  @override
  List<Object?> get props => [
        subscribed,
        saved,
        creatorBlocked,
        creatorBannedFromCommunity,
        bannedFromCommunity,
        creatorIsModerator,
        creatorIsAdmin,
        canModerate,
        vote,
      ];

  CommentContext copyWith({
    SubscriptionStatus? subscribed,
    bool? saved,
    bool? creatorBlocked,
    bool? creatorBannedFromCommunity,
    bool? bannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    bool? canModerate,
    VoteState? vote,
  }) {
    return CommentContext(
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      bannedFromCommunity: bannedFromCommunity ?? this.bannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      canModerate: canModerate ?? this.canModerate,
      vote: vote ?? this.vote,
    );
  }
}
