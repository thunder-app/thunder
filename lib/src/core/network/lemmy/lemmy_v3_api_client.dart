import 'package:thunder/src/core/models/thunder_site_response.dart';
import 'package:thunder/src/core/network/lemmy/base_lemmy_api_client.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

/// Lemmy API client for version 0.19.x (v3 API).
///
/// This client uses the `/api/v3` endpoints and the original JSON schema
/// with field names like `actor_id`, `published`, etc.
class LemmyV3ApiClient extends BaseLemmyApiClient {
  LemmyV3ApiClient({
    required super.account,
    super.debug,
    required super.version,
    super.httpClient,
  });

  @override
  String get basePath => '/api/v3';

  // =============================================================
  // Version-specific parsing methods
  // =============================================================

  @override
  ThunderPost parsePost(Map<String, dynamic> json) {
    return ThunderPost.fromLemmyPostView(json);
  }

  @override
  ThunderComment parseComment(Map<String, dynamic> json) {
    return ThunderComment.fromLemmyCommentView(json);
  }

  @override
  ThunderUser parseUser(Map<String, dynamic> json) {
    return ThunderUser.fromLemmyUser(json);
  }

  @override
  ThunderUser parseUserView(Map<String, dynamic> json) {
    return ThunderUser.fromLemmyUserView(json);
  }

  @override
  ThunderCommunity parseCommunity(Map<String, dynamic> json) {
    return ThunderCommunity.fromLemmyCommunity(json);
  }

  @override
  ThunderCommunity parseCommunityView(Map<String, dynamic> json) {
    return ThunderCommunity.fromLemmyCommunityView(json);
  }

  @override
  ThunderSiteResponse parseSiteResponse(Map<String, dynamic> json) {
    return ThunderSiteResponse.fromLemmySiteResponse(json);
  }
}
