import 'package:thunder/src/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:thunder/src/features/community/data/repositories/community_repository_impl.dart';
import 'package:thunder/src/features/drafts/data/models/draft.dart';
import 'package:thunder/src/features/drafts/data/repositories/draft_repository.dart';
import 'package:thunder/src/features/post/data/repositories/post_repository.dart';
import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/primitives/enums/draft_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';

class DraftContext {
  const DraftContext({
    required this.draftType,
    this.existingId,
    this.replyId,
  });

  /// The type of draft
  final DraftType draftType;

  /// The existing id, if we're editing
  final int? existingId;

  /// The reply id, if we're replying to a post or comment
  final int? replyId;

  bool get hasRequiredReplyTarget => !draftType.isCommentCreate || replyId != null;
}

enum DraftPersistenceResult {
  saved,
  deleted,
  skipped,
}

class ActiveDraftRestoreData {
  const ActiveDraftRestoreData({
    required this.draft,
    required this.account,
  });

  final Draft draft;
  final Account account;
}

DraftContext resolvePostDraftContext({
  required int? editingPostId,
  required int? communityId,
}) {
  if (editingPostId != null) {
    return DraftContext(
      draftType: DraftType.postEdit,
      existingId: editingPostId,
    );
  }

  return DraftContext(
    draftType: DraftType.postCreate,
    replyId: communityId,
  );
}

DraftContext resolveCommentDraftContext({
  required int? editingCommentId,
  required int? postId,
  required int? parentCommentId,
}) {
  if (editingCommentId != null) {
    return DraftContext(
      draftType: DraftType.commentEdit,
      existingId: editingCommentId,
    );
  }

  return DraftContext(
    draftType: parentCommentId != null ? DraftType.commentCreateFromComment : DraftType.commentCreateFromPost,
    replyId: parentCommentId ?? postId,
  );
}

Draft buildPostDraft({
  required DraftContext context,
  required String? accountId,
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
    accountId: accountId,
    title: title,
    url: url,
    customThumbnail: customThumbnail,
    altText: altText,
    nsfw: nsfw,
    languageId: languageId,
    body: body,
  );
}

Draft buildCommentDraft({
  required DraftContext context,
  required String? accountId,
  required int? languageId,
  required String body,
}) {
  return Draft(
    id: '',
    draftType: context.draftType,
    existingId: context.existingId,
    replyId: context.replyId,
    accountId: accountId,
    languageId: languageId,
    body: body,
  );
}

Future<Draft?> restoreDraft({
  required DraftRepository repository,
  required DraftContext context,
}) async {
  if (!context.hasRequiredReplyTarget) {
    return null;
  }

  return repository.fetchDraft(context.draftType, context.existingId, context.replyId);
}

Future<DraftPersistenceResult> persistDraft({
  required DraftRepository repository,
  required DraftContext context,
  required Draft draft,
  required bool save,
  required bool differsFromEdit,
  required bool hasContent,
}) async {
  if (!context.hasRequiredReplyTarget) {
    return DraftPersistenceResult.skipped;
  }

  if (hasContent && save && differsFromEdit) {
    await repository.upsertDraft(draft, active: true);
    return DraftPersistenceResult.saved;
  }

  await repository.deleteDraft(context.draftType, context.existingId, context.replyId);
  return DraftPersistenceResult.deleted;
}

bool postDraftDiffersFromEdit(Draft draft, ThunderPost? post) {
  if (post == null) {
    return true;
  }

  return draft.title != post.name ||
      draft.url != (post.url ?? '') ||
      draft.customThumbnail != (post.thumbnailUrl ?? '') ||
      draft.altText != (post.altText ?? '') ||
      draft.nsfw != post.nsfw ||
      draft.languageId != post.languageId ||
      draft.body != (post.body ?? '');
}

bool commentDraftDiffersFromEdit(Draft draft, ThunderComment? comment) {
  if (comment == null) {
    return true;
  }

  return draft.body != comment.content || draft.languageId != comment.languageId;
}

Future<ActiveDraftRestoreData?> resolveActiveDraftRestoreData({
  required DraftRepository repository,
  required Account account,
}) async {
  final activeDraft = await repository.fetchActiveDraft();
  if (activeDraft == null || !activeDraft.hasRestorableContent) {
    if (activeDraft != null) {
      await repository.clearActiveDraft();
    }

    return null;
  }

  Account restoreAccount = account;
  if (activeDraft.accountId?.isNotEmpty == true) {
    final account = await Account.fetchAccount(activeDraft.accountId!);
    if (account != null) {
      restoreAccount = account;
    }
  }

  return ActiveDraftRestoreData(
    draft: activeDraft,
    account: restoreAccount,
  );
}

Future<void> restoreActiveDraftSession({
  required DraftRepository repository,
  required Account account,
  required Future<void> Function(Account account, int? communityId, ThunderCommunity? community) onPostCreateRestore,
  required Future<void> Function(Account account, ThunderPost post) onPostEditRestore,
  required Future<void> Function(Account account, ThunderPost post) onCommentCreateFromPostRestore,
  required Future<void> Function(Account account, ThunderComment comment) onCommentCreateFromCommentRestore,
  required Future<void> Function(Account account, ThunderComment comment) onCommentEditRestore,
}) async {
  final restoreData = await resolveActiveDraftRestoreData(
    repository: repository,
    account: account,
  );

  if (restoreData == null) {
    return;
  }

  final activeDraft = restoreData.draft;
  final restoreAccount = restoreData.account;

  try {
    switch (activeDraft.draftType) {
      case DraftType.postCreate:
      case DraftType.postCreateGeneral:
        ThunderCommunity? community;

        if (activeDraft.replyId != null) {
          try {
            final details = await CommunityRepositoryImpl(account: restoreAccount).getCommunity(id: activeDraft.replyId);
            community = details.community;
          } catch (_) {
            community = null;
          }
        }

        await onPostCreateRestore(restoreAccount, activeDraft.replyId, community);
        break;

      case DraftType.postEdit:
        if (activeDraft.existingId == null) {
          await repository.clearActiveDraft();
          return;
        }

        final response = await PostRepositoryImpl(account: restoreAccount).getPost(activeDraft.existingId!);
        final post = response?['post'];

        if (post is! ThunderPost) {
          return;
        }

        await onPostEditRestore(restoreAccount, post);
        break;

      case DraftType.commentCreateFromPost:
        if (activeDraft.replyId == null) {
          await repository.clearActiveDraft();
          return;
        }

        final response = await PostRepositoryImpl(account: restoreAccount).getPost(activeDraft.replyId!);
        final post = response?['post'];

        if (post is! ThunderPost) {
          return;
        }

        await onCommentCreateFromPostRestore(restoreAccount, post);
        break;

      case DraftType.commentCreateFromComment:
        if (activeDraft.replyId == null) {
          await repository.clearActiveDraft();
          return;
        }

        final comment = await CommentRepositoryImpl(account: restoreAccount).getComment(activeDraft.replyId!);
        await onCommentCreateFromCommentRestore(restoreAccount, comment);
        break;

      case DraftType.commentEdit:
        if (activeDraft.existingId == null) {
          await repository.clearActiveDraft();
          return;
        }

        final comment = await CommentRepositoryImpl(account: restoreAccount).getComment(activeDraft.existingId!);
        await onCommentEditRestore(restoreAccount, comment);
        break;

      case DraftType.commentCreate:
        if (activeDraft.replyId == null) {
          await repository.clearActiveDraft();
          return;
        }

        try {
          final comment = await CommentRepositoryImpl(account: restoreAccount).getComment(activeDraft.replyId!);
          await onCommentCreateFromCommentRestore(restoreAccount, comment);
        } catch (_) {
          final response = await PostRepositoryImpl(account: restoreAccount).getPost(activeDraft.replyId!);
          final post = response?['post'];

          if (post is! ThunderPost) {
            return;
          }

          await onCommentCreateFromPostRestore(restoreAccount, post);
        }
        break;
    }
  } catch (_) {
    // If anything fails, leave the active marker to allow a future recovery attempt.
  }
}
