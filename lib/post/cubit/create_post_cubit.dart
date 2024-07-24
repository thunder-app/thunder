import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/error_messages.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit()
      : super(const CreatePostState(status: CreatePostStatus.initial));

  Future<void> clearMessage() async {
    emit(state.copyWith(status: CreatePostStatus.initial, message: null));
  }

  Future<void> uploadImages(List<String> imageFiles,
      {bool isPostImage = false}) async {
    Account? account = await fetchActiveProfileAccount();
    if (account == null) return;

    PictrsApi pictrs = PictrsApi(account.instance!);
    List<String> urls = [];

    isPostImage
        ? emit(
            state.copyWith(status: CreatePostStatus.postImageUploadInProgress))
        : emit(state.copyWith(status: CreatePostStatus.imageUploadInProgress));

    try {
      for (String imageFile in imageFiles) {
        PictrsUpload result =
            await pictrs.upload(filePath: imageFile, auth: account.jwt);
        String url =
            "https://${account.instance!}/pictrs/image/${result.files[0].file}";

        urls.add(url);

        // Add a delay between each upload to avoid possible rate limiting
        await Future.wait(urls
            .map((url) => Future.delayed(const Duration(milliseconds: 500))));
      }

      isPostImage
          ? emit(state.copyWith(
              status: CreatePostStatus.postImageUploadSuccess, imageUrls: urls))
          : emit(state.copyWith(
              status: CreatePostStatus.imageUploadSuccess, imageUrls: urls));
    } catch (e) {
      isPostImage
          ? emit(state.copyWith(
              status: CreatePostStatus.postImageUploadFailure,
              message: e.toString()))
          : emit(state.copyWith(
              status: CreatePostStatus.imageUploadFailure,
              message: e.toString()));
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
    bool? nsfw,
    int? postIdBeingEdited,
    int? languageId,
  }) async {
    emit(state.copyWith(status: CreatePostStatus.submitting));

    try {
      PostView postView = await createPost(
        communityId: communityId,
        name: name,
        body: body,
        url: url,
        customThumbnail: customThumbnail,
        nsfw: nsfw,
        postIdBeingEdited: postIdBeingEdited,
        languageId: languageId,
      );

      // Parse the newly created post
      List<PostViewMedia> postViewMedias = await parsePostViews([postView]);

      emit(state.copyWith(
          status: CreatePostStatus.success,
          postViewMedia: postViewMedias.firstOrNull));
      return postViewMedias.firstOrNull?.postView.post.id;
    } catch (e) {
      emit(state.copyWith(
          status: CreatePostStatus.error,
          message: getExceptionErrorMessage(e)));
    }

    return null;
  }
}
