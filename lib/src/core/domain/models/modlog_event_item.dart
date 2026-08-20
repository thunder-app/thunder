import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';
import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';

/// Pure foundation DTO used by networking boundaries for modlog entries.
class ModlogEvent {
  const ModlogEvent({required this.type, required this.dateTime, this.moderator, this.admin, this.reason, this.user, this.post, this.comment, this.community, required this.actioned});

  final ModlogActionType type;
  final String dateTime;
  final ThunderUser? moderator;
  final ThunderUser? admin;
  final String? reason;
  final ThunderUser? user;
  final ThunderPost? post;
  final ThunderComment? comment;
  final ThunderCommunity? community;
  final bool actioned;
}
