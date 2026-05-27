import 'package:collection/collection.dart';

import 'package:thunder/src/foundation/primitives/enums/feed_list_type.dart';
import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';
import 'package:thunder/src/foundation/primitives/models/media.dart';
import 'package:thunder/src/foundation/primitives/models/piefed_post_metadata.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_content_item.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_flair.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';
import 'package:thunder/src/foundation/primitives/models/vote_state.dart';
import 'package:thunder/src/foundation/primitives/enums/post_sort_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_local_user.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_my_user.dart';

/// Turns platform responses into Thunder models.
abstract class PrimitiveMapper {
  /// Builds a post from a platform post object.
  ThunderPost post(Map<String, dynamic> json, {List<Media> media = const []});

  /// Builds a post from a platform post view.
  ThunderPost postView(Map<String, dynamic> json, {List<Media> media = const []});

  /// Builds a comment from a platform comment object.
  ThunderComment comment(Map<String, dynamic> json);

  /// Builds a comment from a platform comment view.
  ThunderComment commentView(Map<String, dynamic> json, {NotificationRef? notification});

  /// Builds a user from a platform person object.
  ThunderUser user(Map<String, dynamic> json);

  /// Builds a user from a platform person view.
  ThunderUser userView(Map<String, dynamic> json);

  /// Builds a community from a platform community object.
  ThunderCommunity community(Map<String, dynamic> json, {SubscriptionStatus? subscribed});

  /// Builds a community from a platform community view.
  ThunderCommunity communityView(Map<String, dynamic> json);

  /// Builds a private message from a platform message view.
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification});
}

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
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated']),
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
    final subscribed = _subscriptionStatus(json['subscribed']);

    return post(postJson, media: media).copyWith(
      creator: creatorJson is Map<String, dynamic> ? user(creatorJson) : null,
      community: communityJson is Map<String, dynamic> ? community(communityJson, subscribed: subscribed) : null,
      imageDetails: json['image_details'],
      counts: PostCounts(
        comments: counts?['comments'],
        score: counts?['score'],
        upvotes: counts?['upvotes'],
        downvotes: counts?['downvotes'],
        newestCommentAt: _date(counts?['newest_comment_time']),
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
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated']),
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
        subscribed: _subscriptionStatus(json['subscribed']),
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
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated']),
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
        banExpires: _date(json['ban_expires']),
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
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated']),
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
    return community(communityJson, subscribed: _subscriptionStatus(json['subscribed'])).copyWith(
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
        subscribed: _subscriptionStatus(json['subscribed']),
        blocked: json['blocked'],
        bannedFromCommunity: json['banned_from_community'],
        canModerate: json['can_mod'],
      ),
    );
  }

  @override
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final privateMessage = json['private_message'] as Map<String, dynamic>;
    final published = _date(privateMessage['published']) ?? DateTime.now();
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
    final subscribed = _subscriptionStatus(json['subscribed']);
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
              newestCommentAt: _date(counts?['newest_comment_time']),
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

/// Mapper for Lemmy 1.0.0 responses.
class LemmyV4PrimitiveMapper extends LemmyV3PrimitiveMapper {
  const LemmyV4PrimitiveMapper();

  @override
  ThunderPost post(Map<String, dynamic> json, {List<Media> media = const []}) {
    return ThunderPost(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      body: json['body'],
      creatorId: json['creator_id'],
      communityId: json['community_id'],
      published: _date(json['published_at']) ?? DateTime.now(),
      updated: _date(json['updated_at']),
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
      counts: PostCounts(
        comments: json['comments'],
        score: json['score'],
        upvotes: json['upvotes'],
        downvotes: json['downvotes'],
        newestCommentAt: _date(json['newest_comment_time_at']),
      ),
      media: media,
    );
  }

  @override
  ThunderPost postView(Map<String, dynamic> json, {List<Media> media = const []}) {
    final actions = json['post_actions'];
    final communityActions = json['community_actions'];
    return post(json['post'], media: media).copyWith(
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      community: json['community'] is Map<String, dynamic> ? communityView(json) : null,
      imageDetails: json['image_details'],
      context: PostContext(
        saved: actions?['saved_at'] != null,
        read: actions?['read_at'] != null,
        hidden: actions?['hidden_at'] != null,
        vote: VoteState.fromIsUpvote(actions?['vote_is_upvote']),
        subscribed: _v4SubscriptionStatus(communityActions?['follow_state']),
        creatorBlocked: json['person_actions']?['blocked_at'] != null,
        creatorBannedFromCommunity: json['creator_banned_from_community'],
        creatorIsModerator: json['creator_is_moderator'],
        creatorIsAdmin: json['creator_is_admin'],
        canModerate: json['can_mod'],
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
      published: _date(json['published_at']) ?? DateTime.now(),
      updated: _date(json['updated_at']),
      apId: json['ap_id'],
      path: json['path'],
      languageId: json['language_id'],
      counts: CommentCounts(
        score: json['score'],
        upvotes: json['upvotes'],
        downvotes: json['downvotes'],
        childCount: json['child_count'],
      ),
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
    final actions = json['comment_actions'];
    final communityActions = json['community_actions'];
    return comment(json['comment']).copyWith(
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      post: json['post'] is Map<String, dynamic> ? post(json['post']) : null,
      community: json['community'] is Map<String, dynamic> ? community(json['community']) : null,
      notification: notification,
      context: CommentContext(
        subscribed: _v4SubscriptionStatus(communityActions?['follow_state']),
        saved: actions?['saved_at'] != null,
        creatorBlocked: json['person_actions']?['blocked_at'] != null,
        creatorBannedFromCommunity: json['creator_banned_from_community'],
        creatorIsModerator: json['creator_is_moderator'],
        creatorIsAdmin: json['creator_is_admin'],
        canModerate: json['can_mod'],
        vote: VoteState.fromIsUpvote(actions?['vote_is_upvote']),
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
      published: _date(json['published_at']) ?? DateTime.now(),
      updated: _date(json['updated_at']),
      actorId: json['ap_id'],
      bio: json['bio'],
      banner: json['banner'],
      matrixUserId: json['matrix_user_id'],
      instanceId: json['instance_id'],
      counts: UserCounts(posts: json['post_count'], comments: json['comment_count']),
      status: UserStatus(
        banned: json['banned'] ?? false,
        local: json['local'] ?? false,
        deleted: json['deleted'] ?? false,
        botAccount: json['bot_account'] ?? false,
        banExpires: _date(json['ban_expires_at']),
      ),
    );
  }

  @override
  ThunderUser userView(Map<String, dynamic> json) {
    final person = user(json['person']);
    final actions = json['person_actions'];
    return person.copyWith(
      context: UserContext(
        isAdmin: json['is_admin'],
        blocked: actions?['blocked_at'] != null,
        note: actions?['note'],
      ),
    );
  }

  @override
  ThunderCommunity community(Map<String, dynamic> json, {SubscriptionStatus? subscribed}) {
    return ThunderCommunity(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      description: json['description'] ?? json['summary'],
      published: _date(json['published_at']) ?? DateTime.now(),
      updated: _date(json['updated_at']),
      actorId: json['ap_id'],
      icon: json['icon'],
      banner: json['banner'],
      instanceId: json['instance_id'],
      visibility: json['visibility'] ?? 'public',
      status: CommunityStatus(
        removed: json['removed'] ?? json['local_removed'] ?? false,
        deleted: json['deleted'] ?? false,
        nsfw: json['nsfw'] ?? false,
        local: json['local'] ?? false,
        hidden: false,
        postingRestrictedToMods: json['posting_restricted_to_mods'] ?? false,
      ),
      counts: CommunityCounts(
        subscribers: json['subscribers'],
        subscribersLocal: json['subscribers_local'],
        posts: json['posts'],
        comments: json['comments'],
        usersActiveDay: json['users_active_day'],
        usersActiveWeek: json['users_active_week'],
        usersActiveMonth: json['users_active_month'],
        usersActiveHalfYear: json['users_active_half_year'],
      ),
      context: CommunityContext(subscribed: subscribed),
    );
  }

  @override
  ThunderCommunity communityView(Map<String, dynamic> json) {
    final actions = json['community_actions'];
    return community(json['community'], subscribed: _v4SubscriptionStatus(actions?['follow_state'])).copyWith(
      context: CommunityContext(
        subscribed: _v4SubscriptionStatus(actions?['follow_state']),
        blocked: actions?['blocked_at'] != null,
        bannedFromCommunity: actions?['received_ban_at'] != null,
        canModerate: json['can_mod'],
      ),
    );
  }

  @override
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final privateMessage = json['private_message'] as Map<String, dynamic>;
    final published = _date(privateMessage['published_at']) ?? DateTime.now();
    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'] ?? false,
      published: published,
      recipient: json['recipient'] is Map<String, dynamic> ? user(json['recipient']) : null,
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      notification: notification ?? NotificationRef(id: privateMessage['id'], kind: NotificationKind.privateMessage, read: privateMessage['read'] ?? false, createdAt: published),
    );
  }

  ThunderContentItem contentItem(Map<String, dynamic> json) {
    return switch (json['type_']) {
      'post' => ThunderPostItem(postView(json)),
      'comment' => ThunderCommentItem(commentView(json)),
      _ => throw FormatException('Unsupported content item type: ${json['type_']}'),
    };
  }

  NotificationRef notificationRef(Map<String, dynamic> json) {
    final notification = json['notification'];
    return NotificationRef(
      id: notification['id'],
      kind: _notificationKind(notification['kind']),
      read: notification['read'] ?? false,
      createdAt: _date(notification['published_at']) ?? DateTime.now(),
    );
  }

  @override
  ThunderReport postReportView(Map<String, dynamic> json) {
    final report = json['post_report'];
    final actions = json['post_actions'];
    final communityActions = json['community_actions'];
    final postJson = json['post'];
    final mappedPost = postJson is Map<String, dynamic>
        ? post(postJson).copyWith(
            creator: json['post_creator'] is Map<String, dynamic> ? user(json['post_creator']) : null,
            community: json['community'] is Map<String, dynamic> ? communityView(json) : null,
            context: PostContext(
              saved: actions?['saved_at'] != null,
              read: actions?['read_at'] != null,
              hidden: actions?['hidden_at'] != null,
              vote: VoteState.fromIsUpvote(actions?['vote_is_upvote']),
              subscribed: _v4SubscriptionStatus(communityActions?['follow_state']),
              creatorBlocked: json['person_actions']?['blocked_at'] != null,
              creatorBannedFromCommunity: json['creator_banned_from_community'],
              creatorIsModerator: json['creator_is_moderator'],
              creatorIsAdmin: json['creator_is_admin'],
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
      community: json['community'] is Map<String, dynamic> ? community(json['community'], subscribed: _v4SubscriptionStatus(communityActions?['follow_state'])) : null,
    );
  }

  @override
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

  ThunderReport reportView(Map<String, dynamic> json) {
    return switch (json['type_']) {
      'post' => postReportView(json),
      'comment' => commentReportView(json),
      'private_message' => _privateMessageReportView(json),
      'community' => _communityReportView(json),
      _ => throw FormatException('Unsupported report type: ${json['type_']}'),
    };
  }

  ThunderReport _privateMessageReportView(Map<String, dynamic> json) {
    final report = json['private_message_report'];
    final privateMessage = json['private_message'];
    return ThunderReport(
      id: report['id'],
      kind: ReportKind.privateMessage,
      reason: report['reason'],
      resolved: report['resolved'],
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      privateMessage: privateMessage is Map<String, dynamic>
          ? ThunderPrivateMessage(
              id: privateMessage['id'],
              creatorId: privateMessage['creator_id'],
              recipientId: privateMessage['recipient_id'],
              content: privateMessage['content'],
              deleted: privateMessage['deleted'] ?? false,
              published: _date(privateMessage['published_at']) ?? DateTime.now(),
              creator: json['private_message_creator'] is Map<String, dynamic> ? user(json['private_message_creator']) : null,
            )
          : null,
    );
  }

  ThunderReport _communityReportView(Map<String, dynamic> json) {
    final report = json['community_report'];
    return ThunderReport(
      id: report['id'],
      kind: ReportKind.community,
      reason: report['reason'],
      resolved: report['resolved'],
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      community: json['community'] is Map<String, dynamic> ? community(json['community']) : null,
    );
  }
}

/// Mapper for PieFed responses.
class PiefedPrimitiveMapper implements PrimitiveMapper {
  const PiefedPrimitiveMapper();

  @override
  ThunderPost post(Map<String, dynamic> json, {List<Media> media = const []}) {
    return ThunderPost(
      id: json['id'],
      name: json['title'],
      url: json['url'],
      body: json['body'],
      creatorId: json['user_id'],
      communityId: json['community_id'],
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated'] ?? json['edited_at']),
      thumbnailUrl: json['thumbnail_url'],
      apId: json['ap_id'],
      languageId: json['language_id'],
      altText: json['alt_text'],
      status: PostStatus(
        deleted: json['deleted'] ?? false,
        removed: json['removed'] ?? false,
        locked: json['locked'] ?? false,
        nsfw: json['nsfw'] ?? false,
        local: json['local'] ?? false,
        featuredCommunity: json['sticky'] ?? false,
        featuredLocal: false,
      ),
      tags: parsePiefedTags(json['tags']),
      flairs: ThunderFlair.parsePiefedList(json['flair_list']),
      media: media,
    );
  }

  @override
  ThunderPost postView(Map<String, dynamic> json, {List<Media> media = const []}) {
    final subscribed = _subscriptionStatus(json['subscribed']);
    final counts = json['counts'];
    return post(json['post'], media: media).copyWith(
      creator: json['creator'] is Map<String, dynamic> ? user(json['creator']) : null,
      community: json['community'] is Map<String, dynamic> ? community(json['community'], subscribed: subscribed) : null,
      imageDetails: json['post']?['image_details'],
      tags: parsePiefedTags(json['post']?['tags']),
      flairs: ThunderFlair.parsePiefedList(json['flair_list']),
      counts: PostCounts(
        comments: counts?['comments'],
        score: counts?['score'],
        upvotes: counts?['upvotes'],
        downvotes: counts?['downvotes'],
        newestCommentAt: _date(counts?['newest_comment_time']),
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
      creatorId: json['user_id'],
      postId: json['post_id'],
      content: json['body'],
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated']),
      apId: json['ap_id'],
      path: json['path'],
      languageId: json['language_id'],
      status: CommentStatus(
        deleted: json['deleted'] ?? false,
        removed: json['removed'] ?? false,
        local: json['local'] ?? false,
        distinguished: json['distinguished'] ?? false,
      ),
    );
  }

  @override
  ThunderComment commentView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final counts = json['counts'];
    return comment(json['comment']).copyWith(
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
        subscribed: _subscriptionStatus(json['subscribed']),
        saved: json['saved'],
        creatorBlocked: json['creator_blocked'],
        creatorBannedFromCommunity: json['creator_banned_from_community'],
        bannedFromCommunity: json['banned_from_community'],
        creatorIsModerator: json['creator_is_moderator'],
        creatorIsAdmin: json['creator_is_admin'],
        vote: VoteState.fromScore(json['my_vote']),
      ),
    );
  }

  @override
  ThunderUser user(Map<String, dynamic> json) {
    return ThunderUser(
      id: json['id'],
      name: json['user_name'],
      displayName: json['title'],
      avatar: json['avatar'],
      published: _date(json['published']) ?? DateTime.now(),
      actorId: json['actor_id'],
      bio: json['about'],
      banner: json['banner'],
      instanceId: json['instance_id'],
      status: UserStatus(
        banned: json['banned'] ?? false,
        local: json['local'] ?? false,
        deleted: json['deleted'] ?? false,
        botAccount: json['bot'] ?? false,
      ),
    );
  }

  @override
  ThunderUser userView(Map<String, dynamic> json) {
    final counts = json['counts'];
    return user(json['person']).copyWith(
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
      published: _date(json['published']) ?? DateTime.now(),
      updated: _date(json['updated']),
      actorId: json['actor_id'],
      icon: json['icon'],
      banner: json['banner'],
      instanceId: json['instance_id'],
      visibility: 'Public',
      status: CommunityStatus(
        removed: json['removed'] ?? false,
        deleted: json['deleted'] ?? false,
        nsfw: json['nsfw'] ?? false,
        local: json['local'] ?? false,
        hidden: json['hidden'] ?? false,
        postingRestrictedToMods: json['restricted_to_mods'] ?? false,
      ),
      context: CommunityContext(subscribed: subscribed, bannedFromCommunity: json['banned']),
    );
  }

  @override
  ThunderCommunity communityView(Map<String, dynamic> json) {
    final counts = json['counts'];
    final subscribed = _subscriptionStatus(json['subscribed']);
    return community(json['community'], subscribed: subscribed).copyWith(
      counts: CommunityCounts(
        subscribers: counts?['total_subscriptions_count'],
        subscribersLocal: counts?['subscriptions_count'],
        posts: counts?['post_count'],
        comments: counts?['post_reply_count'],
        usersActiveDay: counts?['active_daily'],
        usersActiveWeek: counts?['active_weekly'],
        usersActiveMonth: counts?['active_monthly'],
        usersActiveHalfYear: counts?['active_6monthly'],
      ),
      context: CommunityContext(subscribed: subscribed, blocked: json['blocked'], bannedFromCommunity: json['community']?['banned']),
    );
  }

  @override
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final privateMessage = json['private_message'];
    final published = _date(privateMessage['published']) ?? DateTime.now();
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

ThunderLocalUser localUserFromLemmyV4(Map<String, dynamic> localUser) {
  return ThunderLocalUser(
    email: localUser['email'],
    showNsfw: localUser['show_nsfw'] ?? false,
    showNsfl: null,
    defaultSortType: _postSortType(localUser['default_post_sort_type']),
    defaultListingType: _feedListType(localUser['default_listing_type']),
    showScores: localUser['show_score'] ?? true,
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

ThunderLocalUserView localUserViewFromLemmyV4(Map<String, dynamic> localUserView) {
  const mapper = LemmyV4PrimitiveMapper();
  return ThunderLocalUserView(
    localUser: localUserFromLemmyV4(localUserView['local_user']),
    person: mapper.user(localUserView['person']),
  );
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

SubscriptionStatus? _subscriptionStatus(dynamic value) {
  if (value == null) return null;
  return SubscriptionStatus.values.firstWhereOrNull((status) => status.name == value);
}

SubscriptionStatus? _v4SubscriptionStatus(dynamic value) {
  return switch (value) {
    'accepted' => SubscriptionStatus.subscribed,
    'pending' || 'approval_required' => SubscriptionStatus.pending,
    'denied' => SubscriptionStatus.notSubscribed,
    _ => null,
  };
}

PostSortType? _postSortType(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return PostSortType.values.firstWhereOrNull((sort) => sort.value.toLowerCase() == normalized || sort.name.toLowerCase() == normalized);
}

FeedListType? _feedListType(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return FeedListType.values.firstWhereOrNull((type) => type.value.toLowerCase() == normalized || type.name.toLowerCase() == normalized);
}

NotificationKind _notificationKind(dynamic value) {
  return switch (value) {
    'mention' => NotificationKind.mention,
    'reply' => NotificationKind.reply,
    'subscribed' => NotificationKind.subscribed,
    'private_message' => NotificationKind.privateMessage,
    'mod_action' => NotificationKind.modAction,
    _ => NotificationKind.reply,
  };
}
