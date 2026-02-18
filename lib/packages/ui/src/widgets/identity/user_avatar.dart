import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/models/identity/avatar_data.dart';
import 'package:thunder/packages/ui/src/widgets/identity/avatar_widgets.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.data,
  });

  final AvatarData data;

  @override
  Widget build(BuildContext context) {
    return UserAvatarWidget(data: data);
  }
}
