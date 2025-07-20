import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/comment/models/thunder_comment.dart';


extension CommentReplyViewExtension on CommentReplyView {
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
      myVote: myVote as int?,
    );

    return ThunderComment.fromLemmyCommentView(commentView.toJson());
  }
}
