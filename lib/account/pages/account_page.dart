import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    AuthState authState = context.watch<AuthBloc>().state;
    AccountState accountState = context.watch<AccountBloc>().state;
    ThunderState thunderState = context.read<ThunderBloc>().state;
    String anonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance;

    return (authState.isLoggedIn && accountState.status == AccountStatus.success && accountState.personView != null)
        ? FeedPage(
            feedType: FeedType.user,
            userId: accountState.personView!.person.id,
            sortType: thunderState.defaultSortType,
          )
        : Center(
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
