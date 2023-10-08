enum PermissionType { user, moderator, admin }

enum PostAction {
  /// User level post actions
  vote(permissionType: PermissionType.user),
  save(permissionType: PermissionType.user),
  delete(permissionType: PermissionType.user),
  report(permissionType: PermissionType.user),
  read(permissionType: PermissionType.user),

  /// Moderator level post actions
  lock(permissionType: PermissionType.moderator),
  pinCommunity(permissionType: PermissionType.moderator),
  remove(permissionType: PermissionType.moderator),

  /// Admin level post actions
  pinInstance(permissionType: PermissionType.admin),
  purge(permissionType: PermissionType.admin);

  const PostAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
