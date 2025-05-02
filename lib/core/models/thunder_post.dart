import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/models.dart';

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

  /// Creates a new instance of [ThunderPost] with the given fields replaced with the new values.
  ThunderPost copyWith({
    Post? post,
    PostView? postView,
    List<Media>? media,
  }) {
    return ThunderPost(
      post ?? _post,
      postView: postView ?? _postView,
      media: media ?? _media,
    );
  }

  /// The internal post model. ONLY use this in special cases where the raw model is required.
  Post get internalPost => _post;

  /// The internal post view model. ONLY use this in special cases where the raw model is required.
  PostView? get internalPostView => _postView;

  /// The ID of the post.
  int get id => _post.id;

  /// The url associated with the post
  String? get link => _post.url;

  /// The thumbnail associated with the post.
  String? get thumbnail => _post.thumbnailUrl;

  /// The alternate text associated with the post's media.
  String? get altText => _post.altText;

  /// The content of the post.
  String? get body => _post.body;

  /// Whether the post is marked as NSFW.
  bool get nsfw => _post.nsfw;

  /// Whether the post's creator is a moderator of the community.
  bool? get creatorIsModerator => _postView?.creatorIsModerator;

  /// Whether the post's creator is an admin of the instance.
  bool? get creatorIsAdmin => _postView?.creatorIsAdmin;

  /// Whether the post's creator is banned from the community.
  bool? get creatorBannedFromCommunity => _postView?.creatorBannedFromCommunity;

  /// The subscribed status of the post.
  SubscribedType? get subscribed => _postView?.subscribed;

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

  /// The creator of the post
  ThunderUser? get creator => _postView?.creator != null ? ThunderUser(_postView!.creator) : null;

  /// The community associated with the post
  ThunderCommunity? get community => _postView?.community != null ? ThunderCommunity(_postView!.community, subscribed: _postView?.subscribed) : null;

  /// The url for the post. This is generally associated with the ActivityPub actor URL.
  String get url => _post.apId;
}
