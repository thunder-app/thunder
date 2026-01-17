import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/shared/utils/error_messages.dart';
import 'package:thunder/src/app/utils/global_context.dart';

part 'create_comment_state.dart';

class CreateCommentCubit extends Cubit<CreateCommentState> {
  /// The current account.
  Account account;

  /// The repository for the comment.
  late CommentRepository repository;

  CreateCommentCubit({required this.account}) : super(const CreateCommentState(status: CreateCommentStatus.initial)) {
    repository = CommentRepositoryImpl(account: account);
  }

  Future<void> clearMessage() async {
    emit(state.copyWith(status: CreateCommentStatus.initial, message: null));
  }

  Future<void> switchAccount(Account newAccount) async {
    account = newAccount;
    repository = CommentRepositoryImpl(account: account);

    debugPrint('Account switched to ${account.username}@${account.instance}');
    emit(state.copyWith(status: CreateCommentStatus.success));
  }

  Future<void> uploadImages(List<String> imageFiles) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    List<String> urls = [];

    emit(state.copyWith(status: CreateCommentStatus.imageUploadInProgress));

    try {
      final accountRepository = AccountRepositoryImpl(account: account);

      for (String imageFile in imageFiles) {
        final url = await accountRepository.uploadImage(imageFile);
        urls.add(url);

        // Add a delay between each upload to avoid possible rate limiting
        await Future.wait(urls.map((url) => Future.delayed(const Duration(milliseconds: 500))));
      }

      emit(state.copyWith(status: CreateCommentStatus.imageUploadSuccess, imageUrls: urls));
    } catch (e) {
      emit(state.copyWith(status: CreateCommentStatus.imageUploadFailure, message: e.toString()));
    }
  }

  /// Creates or edits a comment. When successful, it emits the newly created/updated comment
  /// in the form of a [ThunderComment] and returns the newly created comment id.
  Future<int?> createOrEditComment({int? postId, int? parentCommentId, required String content, int? commentIdBeingEdited, int? languageId}) async {
    assert(!(postId == null && commentIdBeingEdited == null));

    try {
      emit(state.copyWith(status: CreateCommentStatus.submitting));

      ThunderComment comment;

      if (commentIdBeingEdited != null) {
        comment = await repository.edit(commentId: commentIdBeingEdited, content: content, languageId: languageId);
      } else {
        comment = await repository.create(postId: postId!, content: content, parentId: parentCommentId, languageId: languageId);
      }

      emit(state.copyWith(status: CreateCommentStatus.success, comment: comment));
      return comment.id;
    } catch (e) {
      emit(state.copyWith(status: CreateCommentStatus.error, message: getExceptionErrorMessage(e)));
    }

    return null;
  }
}
