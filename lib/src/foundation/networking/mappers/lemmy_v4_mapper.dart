import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';
import 'package:thunder/src/foundation/primitives/models/media.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_content_item.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';
import 'package:thunder/src/foundation/primitives/models/vote_state.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_local_user.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_my_user.dart';

import 'package:thunder/src/foundation/networking/mappers/mapper_helpers.dart';
import 'package:thunder/src/foundation/networking/mappers/lemmy_v3_mapper.dart';

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
      published: mapperDate(json['published_at']) ?? DateTime.now(),
      updated: mapperDate(json['updated_at']),
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
        newestCommentAt: mapperDate(json['newest_comment_time_at']),
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
        subscribed: mapperV4SubscriptionStatus(communityActions?['follow_state']),
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
      published: mapperDate(json['published_at']) ?? DateTime.now(),
      updated: mapperDate(json['updated_at']),
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
        subscribed: mapperV4SubscriptionStatus(communityActions?['follow_state']),
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
      published: mapperDate(json['published_at']) ?? DateTime.now(),
      updated: mapperDate(json['updated_at']),
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
        banExpires: mapperDate(json['ban_expires_at']),
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
      published: mapperDate(json['published_at']) ?? DateTime.now(),
      updated: mapperDate(json['updated_at']),
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
    return community(json['community'], subscribed: mapperV4SubscriptionStatus(actions?['follow_state'])).copyWith(
      context: CommunityContext(
        subscribed: mapperV4SubscriptionStatus(actions?['follow_state']),
        blocked: actions?['blocked_at'] != null,
        bannedFromCommunity: actions?['received_ban_at'] != null,
        canModerate: json['can_mod'],
      ),
    );
  }

  @override
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification}) {
    final privateMessage = json['private_message'] as Map<String, dynamic>;
    final published = mapperDate(privateMessage['published_at']) ?? DateTime.now();
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
      kind: mapperNotificationKind(notification['kind']),
      read: notification['read'] ?? false,
      createdAt: mapperDate(notification['published_at']) ?? DateTime.now(),
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
              subscribed: mapperV4SubscriptionStatus(communityActions?['follow_state']),
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
      community: json['community'] is Map<String, dynamic> ? community(json['community'], subscribed: mapperV4SubscriptionStatus(communityActions?['follow_state'])) : null,
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
              published: mapperDate(privateMessage['published_at']) ?? DateTime.now(),
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

ThunderLocalUser localUserFromLemmyV4(Map<String, dynamic> localUser) {
  return ThunderLocalUser(
    email: localUser['email'],
    showNsfw: localUser['show_nsfw'] ?? false,
    showNsfl: null,
    defaultSortType: mapperPostSortType(localUser['default_post_sort_type']),
    defaultListingType: mapperFeedListType(localUser['default_listing_type']),
    showScores: localUser['show_score'] ?? true,
    showBotAccounts: localUser['show_bot_accounts'] ?? true,
    showReadPosts: localUser['show_read_posts'] ?? true,
  );
}

ThunderLocalUserView localUserViewFromLemmyV4(Map<String, dynamic> localUserView) {
  const mapper = LemmyV4PrimitiveMapper();
  return ThunderLocalUserView(
    localUser: localUserFromLemmyV4(localUserView['local_user']),
    person: mapper.user(localUserView['person']),
  );
}
