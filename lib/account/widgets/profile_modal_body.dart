import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/utils/logout_dialog.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileModalBody extends StatefulWidget {
  final bool anonymous;

  const ProfileModalBody({super.key, this.anonymous = false});

  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  @override
  State<ProfileModalBody> createState() => _ProfileModalBodyState();
}

class _ProfileModalBodyState extends State<ProfileModalBody> {
  void pushRegister({bool anonymous = false}) {
    ProfileModalBody.shellNavigatorKey.currentState!.pushNamed("/login", arguments: {'anonymous': anonymous});
  }

  void popRegister() {
    ProfileModalBody.shellNavigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: ProfileModalBody.shellNavigatorKey,
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
        page = LoginPage(popRegister: popRegister, anonymous: (settings.arguments as Map<String, bool>)['anonymous']!);
        break;
    }
    return SwipeablePageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }
}

class ProfileSelect extends StatefulWidget {
  final void Function({bool anonymous}) pushRegister;
  ProfileSelect({Key? key, required this.pushRegister}) : super(key: key);

  @override
  State<ProfileSelect> createState() => _ProfileSelectState();
}

class _ProfileSelectState extends State<ProfileSelect> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  List<AccountExtended>? accounts;
  List<AnonymousInstanceExtended>? anonymousInstances;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? currentAccountId = context.watch<AuthBloc>().state.account?.id;
    String? currentAnonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance;

    if (accounts == null) {
      fetchAccounts();
    }

    if (accounts != null) {
      return ListView.builder(
        itemBuilder: (context, index) {
          if (index == accounts?.length) {
            return Column(
              children: [
                if (accounts != null && accounts!.isNotEmpty) const Divider(indent: 16.0, endIndent: 16.0, thickness: 2.0),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Account'),
                  onTap: () => widget.pushRegister(),
                ),
              ],
            );
          } else {
            return ListTile(
              leading: AnimatedCrossFade(
                crossFadeState: accounts![index].instanceIcon == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 500),
                firstChild: const SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.person,
                  ),
                ),
                secondChild: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundImage: accounts![index].instanceIcon == null ? null : CachedNetworkImageProvider(accounts![index].instanceIcon!),
                ),
              ),
              title: Text(
                accounts![index].account.username ?? 'N/A',
                style: theme.textTheme.titleMedium?.copyWith(),
              ),
              subtitle: Text(accounts![index].account.instance?.replaceAll('https://', '') ?? 'N/A'),
              onTap: (currentAccountId == accounts![index].account.id)
                  ? null
                  : () {
                      context.read<AuthBloc>().add(SwitchAccount(accountId: accounts![index].account.id));
                      context.pop();
                    },
              trailing: (currentAccountId == accounts![index].account.id)
                  ? const InputChip(
                      label: Text('Active'),
                      visualDensity: VisualDensity.compact,
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.delete,
                        semanticLabel: 'Remove Account',
                      ),
                    ),
                  );
                }
              }
            },
            itemCount: (accounts?.length ?? 0) + (anonymousInstances?.length ?? 0) + 1,
          ),
        ),
      ),
    );
  }

  Future<void> fetchAccounts() async {
    List<Account> accounts = await Account.accounts();

    List<AccountExtended> accountsExtended = await Future.wait(accounts.map((Account account) async {
      return AccountExtended(account: account, instance: account.instance, instanceIcon: null);
    })).timeout(const Duration(seconds: 5));

    // Intentionally don't await these here
    fetchInstanceIcons(accountsExtended);
    pingInstances(accountsExtended);

    setState(() => this.accounts = accountsExtended);
  }

  Future<void> fetchInstanceIcons(List<AccountExtended> accountsExtended) async {
    accountsExtended.forEach((account) async {
      final GetInstanceIconResponse instanceIconResponse = await getInstanceIcon(account.instance).timeout(
        const Duration(seconds: 3),
        onTimeout: () => const GetInstanceIconResponse(success: false),
      );

      setState(() {
        account.instanceIcon = instanceIconResponse.icon;
        account.alive = instanceIconResponse.success;
      });
    });
  }

  Future<void> pingInstances(List<AccountExtended> accountsExtended) async {
    accountsExtended.forEach((account) async {
      if (account.instance != null) {
        PingData pingData = await Ping(
          account.instance!,
          count: 1,
          timeout: 5,
        ).stream.first;
        setState(() => account.latency = pingData.response?.time);
      }
    });
  }

  void fetchAnonymousInstances() {
    final List<AnonymousInstanceExtended> anonymousInstances = context.read<ThunderBloc>().state.anonymousInstances.map((instance) => AnonymousInstanceExtended(instance: instance)).toList();

    fetchAnonymousInstanceIcons(anonymousInstances);

    setState(() {
      this.anonymousInstances = anonymousInstances;
    });
  }

  Future<void> fetchAnonymousInstanceIcons(List<AnonymousInstanceExtended> anonymousInstancesExtended) async {
    anonymousInstancesExtended.forEach((anonymousInstance) async {
      final instanceIcon = await getInstanceIcon(anonymousInstance.instance).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      setState(() => anonymousInstance.instanceIcon = instanceIcon);
    });
  }
}

/// Wrapper class around Account with support for instance icon
class AccountExtended {
  final Account account;
  String? instance;
  String? instanceIcon;
  Duration? latency;
  bool? alive;

  AccountExtended({required this.account, this.instance, this.instanceIcon});
}

/// Wrapper class around Account with support for instance icon
class AnonymousInstanceExtended {
  String instance;
  String? instanceIcon;

  AnonymousInstanceExtended({required this.instance, this.instanceIcon});
}
