import 'package:thunder/post/enums/post_action.dart';

enum UserAction {
  /// User level user actions
  block(permissionType: PermissionType.user);

  /// Moderator level user actions
  // ban(permissionType: PermissionType.moderator),

  /// Admin level user actions
  // purge(permissionType: PermissionType.admin);

  const UserAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
