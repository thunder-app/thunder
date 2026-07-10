import 'package:thunder/src/core/core.dart';

const testLocalization = TestLocalizationService();

final testPublished = DateTime.utc(2026, 1, 1);

Account loggedInAccount({String id = '1'}) => Account(
      id: id,
      index: 0,
      instance: 'thunder.test',
      username: 'thunder',
      jwt: 'jwt',
      userId: 42,
    );

Account anonymousAccount({String id = '2'}) => Account(
      id: id,
      index: 1,
      anonymous: true,
      instance: 'thunder.test',
    );

const testPostStatus = PostStatus(
  deleted: false,
  removed: false,
  locked: false,
  nsfw: false,
  local: true,
  featuredCommunity: false,
  featuredLocal: false,
);

const testUserStatus = UserStatus(
  banned: false,
  local: true,
  deleted: false,
  botAccount: false,
);

const testCommunityStatus = CommunityStatus(
  removed: false,
  deleted: false,
  nsfw: false,
  local: true,
  hidden: false,
  postingRestrictedToMods: false,
);

const testCommentStatus = CommentStatus(
  deleted: false,
  removed: false,
  local: true,
  distinguished: false,
);

ThunderUser testUser({int id = 1, String name = 'thunder'}) => ThunderUser(
      id: id,
      name: name,
      published: testPublished,
      actorId: 'https://thunder.test/u/$name',
      instanceId: 1,
      status: testUserStatus,
    );

ThunderCommunity testCommunity({int id = 10, String name = 'test'}) => ThunderCommunity(
      id: id,
      name: name,
      title: 'Test Community',
      published: testPublished,
      actorId: 'https://thunder.test/c/$name',
      instanceId: 1,
      visibility: 'Public',
      status: testCommunityStatus,
    );

ThunderPost testPost({
  int id = 100,
  String name = 'Test post',
  String? body = 'Body',
  List<Media>? media,
}) =>
    ThunderPost(
      id: id,
      name: name,
      body: body,
      creatorId: 1,
      communityId: 10,
      published: testPublished,
      apId: 'https://thunder.test/post/$id',
      languageId: 0,
      status: testPostStatus,
      media: media ?? const [],
    );

ThunderComment testComment({int id = 200, int postId = 100}) => ThunderComment(
      id: id,
      creatorId: 1,
      postId: postId,
      content: 'Comment body',
      published: testPublished,
      apId: 'https://thunder.test/comment/$id',
      path: '0.1',
      languageId: 0,
      status: testCommentStatus,
    );

ThunderSiteResponse testSiteResponse({ThunderMyUser? myUser}) => ThunderSiteResponse(
      site: ThunderSite(name: 'Test Site', actorId: 'https://thunder.test'),
      version: '0.19.0',
      myUser: myUser,
    );

ThunderMyUser testMyUser({List<ThunderCommunity>? follows}) => ThunderMyUser(
      localUserView: ThunderLocalUserView(
        localUser: ThunderLocalUser(
          showNsfw: false,
          showScores: true,
          showBotAccounts: true,
          showReadPosts: true,
        ),
        person: testUser(),
      ),
      follows: follows ?? const [],
      moderates: const [],
      communityBlocks: const [],
      instanceBlocks: const [],
      personBlocks: const [],
    );

ModlogEvent testModlogEvent() => ModlogEvent(
      type: ModlogActionType.modRemovePost,
      dateTime: '2026-01-01T00:00:00Z',
      actioned: true,
    );

Media testMedia({String url = 'https://example.com/image.png'}) => Media(
      mediaUrl: url,
      mediaType: MediaType.image,
    );
