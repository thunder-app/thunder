import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/utils/instance.dart';

class ProfileModalBody extends StatelessWidget {
  const ProfileModalBody({super.key});

  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  void pushRegister() {
    shellNavigatorKey.currentState!.pushNamed("/login");
  }

  void popRegister() {
    shellNavigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: shellNavigatorKey,
      onPopPage: (route, result) => false,
      pages: [MaterialPage(child: ProfileSelect(pushRegister: pushRegister))],
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case '/':
        page = ProfileSelect(pushRegister: pushRegister);
        break;

      case '/login':
        page = LoginPage(popRegister: popRegister);
        break;
    }
    return MaterialPageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }
}

class ProfileSelect extends StatelessWidget {
  final VoidCallback pushRegister;
  const ProfileSelect({Key? key, required this.pushRegister}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? currentAccountId = context.read<AuthBloc>().state.account?.id;

    return FutureBuilder(
      future: fetchAccounts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, index) {
              if (index == snapshot.data?.length) {
                return Column(
                  children: [
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) const Divider(indent: 16.0, endIndent: 16.0, thickness: 2.0),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Account'),
                      onTap: () => pushRegister(),
                    ),
                  ],
                );
              } else {
                return ListTile(
                  leading: snapshot.data![index].instanceIcon == null
                      ? const Icon(
                          Icons.person,
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundImage: snapshot.data![index].instanceIcon == null ? null : CachedNetworkImageProvider(snapshot.data![index].instanceIcon!),
                        ),
                  title: Text(
                    snapshot.data![index].account.username ?? 'N/A',
                    style: theme.textTheme.titleMedium?.copyWith(),
                  ),
                  subtitle: Text(snapshot.data![index].account.instance?.replaceAll('https://', '') ?? 'N/A'),
                  onTap: (currentAccountId == snapshot.data![index].account.id)
                      ? null
                      : () {
                          context.read<AuthBloc>().add(SwitchAccount(accountId: snapshot.data![index].account.id));
                          context.pop();
                        },
                  trailing: (currentAccountId == snapshot.data![index].account.id)
                      ? const InputChip(
                          label: Text('Active'),
                          visualDensity: VisualDensity.compact,
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.delete,
                            semanticLabel: 'Remove Account',
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(RemoveAccount(accountId: snapshot.data![index].account.id));
                            context.pop();
                          }),
                );
              }
            },
            itemCount: (snapshot.data?.length ?? 0) + 1,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<AccountExtended>> fetchAccounts() async {
    List<AccountExtended> accounts = await Future.wait((await Account.accounts()).map((account) async {
      final instanceIcon = await getInstanceIcon(account.instance);
      return AccountExtended(account: account, instanceIcon: instanceIcon);
    }).toList());

    return accounts;
  }
}

/// Wrapper class around Account with support for instance icon
class AccountExtended {
  final Account account;
  final String? instanceIcon;

  const AccountExtended({required this.account, this.instanceIcon});
}
