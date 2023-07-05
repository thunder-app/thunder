import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/user/pages/user_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    AuthState authState = context.read<AuthBloc>().state;
    AccountState accountState = context.read<AccountBloc>().state;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (authState.isLoggedIn && accountState.status == AccountStatus.success) return UserPage(userId: accountState.personView!.person.id, isAccountUser: true);
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_rounded, size: 100, color: theme.dividerColor),
              const SizedBox(height: 16),
              const Text('Add an account to see your profile', textAlign: TextAlign.center),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                child: const Text('Manage Accounts'),
                onPressed: () => showProfileModalSheet(context),
              )
            ],
          ),
        );
      },
    );
  }
}
