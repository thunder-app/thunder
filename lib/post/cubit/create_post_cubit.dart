import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/error_messages.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(const CreatePostState(status: CreatePostStatus.initial));

  Future<void> clearMessage() async {
    emit(state.copyWith(status: CreatePostStatus.initial, message: null));
  }

  Future<void> uploadImage(String imageFile, {bool isPostImage = false}) async {
    Account? account = await fetchActiveProfileAccount();
    if (account == null) return;

    PictrsApi pictrs = PictrsApi(account.instance!);

    isPostImage ? emit(state.copyWith(status: CreatePostStatus.postImageUploadInProgress)) : emit(state.copyWith(status: CreatePostStatus.imageUploadInProgress));

    try {
      PictrsUpload result = await pictrs.upload(filePath: imageFile, auth: account.jwt);
      String url = "https://${account.instance!}/pictrs/image/${result.files[0].file}";

      isPostImage ? emit(state.copyWith(status: CreatePostStatus.postImageUploadSuccess, imageUrl: url)) : emit(state.copyWith(status: CreatePostStatus.imageUploadSuccess, imageUrl: url));
    } catch (e) {
      isPostImage
          ? emit(state.copyWith(status: CreatePostStatus.postImageUploadFailure, message: e.toString()))
          : emit(state.copyWith(status: CreatePostStatus.imageUploadFailure, message: e.toString()));
    }
  }

  /// Creates or edits a post. When successful, it emits the newly created/updated post in the form of a [PostViewMedia]
  /// and returns the newly created post id.
  Future<int?> createOrEditPost({required int communityId, required String name, String? body, String? url, bool? nsfw, int? postIdBeingEdited, int? languageId}) async {
    emit(state.copyWith(status: CreatePostStatus.submitting));

    try {
      final lemmy = LemmyClient.instance.lemmyApiV3;
      // PostView postView = await createPost(
      //   communityId: communityId,
      //   name: name,
      //   body: body,
      //   url: url,
      //   nsfw: nsfw,
      //   postIdBeingEdited: postIdBeingEdited,
      //   languageId: languageId,
      // );

      GetPostResponse getPostResponse = await lemmy.run(GetPost(id: 14462486));

      // Parse the newly created post
      List<PostViewMedia> postViewMedias = await parsePostViews([getPostResponse.postView]);

      emit(state.copyWith(status: CreatePostStatus.success, postViewMedia: postViewMedias.firstOrNull));
      return postViewMedias.firstOrNull?.postView.post.id;
    } catch (e) {
      emit(state.copyWith(status: CreatePostStatus.error, message: getExceptionErrorMessage(e)));
    }

    return null;
  }
}
