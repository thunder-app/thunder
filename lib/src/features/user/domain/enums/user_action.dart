import 'package:thunder/src/features/post/post.dart';

enum UserAction {
  setUserLabel(permissionType: PermissionType.all),

  /// User level user actions
  block(permissionType: PermissionType.user),

  /// Moderator level user actions
  addModerator(permissionType: PermissionType.moderator),
  banFromCommunity(permissionType: PermissionType.moderator);

  /// Admin level user actions
  // purge(permissionType: PermissionType.admin);

  const UserAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
