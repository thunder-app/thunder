import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:thunder/core/database/database.dart';
import 'package:thunder/core/database/type_converters.dart';
import 'package:thunder/drafts/draft_type.dart';
import 'package:thunder/main.dart';

class Draft {
  /// The database identifier for this object
  final String id;

  /// The type of draft
  final DraftType draftType;

  /// Existing id, if we're editing
  final int? existingId;

  /// The community/post/comment we're replying to
  final int? replyId;

  /// The title of the post
  final String? title;

  /// The URL of the post
  final String? url;

  /// The custom thumbnail of the post
  final String? customThumbnail;

  /// The body of the post/comment
  final String? body;

  const Draft({
    required this.id,
    required this.draftType,
    this.existingId,
    this.replyId,
    this.title,
    this.url,
    this.customThumbnail,
    this.body,
  });

  Draft copyWith({
    String? id,
    DraftType? draftType,
    int? existingId,
    int? replyId,
    String? title,
    String? url,
    String? customThumbnail,
    String? body,
  }) =>
      Draft(
        id: id ?? this.id,
        draftType: draftType ?? this.draftType,
        existingId: existingId ?? this.existingId,
        replyId: replyId ?? this.replyId,
        title: title ?? this.title,
        url: url ?? this.url,
        customThumbnail: customThumbnail ?? this.customThumbnail,
        body: body ?? this.body,
      );

  /// See whether this draft contains enough info to save for a post
  bool get isPostNotEmpty => title?.isNotEmpty == true || url?.isNotEmpty == true || customThumbnail?.isNotEmpty == true || body?.isNotEmpty == true;

  /// See whether this draft contains enough info to save for a comment
  bool get isCommentNotEmpty => body?.isNotEmpty == true;

  /// Create or update a draft in the db
  static Future<Draft?> upsertDraft(Draft draft) async {
    try {
      final existingDraft = await (database.select(database.drafts)
            ..where((t) => t.draftType.equals(const DraftTypeConverter().toSql(draft.draftType)))
            ..where((t) => draft.existingId == null ? t.existingId.isNull() : t.existingId.equals(draft.existingId!))
            ..where((t) => draft.replyId == null ? t.replyId.isNull() : t.replyId.equals(draft.replyId!)))
          .getSingleOrNull();

      if (existingDraft == null) {
        final id = await database.into(database.drafts).insert(
              DraftsCompanion.insert(
                draftType: draft.draftType,
                existingId: Value(draft.existingId),
                replyId: Value(draft.replyId),
                title: Value(draft.title),
                url: Value(draft.url),
                customThumbnail: Value(draft.customThumbnail),
                body: Value(draft.body),
              ),
            );
        return draft.copyWith(id: id.toString());
      } else {
        await database.update(database.drafts).replace(
              DraftsCompanion(
                id: Value(existingDraft.id),
                draftType: Value(draft.draftType),
                existingId: Value(draft.existingId),
                replyId: Value(draft.replyId),
                title: Value(draft.title),
                url: Value(draft.url),
                customThumbnail: Value(draft.customThumbnail),
                body: Value(draft.body),
              ),
            );
        return draft.copyWith(id: existingDraft.id.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Retrieve a draft from the db
  static Future<Draft?> fetchDraft(DraftType draftType, int? existingId, int? replyId) async {
    try {
      final draft = await (database.select(database.drafts)
            ..where((t) => t.draftType.equals(const DraftTypeConverter().toSql(draftType)))
            ..where((t) => existingId == null ? t.existingId.isNull() : t.existingId.equals(existingId))
            ..where((t) => replyId == null ? t.replyId.isNull() : t.replyId.equals(replyId)))
          .getSingleOrNull();

      if (draft == null) return null;

      return Draft(
        id: draft.id.toString(),
        draftType: draft.draftType,
        existingId: draft.existingId,
        replyId: draft.replyId,
        title: draft.title,
        url: draft.url,
        customThumbnail: draft.customThumbnail,
        body: draft.body,
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Delete a draft from the db
  static Future<void> deleteDraft(DraftType draftType, int? existingId, int? replyId) async {
    try {
      await (database.delete(database.drafts)
            ..where((t) => t.draftType.equals(const DraftTypeConverter().toSql(draftType)))
            ..where((t) => existingId == null ? t.existingId.isNull() : t.existingId.equals(existingId))
            ..where((t) => replyId == null ? t.replyId.isNull() : t.replyId.equals(replyId)))
          .go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
