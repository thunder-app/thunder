import 'package:drift/native.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';

void main() {
  group('draft compose context helpers', () {
    test('resolve post context handles edit and create', () {
      final editContext = resolvePostDraftContext(editingPostId: 4, communityId: 11);
      final createContext = resolvePostDraftContext(editingPostId: null, communityId: 11);

      expect(editContext.draftType, DraftType.postEdit);
      expect(editContext.existingId, 4);
      expect(editContext.replyId, isNull);

      expect(createContext.draftType, DraftType.postCreate);
      expect(createContext.existingId, isNull);
      expect(createContext.replyId, 11);
    });

    test('resolve comment context handles comment edit and reply targets', () {
      final editContext = resolveCommentDraftContext(editingCommentId: 9, postId: 21, parentCommentId: 33);
      final replyToPostContext = resolveCommentDraftContext(editingCommentId: null, postId: 21, parentCommentId: null);
      final replyToCommentContext = resolveCommentDraftContext(editingCommentId: null, postId: 21, parentCommentId: 33);

      expect(editContext.draftType, DraftType.commentEdit);
      expect(editContext.existingId, 9);

      expect(replyToPostContext.draftType, DraftType.commentCreateFromPost);
      expect(replyToPostContext.replyId, 21);

      expect(replyToCommentContext.draftType, DraftType.commentCreateFromComment);
      expect(replyToCommentContext.replyId, 33);
    });
  });

  group('persist compose draft', () {
    late AppDatabase appDatabase;
    late DraftRepository draftRepository;

    setUp(() {
      appDatabase = AppDatabase(NativeDatabase.memory());
      database = appDatabase;
      draftRepository = DraftRepositoryImpl(database: appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('persists active draft when content exists', () async {
      final context = resolvePostDraftContext(editingPostId: null, communityId: 42);
      final draft = buildPostDraft(
        context: context,
        accountId: '1',
        title: 'title',
        url: '',
        customThumbnail: '',
        altText: '',
        nsfw: true,
        languageId: 3,
        body: 'body',
      );

      final result = await persistDraft(
        repository: draftRepository,
        context: context,
        draft: draft,
        save: true,
        differsFromEdit: true,
        hasContent: draft.isPostNotEmpty,
      );

      final active = await draftRepository.fetchActiveDraft();

      expect(result, DraftPersistenceResult.saved);
      expect(active, isNotNull);
      expect(active!.active, isTrue);
      expect(active.replyId, 42);
    });

    test('skips when comment context is missing reply target', () async {
      const context = DraftContext(draftType: DraftType.commentCreateFromPost);
      final draft = buildCommentDraft(context: context, accountId: '1', languageId: 5, body: 'hello');

      final result = await persistDraft(
        repository: draftRepository,
        context: context,
        draft: draft,
        save: true,
        differsFromEdit: true,
        hasContent: draft.isCommentNotEmpty,
      );

      final active = await draftRepository.fetchActiveDraft();
      expect(result, DraftPersistenceResult.skipped);
      expect(active, isNull);
    });
  });

  group('draft diff helpers', () {
    test('post draft diff includes nsfw and language', () {
      final draft = Draft(
        id: '',
        draftType: DraftType.postEdit,
        existingId: 10,
        title: 'title',
        url: 'https://example.com',
        customThumbnail: 'https://example.com/image.png',
        altText: 'alt',
        nsfw: true,
        languageId: 2,
        body: 'body',
      );

      final post = ThunderPost(
        id: 10,
        name: 'title',
        url: 'https://example.com',
        body: 'body',
        altText: 'alt',
        creatorId: 1,
        communityId: 2,
        removed: false,
        locked: false,
        published: DateTime.now(),
        deleted: false,
        nsfw: false,
        thumbnailUrl: 'https://example.com/image.png',
        apId: 'apId',
        local: true,
        languageId: 1,
        featuredCommunity: false,
        featuredLocal: false,
        creator: ThunderUser(
          id: 1,
          name: 'user',
          banned: false,
          published: DateTime.fromMillisecondsSinceEpoch(0),
          actorId: 'actor',
          local: true,
          deleted: false,
          botAccount: false,
          instanceId: 1,
        ),
        community: ThunderCommunity(
          id: 2,
          name: 'community',
          title: 'community',
          removed: false,
          published: DateTime.fromMillisecondsSinceEpoch(0),
          deleted: false,
          nsfw: false,
          actorId: 'communityActor',
          local: true,
          hidden: false,
          postingRestrictedToMods: false,
          instanceId: 1,
          visibility: 'Public',
          subscribed: SubscriptionStatus.notSubscribed,
        ),
      );

      expect(postDraftDiffersFromEdit(draft, post), isTrue);
    });

    test('comment draft diff includes language', () {
      final draft = Draft(id: '', draftType: DraftType.commentEdit, existingId: 5, body: 'body', languageId: 2);
      final comment = ThunderComment(
        id: 5,
        creatorId: 1,
        postId: 2,
        content: 'body',
        removed: false,
        published: DateTime.fromMillisecondsSinceEpoch(0),
        deleted: false,
        apId: 'apId',
        local: true,
        path: '0.5',
        distinguished: false,
        languageId: 1,
      );

      expect(commentDraftDiffersFromEdit(draft, comment), isTrue);
    });
  });
}
