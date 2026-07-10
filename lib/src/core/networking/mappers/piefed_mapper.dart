import 'package:thunder/src/core/domain/enums/subscription_status.dart';
import 'package:thunder/src/core/domain/models/media.dart';
import 'package:thunder/src/core/domain/models/piefed_post_metadata.dart';
import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_flair.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_private_message.dart';
import 'package:thunder/src/core/domain/models/thunder_report.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
import 'package:thunder/src/core/domain/models/notification_ref.dart';
import 'package:thunder/src/core/domain/models/vote_state.dart';

import 'package:thunder/src/core/networking/mappers/mapper_helpers.dart';
import 'package:thunder/src/core/networking/mappers/primitive_mapper.dart';

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
      published: mapperDate(json['published']) ?? DateTime.now(),
      updated: mapperDate(json['updated'] ?? json['edited_at']),
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
    final subscribed = mapperSubscriptionStatus(json['subscribed']);
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
      creatorId: json['user_id'],
      postId: json['post_id'],
      content: json['body'],
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
        subscribed: mapperSubscriptionStatus(json['subscribed']),
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
      published: mapperDate(json['published']) ?? DateTime.now(),
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
      published: mapperDate(json['published']) ?? DateTime.now(),
      updated: mapperDate(json['updated']),
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
    final subscribed = mapperSubscriptionStatus(json['subscribed']);
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
