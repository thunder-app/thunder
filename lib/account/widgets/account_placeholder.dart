import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class AccountPlaceholder extends StatelessWidget {
  const AccountPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    String anonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance ?? '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded, size: 100, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.browsingAnonymously(anonymousInstance), textAlign: TextAlign.center),
            Text(AppLocalizations.of(context)!.addAccountToSeeProfile, textAlign: TextAlign.center),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
              child: Text(AppLocalizations.of(context)!.manageAccounts),
              onPressed: () => showProfileModalSheet(context),
            )
          ],
        ),
      ),
    );
  }
}
