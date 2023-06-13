import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String defaultAvatar = 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    AuthState authState = context.read<AuthBloc>().state;
    AccountState accountState = context.read<AccountBloc>().state;

    return Scaffold(
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
                              foregroundImage: CachedNetworkImageProvider(accountState.personView!.person.avatar ?? defaultAvatar),
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
                              onPressed: () => {
                                context.read<AuthBloc>().add(ClearAuth()),
                              },
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const LoginPage(),
            ),
          );
        },
      ),
    );
  }
}
