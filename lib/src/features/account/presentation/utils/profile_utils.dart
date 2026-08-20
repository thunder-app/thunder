import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';

/// Triggers the profile modal sheet to allow selection of a different profile.
Future<void> showProfileModalSheet(BuildContext context, {bool showLogoutDialog = false, bool quickSelectMode = false, String? customHeading}) async {
  await showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.8,
        child: ProfileModalBody(showLogoutDialog: showLogoutDialog, quickSelectMode: quickSelectMode, customHeading: customHeading),
      );
    },
  );
}
