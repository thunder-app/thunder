import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/post/utils/post.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(const CreatePostState(status: CreatePostStatus.initial));

  Future<void> clearMessage() async {
    emit(state.copyWith(status: state.status, message: null));
  }

  Future<void> uploadImage(String imageFile) async {
    Account? account = await fetchActiveProfileAccount();
    if (account == null) return;

    PictrsApi pictrs = PictrsApi(account.instance!);

    emit(state.copyWith(status: CreatePostStatus.imageUploadInProgress));

    try {
      PictrsUpload result = await pictrs.upload(filePath: imageFile, auth: account.jwt);
      String url = "https://${account.instance!}/pictrs/image/${result.files[0].file}";

      emit(state.copyWith(status: CreatePostStatus.imageUploadSuccess, imageUrl: url));
    } catch (e) {
      emit(state.copyWith(status: CreatePostStatus.imageUploadFailure, message: e.toString()));
    }
  }

  /// Creates or edits a post. When successful, it returns the newly created/updated post in the form of a [PostViewMedia]
  Future<void> createOrEditPost({required int communityId, required String name, String? body, String? url, bool? nsfw, int? postIdBeingEdited}) async {
    emit(state.copyWith(status: CreatePostStatus.loading));

    try {
      PostView postView = await createPost(
        communityId: communityId,
        name: name,
        body: body,
        url: url,
        nsfw: nsfw,
        postIdBeingEdited: postIdBeingEdited,
      );

      // Parse the newly created post
      List<PostViewMedia> postViewMedias = await parsePostViews([postView]);

      emit(state.copyWith(status: CreatePostStatus.success, postViewMedia: postViewMedias.firstOrNull));
    } catch (e) {
      return emit(state.copyWith(status: CreatePostStatus.error, message: e.toString()));
    }
  }
}
