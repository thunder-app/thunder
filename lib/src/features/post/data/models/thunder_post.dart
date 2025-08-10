import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/subscription_status.dart';
import 'package:thunder/src/core/models/media.dart';
import 'package:thunder/src/features/user/user.dart';

class ThunderPost {
  /// The post's ID
  final int id;

  /// The post's name
  final String name;

  /// The post's URL
  final String? url;

  /// The post's body
  final String? body;

  /// The post's creator ID
  final int creatorId;

  /// The post's community ID
  final int communityId;

  /// Whether the post is removed
  final bool removed;

  /// Whether the post is locked
  final bool locked;

  /// The post's published date
  final DateTime published;

  /// The post's updated date
  final DateTime? updated;

  /// Whether the post is deleted
  final bool deleted;

  /// Whether the post is NSFW
  final bool nsfw;

  /// The post's embed title
  final String? embedTitle;

  /// The post's embed description
  final String? embedDescription;

  /// The post's thumbnail URL
  final String? thumbnailUrl;

  /// The post's AP ID
  final String apId;

  /// Whether the post is local
  final bool local;

  /// The post's embed video URL
  final String? embedVideoUrl;

  /// The post's language ID
  final int languageId;

  /// Whether the post is featured in the community
  final bool featuredCommunity;

  /// Whether the post is featured on the instance
  final bool featuredLocal;

  /// The post's URL content type
  final String? urlContentType;

  /// The post's alternate text
  final String? altText;

  /// The post's creator
  final ThunderUser? creator;

  /// The post's community
  final ThunderCommunity? community;

  /// The post's image details
  final Map<String, dynamic>? imageDetails;

  /// Whether the post's creator is banned from the community
  final bool? creatorBannedFromCommunity;

  /// Whether the post is banned from the community
  final bool? bannedFromCommunity;

  /// Whether the post's creator is a moderator of the community
  final bool? creatorIsModerator;

  /// Whether the post's creator is an admin of the instance
  final bool? creatorIsAdmin;

  /// The number of comments on the post
  final int? comments;

  /// The score of the post
  final int? score;

  /// The number of upvotes on the post
  final int? upvotes;

  /// The number of downvotes on the post
  final int? downvotes;

  /// The time of the newest comment on the post
  final DateTime? newestCommentTime;

  /// The subscribed status of the post
  final SubscriptionStatus? subscribed;

  /// Whether the post is saved
  final bool? saved;

  /// Whether the post is read
  final bool? read;

  /// Whether the post is hidden
  final bool? hidden;

  /// Whether the post's creator is blocked
  final bool? creatorBlocked;

  /// The vote status of the post
  final int? myVote;

  /// The number of unread comments on the post
  final int? unreadComments;

  /// The media associated with the post
  final List<Media> media;

  ThunderPost({
    required this.id,
    required this.name,
    this.url,
    this.body,
    required this.creatorId,
    required this.communityId,
    required this.removed,
    required this.locked,
    required this.published,
    this.updated,
    required this.deleted,
    required this.nsfw,
    this.embedTitle,
    this.embedDescription,
    this.thumbnailUrl,
    required this.apId,
    required this.local,
    this.embedVideoUrl,
    required this.languageId,
    required this.featuredCommunity,
    required this.featuredLocal,
    this.urlContentType,
    this.altText,
    this.creator,
    this.community,
    this.imageDetails,
    this.creatorBannedFromCommunity,
    this.bannedFromCommunity,
    this.creatorIsModerator,
    this.creatorIsAdmin,
    this.comments,
    this.score,
    this.upvotes,
    this.downvotes,
    this.newestCommentTime,
    this.subscribed,
    this.saved,
    this.read,
    this.hidden,
    this.creatorBlocked,
    this.myVote,
    this.unreadComments,
    this.media = const [],
  });

  ThunderPost copyWith({
    int? id,
    String? name,
    String? url,
    String? body,
    int? creatorId,
    int? communityId,
    bool? removed,
    bool? locked,
    DateTime? published,
    DateTime? updated,
    bool? deleted,
    bool? nsfw,
    String? embedTitle,
    String? embedDescription,
    String? thumbnailUrl,
    String? apId,
    bool? local,
    String? embedVideoUrl,
    int? languageId,
    bool? featuredCommunity,
    bool? featuredLocal,
    String? urlContentType,
    String? altText,
    ThunderUser? creator,
    ThunderCommunity? community,
    Map<String, dynamic>? imageDetails,
    bool? creatorBannedFromCommunity,
    bool? bannedFromCommunity,
    bool? creatorIsModerator,
    bool? creatorIsAdmin,
    int? comments,
    int? score,
    int? upvotes,
    int? downvotes,
    DateTime? newestCommentTime,
    SubscriptionStatus? subscribed,
    bool? saved,
    bool? read,
    bool? hidden,
    bool? creatorBlocked,
    int? myVote,
    int? unreadComments,
    List<Media>? media,
  }) {
    return ThunderPost(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      body: body ?? this.body,
      creatorId: creatorId ?? this.creatorId,
      communityId: communityId ?? this.communityId,
      removed: removed ?? this.removed,
      locked: locked ?? this.locked,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      deleted: deleted ?? this.deleted,
      nsfw: nsfw ?? this.nsfw,
      embedTitle: embedTitle ?? this.embedTitle,
      embedDescription: embedDescription ?? this.embedDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      apId: apId ?? this.apId,
      local: local ?? this.local,
      embedVideoUrl: embedVideoUrl ?? this.embedVideoUrl,
      languageId: languageId ?? this.languageId,
      featuredCommunity: featuredCommunity ?? this.featuredCommunity,
      featuredLocal: featuredLocal ?? this.featuredLocal,
      urlContentType: urlContentType ?? this.urlContentType,
      altText: altText ?? this.altText,
      creator: creator ?? this.creator,
      community: community ?? this.community,
      imageDetails: imageDetails ?? this.imageDetails,
      creatorBannedFromCommunity: creatorBannedFromCommunity ?? this.creatorBannedFromCommunity,
      bannedFromCommunity: bannedFromCommunity ?? this.bannedFromCommunity,
      creatorIsModerator: creatorIsModerator ?? this.creatorIsModerator,
      creatorIsAdmin: creatorIsAdmin ?? this.creatorIsAdmin,
      comments: comments ?? this.comments,
      score: score ?? this.score,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      newestCommentTime: newestCommentTime ?? this.newestCommentTime,
      subscribed: subscribed ?? this.subscribed,
      saved: saved ?? this.saved,
      read: read ?? this.read,
      hidden: hidden ?? this.hidden,
      creatorBlocked: creatorBlocked ?? this.creatorBlocked,
      myVote: myVote ?? this.myVote,
      unreadComments: unreadComments ?? this.unreadComments,
      media: media ?? this.media,
    );
  }

  factory ThunderPost.fromLemmyPost(Map<String, dynamic> post, {List<Media> media = const []}) {
    return ThunderPost(
      id: post['id'],
      name: post['name'],
      url: post['url'],
      body: post['body'],
      creatorId: post['creator_id'],
      communityId: post['community_id'],
      removed: post['removed'],
      locked: post['locked'],
      published: DateTime.parse(post['published']),
      updated: post['updated'] != null ? DateTime.parse(post['updated']) : null,
      deleted: post['deleted'],
      nsfw: post['nsfw'],
      embedTitle: post['embed_title'],
      embedDescription: post['embed_description'],
      thumbnailUrl: post['thumbnail_url'],
      apId: post['ap_id'],
      local: post['local'],
      languageId: post['language_id'],
      featuredCommunity: post['featured_community'],
      featuredLocal: post['featured_local'],
      urlContentType: post['url_content_type'],
      altText: post['alt_text'],
      media: media,
    );
  }

  factory ThunderPost.fromLemmyPostView(Map<String, dynamic> postView, {List<Media> media = const []}) {
    final post = postView['post'];
    final creator = postView['creator'];
    final community = postView['community'];
    final imageDetails = postView['image_details'];
    final counts = postView['counts'];

    final subscribed = postView['subscribed'] != null ? SubscriptionStatus.values.firstWhere((e) => e.name == postView['subscribed']) : null;

    return ThunderPost(
      id: post['id'],
      name: post['name'],
      url: post['url'],
      body: post['body'],
      creatorId: post['creator_id'],
      communityId: post['community_id'],
      removed: post['removed'],
      locked: post['locked'],
      published: DateTime.parse(post['published']),
      updated: post['updated'] != null ? DateTime.parse(post['updated']) : null,
      deleted: post['deleted'],
      nsfw: post['nsfw'],
      embedTitle: post['embed_title'],
      embedDescription: post['embed_description'],
      thumbnailUrl: post['thumbnail_url'],
      apId: post['ap_id'],
      local: post['local'],
      languageId: post['language_id'],
      featuredCommunity: post['featured_community'],
      featuredLocal: post['featured_local'],
      urlContentType: post['url_content_type'],
      altText: post['alt_text'],
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
      community: community != null ? ThunderCommunity.fromLemmyCommunity(community, subscribed: subscribed) : null,
      imageDetails: imageDetails,
      creatorBannedFromCommunity: postView['creator_banned_from_community'],
      bannedFromCommunity: postView['banned_from_community'],
      creatorIsModerator: postView['creator_is_moderator'],
      creatorIsAdmin: postView['creator_is_admin'],
      comments: counts['comments'],
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      newestCommentTime: counts['newest_comment_time'] != null ? DateTime.parse(counts['newest_comment_time']) : null,
      subscribed: subscribed,
      saved: postView['saved'],
      read: postView['read'],
      hidden: postView['hidden'],
      creatorBlocked: postView['creator_blocked'],
      myVote: postView['my_vote'],
      unreadComments: postView['unread_comments'],
      media: media,
    );
  }

  factory ThunderPost.fromPiefedPostView(Map<String, dynamic> postView, {List<Media> media = const []}) {
    final post = postView['post'];
    final creator = postView['creator'];
    final community = postView['community'];
    final counts = postView['counts'];

    final subscribed = postView['subscribed'] != null ? SubscriptionStatus.values.firstWhere((e) => e.name == postView['subscribed']) : null;

    return ThunderPost(
      id: post['id'],
      name: post['title'],
      url: post['url'],
      body: post['body'],
      creatorId: post['user_id'],
      communityId: post['community_id'],
      removed: post['removed'],
      locked: post['locked'],
      published: DateTime.parse(post['published']),
      updated: post['edited_at'] != null ? DateTime.parse(post['edited_at']) : null,
      deleted: post['deleted'],
      nsfw: post['nsfw'],
      // embedTitle // Not available in PieFed
      // embedDescription // Not available in PieFed
      // embedVideoUrl // Not available in PieFed
      thumbnailUrl: post['thumbnail_url'],
      apId: post['ap_id'],
      local: post['local'],
      languageId: post['language_id'],
      featuredCommunity: post['sticky'],
      featuredLocal: false, // Not available in PieFed
      // urlContentType // Not available in PieFed
      altText: post['alt_text'],
      creator: ThunderUser.fromPiefedUser(creator),
      community: ThunderCommunity.fromPiefedCommunity(community, subscribed: subscribed),
      // imageDetails // Not available in PieFed
      creatorBannedFromCommunity: postView['creator_banned_from_community'],
      bannedFromCommunity: postView['banned_from_community'],
      creatorIsModerator: postView['creator_is_moderator'],
      creatorIsAdmin: postView['creator_is_admin'],
      comments: counts['comments'],
      score: counts['score'],
      upvotes: counts['upvotes'],
      downvotes: counts['downvotes'],
      newestCommentTime: counts['newest_comment_time'] != null ? DateTime.parse(counts['newest_comment_time']) : null,
      subscribed: subscribed,
      saved: postView['saved'],
      read: postView['read'],
      hidden: postView['hidden'],
      // creatorBlocked // Not available in PieFed
      myVote: postView['my_vote'],
      unreadComments: postView['unread_comments'],
      media: media,
    );
  }

  factory ThunderPost.fromPiefedPost(Map<String, dynamic> post, {List<Media> media = const []}) {
    return ThunderPost(
      id: post['id'],
      name: post['title'],
      url: post['url'],
      body: post['body'],
      creatorId: post['user_id'],
      communityId: post['community_id'],
      removed: post['removed'],
      locked: post['locked'],
      published: DateTime.parse(post['published']),
      updated: post['updated'] != null ? DateTime.parse(post['updated']) : null,
      deleted: post['deleted'],
      nsfw: post['nsfw'],
      // embedTitle // Not available in PieFed
      // embedDescription // Not available in PieFed
      thumbnailUrl: post['thumbnail_url'],
      apId: post['ap_id'],
      local: post['local'],
      languageId: post['language_id'],
      featuredCommunity: post['sticky'],
      featuredLocal: false, // Not available in PieFed
      // urlContentType // Not available in PieFed
      altText: post['alt_text'],
      media: media,
    );
  }
}
