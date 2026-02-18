import 'package:thunder/src/foundation/primitives/models/thunder_site_response.dart';
import 'package:thunder/src/foundation/networking/lemmy/base_lemmy_api_client.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';

/// Lemmy API client for version 1.0.0+ (v4 API).
///
/// This client uses the `/api/v4` endpoints. When the v4 schema differs
/// from v3, this class should override the appropriate methods.
///
/// Note: As of this implementation, the parsing methods use the same
/// factories as v3. When Lemmy v4 introduces schema changes, create
/// new `fromLemmyV4*` factory constructors in the model classes and
/// update this client to use them.
class LemmyV4ApiClient extends BaseLemmyApiClient {
  LemmyV4ApiClient({
    required super.account,
    super.debug,
    required super.version,
    super.httpClient,
  });

  @override
  String get basePath => '/api/v4';

  // =============================================================
  // Version-specific parsing methods
  // =============================================================
  //
  // TODO: When Lemmy v4 introduces schema changes:
  // 1. Create new `fromLemmyV4*` factory constructors in model classes
  // 2. Update these methods to use the v4 factories
  // 3. Override any methods in BaseLemmyApiClient that have different
  //    endpoints or request/response formats in v4

  @override
  ThunderPost parsePost(Map<String, dynamic> json) {
    // TODO: Replace with ThunderPost.fromLemmyV4PostView when v4 schema differs
    return ThunderPost.fromLemmyPostView(json);
  }

  @override
  ThunderComment parseComment(Map<String, dynamic> json) {
    // TODO: Replace with ThunderComment.fromLemmyV4CommentView when v4 schema differs
    return ThunderComment.fromLemmyCommentView(json);
  }

  @override
  ThunderUser parseUser(Map<String, dynamic> json) {
    // TODO: Replace with ThunderUser.fromLemmyV4User when v4 schema differs
    return ThunderUser.fromLemmyUser(json);
  }

  @override
  ThunderUser parseUserView(Map<String, dynamic> json) {
    // TODO: Replace with ThunderUser.fromLemmyV4UserView when v4 schema differs
    return ThunderUser.fromLemmyUserView(json);
  }

  @override
  ThunderCommunity parseCommunity(Map<String, dynamic> json) {
    // TODO: Replace with ThunderCommunity.fromLemmyV4Community when v4 schema differs
    return ThunderCommunity.fromLemmyCommunity(json);
  }

  @override
  ThunderCommunity parseCommunityView(Map<String, dynamic> json) {
    // TODO: Replace with ThunderCommunity.fromLemmyV4CommunityView when v4 schema differs
    return ThunderCommunity.fromLemmyCommunityView(json);
  }

  @override
  ThunderSiteResponse parseSiteResponse(Map<String, dynamic> json) {
    // TODO: Replace with ThunderSiteResponse.fromLemmyV4SiteResponse when v4 schema differs
    return ThunderSiteResponse.fromLemmySiteResponse(json);
  }

  // =============================================================
  // V4-specific endpoint overrides
  // =============================================================
  //
  // Override methods from BaseLemmyApiClient here when the v4 API
  // differs from v3 in:
  // - Endpoint paths
  // - Request parameters
  // - Response structure
  //
  // Example:
  // @override
  // Future<GetPostsResponse> getPosts({...}) async {
  //   // V4-specific implementation
  // }
}
