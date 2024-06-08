import 'package:thunder/post/enums/post_action.dart';

enum CommentAction {
  /// User level comment actions
  vote(permissionType: PermissionType.user),
  save(permissionType: PermissionType.user),
  delete(permissionType: PermissionType.user),
  report(permissionType: PermissionType.user),

  /// Moderator level post actions
  remove(permissionType: PermissionType.moderator),

  /// Admin level post actions
  purge(permissionType: PermissionType.admin);

  const CommentAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
