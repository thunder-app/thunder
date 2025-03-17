import 'package:lemmy_api_client/v3.dart';

class ThunderCommunity {
  /// The Lemmy API model for the community.
  Community community;

  ThunderCommunity(this.community);

  /// The ID of the community.
  int get id => community.id;

  /// The name of the community. If the community has a title, it is used. Otherwise, the name is used.
  String get name => community.title.isNotEmpty == true ? community.title : community.name;

  /// The name of the community.
  String get communityName => community.name;

  /// The title of the community.
  String get title => community.title;

  /// Whether the community is locked from posting.
  bool get locked => community.postingRestrictedToMods;

  /// The icon of the community.
  String? get icon => community.icon;

  /// The URL to the community. This is generally associated with the ActivityPub actor URL.
  String get url => community.actorId;
}
