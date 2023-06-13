import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/models/media.dart';

class PostViewMedia extends PostView {
  final List<Media> media;

  PostViewMedia({
    required super.post,
    required super.community,
    required super.counts,
    required super.creator,
    required super.creatorBannedFromCommunity,
    required super.creatorBlocked,
    required super.saved,
    required super.subscribed,
    required super.read,
    required super.unreadComments,
    this.media = const [],
  });
}
