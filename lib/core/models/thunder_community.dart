import 'package:lemmy_api_client/v3.dart';

class ThunderCommunity {
  /// The Lemmy API model for the community.
  final Community _community;

  /// The Lemmy API model for the community view.
  final CommunityView? _communityView;

  ThunderCommunity(this._community, {CommunityView? communityView}) : _communityView = communityView;

  /// The ID of the community.
  int get id => _community.id;

  /// The name of the community. If the community has a title, it is used. Otherwise, the name is used.
  String get name => _community.title.isNotEmpty == true ? _community.title : _community.name;

  /// The name of the community.
  String get communityName => _community.name;

  /// The title of the community.
  String get title => _community.title;

  /// Whether the community is locked from posting.
  bool get locked => _community.postingRestrictedToMods;

  /// The icon of the community.
  String? get icon => _community.icon;

  /// The URL to the community. This is generally associated with the ActivityPub actor URL.
  String get url => _community.actorId;

  /// The number of subscribers to the community.
  int? get subscribers => _communityView?.counts.subscribers;

  /// The current user subscription status to the community.
  SubscribedType? get subscribed => _communityView?.subscribed;
}
