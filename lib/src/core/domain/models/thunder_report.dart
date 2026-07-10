import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/models/thunder_comment.dart';
import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_post.dart';
import 'package:thunder/src/core/domain/models/thunder_private_message.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';

/// The kind of content a report is about.
enum ReportKind {
  /// A post report.
  post,

  /// A comment report.
  comment,

  /// A private-message report.
  privateMessage,

  /// A community report.
  community,
}

class ThunderReport extends Equatable {
  /// The report id on its home instance.
  final int id;

  /// What kind of content was reported.
  final ReportKind kind;

  /// Reason entered by the reporter.
  final String reason;

  /// Whether moderators have resolved the report.
  final bool resolved;

  /// User who created the report, when included.
  final ThunderUser? creator;

  /// Reported post for [ReportKind.post].
  final ThunderPost? post;

  /// Reported comment for [ReportKind.comment].
  final ThunderComment? comment;

  /// Related or reported community.
  final ThunderCommunity? community;

  /// Reported private message for [ReportKind.privateMessage].
  final ThunderPrivateMessage? privateMessage;

  const ThunderReport({
    required this.id,
    required this.kind,
    required this.reason,
    required this.resolved,
    this.creator,
    this.post,
    this.comment,
    this.community,
    this.privateMessage,
  });

  @override
  List<Object?> get props => [id, kind, reason, resolved, creator, post, comment, community, privateMessage];

  ThunderReport copyWith({
    int? id,
    ReportKind? kind,
    String? reason,
    bool? resolved,
    ThunderUser? creator,
    ThunderPost? post,
    ThunderComment? comment,
    ThunderCommunity? community,
    ThunderPrivateMessage? privateMessage,
  }) {
    return ThunderReport(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      creator: creator ?? this.creator,
      post: post ?? this.post,
      comment: comment ?? this.comment,
      community: community ?? this.community,
      privateMessage: privateMessage ?? this.privateMessage,
    );
  }
}
