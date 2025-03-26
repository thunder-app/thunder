import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/models/media.dart';

class ThunderPost {
  /// The Lemmy API model for the post.
  final Post _post;

  /// The media associated with the post.
  final List<Media> _media;

  /// The Lemmy API model for the post view.
  final PostView? _postView;

  ThunderPost(this._post, {PostView? postView, List<Media> media = const []})
      : _postView = postView,
        _media = media;

  /// The ID of the post.
  int get id => _post.id;

  /// The title of the post.
  String get title => _post.name;

  /// Whether the post was read or not.
  bool get read => _postView?.read ?? false;

  /// Whether the post was hidden by the current user.
  bool get hidden => _postView?.hidden ?? false;

  /// Whether the post was removed by a moderator or admin.
  bool get removed => _post.removed;

  /// Whether the post was deleted by the user.
  bool get deleted => _post.deleted;

  /// Whether the post was saved by the user.
  bool get saved => _postView?.saved ?? false;

  /// Whether the post was locked by a moderator or admin.
  bool get locked => _post.locked;

  /// Whether the post was featured in the community by a moderator or admin.
  bool get featuredCommunity => _post.featuredCommunity;

  /// Whether the post is featured on the instance.
  bool get featuredLocal => _post.featuredLocal;

  /// The media associated with the post.
  List<Media> get media => _media;

  /// The date the post was created.
  DateTime get created => _post.published;

  /// The date the post was last updated.
  DateTime? get updated => _post.updated;

  /// The number of comments on the post.
  int? get comments => _postView?.counts.comments;

  /// The number of upvotes on the post.
  int? get upvotes => _postView?.counts.upvotes;

  /// The number of downvotes on the post.
  int? get downvotes => _postView?.counts.downvotes;

  /// The score of the post.
  int? get score => _postView?.counts.score;

  /// The vote status by the current user.
  int? get voteType => _postView?.myVote;

  /// The number of unread comments on the post.
  int? get unreadComments => _postView?.unreadComments;

  /// The language of the post.
  int? get languageId => _post.languageId;
}
