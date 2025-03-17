import 'package:lemmy_api_client/v3.dart';

class ThunderUser {
  /// The Lemmy API model for the user.
  Person user;

  /// The total number of posts that the user has made.
  final int? totalPosts;

  /// The total number of comments that the user has made.
  final int? totalComments;

  ThunderUser(this.user, {this.totalPosts, this.totalComments});

  /// The ID of the user.
  int get id => user.id;

  /// The name of the user. If the user has a display name, it is used. Otherwise, the username is used.
  String get name => (displayName?.isNotEmpty == true ? displayName : username) ?? '';

  /// The username of the user.
  String get username => user.name;

  /// The display name of the user.
  String? get displayName => user.displayName;

  /// The avatar of the user.
  String? get icon => user.avatar;

  /// The banner of the user.
  String? get banner => user.banner;

  /// The URL to the user's profile. This is generally associated with the ActivityPub actor URL.
  String get url => user.actorId;

  /// The date and time that the user was created.
  DateTime get created => user.published;
}
