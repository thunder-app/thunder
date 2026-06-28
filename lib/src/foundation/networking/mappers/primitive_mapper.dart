import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';
import 'package:thunder/src/foundation/primitives/models/media.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';

/// Turns platform responses into Thunder models.
abstract class PrimitiveMapper {
  /// Builds a post from a platform post object.
  ThunderPost post(Map<String, dynamic> json, {List<Media> media = const []});

  /// Builds a post from a platform post view.
  ThunderPost postView(Map<String, dynamic> json, {List<Media> media = const []});

  /// Builds a comment from a platform comment object.
  ThunderComment comment(Map<String, dynamic> json);

  /// Builds a comment from a platform comment view.
  ThunderComment commentView(Map<String, dynamic> json, {NotificationRef? notification});

  /// Builds a user from a platform person object.
  ThunderUser user(Map<String, dynamic> json);

  /// Builds a user from a platform person view.
  ThunderUser userView(Map<String, dynamic> json);

  /// Builds a community from a platform community object.
  ThunderCommunity community(Map<String, dynamic> json, {SubscriptionStatus? subscribed});

  /// Builds a community from a platform community view.
  ThunderCommunity communityView(Map<String, dynamic> json);

  /// Builds a private message from a platform message view.
  ThunderPrivateMessage privateMessageView(Map<String, dynamic> json, {NotificationRef? notification});
}
