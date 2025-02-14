import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/utils/convert.dart';

import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';

part 'create_comment_state.dart';

class CreateCommentCubit extends Cubit<CreateCommentState> {
  CreateCommentCubit() : super(const CreateCommentState(status: CreateCommentStatus.initial));

  Future<void> clearMessage() async {
    emit(state.copyWith(status: CreateCommentStatus.initial, message: null));
  }

  Future<void> uploadImages(List<String> imageFiles) async {
    Account? account = await fetchActiveProfileAccount();
    if (account == null) return;

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

  /// Creates or edits a comment. When successful, it emits the newly created/updated comment in the form of a [CommentView]
  /// and returns the newly created comment id.
  Future<int?> createOrEditComment({int? postId, int? parentCommentId, required String content, int? commentIdBeingEdited, int? languageId}) async {
    assert(!(postId == null && commentIdBeingEdited == null));
    emit(state.copyWith(status: CreateCommentStatus.submitting));

    try {
      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      CommentResponse commentResponse;

      if (commentIdBeingEdited != null) {
        commentResponse = await lemmy.run(EditComment(
          commentId: commentIdBeingEdited,
          content: content,
          languageId: languageId,
          auth: account!.jwt!,
        ));
      } else {
        commentResponse = await lemmy.run(CreateComment(
          postId: postId!,
          content: content,
          parentId: parentCommentId,
          languageId: languageId,
          auth: account!.jwt!,
        ));
      }

      emit(state.copyWith(status: CreateCommentStatus.success, commentView: convertToCommentView(commentResponse.commentView)));
      return commentResponse.commentView.comment.id;
    } catch (e) {
      emit(state.copyWith(status: CreateCommentStatus.error, message: getExceptionErrorMessage(e)));
    }

    return null;
  }
}
