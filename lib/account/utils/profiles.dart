import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';

import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/account/account.dart';

/// Fetches the currently active profile. This includes logged in and anonymous accounts.
///
/// It will first try to find an active account. If that fails, then it will check for an anonymous account.
/// If no anonymous account is found, it will create a new default anonymous account.
Future<Account> fetchActiveProfile() async {
  final prefs = UserPreferences.instance.preferences;
  final accountId = prefs.getString('active_profile_id');

  Account? account = await Account.fetchAccount(accountId ?? '');
  if (account != null) return account;

  // The user is not logged in. Let's check if there is an anonymous account.
  final instance = prefs.getString(LocalSettings.currentAnonymousInstance.name);
  final anonymousAccounts = await Account.anonymousInstances();

  if (instance != null) {
    account = anonymousAccounts.firstWhereOrNull((account) => account.instance == instance);
    if (account != null) return account;
  }

  // No default instance set. Check if there are any anonymous accounts.
  if (anonymousAccounts.isNotEmpty) {
    account = anonymousAccounts.first;
    return account;
  }

  // No anonymous account found. Let's create a new default one. TODO: Allow changing of default instance.
  account = await Account.insertAnonymousInstance(const Account(id: '', instance: 'lemmy.ml', index: -1, anonymous: true));
  if (account == null) throw Exception("Failed to create default profile");

  // Set this instance as the default anonymous instance.
  await prefs.setString(LocalSettings.currentAnonymousInstance.name, account.instance);

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
  final profileBloc = context.read<ProfileBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  await showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return MultiBlocProvider(
        providers: [BlocProvider.value(value: profileBloc), BlocProvider.value(value: thunderBloc)],
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
