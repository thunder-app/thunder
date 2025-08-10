import 'package:thunder/src/features/post/post.dart';

enum InstanceAction {
  /// User level instance actions
  block(permissionType: PermissionType.user);

  const InstanceAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
