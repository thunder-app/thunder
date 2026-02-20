import 'package:drift/native.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';

void main() {
  late AppDatabase appDatabase;
  late DraftRepository repository;

  setUp(() {
    appDatabase = AppDatabase(NativeDatabase.memory());
    database = appDatabase;
    repository = DraftRepositoryImpl(database: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('upsert draft sets active and stores account', () async {
    final draft = Draft(
      id: '',
      draftType: DraftType.postCreate,
      replyId: 11,
      title: 'title',
      body: 'body',
      accountId: '2',
      nsfw: true,
      languageId: 4,
    );

    final saved = await repository.upsertDraft(draft, active: true);
    final active = await repository.fetchActiveDraft();

    expect(saved, isNotNull);
    expect(active, isNotNull);
    expect(active!.active, isTrue);
    expect(active.draftType, DraftType.postCreate);
    expect(active.replyId, 11);
    expect(active.accountId, '2');
    expect(active.nsfw, isTrue);
    expect(active.languageId, 4);
  });

  test('setting active draft clears previously active draft', () async {
    await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.postCreate, replyId: 11, title: 'one', accountId: '1'),
      active: true,
    );

    await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.commentCreateFromPost, replyId: 42, body: 'two', accountId: '3'),
      active: true,
    );

    final active = await repository.fetchActiveDraft();
    final previous = await repository.fetchDraft(DraftType.postCreate, null, 11);

    expect(active, isNotNull);
    expect(active!.draftType, DraftType.commentCreateFromPost);
    expect(active.replyId, 42);
    expect(previous, isNotNull);
    expect(previous!.active, isFalse);
  });

  test('upsert stores comment language id', () async {
    await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.commentCreateFromPost, replyId: 777, body: 'with language', accountId: '1', languageId: 19),
      active: true,
    );

    final fetched = await repository.fetchDraft(DraftType.commentCreateFromPost, null, 777);

    expect(fetched, isNotNull);
    expect(fetched!.languageId, 19);
  });

  test('upsert keeps draft identity while account changes', () async {
    final initial = await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.postCreate, replyId: 10, title: 'hello', accountId: '1'),
      active: true,
    );

    final updated = await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.postCreate, replyId: 10, title: 'hello', accountId: '999'),
      active: true,
    );

    final fetched = await repository.fetchDraft(DraftType.postCreate, null, 10);

    expect(initial, isNotNull);
    expect(updated, isNotNull);
    expect(updated!.id, initial!.id);
    expect(fetched, isNotNull);
    expect(fetched!.accountId, '999');
  });

  test('fetch supports legacy commentCreate type', () async {
    await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.commentCreate, replyId: 99, body: 'legacy', accountId: '1'),
      active: true,
    );

    final restoredFromPost = await repository.fetchDraft(DraftType.commentCreateFromPost, null, 99);
    final restoredFromComment = await repository.fetchDraft(DraftType.commentCreateFromComment, null, 99);

    expect(restoredFromPost, isNotNull);
    expect(restoredFromComment, isNotNull);
    expect(restoredFromPost!.body, 'legacy');
    expect(restoredFromComment!.body, 'legacy');
  });

  test('fetch supports legacy postCreateGeneral type', () async {
    await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.postCreateGeneral, title: 'legacy post create general', accountId: '1'),
      active: true,
    );

    final restored = await repository.fetchDraft(DraftType.postCreate, null, null);

    expect(restored, isNotNull);
    expect(restored!.title, 'legacy post create general');
  });

  test('database enforces one globally active draft', () async {
    final first = await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.postCreate, replyId: 1, title: 'one', accountId: '1'),
    );
    final second = await repository.upsertDraft(
      Draft(id: '', draftType: DraftType.postCreate, replyId: 2, title: 'two', accountId: '1'),
    );

    expect(first, isNotNull);
    expect(second, isNotNull);

    await database.customStatement('UPDATE drafts SET active = 1 WHERE id = ${first!.id}');

    expect(
      () => database.customStatement('UPDATE drafts SET active = 1 WHERE id = ${second!.id}'),
      throwsA(isA<Object>()),
    );
  });
}
