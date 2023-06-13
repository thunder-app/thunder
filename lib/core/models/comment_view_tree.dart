import 'package:lemmy/lemmy.dart';

class CommentViewTree extends CommentView {
  final List<CommentViewTree> replies;

  CommentViewTree({
    required super.comment,
    required super.community,
    required super.counts,
    required super.creator,
    required super.creatorBannedFromCommunity,
    required super.creatorBlocked,
    required super.post,
    required super.saved,
    required super.subscribed,
    this.replies = const [],
  });
}
