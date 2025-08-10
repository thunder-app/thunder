import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';

/// Restores the previous user that was selected in the app, if it has changed.
/// Useful to call after invoking a page that may change the currently selected user.
void restoreUser(BuildContext context, Account? originalUser) {
  final Account newUser = context.read<ProfileBloc>().state.account;

  if (originalUser != null && originalUser.id != newUser.id) {
    context.read<ProfileBloc>().add(SwitchProfile(accountId: originalUser.id, reload: false));
  }
}
