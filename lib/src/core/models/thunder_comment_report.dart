import 'package:collection/collection.dart';

import 'package:thunder/src/core/enums/subscription_status.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

class ThunderCommentReport {
  /// The comment report's ID.
  final int id;

  /// The comment report's creator ID.
  final int creatorId;

  /// The comment report's comment ID.
  final int commentId;

  /// The comment report's original comment text.
  final String originalCommentText;

  /// The comment report's reason.
  final String reason;

  /// Whether the comment report has been resolved.
  final bool resolved;

  /// The comment report's resolver ID.
  final int? resolverId;

  /// The comment report's created date.
  final DateTime published;

  /// The comment report's updated date.
  final DateTime? updated;

  /// The comment report's comment.
  final ThunderComment? comment;

  /// The comment report's post.
  final ThunderPost? post;

  /// The comment report's community.
  final ThunderCommunity? community;

  /// The comment report's creator.
  final ThunderUser? creator;

  /// The comment report's resolver.
  final ThunderUser? resolver;

  /// The comment report's comment creator.
  final ThunderUser? commentCreator;

  /// Whether the comment report's creator is banned from the community.
  final bool? creatorBannedFromCommunity;

  /// Whether the comment report's creator is a moderator.
  final bool? creatorIsModerator;

  /// Whether the comment report's creator is an admin.
  final bool? creatorIsAdmin;

  /// Whether the comment report's creator is blocked.
  final bool? creatorBlocked;

  /// The comment report's subscription status.
  final SubscriptionStatus? subscribed;

  /// Whether the comment report's creator has saved the comment.
  final bool? saved;

  /// The comment report's my vote.
  final int? myVote;

  /// The comment report's score.
  final int? score;

  /// The comment report's upvotes.
  final int? upvotes;

  /// The comment report's downvotes.
  final int? downvotes;

  /// The comment report's child count.
  final int? childCount;

  ThunderCommentReport({
    required this.id,
    required this.creatorId,
    required this.commentId,
    required this.originalCommentText,
    required this.reason,
    required this.resolved,
    this.resolverId,
    required this.published,
    this.updated,
    this.comment,
    this.post,
    this.community,
    this.creator,
    this.resolver,
    this.commentCreator,
    this.creatorBannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.subscribed,
    this.saved,
    this.creatorBlocked,
    this.myVote,
    this.score,
    this.upvotes,
    this.downvotes,
    this.childCount,
  });

  ThunderCommentReport copyWith({
    int? id,
    int? creatorId,
    int? commentId,
    String? originalCommentText,
    String? reason,
    bool? resolved,
    int? resolverId,
    DateTime? published,
    DateTime? updated,
    ThunderComment? comment,
    ThunderPost? post,
    ThunderCommunity? community,
    ThunderUser? creator,
    ThunderUser? resolver,
    ThunderUser? commentCreator,
    bool? creatorBannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    SubscriptionStatus? subscribed,
    bool? saved,
    bool? creatorBlocked,
    int? myVote,
    int? score,
    int? upvotes,
    int? downvotes,
    int? childCount,
  }) {
    return ThunderCommentReport(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      commentId: commentId ?? this.commentId,
      originalCommentText: originalCommentText ?? this.originalCommentText,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      resolverId: resolverId ?? this.resolverId,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      comment: comment ?? this.comment,
      post: post ?? this.post,
      community: community ?? this.community,
      creator: creator ?? this.creator,
      resolver: resolver ?? this.resolver,
      commentCreator: commentCreator ?? this.commentCreator,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      myVote: myVote ?? this.myVote,
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      childCount: childCount ?? this.childCount,
    );
  }

  factory ThunderCommentReport.fromLemmyCommentReport(Map<String, dynamic> commentReport) {
    return ThunderCommentReport(
      id: commentReport['id'],
      creatorId: commentReport['creator_id'],
      commentId: commentReport['comment_id'],
      originalCommentText: commentReport['original_comment_text'],
      reason: commentReport['reason'],
      resolved: commentReport['resolved'],
      resolverId: commentReport['resolver_id'],
      published: DateTime.parse(commentReport['published']),
      updated: commentReport['updated'] != null ? DateTime.parse(commentReport['updated']) : null,
    );
  }

  factory ThunderCommentReport.fromLemmyCommentReportView(Map<String, dynamic> commentReportView) {
    final commentReport = commentReportView['comment_report'];
    final comment = commentReportView['comment'];
    final post = commentReportView['post'];
    final community = commentReportView['community'];
    final creator = commentReportView['creator'];
    final commentCreator = commentReportView['comment_creator'];
    final counts = commentReportView['counts'];
    final resolver = commentReportView['resolver'];

    return ThunderCommentReport(
      id: commentReport['id'],
      creatorId: commentReport['creator_id'],
      commentId: commentReport['comment_id'],
      originalCommentText: commentReport['original_comment_text'],
      reason: commentReport['reason'],
      resolved: commentReport['resolved'],
      published: DateTime.parse(commentReport['published']),
      updated: commentReport['updated'] != null ? DateTime.parse(commentReport['updated']) : null,
      comment: comment != null ? ThunderComment.fromLemmyComment(comment) : null,
      post: post != null ? ThunderPost.fromLemmyPost(post) : null,
      community: community != null ? ThunderCommunity.fromLemmyCommunity(community) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
      resolver: resolver != null ? ThunderUser.fromLemmyUser(resolver) : null,
      commentCreator: commentCreator != null ? ThunderUser.fromLemmyUser(commentCreator) : null,
      creatorBannedFromCommunity: commentReportView['creator_banned_from_community'],
      creatorIsModerator: commentReportView['creator_is_moderator'],
      creatorIsAdmin: commentReportView['creator_is_admin'],
      subscribed: commentReportView['subscribed'] != null ? SubscriptionStatus.values.firstWhereOrNull((e) => e.name == commentReportView['subscribed']) : null,
      saved: commentReportView['saved'],
      creatorBlocked: commentReportView['creator_blocked'],
      myVote: commentReportView['my_vote'],
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      childCount: counts['child_count'],
    );
  }
}
