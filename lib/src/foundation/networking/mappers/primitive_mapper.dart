import 'package:collection/collection.dart';

import 'package:thunder/src/foundation/primitives/enums/feed_list_type.dart';
import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';
import 'package:thunder/src/foundation/primitives/models/media.dart';
import 'package:thunder/src/foundation/primitives/models/piefed_post_metadata.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_content_item.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_flair.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/foundation/primitives/models/notification_ref.dart';
import 'package:thunder/src/foundation/primitives/models/vote_state.dart';
import 'package:thunder/src/foundation/primitives/enums/post_sort_type.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_local_user.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_my_user.dart';

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
