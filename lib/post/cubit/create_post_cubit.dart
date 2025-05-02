import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(const CreatePostState(status: CreatePostStatus.initial));

  Future<void> clearMessage() async {
    emit(state.copyWith(status: CreatePostStatus.initial, message: null));
  }

  Future<void> uploadImages(List<String> imageFiles, {bool isPostImage = false}) async {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    PictrsApi pictrs = PictrsApi(account.instance);
    List<String> urls = [];

    isPostImage ? emit(state.copyWith(status: CreatePostStatus.postImageUploadInProgress)) : emit(state.copyWith(status: CreatePostStatus.imageUploadInProgress));

    try {
      for (String imageFile in imageFiles) {
        PictrsUpload result = await pictrs.upload(filePath: imageFile, auth: account.jwt);
        String url = "https://${account.instance}/pictrs/image/${result.files[0].file}";

        urls.add(url);

        // Add a delay between each upload to avoid possible rate limiting
        await Future.wait(urls.map((url) => Future.delayed(const Duration(milliseconds: 500))));
      }

      isPostImage ? emit(state.copyWith(status: CreatePostStatus.postImageUploadSuccess, imageUrls: urls)) : emit(state.copyWith(status: CreatePostStatus.imageUploadSuccess, imageUrls: urls));
    } catch (e) {
      isPostImage
          ? emit(state.copyWith(status: CreatePostStatus.postImageUploadFailure, message: e.toString()))
          : emit(state.copyWith(status: CreatePostStatus.imageUploadFailure, message: e.toString()));
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
        altText: altText,
        nsfw: nsfw,
        postIdBeingEdited: postIdBeingEdited,
        languageId: languageId,
      );

      // Parse the newly created post
      List<ThunderPost> posts = await parsePosts([postView]);

      emit(state.copyWith(status: CreatePostStatus.success, post: posts.firstOrNull));
      return posts.firstOrNull?.id;
    } catch (e) {
      emit(state.copyWith(status: CreatePostStatus.error, message: getExceptionErrorMessage(e)));
    }

    return null;
  }
}
