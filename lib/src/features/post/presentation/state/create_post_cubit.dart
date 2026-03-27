import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/foundation/networking/networking.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  /// The current account.
  Account account;

  /// The repository for the post.
  late PostRepository repository;

  /// Factories for creating repositories when the account changes.
  final PostRepository Function(Account) _postRepositoryFactory;
  final AccountRepository Function(Account) _accountRepositoryFactory;
  final LocalizationService _localizationService;

  CreatePostCubit({
    required this.account,
    required PostRepository Function(Account) postRepositoryFactory,
    required AccountRepository Function(Account) accountRepositoryFactory,
    required LocalizationService localizationService,
  })  : _postRepositoryFactory = postRepositoryFactory,
        _accountRepositoryFactory = accountRepositoryFactory,
        _localizationService = localizationService,
        super(const CreatePostState(status: CreatePostStatus.initial)) {
    repository = _postRepositoryFactory(account);
  }

  Future<void> clearMessage() async {
    emit(
      state.copyWith(
        status: CreatePostStatus.initial,
        message: null,
        errorReason: null,
      ),
    );
  }

  /// Switches the account for the post.
  Future<void> switchAccount(Account newAccount) async {
    account = newAccount;
    repository = _postRepositoryFactory(account);

    debugPrint('Account switched to ${account.username}@${account.instance}');
    emit(state.copyWith(
      status: CreatePostStatus.success,
      errorReason: null,
      message: null,
    ));
  }

  Future<void> uploadImages(List<String> imageFiles, {bool isPostImage = false}) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) {
      emit(state.copyWith(
        status: isPostImage ? CreatePostStatus.postImageUploadFailure : CreatePostStatus.imageUploadFailure,
        message: l10n.userNotLoggedIn,
        errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
      ));
      return;
    }

    List<String> urls = [];

    isPostImage
        ? emit(state.copyWith(
            status: CreatePostStatus.postImageUploadInProgress,
            message: null,
            errorReason: null,
          ))
        : emit(state.copyWith(
            status: CreatePostStatus.imageUploadInProgress,
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

      isPostImage
          ? emit(state.copyWith(
              status: CreatePostStatus.postImageUploadSuccess,
              imageUrls: urls,
              message: null,
              errorReason: null,
            ))
          : emit(state.copyWith(
              status: CreatePostStatus.imageUploadSuccess,
              imageUrls: urls,
              message: null,
              errorReason: null,
            ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      isPostImage
          ? emit(state.copyWith(
              status: CreatePostStatus.postImageUploadFailure,
              message: message,
              errorReason: AppErrorReason.actionFailed(message: message),
            ))
          : emit(state.copyWith(
              status: CreatePostStatus.imageUploadFailure,
              message: message,
              errorReason: AppErrorReason.actionFailed(message: message),
            ));
    }
  }

  /// Creates or edits a post. When successful, it emits the newly created/updated post in the form of a [PostViewMedia]
  /// and returns the newly created post id.
  Future<int?> createOrEditPost({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? postIdBeingEdited,
    int? languageId,
  }) async {
    emit(state.copyWith(
      status: CreatePostStatus.submitting,
      message: null,
      errorReason: null,
    ));

    try {
      final post = await repository.create(
        communityId: communityId,
        name: name,
        body: body,
        url: url,
        customThumbnail: customThumbnail,
        altText: altText,
        tags: tags,
        flairIds: flairIds,
        nsfw: nsfw,
        postIdBeingEdited: postIdBeingEdited,
        languageId: languageId,
      );

      emit(state.copyWith(
        status: CreatePostStatus.success,
        post: post,
        message: null,
        errorReason: null,
      ));
      return post.id;
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: CreatePostStatus.error,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message),
      ));
    }

    return null;
  }
}
