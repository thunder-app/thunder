import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/account/account.dart';

/// Fetches the currently active profile account.
Future<Account?> fetchActiveProfileAccount() async {
  final prefs = (await UserPreferences.instance).sharedPreferences;
  final accountId = prefs.getString('active_profile_id');
  final account = await Account.fetchAccount(accountId ?? '');

  return account;
}

/// Triggers the profile modal sheet to allow selection of a different profile.
Future<void> showProfileModalSheet(
  BuildContext context, {
  bool showLogoutDialog = false,
  bool quickSelectMode = false,
  String? customHeading,
  bool reloadOnSwitch = true,
}) async {
  final authBloc = context.read<AuthBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  await showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return MultiBlocProvider(
        providers: [BlocProvider.value(value: authBloc), BlocProvider.value(value: thunderBloc)],
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
