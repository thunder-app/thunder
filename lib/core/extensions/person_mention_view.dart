import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/models/models.dart';

extension PersonMentionViewExtension on PersonMentionView {
  ThunderComment toComment() {
    final commentView = CommentView(
      comment: comment,
      creator: creator,
      post: post,
      community: community,
      counts: counts,
      creatorBannedFromCommunity: creatorBannedFromCommunity,
      subscribed: subscribed,
      saved: saved,
      creatorBlocked: creatorBlocked,
    );

    return ThunderComment(comment: comment, commentView: commentView);
  }
}
