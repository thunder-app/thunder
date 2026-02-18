import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';

class ThunderPostReport {
  /// The post report's ID.
  final int id;

  /// The post report's reason.
  final String reason;

  /// Whether the post report has been resolved.
  final bool resolved;

  /// The post report's post.
  final ThunderPost? post;

  /// The post report's community.
  final ThunderCommunity? community;

  /// The post report's creator.
  final ThunderUser? creator;

  ThunderPostReport({
    required this.id,
    required this.reason,
    required this.resolved,
    this.post,
    this.community,
    this.creator,
  });

  ThunderPostReport copyWith({
    int? id,
    String? reason,
    bool? resolved,
    ThunderPost? post,
    ThunderCommunity? community,
    ThunderUser? creator,
  }) {
    return ThunderPostReport(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      resolved: resolved ?? this.resolved,
      post: post ?? this.post,
      community: community ?? this.community,
      creator: creator ?? this.creator,
    );
  }

  factory ThunderPostReport.fromLemmyPostReport(Map<String, dynamic> postReport) {
    return ThunderPostReport(
      id: postReport['id'],
      reason: postReport['reason'],
      resolved: postReport['resolved'],
    );
  }

  factory ThunderPostReport.fromLemmyPostReportView(Map<String, dynamic> postReportView) {
    final postReport = postReportView['post_report'];
    final post = postReportView['post'];
    final community = postReportView['community'];
    final creator = postReportView['creator'];

    return ThunderPostReport(
      id: postReport['id'],
      reason: postReport['reason'],
      resolved: postReport['resolved'],
      post: post != null ? ThunderPost.fromLemmyPost(post) : null,
      community: community != null ? ThunderCommunity.fromLemmyCommunity(community) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
    );
  }
}
