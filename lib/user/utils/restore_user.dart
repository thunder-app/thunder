import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

/// Restores the previous user that was selected in the app, if it has changed.
/// Useful to call after invoking a page that may change the currently selected user.
void restoreUser(BuildContext context, Account? originalUser) {
  final Account? newUser = context.read<AuthBloc>().state.account;

  if (originalUser != null &&
      newUser != null &&
      originalUser.id != newUser.id) {
    context
        .read<AuthBloc>()
        .add(SwitchAccount(accountId: originalUser.id, reload: false));
  }
}
