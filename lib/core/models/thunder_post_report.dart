import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/user/models/thunder_user.dart';

class ThunderPostReport {
  /// The post report's ID.
  final int id;

  /// The post report's creator ID.
  final int creatorId;

  /// The post report's post ID.
  final int postId;

  /// The post report's original post name.
  final String originalPostName;

  /// The post report's original post URL.
  final String? originalPostUrl;

  /// The post report's original post body.
  final String? originalPostBody;

  /// The post report's reason.
  final String reason;

  /// Whether the post report has been resolved.
  final bool resolved;

  /// The post report's resolver ID.
  final int? resolverId;

  /// The post report's created date.
  final DateTime published;

  /// The post report's updated date.
  final DateTime? updated;

  /// The post report's post.
  final ThunderPost? post;

  /// The post report's community.
  final ThunderCommunity? community;

  /// The post report's creator.
  final ThunderUser? creator;

  /// The post report's resolver.
  final ThunderUser? resolver;

  /// The post report's post creator.
  final ThunderUser? postCreator;

  /// Whether the post report's creator is banned from the community.
  final bool? creatorBannedFromCommunity;

  /// Whether the post report's creator is a moderator.
  final bool? creatorIsModerator;

  /// Whether the post report's creator is an admin.
  final bool? creatorIsAdmin;

  /// The post report's subscription status.
  final SubscriptionStatus? subscribed;

  /// Whether the post report's creator has saved the post.
  final bool? saved;

  /// Whether the post report's creator has read the post.
  final bool? read;

  /// Whether the post report's post is hidden.
  final bool? hidden;

  /// Whether the post report's creator is blocked.
  final bool? creatorBlocked;

  /// The post report's my vote.
  final int? myVote;

  /// The post report's unread comments.
  final int? unreadComments;

  /// The post report's comments.
  final int? comments;

  /// The post report's score.
  final int? score;

  /// The post report's upvotes.
  final int? upvotes;

  /// The post report's downvotes.
  final int? downvotes;

  /// The post report's newest comment time.
  final DateTime? newestCommentTime;

  ThunderPostReport({
    required this.id,
    required this.creatorId,
    required this.postId,
    required this.originalPostName,
    this.originalPostUrl,
    this.originalPostBody,
    required this.reason,
    required this.resolved,
    this.resolverId,
    required this.published,
    this.updated,
    this.post,
    this.community,
    this.creator,
    this.resolver,
    this.postCreator,
    this.creatorBannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.subscribed,
    this.saved,
    this.read,
    this.hidden,
    this.creatorBlocked,
    this.myVote,
    this.unreadComments,
    this.comments,
    this.score,
    this.upvotes,
    this.downvotes,
    this.newestCommentTime,
  });

  ThunderPostReport copyWith({
    int? id,
    int? creatorId,
    int? postId,
    String? originalPostName,
    String? originalPostUrl,
    String? originalPostBody,
    String? reason,
    bool? resolved,
    int? resolverId,
    DateTime? published,
    DateTime? updated,
    ThunderPost? post,
    ThunderCommunity? community,
    ThunderUser? creator,
    ThunderUser? resolver,
    ThunderUser? postCreator,
    bool? creatorBannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    SubscriptionStatus? subscribed,
    bool? saved,
    bool? read,
    bool? hidden,
    bool? creatorBlocked,
    int? myVote,
    int? unreadComments,
    int? comments,
    int? score,
    int? upvotes,
    int? downvotes,
    DateTime? newestCommentTime,
  }) {
    return ThunderPostReport(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      postId: postId ?? this.postId,
      originalPostName: originalPostName ?? this.originalPostName,
      originalPostUrl: originalPostUrl ?? this.originalPostUrl,
      originalPostBody: originalPostBody ?? this.originalPostBody,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      resolverId: resolverId ?? this.resolverId,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      post: post ?? this.post,
      community: community ?? this.community,
      creator: creator ?? this.creator,
      resolver: resolver ?? this.resolver,
      postCreator: postCreator ?? this.postCreator,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      read: read ?? this.read,
      hidden: hidden ?? this.hidden,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      myVote: myVote ?? this.myVote,
      unreadComments: unreadComments ?? this.unreadComments,
      comments: comments ?? this.comments,
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      newestCommentTime: newestCommentTime ?? this.newestCommentTime,
    );
  }

  factory ThunderPostReport.fromLemmyPostReport(Map<String, dynamic> postReport) {
    return ThunderPostReport(
      id: postReport['id'],
      creatorId: postReport['creator_id'],
      postId: postReport['post_id'],
      originalPostName: postReport['original_post_name'],
      originalPostUrl: postReport['original_post_url'],
      originalPostBody: postReport['original_post_body'],
      reason: postReport['reason'],
      resolved: postReport['resolved'],
      resolverId: postReport['resolver_id'],
      published: DateTime.parse(postReport['published']),
      updated: postReport['updated'] != null ? DateTime.parse(postReport['updated']) : null,
    );
  }

  factory ThunderPostReport.fromLemmyPostReportView(Map<String, dynamic> postReportView) {
    final postReport = postReportView['post_report'];
    final post = postReportView['post'];
    final community = postReportView['community'];
    final creator = postReportView['creator'];
    final resolver = postReportView['resolver'];
    final postCreator = postReportView['post_creator'];
    final counts = postReportView['counts'];

    return ThunderPostReport(
      id: postReport['id'],
      creatorId: postReport['creator_id'],
      postId: postReport['post_id'],
      originalPostName: postReport['original_post_name'],
      originalPostUrl: postReport['original_post_url'],
      originalPostBody: postReport['original_post_body'],
      reason: postReport['reason'],
      resolved: postReport['resolved'],
      published: DateTime.parse(postReport['published']),
      updated: postReport['updated'] != null ? DateTime.parse(postReport['updated']) : null,
      post: post != null ? ThunderPost.fromLemmyPost(post) : null,
      community: community != null ? ThunderCommunity.fromLemmyCommunity(community) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
      resolver: resolver != null ? ThunderUser.fromLemmyUser(resolver) : null,
      postCreator: postCreator != null ? ThunderUser.fromLemmyUser(postCreator) : null,
      creatorBannedFromCommunity: postReport['creator_banned_from_community'],
      creatorIsModerator: postReport['creator_is_moderator'],
      creatorIsAdmin: postReport['creator_is_admin'],
      subscribed: postReport['subscribed'] != null ? SubscriptionStatusMapping.fromLemmyType(postReport['subscribed']) : null,
      saved: postReport['saved'],
      read: postReport['read'],
      hidden: postReport['hidden'],
      creatorBlocked: postReport['creator_blocked'],
      myVote: postReport['my_vote'],
      unreadComments: postReport['unread_comments'],
      comments: counts['comments'],
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      newestCommentTime: counts['newest_comment_time'] != null ? DateTime.parse(counts['newest_comment_time']) : null,
    );
  }
}
