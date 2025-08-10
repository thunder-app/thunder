import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/shared/dialogs.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  bool result = false;
  await showThunderDialog<bool>(
    context: context,
    customBuilder: (alertDialog) => BlocProvider<ProfileBloc>.value(
      value: context.read<ProfileBloc>(),
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
      dialogContext.read<ProfileBloc>().add(RemoveProfile(accountId: dialogContext.read<ProfileBloc>().state.account.id));
      Navigator.of(dialogContext).pop();
    },
    primaryButtonText: l10n.logOut,
  );

  return result;
}
