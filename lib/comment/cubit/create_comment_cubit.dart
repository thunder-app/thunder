import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'create_comment_state.dart';

class CreateCommentCubit extends Cubit<CreateCommentState> {
  CreateCommentCubit() : super(const CreateCommentState(status: CreateCommentStatus.initial));

  Future<void> clearMessage() async {
    emit(state.copyWith(status: CreateCommentStatus.initial, message: null));
  }

  Future<void> uploadImages(List<String> imageFiles) async {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    PictrsApi pictrs = PictrsApi(account.instance);
    List<String> urls = [];

    emit(state.copyWith(status: CreateCommentStatus.imageUploadInProgress));

    try {
      for (String imageFile in imageFiles) {
        PictrsUpload result = await pictrs.upload(filePath: imageFile, auth: account.jwt);
        String url = "https://${account.instance}/pictrs/image/${result.files[0].file}";

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
        comment = await editComment(commentIdBeingEdited, content, languageId);
      } else {
        comment = await createComment(postId!, content, parentCommentId, languageId);
      }

      emit(state.copyWith(status: CreateCommentStatus.success, comment: comment));
      return comment.id;
    } catch (e) {
      emit(state.copyWith(status: CreateCommentStatus.error, message: getExceptionErrorMessage(e)));
    }

    return null;
  }
}
