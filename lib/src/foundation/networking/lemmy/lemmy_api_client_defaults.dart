import 'package:thunder/src/foundation/networking/base_api_client.dart';
import 'package:thunder/src/foundation/networking/thunder_api_client.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';

/// Shared [ThunderApiClient] defaults for Lemmy API clients.
mixin LemmyApiClientDefaults on BaseApiClient implements ThunderApiClient {
  @override
  Future<ThunderPost> createPostWithMetadata({
    required String title,
    required int communityId,
    String? url,
    String? contents,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
  }) {
    return createPost(
      title: title,
      communityId: communityId,
      url: url,
      contents: contents,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
      altText: altText,
    );
  }

  @override
  Future<ThunderPost> editPostWithMetadata({
    required int postId,
    required String title,
    String? url,
    String? contents,
    String? altText,
    bool? nsfw,
    int? languageId,
    String? customThumbnail,
    List<String>? tags,
    List<int>? flairIds,
  }) {
    return editPost(
      postId: postId,
      title: title,
      url: url,
      contents: contents,
      altText: altText,
      nsfw: nsfw,
      languageId: languageId,
      customThumbnail: customThumbnail,
    );
  }

  @override
  bool get supportsListReports => true;

  @override
  bool get supportsSettingsImportExport => true;

  @override
  bool get supportsTOTP => true;
}
