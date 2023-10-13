import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/pages/login_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
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

  // Represents the ID of the account/instance we're currently logging out of / removing
  String? loggingOutId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;
    Color selectedColor = theme.colorScheme.primaryContainer;
    if (!darkTheme) {
      selectedColor = HSLColor.fromColor(theme.colorScheme.primaryContainer).withLightness(0.95).toColor();
    }
    String? currentAccountId = context.watch<AuthBloc>().state.account?.id;
    String? currentAnonymousInstance = context.watch<ThunderBloc>().state.currentAnonymousInstance;

    if (accounts == null) {
      fetchAccounts();
    }

    if (anonymousInstances == null) {
      fetchAnonymousInstances();
    }

    return BlocListener<ThunderBloc, ThunderState>(
      listener: (context, state) {},
      listenWhen: (previous, current) {
        if ((previous.anonymousInstances.length != current.anonymousInstances.length) || (previous.currentAnonymousInstance != current.currentAnonymousInstance)) {
          anonymousInstances = null;
        }
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          body: ListView.builder(
            itemBuilder: (context, index) {
              if (index == (accounts?.length ?? 0) + (anonymousInstances?.length ?? 0)) {
                return Column(
                  children: [
                    const Divider(indent: 16.0, endIndent: 16.0, thickness: 2.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            const SizedBox(width: 8.0),
                            Text(
                              AppLocalizations.of(context)!.addAccount,
                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                            ),
                          ],
                        ),
                        onPressed: () => widget.pushRegister(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                          backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add),
                            const SizedBox(width: 8.0),
                            Text(
                              AppLocalizations.of(context)!.addAnonymousInstance,
                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                            ),
                          ],
                        ),
                        onPressed: () => widget.pushRegister(anonymous: true),
                      ),
                    ),
                  ],
                );
              } else {
                if (index < (accounts?.length ?? 0)) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Material(
                      color: currentAccountId == accounts![index].account.id ? selectedColor : null,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: (currentAccountId == accounts![index].account.id)
                            ? null
                            : () {
                                context.read<AuthBloc>().add(SwitchAccount(accountId: accounts![index].account.id));
                                context.pop();
                              },
                        borderRadius: BorderRadius.circular(50),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              AnimatedCrossFade(
                                crossFadeState: accounts![index].instanceIcon == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 500),
                                firstChild: const SizedBox(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                                    child: Icon(
                                      Icons.person,
                                    ),
                                  ),
                                ),
                                secondChild: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  foregroundImage: accounts![index].instanceIcon == null ? null : CachedNetworkImageProvider(accounts![index].instanceIcon!),
                                  maxRadius: 20,
                                ),
                              ),
                              // This widget creates a slight border around the status indicator
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(10),
                                    color: currentAccountId == accounts![index].account.id ? selectedColor : null,
                                  ),
                                ),
                              ),
                              // This is the status indicator
                              Positioned(
                                right: 1,
                                bottom: 1,
                                child: AnimatedOpacity(
                                  opacity: accounts![index].alive == null ? 0 : 1,
                                  duration: const Duration(milliseconds: 500),
                                  child: Icon(
                                    accounts![index].alive == true ? Icons.check_circle_rounded : Icons.remove_circle_rounded,
                                    size: 10,
                                    color: Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.6), accounts![index].alive == true ? Colors.green : Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            accounts![index].account.username ?? 'N/A',
                            style: theme.textTheme.titleMedium?.copyWith(),
                          ),
                          subtitle: Row(
                            children: [
                              Text(accounts![index].account.instance?.replaceAll('https://', '') ?? 'N/A'),
                              AnimatedOpacity(
                                opacity: accounts![index].latency == null ? 0 : 1,
                                duration: const Duration(milliseconds: 500),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${accounts![index].latency?.inMilliseconds}ms',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: (accounts!.length > 1 || anonymousInstances?.isNotEmpty == true)
                              ? (currentAccountId == accounts![index].account.id)
                                  ? IconButton(
                                      icon: loggingOutId == accounts![index].account.id
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(),
                                            )
                                          : Icon(Icons.logout, semanticLabel: AppLocalizations.of(context)!.logOut),
                                      onPressed: () async {
                                        if (await showLogOutDialog(context)) {
                                          setState(() => loggingOutId = accounts![index].account.id);

                                          await Future.delayed(const Duration(milliseconds: 1000), () {
                                            if ((anonymousInstances?.length ?? 0) > 0) {
                                              context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(anonymousInstances!.last.instance));
                                              context.read<AuthBloc>().add(InstanceChanged(instance: anonymousInstances!.last.instance));
                                            } else {
                                              context.read<AuthBloc>().add(SwitchAccount(accountId: accounts!.lastWhere((account) => account.account.id != currentAccountId).account.id));
                                            }

                                            setState(() {
                                              accounts = null;
                                              loggingOutId = null;
                                            });
                                          });
                                        }
                                      },
                                    )
                                  : IconButton(
                                      icon: loggingOutId == accounts![index].account.id
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(),
                                            )
                                          : Icon(
                                              Icons.delete,
                                              semanticLabel: AppLocalizations.of(context)!.removeAccount,
                                            ),
                                      onPressed: () async {
                                        context.read<AuthBloc>().add(RemoveAccount(accountId: accounts![index].account.id));

                                        setState(() => loggingOutId = accounts![index].account.id);

                                        if (currentAccountId != null) {
                                          await Future.delayed(const Duration(milliseconds: 1000), () {
                                            context.read<AuthBloc>().add(SwitchAccount(accountId: currentAccountId));
                                          });
                                        }

                                        setState(() {
                                          accounts = null;
                                          loggingOutId = null;
                                        });
                                      })
                              : null,
                        ),
                      ),
                    ),
                  );
                } else {
                  int realIndex = index - (accounts?.length ?? 0);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Material(
                      color: currentAccountId == null && currentAnonymousInstance == anonymousInstances![realIndex].instance ? selectedColor : null,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: (currentAccountId == null && currentAnonymousInstance == anonymousInstances![realIndex].instance)
                            ? null
                            : () async {
                                context.read<AuthBloc>().add(const LogOutOfAllAccounts());
                                context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(anonymousInstances![realIndex].instance));
                                context.read<AuthBloc>().add(InstanceChanged(instance: anonymousInstances![realIndex].instance));
                                context.pop();
                              },
                        borderRadius: BorderRadius.circular(50),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              AnimatedCrossFade(
                                crossFadeState: anonymousInstances![realIndex].instanceIcon == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 500),
                                firstChild: const SizedBox(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                                    child: Icon(
                                      Icons.language,
                                    ),
                                  ),
                                ),
                                secondChild: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  foregroundImage: anonymousInstances![realIndex].instanceIcon == null ? null : CachedNetworkImageProvider(anonymousInstances![realIndex].instanceIcon!),
                                  maxRadius: 20,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(10),
                                    color: currentAccountId == null && currentAnonymousInstance == anonymousInstances![realIndex].instance ? selectedColor : null,
                                  ),
                                ),
                              ),
                              // This is the status indicator
                              Positioned(
                                right: 1,
                                bottom: 1,
                                child: AnimatedOpacity(
                                  opacity: anonymousInstances![realIndex].alive == null ? 0 : 1,
                                  duration: const Duration(milliseconds: 500),
                                  child: Icon(
                                    anonymousInstances![realIndex].alive == true ? Icons.check_circle_rounded : Icons.remove_circle_rounded,
                                    size: 10,
                                    color: Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.6), anonymousInstances![realIndex].alive == true ? Colors.green : Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              const Icon(
                                Icons.person_off_rounded,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppLocalizations.of(context)!.anonymous,
                                style: theme.textTheme.titleMedium?.copyWith(),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(anonymousInstances![realIndex].instance),
                              AnimatedOpacity(
                                opacity: anonymousInstances![realIndex].latency == null ? 0 : 1,
                                duration: const Duration(milliseconds: 500),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${anonymousInstances![realIndex].latency?.inMilliseconds}ms',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: ((accounts?.length ?? 0) > 0 || anonymousInstances!.length > 1)
                              ? (currentAccountId == null && currentAnonymousInstance == anonymousInstances![realIndex].instance)
                                  ? IconButton(
                                      icon: Icon(Icons.logout, semanticLabel: AppLocalizations.of(context)!.removeInstance),
                                      onPressed: () async {
                                        context.read<ThunderBloc>().add(OnRemoveAnonymousInstance(anonymousInstances![realIndex].instance));

                                        if (anonymousInstances!.length > 1) {
                                          context
                                              .read<ThunderBloc>()
                                              .add(OnSetCurrentAnonymousInstance(anonymousInstances!.lastWhere((instance) => instance != anonymousInstances![realIndex]).instance));
                                          context.read<AuthBloc>().add(InstanceChanged(instance: anonymousInstances!.lastWhere((instance) => instance != anonymousInstances![realIndex]).instance));
                                        } else {
                                          context.read<AuthBloc>().add(SwitchAccount(accountId: accounts!.last.account.id));
                                        }

                                        setState(() => anonymousInstances = null);
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        semanticLabel: AppLocalizations.of(context)!.removeInstance,
                                      ),
                                      onPressed: () async {
                                        context.read<ThunderBloc>().add(OnRemoveAnonymousInstance(anonymousInstances![realIndex].instance));
                                        setState(() {
                                          anonymousInstances = null;
                                        });
                                      })
                              : null,
                        ),
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
        const Duration(seconds: 5),
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
    pingAnonymousInstances(anonymousInstances);

    setState(() => this.anonymousInstances = anonymousInstances);
  }

  Future<void> fetchAnonymousInstanceIcons(List<AnonymousInstanceExtended> anonymousInstancesExtended) async {
    anonymousInstancesExtended.forEach((anonymousInstance) async {
      final GetInstanceIconResponse instanceIconResponse = await getInstanceIcon(anonymousInstance.instance).timeout(
        const Duration(seconds: 5),
        onTimeout: () => const GetInstanceIconResponse(success: false),
      );
      setState(() {
        anonymousInstance.instanceIcon = instanceIconResponse.icon;
        anonymousInstance.alive = instanceIconResponse.success;
      });
    });
  }

  Future<void> pingAnonymousInstances(List<AnonymousInstanceExtended> anonymousInstancesExtended) async {
    anonymousInstancesExtended.forEach((anonymousInstance) async {
      PingData pingData = await Ping(
        anonymousInstance.instance,
        count: 1,
        timeout: 5,
      ).stream.first;
      setState(() => anonymousInstance.latency = pingData.response?.time);
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
  Duration? latency;
  bool? alive;

  AnonymousInstanceExtended({required this.instance, this.instanceIcon});
}
