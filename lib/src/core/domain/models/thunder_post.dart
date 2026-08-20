import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/enums/subscription_status.dart';
import 'package:thunder/src/core/domain/models/media.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_flair.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
import 'package:thunder/src/core/domain/models/vote_state.dart';

class ThunderPost extends Equatable {
  /// The post id on its home instance.
  final int id;

  /// Post title.
  final String name;

  /// Optional external URL attached to the post.
  final String? url;

  /// Optional Markdown body.
  final String? body;

  /// ID of the post creator.
  final int creatorId;

  /// ID of the community containing the post.
  final int communityId;

  /// When the post was created.
  final DateTime published;

  /// When the post was last edited, when available.
  final DateTime? updated;

  /// Thumbnail URL provided by the instance, when available.
  final String? thumbnailUrl;

  /// Canonical ActivityPub URL for the post.
  final String apId;

  /// Optional embedded video URL.
  final String? embedVideoUrl;

  /// Language selected for the post.
  final int languageId;

  /// Alternative text for post media.
  final String? altText;

  /// Short text preview used by compact surfaces.
  final String? textPreview;

  /// Creator details, when they were included with the response.
  final ThunderUser? creator;

  /// Community details, when they were included with the response.
  final ThunderCommunity? community;

  /// Extra image details used by media helpers.
  final Map<String, dynamic>? imageDetails;

  /// What has happened to the post itself, such as deletion or locking.
  final PostStatus status;

  /// Scores and comment counts for the post.
  final PostCounts counts;

  /// How the signed-in account relates to this post.
  final PostContext context;

  /// Media attachments found for the post.
  final List<Media> media;

  /// Tags attached to the post, when the platform supports them.
  final List<String> tags;

  /// Flairs attached to the post, when the platform supports them.
  final List<ThunderFlair> flairs;

  const ThunderPost({
    required this.id,
    required this.name,
    this.url,
    this.body,
    required this.creatorId,
    required this.communityId,
    required this.published,
    this.updated,
    this.thumbnailUrl,
    required this.apId,
    this.embedVideoUrl,
    required this.languageId,
    this.altText,
    this.textPreview,
    this.creator,
    this.community,
    this.imageDetails,
    required this.status,
    this.counts = const PostCounts(),
    this.context = const PostContext(),
    this.media = const [],
    this.tags = const [],
    this.flairs = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    url,
    body,
    creatorId,
    communityId,
    published,
    updated,
    thumbnailUrl,
    apId,
    embedVideoUrl,
    languageId,
    altText,
    textPreview,
    creator,
    community,
    imageDetails,
    status,
    counts,
    context,
    media,
    tags,
    flairs,
  ];

  ThunderPost copyWith({
    int? id,
    String? name,
    String? url,
    String? body,
    int? creatorId,
    int? communityId,
    DateTime? published,
    DateTime? updated,
    String? thumbnailUrl,
    String? apId,
    String? embedVideoUrl,
    int? languageId,
    String? altText,
    String? textPreview,
    ThunderUser? creator,
    ThunderCommunity? community,
    Map<String, dynamic>? imageDetails,
    PostStatus? status,
    PostCounts? counts,
    PostContext? context,
    List<Media>? media,
    List<String>? tags,
    List<ThunderFlair>? flairs,
  }) {
    return ThunderPost(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      body: body ?? this.body,
      creatorId: creatorId ?? this.creatorId,
      communityId: communityId ?? this.communityId,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      apId: apId ?? this.apId,
      embedVideoUrl: embedVideoUrl ?? this.embedVideoUrl,
      languageId: languageId ?? this.languageId,
      altText: altText ?? this.altText,
      textPreview: textPreview ?? this.textPreview,
      creator: creator ?? this.creator,
      community: community ?? this.community,
      imageDetails: imageDetails ?? this.imageDetails,
      status: status ?? this.status,
      counts: counts ?? this.counts,
      context: context ?? this.context,
      media: media ?? this.media,
      tags: tags ?? this.tags,
      flairs: flairs ?? this.flairs,
    );
  }
}

class PostStatus extends Equatable {
  /// Whether the creator deleted it.
  final bool deleted;

  /// Whether moderators removed it.
  final bool removed;

  /// Whether new comments are locked.
  final bool locked;

  /// Whether it is marked not safe for work.
  final bool nsfw;

  /// Whether it comes from the current instance.
  final bool local;

  /// Whether it is featured in its community.
  final bool featuredCommunity;

  /// Whether it is featured on the local instance.
  final bool featuredLocal;

  const PostStatus({required this.deleted, required this.removed, required this.locked, required this.nsfw, required this.local, required this.featuredCommunity, required this.featuredLocal});

  @override
  List<Object?> get props => [deleted, removed, locked, nsfw, local, featuredCommunity, featuredLocal];

  PostStatus copyWith({bool? deleted, bool? removed, bool? locked, bool? nsfw, bool? local, bool? featuredCommunity, bool? featuredLocal}) {
    return PostStatus(
      deleted: deleted ?? this.deleted,
      removed: removed ?? this.removed,
      locked: locked ?? this.locked,
      nsfw: nsfw ?? this.nsfw,
      local: local ?? this.local,
      featuredCommunity: featuredCommunity ?? this.featuredCommunity,
      featuredLocal: featuredLocal ?? this.featuredLocal,
    );
  }
}

class PostCounts extends Equatable {
  /// Net score, when available.
  final int? score;

  /// Number of upvotes, when available.
  final int? upvotes;

  /// Number of downvotes, when available.
  final int? downvotes;

  /// Number of comments.
  final int? comments;

  /// Number of unread comments for the signed-in account.
  final int? unreadComments;

  /// Time of the newest comment, when available.
  final DateTime? newestCommentAt;

  const PostCounts({this.score, this.upvotes, this.downvotes, this.comments, this.unreadComments, this.newestCommentAt});

  @override
  List<Object?> get props => [score, upvotes, downvotes, comments, unreadComments, newestCommentAt];

  PostCounts copyWith({int? score, int? upvotes, int? downvotes, int? comments, int? unreadComments, DateTime? newestCommentAt}) {
    return PostCounts(
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      comments: comments ?? this.comments,
      unreadComments: unreadComments ?? this.unreadComments,
      newestCommentAt: newestCommentAt ?? this.newestCommentAt,
    );
  }
}

class PostContext extends Equatable {
  /// Whether the signed-in account saved it.
  final bool? saved;

  /// Whether the signed-in account has read it.
  final bool? read;

  /// Whether the signed-in account has hidden it.
  final bool? hidden;

  /// The signed-in account's vote.
  final VoteState vote;

  /// Subscription state for the post's community.
  final SubscriptionStatus? subscribed;

  /// Whether the signed-in account blocked the creator.
  final bool? creatorBlocked;

  /// Whether the creator is banned from the community.
  final bool? creatorBannedFromCommunity;

  /// Whether the creator moderates the community.
  final bool? creatorIsModerator;

  /// Whether the creator is an instance admin.
  final bool? creatorIsAdmin;

  /// Whether the signed-in account can moderate this post.
  final bool? canModerate;

  const PostContext({
    this.saved,
    this.read,
    this.hidden,
    this.vote = VoteState.none,
    this.subscribed,
    this.creatorBlocked,
    this.creatorBannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.canModerate,
  });

  @override
  List<Object?> get props => [saved, read, hidden, vote, subscribed, creatorBlocked, creatorBannedFromCommunity, creatorIsModerator, creatorIsAdmin, canModerate];

  PostContext copyWith({
    bool? saved,
    bool? read,
    bool? hidden,
    VoteState? vote,
    SubscriptionStatus? subscribed,
    bool? creatorBlocked,
    bool? creatorBannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    bool? canModerate,
  }) {
    return PostContext(
      saved: saved ?? this.saved,
      read: read ?? this.read,
      hidden: hidden ?? this.hidden,
      vote: vote ?? this.vote,
      subscribed: subscribed ?? this.subscribed,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      canModerate: canModerate ?? this.canModerate,
    );
  }
}
