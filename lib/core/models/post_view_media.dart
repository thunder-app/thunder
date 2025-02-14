import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/models.dart';

class PostViewMedia {
  PostView postView;
  List<Media> media;

  PostViewMedia({
    required this.postView,
    this.media = const [],
  });
}
