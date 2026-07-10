import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

class Account {
  /// The internal id of the account in the database
  final String id;

  /// The position of the account in the list of accounts
  final int index;

  /// Whether the account is anonymous or not
  final bool anonymous;

  /// The instance of the account
  final String instance;

  /// The username of the account. This is only applicable to non-anonymous accounts
  final String? username;

  /// The display name of the account. This is only applicable to non-anonymous accounts
  final String? displayName;

  /// The JWT token of the account. This is only applicable to non-anonymous accounts
  final String? jwt;

  /// The user id of the account. This is only applicable to non-anonymous accounts
  final int? userId;

  /// The platform of the account (lemmy, piefed, etc.)
  final ThreadiversePlatform? platform;

  const Account({
    required this.id,
    required this.index,
    this.anonymous = false,
    required this.instance,
    this.username,
    this.displayName,
    this.jwt,
    this.userId,
    this.platform,
  });

  Account copyWith({String? id, int? index, ThreadiversePlatform? platform}) => Account(
        id: id ?? this.id,
        index: index ?? this.index,
        anonymous: anonymous,
        instance: instance,
        username: username,
        displayName: displayName,
        jwt: jwt,
        userId: userId,
        platform: platform ?? this.platform,
      );

  String get actorId => 'https://$instance/u/$username';
}
