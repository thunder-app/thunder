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

DateTime? mapperDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

SubscriptionStatus? mapperSubscriptionStatus(dynamic value) {
  if (value == null) return null;
  return SubscriptionStatus.values.firstWhereOrNull((status) => status.name == value);
}

SubscriptionStatus? mapperV4SubscriptionStatus(dynamic value) {
  return switch (value) {
    'accepted' => SubscriptionStatus.subscribed,
    'pending' || 'approval_required' => SubscriptionStatus.pending,
    'denied' => SubscriptionStatus.notSubscribed,
    _ => null,
  };
}

PostSortType? mapperPostSortType(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return PostSortType.values.firstWhereOrNull((sort) => sort.value.toLowerCase() == normalized || sort.name.toLowerCase() == normalized);
}

FeedListType? mapperFeedListType(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return FeedListType.values.firstWhereOrNull((type) => type.value.toLowerCase() == normalized || type.name.toLowerCase() == normalized);
}

NotificationKind mapperNotificationKind(dynamic value) {
  return switch (value) {
    'mention' => NotificationKind.mention,
    'reply' => NotificationKind.reply,
    'subscribed' => NotificationKind.subscribed,
    'private_message' => NotificationKind.privateMessage,
    'mod_action' => NotificationKind.modAction,
    _ => NotificationKind.reply,
  };
}
