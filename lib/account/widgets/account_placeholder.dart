import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// A widget that displays a placeholder when no user account is logged in.
///
/// The widget is used in the Account page to prompt the user to login to an account.
class AccountPlaceholder extends StatelessWidget {
  const AccountPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final instance = context.watch<ThunderBloc>().state.currentAnonymousInstance ?? '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded, size: 100.0, color: theme.dividerColor),
            const SizedBox(height: 16.0),
            Text(l10n.browsingAnonymously(instance), textAlign: TextAlign.center),
            Text(l10n.addAccountToSeeProfile, textAlign: TextAlign.center),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
              child: Text(l10n.manageAccounts),
              onPressed: () => showProfileModalSheet(context),
            )
          ],
        ),
      ),
    );
  }
}
