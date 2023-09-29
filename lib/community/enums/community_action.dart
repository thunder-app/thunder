import 'package:thunder/post/enums/post_action.dart';

enum CommunityAction {
  /// User level post actions
  block(permissionType: PermissionType.user),
  follow(permissionType: PermissionType.user);
  // create(permissionType: PermissionType.user),

  /// Moderator level post actions
  // banUser(permissionType: PermissionType.moderator),
  // addModerator(permissionType: PermissionType.moderator),
  // delete(permissionType: PermissionType.moderator),
  // edit(permissionType: PermissionType.moderator),

  /// Admin level post actions
  // purge(permissionType: PermissionType.admin);

  const CommunityAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
