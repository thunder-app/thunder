import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/models/models.dart';

class PostView {
  final Post post;

  final Person creator;

  final Community community;

  final ImageDetails? imageDetails;

  final bool creatorBannedFromCommunity;

  final bool? bannedFromCommunity;

  final bool? creatorIsModerator;

  final bool? creatorIsAdmin;

  final PostAggregates counts;

  final SubscribedType subscribed;

  final bool saved;

  final bool read;

  final bool? hidden;

  final bool creatorBlocked;

  final int? myVote;

  final int unreadComments;

  const PostView({
    required this.post, // v0.18.0
    required this.creator, // v0.18.0
    required this.community, // v0.18.0
    this.imageDetails, // v0.19.6 (optional)
    required this.creatorBannedFromCommunity, // v0.18.0
    this.bannedFromCommunity, // v0.19.4 (required)
    this.creatorIsModerator, // v0.19.0 (required)
    this.creatorIsAdmin, // v0.19.0 (required)
    required this.counts, // v0.18.0
    required this.subscribed, // v0.18.0
    required this.saved, // v0.18.0
    required this.read, // v0.18.0
    this.hidden, // v0.19.4 (required)
    required this.creatorBlocked, // v0.18.0
    this.myVote, // v0.18.0
    required this.unreadComments, // v0.18.0
  });

  PostView copyWith({
    Post? post,
    Person? creator,
    Community? community,
    ImageDetails? imageDetails,
    bool? creatorBannedFromCommunity,
    bool? bannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    PostAggregates? counts,
    SubscribedType? subscribed,
    bool? saved,
    bool? read,
    bool? hidden,
    bool? creatorBlocked,
    int? myVote,
    int? unreadComments,
  }) {
    return PostView(
      post: post ?? this.post,
      creator: creator ?? this.creator,
      community: community ?? this.community,
      imageDetails: imageDetails ?? this.imageDetails,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      bannedFromCommunity: bannedFromCommunity ?? this.bannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      counts: counts ?? this.counts,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      read: read ?? this.read,
      hidden: hidden ?? this.hidden,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      myVote: myVote ?? this.myVote,
      unreadComments: unreadComments ?? this.unreadComments,
    );
  }
}
