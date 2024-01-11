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
  final bool showLogoutDialog;

  const ProfileModalBody({super.key, this.anonymous = false, this.showLogoutDialog = false});

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
      pages: [
        MaterialPage(
          child: ProfileSelect(
            pushRegister: pushRegister,
            showLogoutDialog: widget.showLogoutDialog,
          ),
        )
      ],
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case '/':
        page = ProfileSelect(
          pushRegister: pushRegister,
          showLogoutDialog: widget.showLogoutDialog,
        );
        break;

      case '/login':
        page = LoginPage(popRegister: popRegister, anonymous: (settings.arguments as Map<String, bool>)['anonymous']!);
        break;
    }
    return SwipeablePageRoute<dynamic>(
      canOnlySwipeFromEdge: !context.read<ThunderBloc>().state.enableFullScreenSwipeNavigationGesture,
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }
}

class ProfileSelect extends StatefulWidget {
  final void Function({bool anonymous}) pushRegister;
  final bool showLogoutDialog;

  const ProfileSelect({
    super.key,
    required this.pushRegister,
    this.showLogoutDialog = false,
  });

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
  void initState() {
    super.initState();

    if (widget.showLogoutDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 250));
        _logOutOfActiveAccount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(l10n.account(2)),
                centerTitle: false,
                scrolledUnderElevation: 0,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    tooltip: l10n.addAccount,
                    onPressed: () => widget.pushRegister(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: l10n.addAnonymousInstance,
                    onPressed: () => widget.pushRegister(anonymous: true),
                  ),
                  const SizedBox(width: 12.0),
                ],
              ),
              SliverList.builder(
                itemBuilder: (context, index) {
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
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 250),
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
                              subtitle: Wrap(
                                children: [
                                  Text(accounts![index].account.instance?.replaceAll('https://', '') ?? 'N/A'),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    child: accounts![index].version == null
                                        ? const SizedBox(height: 20, width: 0)
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
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
                                                'v${accounts![index].version}',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    child: accounts![index].latency == null
                                        ? const SizedBox(height: 20, width: 0)
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
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
                                          onPressed: () => _logOutOfActiveAccount(activeAccountId: accounts![index].account.id),
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
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 250),
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
                              subtitle: Wrap(
                                children: [
                                  Text(anonymousInstances![realIndex].instance),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    child: anonymousInstances![realIndex].version == null
                                        ? const SizedBox(height: 20, width: 0)
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
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
                                                'v${anonymousInstances![realIndex].version}',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    child: anonymousInstances![realIndex].latency == null
                                        ? const SizedBox(height: 20, width: 0)
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
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
                      ),
                    );
                  }
                },
                itemCount: (accounts?.length ?? 0) + (anonymousInstances?.length ?? 0),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logOutOfActiveAccount({String? activeAccountId}) async {
    activeAccountId ??= context.read<AuthBloc>().state.account?.id;

    final AuthBloc authBloc = context.read<AuthBloc>();
    final ThunderBloc thunderBloc = context.read<ThunderBloc>();

    final List<Account> accountsNotCurrent = (await Account.accounts()).where((a) => a.id != activeAccountId).toList();

    if (context.mounted && activeAccountId != null && await showLogOutDialog(context)) {
      setState(() => loggingOutId = activeAccountId);

      await Future.delayed(const Duration(milliseconds: 1000), () {
        if ((anonymousInstances?.length ?? 0) > 0) {
          thunderBloc.add(OnSetCurrentAnonymousInstance(anonymousInstances!.last.instance));
          authBloc.add(InstanceChanged(instance: anonymousInstances!.last.instance));
        } else if (accountsNotCurrent.isNotEmpty) {
          authBloc.add(SwitchAccount(accountId: accountsNotCurrent.last.id));
        } else {
          // No accounts and no anonymous instances left. Create a new one.
          authBloc.add(const LogOutOfAllAccounts());
          thunderBloc.add(const OnAddAnonymousInstance('lemmy.ml'));
          thunderBloc.add(const OnSetCurrentAnonymousInstance('lemmy.ml'));
        }

        setState(() {
          accounts = null;
          loggingOutId = null;
        });
      });
    }
  }

  Future<void> fetchAccounts() async {
    List<Account> accounts = await Account.accounts();

    List<AccountExtended> accountsExtended = await Future.wait(accounts.map((Account account) async {
      return AccountExtended(account: account, instance: account.instance, instanceIcon: null);
    })).timeout(const Duration(seconds: 5));

    // Intentionally don't await these here
    fetchInstanceInfo(accountsExtended);
    pingInstances(accountsExtended);

    setState(() => this.accounts = accountsExtended);
  }

  Future<void> fetchInstanceInfo(List<AccountExtended> accountsExtended) async {
    accountsExtended.forEach((account) async {
      final GetInstanceInfoResponse instanceinfoResponse = await getInstanceInfo(account.instance).timeout(
        const Duration(seconds: 5),
        onTimeout: () => const GetInstanceInfoResponse(success: false),
      );
      setState(() {
        account.instanceIcon = instanceinfoResponse.icon;
        account.version = instanceinfoResponse.version;
        account.alive = instanceinfoResponse.success;
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

    fetchAnonymousInstanceInfo(anonymousInstances);
    pingAnonymousInstances(anonymousInstances);

    setState(() => this.anonymousInstances = anonymousInstances);
  }

  Future<void> fetchAnonymousInstanceInfo(List<AnonymousInstanceExtended> anonymousInstancesExtended) async {
    anonymousInstancesExtended.forEach((anonymousInstance) async {
      final GetInstanceInfoResponse instanceInfoResponse = await getInstanceInfo(anonymousInstance.instance).timeout(
        const Duration(seconds: 5),
        onTimeout: () => const GetInstanceInfoResponse(success: false),
      );
      setState(() {
        anonymousInstance.instanceIcon = instanceInfoResponse.icon;
        anonymousInstance.version = instanceInfoResponse.version;
        anonymousInstance.alive = instanceInfoResponse.success;
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
  String? version;
  Duration? latency;
  bool? alive;

  AccountExtended({required this.account, this.instance, this.instanceIcon});
}

/// Wrapper class around Account with support for instance icon
class AnonymousInstanceExtended {
  String instance;
  String? instanceIcon;
  String? version;
  Duration? latency;
  bool? alive;

  AnonymousInstanceExtended({required this.instance, this.instanceIcon});
}
