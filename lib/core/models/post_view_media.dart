import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/enums/post_view_context.dart';

class PostViewMedia {
  PostView postView;
  List<Media> media;
  PostViewContext postViewContext;

  PostViewMedia({
    required this.postView,
    required this.postViewContext,
    this.media = const [],
  });
}
