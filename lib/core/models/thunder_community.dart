import 'package:lemmy_api_client/v3.dart';

class ThunderCommunity {
  /// The Lemmy API model for the community.
  final Community _community;

  /// The Lemmy API model for the community view.
  late CommunityView? _communityView;

  ThunderCommunity(this._community, {CommunityView? communityView, SubscribedType? subscribed}) {
    if (communityView == null && subscribed != null) {
      // If the community view is not provided, create a new one with the provided subscription status.
      _communityView = CommunityView(
        community: _community,
        subscribed: subscribed,
        blocked: false,
        counts: CommunityAggregates(
          communityId: _community.id,
          published: _community.published,
          subscribers: -1,
          subscribersLocal: -1,
          usersActiveDay: -1,
          usersActiveWeek: -1,
          usersActiveMonth: -1,
          usersActiveHalfYear: -1,
          posts: -1,
          comments: -1,
        ),
      );
    } else {
      // If the community view is provided, use it.
      _communityView = communityView;
    }
  }

  /// The ID of the community.
  int get id => _community.id;

  /// The name of the community. If the community has a title, it is used. Otherwise, the name is used.
  String get titleOrName => _community.title.isNotEmpty == true ? _community.title : _community.name;

  /// The name of the community.
  String get name => _community.name;

  /// The title of the community.
  String get title => _community.title;

  /// The description of the community.
  String? get description => _community.description;

  /// Whether the community is locked from posting.
  bool get locked => _community.postingRestrictedToMods;

  /// Whether the community is blocked by the user.
  bool? get blocked => _communityView?.blocked;

  /// The icon of the community.
  String? get icon => _community.icon;

  /// The banner of the community.
  String? get banner => _community.banner;

  /// Whether the community is removed.
  bool get removed => _community.removed;

  /// The URL to the community. This is generally associated with the ActivityPub actor URL.
  String get url => _community.actorId;

  /// The number of subscribers to the community, includes federated instances.
  int? get subscribers => _communityView?.counts.subscribers;

  /// The number of subscribers to the community, only includes local instance.
  int? get subscribersLocal => _communityView?.counts.subscribersLocal;

  /// The number of active daily users in the community.
  int? get usersActiveDay => _communityView?.counts.usersActiveDay;

  /// The number of active weekly users in the community.
  int? get usersActiveWeek => _communityView?.counts.usersActiveWeek;

  /// The number of active monthly users in the community.
  int? get usersActiveMonth => _communityView?.counts.usersActiveMonth;

  /// The number of active half-yearly users in the community.
  int? get usersActiveHalfYear => _communityView?.counts.usersActiveHalfYear;

  /// The current user subscription status to the community.
  SubscribedType? get subscribed => _communityView?.subscribed;

  /// The date and time that the community was created.
  DateTime get created => _community.published;

  /// The total number of posts in the community.
  int? get totalPosts => _communityView?.counts.posts;

  /// The total number of comments in the community.
  int? get totalComments => _communityView?.counts.comments;

  /// Whether the community is local to the instance, or federated.
  bool? get local => _community.local;

  /// The instance ID of the community.
  int get instanceId => _community.instanceId;
}
