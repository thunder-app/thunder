import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/models/models.dart';

class CommentView {
  final Comment comment;

  final Person creator;

  final Post post;

  final Community community;

  final CommentAggregates counts;

  final bool creatorBannedFromCommunity;

  final bool? bannedFromCommunity;

  final bool? creatorIsModerator;

  final bool? creatorIsAdmin;

  final SubscribedType subscribed;

  final bool saved;

  final bool creatorBlocked;

  final int? myVote;

  const CommentView({
    required this.comment, // v0.18.0
    required this.creator, // v0.18.0
    required this.post, // v0.18.0
    required this.community, // v0.18.0
    required this.counts, // v0.18.0
    required this.creatorBannedFromCommunity, // v0.18.0
    this.bannedFromCommunity, // v0.19.4 (required)
    this.creatorIsModerator, // v0.19.0 (required)
    this.creatorIsAdmin, // v0.19.0 (required)
    required this.subscribed, // v0.18.0
    required this.saved, // v0.18.0
    required this.creatorBlocked, // v0.18.0
    this.myVote, // v0.18.0
  });

  CommentView copyWith({
    Comment? comment,
    Person? creator,
    Post? post,
    Community? community,
    CommentAggregates? counts,
    bool? creatorBannedFromCommunity,
    bool? bannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    SubscribedType? subscribed,
    bool? saved,
    bool? creatorBlocked,
    int? myVote,
  }) {
    return CommentView(
      comment: comment ?? this.comment,
      creator: creator ?? this.creator,
      post: post ?? this.post,
      community: community ?? this.community,
      counts: counts ?? this.counts,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      bannedFromCommunity: bannedFromCommunity ?? this.bannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      myVote: myVote ?? this.myVote,
    );
  }
}
