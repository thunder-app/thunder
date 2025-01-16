import 'package:thunder/post/enums/post_action.dart';

enum CommentAction {
  viewSource(permissionType: PermissionType.all),

  /// User level comment actions
  vote(permissionType: PermissionType.user),
  save(permissionType: PermissionType.user),
  delete(permissionType: PermissionType.user),
  report(permissionType: PermissionType.user),
  reply(permissionType: PermissionType.user),
  edit(permissionType: PermissionType.user),
  read(permissionType: PermissionType.user), // This is used for inbox items (replies/mentions)

  /// Moderator level post actions
  remove(permissionType: PermissionType.moderator),

  /// Admin level post actions
  purge(permissionType: PermissionType.admin);

  const CommentAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
