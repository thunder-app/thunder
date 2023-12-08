import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/dialogs.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  bool result = false;
  await showThunderDialog<bool>(
    context: context,
    customBuilder: (alertDialog) => BlocProvider<AuthBloc>.value(
      value: context.read<AuthBloc>(),
      child: alertDialog,
    ),
    title: AppLocalizations.of(context)!.confirmLogOutTitle,
    contentText: AppLocalizations.of(context)!.confirmLogOutBody,
    onSecondaryButtonPressed: (dialogContext) {
      result = false;
      dialogContext.pop();
    },
    secondaryButtonText: AppLocalizations.of(context)!.cancel,
    onPrimaryButtonPressed: (dialogContext, _) {
      result = true;
      dialogContext.read<AuthBloc>().add(RemoveAccount(
            accountId: dialogContext.read<AuthBloc>().state.account!.id,
          ));
      dialogContext.pop();
    },
    primaryButtonText: AppLocalizations.of(context)!.logOut,
  );

  return result;
}
