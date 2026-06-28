import 'package:thunder/src/features/comment/data/repositories/comment_repository.dart';
import 'package:thunder/src/features/community/data/repositories/community_repository.dart';
import 'package:thunder/src/features/drafts/data/models/draft.dart';
import 'package:thunder/src/features/drafts/data/repositories/draft_repository.dart';
import 'package:thunder/src/features/post/data/repositories/post_repository.dart';
import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/primitives/enums/draft_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';

enum DraftPersistenceResult {
  saved,
  deleted,
  skipped,
}

enum DraftOpenResult {
  opened,
  retryableFailure,
  abandoned,
}

class DraftContext {
  /// The type of draft
  final DraftType draftType;

  /// The existing id, if we're editing
  final int? existingId;

  /// The reply id, if we're replying to a post or comment
  final int? replyId;

  const DraftContext({required this.draftType, this.existingId, this.replyId});

  bool get hasRequiredReplyTarget => !draftType.isCommentCreate || replyId != null;
}

/// Resolves the post draft context
DraftContext resolvePostDraftContext({required int? editingPostId, required int? communityId}) {
  if (editingPostId != null) {
    return DraftContext(draftType: DraftType.postEdit, existingId: editingPostId);
  }

  return DraftContext(draftType: DraftType.postCreate, replyId: communityId);
}

/// Resolves the comment draft context
DraftContext resolveCommentDraftContext({required int? editingCommentId, required int? postId, required int? parentCommentId}) {
  if (editingCommentId != null) {
    return DraftContext(draftType: DraftType.commentEdit, existingId: editingCommentId);
  }

  return DraftContext(
    draftType: parentCommentId != null ? DraftType.commentCreateFromComment : DraftType.commentCreateFromPost,
    replyId: parentCommentId ?? postId,
  );
}

/// Builds a post draft
Draft buildPostDraft({
  required DraftContext context,
  required String title,
  required String url,
  required String customThumbnail,
  required String altText,
  required bool nsfw,
  required int? languageId,
  required String body,
}) {
  return Draft(
    id: '',
    draftType: context.draftType,
    existingId: context.existingId,
    replyId: context.replyId,
    title: title,
    url: url,
    customThumbnail: customThumbnail,
    altText: altText,
    nsfw: nsfw,
    languageId: languageId,
    body: body,
  );
}

/// Builds a comment draft
Draft buildCommentDraft({required DraftContext context, required int? languageId, required String body}) {
  return Draft(
    id: '',
    draftType: context.draftType,
    existingId: context.existingId,
    replyId: context.replyId,
    languageId: languageId,
    body: body,
  );
}

/// Restores the draft
Future<Draft?> restoreDraft({required DraftRepository repository, required DraftContext context}) async {
  if (!context.hasRequiredReplyTarget) return null;
  return repository.fetchDraft(context.draftType, context.existingId, context.replyId);
}

/// Persists the draft
Future<DraftPersistenceResult> persistDraft({
  required DraftRepository repository,
  required DraftContext context,
  required Draft draft,
  required bool save,
  required bool differsFromEdit,
  required bool hasContent,
}) async {
  if (!context.hasRequiredReplyTarget) return DraftPersistenceResult.skipped;

  if (hasContent && save && differsFromEdit) {
    await repository.upsertDraft(draft, active: true);
    return DraftPersistenceResult.saved;
  }

  await repository.deleteDraft(context.draftType, context.existingId, context.replyId);
  return DraftPersistenceResult.deleted;
}

/// Checks if the draft differs from the original post
bool postDraftDiffersFromEdit(Draft draft, ThunderPost? post) {
  if (post == null) return true;

  final isTitleDifferent = draft.title != post.name;
  final isUrlDifferent = draft.url != post.url;
  final isCustomThumbnailDifferent = draft.customThumbnail != post.thumbnailUrl;
  final isAltTextDifferent = draft.altText != post.altText;
  final isNsfwDifferent = draft.nsfw != post.status.nsfw;
  final isLanguageIdDifferent = draft.languageId != post.languageId;
  final isBodyDifferent = draft.body != post.body;

  return isTitleDifferent || isUrlDifferent || isCustomThumbnailDifferent || isAltTextDifferent || isNsfwDifferent || isLanguageIdDifferent || isBodyDifferent;
}

/// Checks if the draft differs from the original comment
bool commentDraftDiffersFromEdit(Draft draft, ThunderComment? comment) {
  if (comment == null) return true;

  final isBodyDifferent = draft.body != comment.content;
  final isLanguageIdDifferent = draft.languageId != comment.languageId;

  return isBodyDifferent || isLanguageIdDifferent;
}

/// Opens the draft session
Future<DraftOpenResult> openDraftSession({
  required DraftRepository repository,
  required Draft draft,
  required Account account,
  required Future<void> Function(Account account, int? communityId, ThunderCommunity? community) onPostCreateRestore,
  required Future<void> Function(Account account, ThunderPost post) onPostEditRestore,
  required Future<void> Function(Account account, ThunderPost post) onCommentCreateFromPostRestore,
  required Future<void> Function(Account account, ThunderComment comment) onCommentCreateFromCommentRestore,
  required Future<void> Function(Account account, ThunderComment comment) onCommentEditRestore,
}) async {
  try {
    switch (draft.draftType) {
      case DraftType.postCreate:
      case DraftType.postCreateGeneral:
        ThunderCommunity? community;

        if (draft.replyId != null) {
          try {
            final details = await CommunityRepositoryImpl(account: account).getCommunity(id: draft.replyId);
            community = details.community;
          } catch (_) {
            community = null;
          }
        }

        await onPostCreateRestore(account, draft.replyId, community);
        return DraftOpenResult.opened;

      case DraftType.postEdit:
        if (draft.existingId == null) {
          await repository.clearActiveDraft();
          return DraftOpenResult.abandoned;
        }

        final response = await PostRepositoryImpl(account: account).getPost(draft.existingId!);
        final post = response?.post;

        if (post is! ThunderPost) {
          return DraftOpenResult.abandoned;
        }

        await onPostEditRestore(account, post);
        return DraftOpenResult.opened;

      case DraftType.commentCreateFromPost:
        if (draft.replyId == null) {
          await repository.clearActiveDraft();
          return DraftOpenResult.abandoned;
        }

        final response = await PostRepositoryImpl(account: account).getPost(draft.replyId!);
        final post = response?.post;

        if (post is! ThunderPost) {
          return DraftOpenResult.abandoned;
        }

        await onCommentCreateFromPostRestore(account, post);
        return DraftOpenResult.opened;

      case DraftType.commentCreateFromComment:
        if (draft.replyId == null) {
          await repository.clearActiveDraft();
          return DraftOpenResult.abandoned;
        }

        final comment = await CommentRepositoryImpl(account: account).getComment(draft.replyId!);
        await onCommentCreateFromCommentRestore(account, comment);
        return DraftOpenResult.opened;

      case DraftType.commentEdit:
        if (draft.existingId == null) {
          await repository.clearActiveDraft();
          return DraftOpenResult.abandoned;
        }

        final comment = await CommentRepositoryImpl(account: account).getComment(draft.existingId!);
        await onCommentEditRestore(account, comment);
        return DraftOpenResult.opened;

      case DraftType.commentCreate:
        if (draft.replyId == null) {
          await repository.clearActiveDraft();
          return DraftOpenResult.abandoned;
        }

        try {
          final comment = await CommentRepositoryImpl(account: account).getComment(draft.replyId!);
          await onCommentCreateFromCommentRestore(account, comment);
        } catch (_) {
          final response = await PostRepositoryImpl(account: account).getPost(draft.replyId!);
          final post = response?.post;

          if (post is! ThunderPost) {
            return DraftOpenResult.abandoned;
          }

          await onCommentCreateFromPostRestore(account, post);
        }
        return DraftOpenResult.opened;
    }
  } catch (_) {
    // If anything fails, leave the active marker to allow a future recovery attempt.
    return DraftOpenResult.retryableFailure;
  }
}

/// Restores the active draft session
Future<void> restoreActiveDraftSession({
  required DraftRepository repository,
  required Account account,
  required Future<void> Function(Account account, int? communityId, ThunderCommunity? community) onPostCreateRestore,
  required Future<void> Function(Account account, ThunderPost post) onPostEditRestore,
  required Future<void> Function(Account account, ThunderPost post) onCommentCreateFromPostRestore,
  required Future<void> Function(Account account, ThunderComment comment) onCommentCreateFromCommentRestore,
  required Future<void> Function(Account account, ThunderComment comment) onCommentEditRestore,
}) async {
  final draft = await repository.fetchActiveDraft();
  if (draft == null) return;

  if (!draft.hasRestorableContent) {
    await repository.clearActiveDraft();
    return;
  }

  final result = await openDraftSession(
    repository: repository,
    draft: draft,
    account: account,
    onPostCreateRestore: onPostCreateRestore,
    onPostEditRestore: onPostEditRestore,
    onCommentCreateFromPostRestore: onCommentCreateFromPostRestore,
    onCommentCreateFromCommentRestore: onCommentCreateFromCommentRestore,
    onCommentEditRestore: onCommentEditRestore,
  );

  if (result == DraftOpenResult.abandoned) {
    await repository.clearActiveDraft();
  }
}
