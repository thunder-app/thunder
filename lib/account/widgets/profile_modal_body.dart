import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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
    String? currentAccountId = context.read<ThunderBloc>().state.preferences?.getString('active_profile_id');
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
                print(currentAccountId);
                print(currentAccountId == snapshot.data![index].id);
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(snapshot.data![index].username ?? 'N/A'),
                  subtitle: Text(snapshot.data![index].instance?.replaceAll('https://', '') ?? 'N/A'),
                  onTap: (currentAccountId == snapshot.data![index].id)
                      ? null
                      : () {
                          context.read<AuthBloc>().add(SwitchAccount(accountId: snapshot.data![index].id));
                          context.pop();
                        },
                  trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<AuthBloc>().add(RemoveAccount(accountId: snapshot.data![index].id));
                        context.pop();
                      }),
                );
              }
            },
            itemCount: (snapshot.data?.length ?? 0) + 1,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future<List<Account>> fetchAccounts() async {
    List<Account> accounts = await Account.accounts();
    return accounts;
  }
}
