import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/dialogs.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  bool result = false;
  await showThunderDialog<bool>(
    context: context,
    customBuilder: (alertDialog) => BlocProvider<AuthBloc>.value(
      value: context.read<AuthBloc>(),
      child: alertDialog,
    ),
    title: l10n.confirmLogOutTitle,
    contentText: l10n.confirmLogOutBody,
    onSecondaryButtonPressed: (dialogContext) {
      result = false;
      Navigator.of(dialogContext).pop();
    },
    secondaryButtonText: l10n.cancel,
    onPrimaryButtonPressed: (dialogContext, _) {
      result = true;
      dialogContext.read<AuthBloc>().add(RemoveAccount(
            accountId: dialogContext.read<AuthBloc>().state.account!.id,
          ));
      Navigator.of(dialogContext).pop();
    },
    primaryButtonText: l10n.logOut,
  );

  return result;
}
