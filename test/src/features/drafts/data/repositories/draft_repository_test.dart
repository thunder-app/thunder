import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/drafts/data/models/draft.dart';
import 'package:thunder/src/features/drafts/data/repositories/draft_repository.dart';
import 'package:thunder/src/core/core.dart';

import '../../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase database;
  late DraftRepository repository;

  setUp(() async {
    database = createInMemoryDatabase();
    repository = DraftRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Draft newDraft({
    String id = '',
    DraftType draftType = DraftType.postCreate,
    int? existingId,
    int? replyId,
    bool active = false,
    String? title,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
  }) =>
      Draft(
        id: id,
        draftType: draftType,
        existingId: existingId,
        replyId: replyId,
        active: active,
        title: title,
        body: body,
        url: url,
        customThumbnail: customThumbnail,
        altText: altText,
      );

  group('DraftRepositoryImpl', () {
    test('upsertDraft inserts a new draft and returns it with generated id', () async {
      final saved = await repository.upsertDraft(newDraft(title: 'Title'));

      expect(saved, isNotNull);
      expect(saved!.id, isNotEmpty);
      expect(saved.title, 'Title');
    });

    test('upsertDraft updates existing draft matched by type, existingId, and replyId', () async {
      final first = await repository.upsertDraft(
        newDraft(
          draftType: DraftType.commentEdit,
          existingId: 100,
          body: 'First',
        ),
      );

      final updated = await repository.upsertDraft(
        newDraft(
          draftType: DraftType.commentEdit,
          existingId: 100,
          body: 'Updated',
        ),
      );

      expect(updated!.id, first!.id);
      expect(updated.body, 'Updated');

      final fetched = await repository.fetchDraft(DraftType.commentEdit, 100, null);
      expect(fetched!.body, 'Updated');
    });

    test('upsertDraft normalizes empty strings to null before storage', () async {
      await repository.upsertDraft(
        newDraft(
          title: 'Title',
          body: '   ',
          url: '',
        ),
      );

      final row = await (database.select(database.drafts)..limit(1)).getSingle();
      expect(row.title, 'Title');
      expect(row.body, isNull);
      expect(row.url, isNull);
    });

    test('upsertDraft with active true clears other active drafts', () async {
      await repository.upsertDraft(newDraft(title: 'First', body: 'A'), active: true);
      await repository.upsertDraft(newDraft(title: 'Second', body: 'B'), active: true);

      final active = await repository.fetchActiveDraft();
      expect(active!.title, 'Second');

      final drafts = await repository.fetchAllDrafts();
      expect(drafts.where((draft) => draft.active).length, 1);
    });

    test('fetchDraft returns null when no match', () async {
      final draft = await repository.fetchDraft(DraftType.postEdit, 999, null);

      expect(draft, isNull);
    });

    test('fetchAllDrafts excludes drafts without restorable content', () async {
      await repository.upsertDraft(newDraft());
      await repository.upsertDraft(newDraft(title: 'Saved title'));

      final drafts = await repository.fetchAllDrafts();

      expect(drafts, hasLength(1));
      expect(drafts.single.title, 'Saved title');
    });

    test('deleteDraft removes matching row', () async {
      await repository.upsertDraft(
        newDraft(
          draftType: DraftType.postEdit,
          existingId: 50,
          title: 'Delete me',
        ),
      );

      await repository.deleteDraft(DraftType.postEdit, 50, null);

      final draft = await repository.fetchDraft(DraftType.postEdit, 50, null);
      expect(draft, isNull);
    });
  });
}
