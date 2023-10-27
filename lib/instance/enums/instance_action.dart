import 'package:thunder/post/enums/post_action.dart';

enum InstanceAction {
  /// User level instance actions
  block(permissionType: PermissionType.user);

  const InstanceAction({
    required this.permissionType,
  });

  final PermissionType permissionType;
}
