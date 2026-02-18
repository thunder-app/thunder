import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/foundation/networking/networking.dart';

part 'create_comment_state.dart';

class CreateCommentCubit extends Cubit<CreateCommentState> {
  /// The current account.
  Account account;

  /// The repository for the comment.
  late CommentRepository repository;

  /// Factories for creating repositories when the account changes.
  final CommentRepository Function(Account) _commentRepositoryFactory;
  final AccountRepository Function(Account) _accountRepositoryFactory;
  final LocalizationService _localizationService;

  CreateCommentCubit({
    required this.account,
    required CommentRepository Function(Account) commentRepositoryFactory,
    required AccountRepository Function(Account) accountRepositoryFactory,
    required LocalizationService localizationService,
  })  : _commentRepositoryFactory = commentRepositoryFactory,
        _accountRepositoryFactory = accountRepositoryFactory,
        _localizationService = localizationService,
        super(const CreateCommentState(status: CreateCommentStatus.initial)) {
    repository = _commentRepositoryFactory(account);
  }

  Future<void> clearMessage() async {
    emit(state.copyWith(
      status: CreateCommentStatus.initial,
      message: null,
      errorReason: null,
    ));
  }

  Future<void> switchAccount(Account newAccount) async {
    account = newAccount;
    repository = _commentRepositoryFactory(account);

    debugPrint('Account switched to ${account.username}@${account.instance}');
    emit(state.copyWith(
      status: CreateCommentStatus.success,
      message: null,
      errorReason: null,
    ));
  }

  Future<void> uploadImages(List<String> imageFiles) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) {
      emit(state.copyWith(
        status: CreateCommentStatus.imageUploadFailure,
        message: l10n.userNotLoggedIn,
        errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
      ));
      return;
    }

    List<String> urls = [];

    emit(state.copyWith(
      status: CreateCommentStatus.imageUploadInProgress,
      message: null,
      errorReason: null,
    ));

    try {
      final accountRepository = _accountRepositoryFactory(account);

      for (String imageFile in imageFiles) {
        final url = await accountRepository.uploadImage(imageFile);
        urls.add(url);

        // Add a delay between each upload to avoid possible rate limiting
        await Future.wait(urls.map((url) => Future.delayed(const Duration(milliseconds: 500))));
      }

      emit(state.copyWith(
        status: CreateCommentStatus.imageUploadSuccess,
        imageUrls: urls,
        message: null,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: CreateCommentStatus.imageUploadFailure,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message),
      ));
    }
  }

  /// Creates or edits a comment. When successful, it emits the newly created/updated comment
  /// in the form of a [ThunderComment] and returns the newly created comment id.
  Future<int?> createOrEditComment({int? postId, int? parentCommentId, required String content, int? commentIdBeingEdited, int? languageId}) async {
    assert(!(postId == null && commentIdBeingEdited == null));

    try {
      emit(state.copyWith(
        status: CreateCommentStatus.submitting,
        message: null,
        errorReason: null,
      ));

      ThunderComment comment;

      if (commentIdBeingEdited != null) {
        comment = await repository.edit(commentId: commentIdBeingEdited, content: content, languageId: languageId);
      } else {
        comment = await repository.create(postId: postId!, content: content, parentId: parentCommentId, languageId: languageId);
      }

      emit(state.copyWith(
        status: CreateCommentStatus.success,
        comment: comment,
        message: null,
        errorReason: null,
      ));
      return comment.id;
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: CreateCommentStatus.error,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message),
      ));
    }

    return null;
  }
}
