import 'package:collection/collection.dart';

import 'package:thunder/src/foundation/primitives/enums/feed_list_type.dart';
import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';
import 'package:thunder/src/foundation/primitives/models/media.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';
import 'package:thunder/src/foundation/primitives/models/vote_state.dart';
import 'package:thunder/src/foundation/primitives/enums/post_sort_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_local_user.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_my_user.dart';

import 'package:thunder/src/foundation/networking/mappers/mapper_helpers.dart';
import 'package:thunder/src/foundation/networking/mappers/primitive_mapper.dart';

/// Mapper for Lemmy 0.19.x responses.
class LemmyV3PrimitiveMapper implements PrimitiveMapper {
  const LemmyV3PrimitiveMapper();

  @override
  ThunderPost post(Map<String, dynamic> json, {List<Media> media = const []}) {
    return ThunderPost(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      body: json['body'],
      creatorId: json['creator_id'],
      communityId: json['community_id'],
      published: mapperDate(json['published']) ?? DateTime.now(),
      updated: mapperDate(json['updated']),
      thumbnailUrl: json['thumbnail_url'],
      apId: json['ap_id'],
      embedVideoUrl: json['embed_video_url'],
      languageId: json['language_id'],
      altText: json['alt_text'],
      status: PostStatus(
        deleted: json['deleted'] ?? false,
        removed: json['removed'] ?? false,
        locked: json['locked'] ?? false,
        nsfw: json['nsfw'] ?? false,
        local: json['local'] ?? false,
        featuredCommunity: json['featured_community'] ?? false,
        featuredLocal: json['featured_local'] ?? false,
      ),
      media: media,
    );
  }

  @override
  ThunderPost postView(Map<String, dynamic> json, {List<Media> media = const []}) {
    final postJson = json['post'] as Map<String, dynamic>;
    final creatorJson = json['creator'];
    final communityJson = json['community'];
    final counts = json['counts'];
    final subscribed = mapperSubscriptionStatus(json['subscribed']);

    return post(postJson, media: media).copyWith(
      creator: creatorJson is Map<String, dynamic> ? user(creatorJson) : null,
      community: communityJson is Map<String, dynamic> ? community(communityJson, subscribed: subscribed) : null,
      imageDetails: json['image_details'],
      counts: PostCounts(
        comments: counts?['comments'],
        score: counts?['score'],
        upvotes: counts?['upvotes'],
        downvotes: counts?['downvotes'],
        newestCommentAt: mapperDate(counts?['newest_comment_time']),
        unreadComments: json['unread_comments'],
      ),
      context: PostContext(
        subscribed: subscribed,
        saved: json['saved'],
        read: json['read'],
        hidden: json['hidden'],
        creatorBlocked: json['creator_blocked'],
        creatorBannedFromCommunity: json['creator_banned_from_community'],
        creatorIsModerator: json['creator_is_moderator'],
        creatorIsAdmin: json['creator_is_admin'],
        vote: VoteState.fromScore(json['my_vote']),
      ),
    );
  }

  @override
  ThunderComment comment(Map<String, dynamic> json) {
    return ThunderComment(
      id: json['id'],
      creatorId: json['creator_id'],
      postId: json['post_id'],
      content: json['content'],
      published: mapperDate(json['published']) ?? DateTime.now(),
      updated: mapperDate(json['updated']),
      apId: json['ap_id'],
      path: json['path'],
      languageId: json['language_id'],
      status: CommentStatus(
        deleted: json['deleted'] ?? false,
        removed: json['removed'] ?? false,
        local: json['local'] ?? false,
        distinguished: json['distinguished'] ?? false,
        locked: json['locked'] ?? false,
      ),
    );
  }

  @override
  ThunderComment commentView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final commentJson = json['comment'] as Map<String, dynamic>;
    final counts = json['counts'];

    return comment(commentJson).copyWith(
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      post: json['post'] is Map<String, dynamic> ? post(json['post']) : null,
      community: json['community'] is Map<String, dynamic> ? community(json['community']) : null,
      recipient: json['recipient'] is Map<String, dynamic> ? user(json['recipient']) : null,
      notification: notification,
      counts: CommentCounts(
        score: counts?['score'],
        upvotes: counts?['upvotes'],
        downvotes: counts?['downvotes'],
        childCount: counts?['child_count'],
      ),
      context: CommentContext(
        creatorBannedFromCommunity: json['creator_banned_from_community'],
        bannedFromCommunity: json['banned_from_community'],
        creatorIsModerator: json['creator_is_moderator'],
        creatorIsAdmin: json['creator_is_admin'],
        subscribed: mapperSubscriptionStatus(json['subscribed']),
        saved: json['saved'],
        creatorBlocked: json['creator_blocked'],
        vote: VoteState.fromScore(json['my_vote']),
      ),
    );
  }

  @override
  ThunderUser user(Map<String, dynamic> json) {
    return ThunderUser(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      avatar: json['avatar'],
      published: mapperDate(json['published']) ?? DateTime.now(),
      updated: mapperDate(json['updated']),
      actorId: json['actor_id'],
      bio: json['bio'],
      banner: json['banner'],
      matrixUserId: json['matrix_user_id'],
      instanceId: json['instance_id'],
      status: UserStatus(
        banned: json['banned'] ?? false,
        local: json['local'] ?? false,
        deleted: json['deleted'] ?? false,
        botAccount: json['bot_account'] ?? false,
        banExpires: mapperDate(json['ban_expires']),
      ),
    );
  }

  @override
  ThunderUser userView(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>;
    final counts = json['counts'];
    return user(person).copyWith(
      counts: UserCounts(posts: counts?['post_count'], comments: counts?['comment_count']),
      context: UserContext(isAdmin: json['is_admin'], blocked: json['person_blocked']),
    );
  }

  @override
  ThunderCommunity community(Map<String, dynamic> json, {SubscriptionStatus? subscribed}) {
    return ThunderCommunity(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      description: json['description'],
      published: mapperDate(json['published']) ?? DateTime.now(),
      updated: mapperDate(json['updated']),
      actorId: json['actor_id'],
      icon: json['icon'],
      banner: json['banner'],
      instanceId: json['instance_id'],
      visibility: json['visibility'] ?? 'Public',
      status: CommunityStatus(
        removed: json['removed'] ?? false,
        deleted: json['deleted'] ?? false,
        nsfw: json['nsfw'] ?? false,
        local: json['local'] ?? false,
        hidden: json['hidden'] ?? false,
        postingRestrictedToMods: json['posting_restricted_to_mods'] ?? false,
      ),
      context: CommunityContext(subscribed: subscribed),
    );
  }

  @override
  ThunderCommunity communityView(Map<String, dynamic> json) {
    final communityJson = json['community'] as Map<String, dynamic>;
    final counts = json['counts'];
    return community(communityJson, subscribed: mapperSubscriptionStatus(json['subscribed'])).copyWith(
      counts: CommunityCounts(
        subscribers: counts?['subscribers'],
        subscribersLocal: counts?['subscribers_local'],
        posts: counts?['posts'],
        comments: counts?['comments'],
        usersActiveDay: counts?['users_active_day'],
        usersActiveWeek: counts?['users_active_week'],
        usersActiveMonth: counts?['users_active_month'],
        usersActiveHalfYear: counts?['users_active_half_year'],
      ),
      context: CommunityContext(
        subscribed: mapperSubscriptionStatus(json['subscribed']),
        blocked: json['blocked'],
        bannedFromCommunity: json['banned_from_community'],
        canModerate: json['can_mod'],
      ),
    );
  }

  @override
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final privateMessage = json['private_message'] as Map<String, dynamic>;
    final published = mapperDate(privateMessage['published']) ?? DateTime.now();
    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      conversationId: json['conversation_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'] ?? false,
      published: published,
      recipient: json['recipient'] is Map<String, dynamic> ? user(json['recipient']) : null,
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      notification: notification ?? NotificationRef(id: privateMessage['id'], kind: NotificationKind.privateMessage, read: privateMessage['read'] ?? false, createdAt: published),
    );
  }

  ThunderReport postReportView(Map<String, dynamic> json) {
    final report = json['post_report'];
    final subscribed = mapperSubscriptionStatus(json['subscribed']);
    final postJson = json['post'];
    final counts = json['counts'];
    final mappedPost = postJson is Map<String, dynamic>
        ? post(postJson).copyWith(
            creator: json['post_creator'] is Map<String, dynamic> ? user(json['post_creator']) : null,
            community: json['community'] is Map<String, dynamic> ? community(json['community'], subscribed: subscribed) : null,
            counts: PostCounts(
              comments: counts?['comments'],
              score: counts?['score'],
              upvotes: counts?['upvotes'],
              downvotes: counts?['downvotes'],
              newestCommentAt: mapperDate(counts?['newest_comment_time']),
              unreadComments: json['unread_comments'],
            ),
            context: PostContext(
              subscribed: subscribed,
              saved: json['saved'],
              read: json['read'],
              hidden: json['hidden'],
              creatorBlocked: json['creator_blocked'],
              creatorBannedFromCommunity: json['creator_banned_from_community'],
              creatorIsModerator: json['creator_is_moderator'],
              creatorIsAdmin: json['creator_is_admin'],
              vote: VoteState.fromScore(json['my_vote']),
            ),
          )
        : null;

    return ThunderReport(
      id: report['id'],
      kind: ReportKind.post,
      reason: report['reason'],
      resolved: report['resolved'],
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      post: mappedPost,
      community: json['community'] is Map<String, dynamic> ? community(json['community'], subscribed: subscribed) : null,
    );
  }

  ThunderReport commentReportView(Map<String, dynamic> json) {
    final report = json['comment_report'];
    final mappedComment = json['comment'] is Map<String, dynamic>
        ? commentView({
            ...json,
            'creator': json['comment_creator'],
          })
        : null;

    return ThunderReport(
      id: report['id'],
      kind: ReportKind.comment,
      reason: report['reason'],
      resolved: report['resolved'],
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      post: json['post'] is Map<String, dynamic> ? post(json['post']) : null,
      comment: mappedComment,
      community: json['community'] is Map<String, dynamic> ? community(json['community']) : null,
    );
  }
}

ThunderLocalUser localUserFromLemmyV3(Map<String, dynamic> localUser) {
  return ThunderLocalUser(
    email: localUser['email'],
    showNsfw: localUser['show_nsfw'],
    showNsfl: null,
    defaultSortType: localUser['default_sort_type'] != null ? PostSortType.values.firstWhereOrNull((e) => e.value == localUser['default_sort_type']) : null,
    defaultListingType: localUser['default_listing_type'] != null ? FeedListType.values.firstWhereOrNull((e) => e.value == localUser['default_listing_type']) : null,
    showScores: localUser['show_scores'] ?? true,
    showBotAccounts: localUser['show_bot_accounts'] ?? true,
    showReadPosts: localUser['show_read_posts'] ?? true,
  );
}

ThunderLocalUserView localUserViewFromLemmyV3(Map<String, dynamic> localUserView) {
  const mapper = LemmyV3PrimitiveMapper();
  return ThunderLocalUserView(
    localUser: localUserFromLemmyV3(localUserView['local_user']),
    person: mapper.user(localUserView['person']),
  );
}
