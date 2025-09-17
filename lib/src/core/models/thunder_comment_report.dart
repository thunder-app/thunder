import 'package:collection/collection.dart';

import 'package:thunder/src/core/enums/subscription_status.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

class ThunderCommentReport {
  /// The comment report's ID.
  final int id;

  /// The comment report's reason.
  final String reason;

  /// Whether the comment report has been resolved.
  final bool resolved;

  /// The comment report's comment.
  final ThunderComment? comment;

  /// The comment report's post.
  final ThunderPost? post;

  /// The comment report's community.
  final ThunderCommunity? community;

  /// The comment report's creator.
  final ThunderUser? creator;

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
    required this.reason,
    required this.resolved,
    this.comment,
    this.post,
    this.community,
    this.creator,
    this.creatorBannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.creatorBlocked,
    this.subscribed,
    this.saved,
    this.myVote,
    this.score,
    this.upvotes,
    this.downvotes,
    this.childCount,
  });

  ThunderCommentReport copyWith({
    int? id,
    String? reason,
    bool? resolved,
    ThunderComment? comment,
    ThunderPost? post,
    ThunderCommunity? community,
    ThunderUser? creator,
    bool? creatorBannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    bool? creatorBlocked,
    SubscriptionStatus? subscribed,
    bool? saved,
    int? myVote,
    int? score,
    int? upvotes,
    int? downvotes,
    int? childCount,
  }) {
    return ThunderCommentReport(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      comment: comment ?? this.comment,
      post: post ?? this.post,
      community: community ?? this.community,
      creator: creator ?? this.creator,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
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
      reason: commentReport['reason'],
      resolved: commentReport['resolved'],
    );
  }

  factory ThunderCommentReport.fromLemmyCommentReportView(Map<String, dynamic> commentReportView) {
    final commentReport = commentReportView['comment_report'];
    final comment = commentReportView['comment'];
    final post = commentReportView['post'];
    final community = commentReportView['community'];
    final creator = commentReportView['creator'];
    final counts = commentReportView['counts'];

    return ThunderCommentReport(
      id: commentReport['id'],
      reason: commentReport['reason'],
      resolved: commentReport['resolved'],
      comment: comment != null ? ThunderComment.fromLemmyComment(comment) : null,
      post: post != null ? ThunderPost.fromLemmyPost(post) : null,
      community: community != null ? ThunderCommunity.fromLemmyCommunity(community) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
      creatorBannedFromCommunity: commentReportView['creator_banned_from_community'],
      creatorIsModerator: commentReportView['creator_is_moderator'],
      creatorIsAdmin: commentReportView['creator_is_admin'],
      creatorBlocked: commentReportView['creator_blocked'],
      subscribed: commentReportView['subscribed'] != null ? SubscriptionStatus.values.firstWhereOrNull((e) => e.name == commentReportView['subscribed']) : null,
      saved: commentReportView['saved'],
      myVote: commentReportView['my_vote'],
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      childCount: counts['child_count'],
    );
  }
}
