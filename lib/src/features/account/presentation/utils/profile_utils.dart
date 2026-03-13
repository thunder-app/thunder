import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';

/// Triggers the profile modal sheet to allow selection of a different profile.
Future<void> showProfileModalSheet(
  BuildContext context, {
  bool showLogoutDialog = false,
  bool quickSelectMode = false,
  String? customHeading,
  bool reloadOnSwitch = true,
}) async {
  final profileBloc = context.read<ProfileBloc>();

  await showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return MultiBlocProvider(
        providers: [BlocProvider.value(value: profileBloc)],
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: ProfileModalBody(
            showLogoutDialog: showLogoutDialog,
            quickSelectMode: quickSelectMode,
            customHeading: customHeading,
            reloadOnSwitch: reloadOnSwitch,
          ),
        ),
      );
    },
  );
}
