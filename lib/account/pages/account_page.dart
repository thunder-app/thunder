import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/account/widgets/profile_modal_body.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

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

    return Scaffold(
<<<<<<< HEAD
=======
      appBar: AppBar(
        actions: [
          if (authState.isLoggedIn)
            IconButton(
              onPressed: () => showProfileModalSheet(context),
              icon: const Icon(Icons.people_alt_rounded),
            )
        ],
      ),
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: authState.isLoggedIn && accountState.status == AccountStatus.success
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              foregroundImage: accountState.personView!.person.avatar != null ? CachedNetworkImageProvider(accountState.personView!.person.avatar!) : null,
                              maxRadius: 70,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              accountState.personView!.person.name,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${formatNumberToK(accountState.personView!.counts.postScore)} · ${formatNumberToK(accountState.personView!.counts.commentScore)} · ${formatTimeToString(dateTime: accountState.personView!.person.published)}',
                              style: theme.textTheme.labelMedium?.copyWith(color: theme.textTheme.labelMedium?.color?.withAlpha(200)),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
<<<<<<< HEAD
                              onPressed: () => context.read<AuthBloc>().add(ClearAuth()),
=======
                              onPressed: () => context.read<AuthBloc>().add(RemoveAccount(accountId: context.read<AuthBloc>().state.account!.id)),
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      ),
                    )
<<<<<<< HEAD
                  : const LoginPage(),
=======
                  : Center(
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
                    ),
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
            ),
          );
        },
      ),
    );
  }
<<<<<<< HEAD
=======

  void showProfileModalSheet(BuildContext context) {
    AuthBloc authBloc = context.read<AuthBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        showDragHandle: true,
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: authBloc),
              BlocProvider.value(value: thunderBloc),
            ],
            child: const FractionallySizedBox(
              heightFactor: 0.9,
              child: ProfileModalBody(),
            ),
          );
        });
  }
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
}
