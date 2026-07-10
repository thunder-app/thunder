import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/post/presentation/utils/post_media_utils.dart';

/// Creates a placeholder post for appearance settings previews.
Future<ThunderPost?> createExamplePost({
  String? postTitle,
  String? postUrl,
  String? postBody,
  String? postThumbnailUrl,
  String? postAltText,
  bool? locked,
  bool? nsfw,
  bool? pinned,
  String? personName,
  String? personDisplayName,
  String? personInstance,
  String? communityName,
  String? instanceUrl,
  int? commentCount,
  int? scoreCount,
  bool? saved,
  bool? read,
}) async {
  final post = ThunderPost(
    id: 1,
    name: postTitle ?? 'Example Title',
    url: postUrl,
    body: postBody,
    thumbnailUrl: postThumbnailUrl,
    altText: postAltText,
    creatorId: 1,
    communityId: 1,
    published: DateTime.now(),
    apId: '',
    languageId: 0,
    status: PostStatus(
      deleted: false,
      removed: false,
      locked: locked ?? false,
      nsfw: nsfw ?? false,
      local: false,
      featuredCommunity: pinned ?? false,
      featuredLocal: false,
    ),
    creator: ThunderUser(
      id: 1,
      name: personName ?? 'Example Username',
      displayName: personDisplayName ?? 'Example Name',
      published: DateTime.now(),
      actorId: 'https://$personInstance/u/$personName',
      instanceId: 1,
      status: const UserStatus(banned: false, local: false, deleted: false, botAccount: false),
    ),
    community: ThunderCommunity(
      id: 1,
      name: communityName ?? 'Example Community',
      title: '',
      published: DateTime.now(),
      actorId: instanceUrl ?? 'https://thunder.lemmy',
      instanceId: 1,
      visibility: 'Public',
      status: const CommunityStatus(removed: false, deleted: false, nsfw: false, local: false, hidden: false, postingRestrictedToMods: false),
    ),
    counts: PostCounts(comments: commentCount ?? 0, score: scoreCount ?? 0, upvotes: 0, downvotes: 0, newestCommentAt: DateTime.now(), unreadComments: 0),
    context: PostContext(
      creatorBannedFromCommunity: false,
      subscribed: SubscriptionStatus.notSubscribed,
      saved: saved ?? false,
      read: read ?? false,
      creatorBlocked: false,
    ),
  );

  final posts = await parsePosts([post]);
  return posts.firstOrNull;
}
