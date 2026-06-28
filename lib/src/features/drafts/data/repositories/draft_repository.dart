import 'package:drift/drift.dart';

import 'package:thunder/src/features/drafts/data/models/draft.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/foundation/primitives/enums/draft_type.dart';

/// Repository contract for local draft persistence.
abstract class DraftRepository {
  /// Upsert a draft into the database.
  Future<Draft?> upsertDraft(Draft draft, {bool active = false});

  /// Fetch all drafts from the database.
  Future<List<Draft>> fetchAllDrafts();

  /// Fetch a draft from the database.
  Future<Draft?> fetchDraft(DraftType draftType, int? existingId, int? replyId);

  /// Fetch the active draft from the database. The active draft is the draft that will be restored on startup.
  Future<Draft?> fetchActiveDraft();

  /// Clear the active draft from the database.
  Future<void> clearActiveDraft();

  /// Clear the active draft from the database by identity.
  Future<void> clearActiveDraftByIdentity(DraftType draftType, int? existingId, int? replyId);

  /// Marks the selected draft as the only active draft.
  Future<void> setActiveDraftById(String id);

  /// Delete a draft from the database.
  Future<void> deleteDraft(DraftType draftType, int? existingId, int? replyId);
}

/// Implementation of [DraftRepository] backed by local Drift storage.
class DraftRepositoryImpl implements DraftRepository {
  DraftRepositoryImpl({required AppDatabase database}) : _database = database;

  static const DraftTypeConverter _draftTypeConverter = DraftTypeConverter();

  final AppDatabase _database;

  @override
  Future<Draft?> upsertDraft(Draft draft, {bool active = false}) async {
    final Draft normalizedDraft = _normalizeDraftForStorage(draft);
    final List<String> draftTypeSqlValues = _compatibleDraftTypes(normalizedDraft.draftType).map((t) => _draftTypeConverter.toSql(t)).toList();

    return await _database.transaction(() async {
      if (active) {
        await clearActiveDraft();
      }

      final existingDrafts = await (_database.select(_database.drafts)
            ..where((t) => t.draftType.isIn(draftTypeSqlValues))
            ..where((t) => normalizedDraft.existingId == null ? t.existingId.isNull() : t.existingId.equals(normalizedDraft.existingId!))
            ..where((t) => normalizedDraft.replyId == null ? t.replyId.isNull() : t.replyId.equals(normalizedDraft.replyId!)))
          .get();

      dynamic existingDraft;

      for (final candidate in existingDrafts) {
        if (candidate.draftType == normalizedDraft.draftType) {
          existingDraft = candidate;
          break;
        }
      }

      existingDraft ??= existingDrafts.isNotEmpty ? existingDrafts.first : null;

      final bool isActive = active ? true : normalizedDraft.active;

      if (existingDraft == null) {
        final id = await _database.into(_database.drafts).insert(
              DraftsCompanion.insert(
                draftType: normalizedDraft.draftType,
                existingId: Value(normalizedDraft.existingId),
                replyId: Value(normalizedDraft.replyId),
                active: Value(isActive),
                accountId: Value(normalizedDraft.accountId),
                title: Value(normalizedDraft.title),
                url: Value(normalizedDraft.url),
                customThumbnail: Value(normalizedDraft.customThumbnail),
                altText: Value(normalizedDraft.altText),
                nsfw: Value(normalizedDraft.nsfw),
                languageId: Value(normalizedDraft.languageId),
                body: Value(normalizedDraft.body),
              ),
            );

        return normalizedDraft.copyWith(id: id.toString(), active: isActive);
      }

      await _database.update(_database.drafts).replace(
            DraftsCompanion(
              id: Value(existingDraft.id),
              draftType: Value(normalizedDraft.draftType),
              existingId: Value(normalizedDraft.existingId),
              replyId: Value(normalizedDraft.replyId),
              active: Value(isActive),
              accountId: Value(normalizedDraft.accountId),
              title: Value(normalizedDraft.title),
              url: Value(normalizedDraft.url),
              customThumbnail: Value(normalizedDraft.customThumbnail),
              altText: Value(normalizedDraft.altText),
              nsfw: Value(normalizedDraft.nsfw),
              languageId: Value(normalizedDraft.languageId),
              body: Value(normalizedDraft.body),
            ),
          );

      return normalizedDraft.copyWith(id: existingDraft.id.toString(), active: isActive);
    });
  }

  @override
  Future<Draft?> fetchDraft(DraftType draftType, int? existingId, int? replyId) async {
    final List<String> draftTypeSqlValues = _compatibleDraftTypes(draftType).map((t) => _draftTypeConverter.toSql(t)).toList();
    final drafts = await (_database.select(_database.drafts)
          ..where((t) => t.draftType.isIn(draftTypeSqlValues))
          ..where((t) => existingId == null ? t.existingId.isNull() : t.existingId.equals(existingId))
          ..where((t) => replyId == null ? t.replyId.isNull() : t.replyId.equals(replyId)))
        .get();

    if (drafts.isEmpty) return null;

    dynamic draft;

    for (final candidate in drafts) {
      if (candidate.draftType == draftType) {
        draft = candidate;
        break;
      }
    }

    draft ??= drafts.first;

    return _toDraft(draft);
  }

  @override
  Future<List<Draft>> fetchAllDrafts() async {
    final drafts = await (_database.select(_database.drafts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.active, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
        .get();

    return drafts.map(_toDraft).where((draft) => draft.hasRestorableContent).toList();
  }

  @override
  Future<Draft?> fetchActiveDraft() async {
    final drafts = await (_database.select(_database.drafts)..where((t) => t.active.equals(true))).get();

    if (drafts.isEmpty) {
      return null;
    }

    return _toDraft(drafts.first);
  }

  @override
  Future<void> clearActiveDraft() async {
    await (_database.update(_database.drafts)..where((t) => t.active.equals(true))).write(const DraftsCompanion(active: Value(false)));
  }

  @override
  Future<void> clearActiveDraftByIdentity(DraftType draftType, int? existingId, int? replyId) async {
    final List<String> draftTypeSqlValues = _compatibleDraftTypes(draftType).map((t) => _draftTypeConverter.toSql(t)).toList();
    await (_database.update(_database.drafts)
          ..where((t) => t.active.equals(true))
          ..where((t) => t.draftType.isIn(draftTypeSqlValues))
          ..where((t) => existingId == null ? t.existingId.isNull() : t.existingId.equals(existingId))
          ..where((t) => replyId == null ? t.replyId.isNull() : t.replyId.equals(replyId)))
        .write(const DraftsCompanion(active: Value(false)));
  }

  @override
  Future<void> setActiveDraftById(String id) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) return;

    await _database.transaction(() async {
      await clearActiveDraft();
      await (_database.update(_database.drafts)..where((t) => t.id.equals(parsedId))).write(const DraftsCompanion(active: Value(true)));
    });
  }

  @override
  Future<void> deleteDraft(DraftType draftType, int? existingId, int? replyId) async {
    final List<String> draftTypeSqlValues = _compatibleDraftTypes(draftType).map((t) => _draftTypeConverter.toSql(t)).toList();
    await (_database.delete(_database.drafts)
          ..where((t) => t.draftType.isIn(draftTypeSqlValues))
          ..where((t) => existingId == null ? t.existingId.isNull() : t.existingId.equals(existingId))
          ..where((t) => replyId == null ? t.replyId.isNull() : t.replyId.equals(replyId)))
        .go();
  }

  Draft _toDraft(dynamic draft) {
    return Draft(
      id: draft.id.toString(),
      draftType: draft.draftType,
      existingId: draft.existingId,
      replyId: draft.replyId,
      active: draft.active,
      accountId: draft.accountId,
      title: draft.title,
      url: draft.url,
      customThumbnail: draft.customThumbnail,
      altText: draft.altText,
      nsfw: draft.nsfw,
      languageId: draft.languageId,
      body: draft.body,
    );
  }

  Draft _normalizeDraftForStorage(Draft draft) {
    return Draft(
      id: draft.id,
      draftType: draft.draftType,
      existingId: draft.existingId,
      replyId: draft.replyId,
      active: draft.active,
      accountId: draft.accountId,
      title: _normalizeNullableText(draft.title),
      url: _normalizeNullableText(draft.url),
      customThumbnail: _normalizeNullableText(draft.customThumbnail),
      altText: _normalizeNullableText(draft.altText),
      nsfw: draft.nsfw,
      languageId: draft.languageId,
      body: _normalizeNullableText(draft.body),
    );
  }

  List<DraftType> _compatibleDraftTypes(DraftType draftType) {
    if (draftType == DraftType.commentCreateFromPost || draftType == DraftType.commentCreateFromComment) {
      return [draftType, DraftType.commentCreate];
    }

    if (draftType == DraftType.postCreate || draftType == DraftType.postCreateGeneral) {
      return [DraftType.postCreate, DraftType.postCreateGeneral];
    }

    return [draftType];
  }

  String? _normalizeNullableText(String? value) {
    if (value == null) {
      return null;
    }

    if (value.trim().isEmpty) {
      return null;
    }

    return value;
  }
}
