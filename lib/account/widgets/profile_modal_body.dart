import 'dart:io';

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

/// Creates a widget which can display a list of accounts and anonymous instances.
/// By default, when logging out of an account, a confirmation dialog is shown. To suppress this, pass [showLogoutDialog] as `false`.
/// To hide anonymous instances and the ability to add new accounts, pass [quickSelectMode] as `true`.
/// To provide a custom heading for the top of the modal, pass a [customHeading].
/// By default, Thunder will reload when a different account is selected. To suppress this behavior, pass [reloadOnSwitch] as `false`.
class ProfileModalBody extends StatefulWidget {
  final bool showLogoutDialog;
  final bool quickSelectMode;
  final String? customHeading;
  final bool reloadOnSwitch;

  const ProfileModalBody({
    super.key,
    this.showLogoutDialog = false,
    this.quickSelectMode = false,
    this.customHeading,
    this.reloadOnSwitch = true,
  });

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
            quickSelectMode: widget.quickSelectMode,
            customHeading: widget.customHeading,
            reloadOnSave: widget.reloadOnSwitch,
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
          quickSelectMode: widget.quickSelectMode,
          customHeading: widget.customHeading,
          reloadOnSave: widget.reloadOnSwitch,
        );
        break;

      case '/login':
        page = LoginPage(popRegister: popRegister, anonymous: (settings.arguments as Map<String, bool>)['anonymous']!);
        break;
    }
    return SwipeablePageRoute<dynamic>(
      canSwipe: Platform.isIOS || context.read<ThunderBloc>().state.enableFullScreenSwipeNavigationGesture,
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
  final bool quickSelectMode;
  final String? customHeading;
  final bool reloadOnSave;

  const ProfileSelect({
    super.key,
    required this.pushRegister,
    this.showLogoutDialog = false,
    this.quickSelectMode = false,
    this.customHeading,
    this.reloadOnSave = true,
  });

  @override
  State<ProfileSelect> createState() => _ProfileSelectState();
}

class _ProfileSelectState extends State<ProfileSelect> {
  List<AccountExtended>? accounts;
  List<AnonymousInstanceExtended>? anonymousInstances;

  bool areAccountsBeingReordered = false;
  bool areAnonymousInstancesBeingReordered = false;
  int? accountBeingReorderedIndex;
  int? anonymousInstanceBeingReorderedIndex;

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

    if (!widget.quickSelectMode && anonymousInstances == null) {
      fetchAnonymousInstances();
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ThunderBloc, ThunderState>(
          listener: (context, state) {},
          listenWhen: (previous, current) {
            if (previous.currentAnonymousInstance != current.currentAnonymousInstance) {
              anonymousInstances = null;
            }
            return true;
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.success && state.isLoggedIn == true) {
              context.read<ThunderBloc>().add(const OnSetCurrentAnonymousInstance(null));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.cardColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(widget.customHeading ?? l10n.account(2)),
              centerTitle: false,
              scrolledUnderElevation: 0,
              pinned: false,
              actions: !widget.quickSelectMode
                  ? [
                      if ((accounts?.length ?? 0) > 1)
                        IconButton(
                          icon: areAccountsBeingReordered ? const Icon(Icons.check_rounded) : const Icon(Icons.edit_note_rounded),
                          tooltip: l10n.reorder,
                          onPressed: () => setState(() => areAccountsBeingReordered = !areAccountsBeingReordered),
                        ),
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        tooltip: l10n.addAccount,
                        onPressed: () => widget.pushRegister(),
                      ),
                      const SizedBox(width: 12.0),
                    ]
                  : [],
            ),
            if (accounts?.isNotEmpty == true)
              SliverReorderableList(
                onReorderStart: (index) => setState(() => accountBeingReorderedIndex = index),
                onReorderEnd: (index) => setState(() => accountBeingReorderedIndex = null),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final AccountExtended item = accounts!.removeAt(oldIndex);
                    accounts!.insert(newIndex, item);
                  });

                  _updateAccountIndices();
                },
                proxyDecorator: (child, index, animation) => Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(50),
                    child: child,
                  ),
                ),
                itemBuilder: (context, index) {
                  return ReorderableDragStartListener(
                    enabled: areAccountsBeingReordered,
                    key: Key('account-$index'),
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Material(
                        color: currentAccountId == accounts![index].account.id ? selectedColor : null,
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          onTap: (currentAccountId == accounts![index].account.id)
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(SwitchAccount(accountId: accounts![index].account.id, reload: widget.reloadOnSave));
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
                                  Text(accounts![index].account.instance.replaceAll('https://', '') ?? 'N/A'),
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
                              trailing: !widget.quickSelectMode
                                  ? areAccountsBeingReordered
                                      ? const Icon(Icons.drag_handle)
                                      : (currentAccountId == accounts![index].account.id)
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
                    ),
                  );
                },
                itemCount: accounts!.length,
              ),
            if (accounts?.isNotEmpty != true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    l10n.noAccountsAdded,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            if (!widget.quickSelectMode) ...[
              SliverAppBar(
                title: Text(l10n.anonymousInstances),
                centerTitle: false,
                scrolledUnderElevation: 0,
                pinned: false,
                actions: !widget.quickSelectMode
                    ? [
                        if ((anonymousInstances?.length ?? 0) > 1)
                          IconButton(
                            icon: areAnonymousInstancesBeingReordered ? const Icon(Icons.check_rounded) : const Icon(Icons.edit_note_rounded),
                            tooltip: l10n.reorder,
                            onPressed: () => setState(() => areAnonymousInstancesBeingReordered = !areAnonymousInstancesBeingReordered),
                          ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: l10n.addAnonymousInstance,
                          onPressed: () => widget.pushRegister(anonymous: true),
                        ),
                        const SizedBox(width: 12.0),
                      ]
                    : [],
              ),
              if (anonymousInstances?.isNotEmpty == true)
                SliverReorderableList(
                  onReorderStart: (index) => setState(() => anonymousInstanceBeingReorderedIndex = index),
                  onReorderEnd: (index) => setState(() => anonymousInstanceBeingReorderedIndex = null),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final AnonymousInstanceExtended item = anonymousInstances!.removeAt(oldIndex);
                      anonymousInstances!.insert(newIndex, item);
                    });

                    _updateAccountIndices();
                  },
                  proxyDecorator: (child, index, animation) => Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(50),
                      child: child,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return ReorderableDragStartListener(
                      enabled: areAnonymousInstancesBeingReordered,
                      key: Key('anonymous-$index'),
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Material(
                          elevation: anonymousInstanceBeingReorderedIndex == index ? 3 : 0,
                          color: currentAccountId == null && currentAnonymousInstance == anonymousInstances![index].anonymousInstance.instance ? selectedColor : null,
                          borderRadius: BorderRadius.circular(50),
                          child: InkWell(
                            onTap: (currentAccountId == null && currentAnonymousInstance == anonymousInstances![index].anonymousInstance.instance)
                                ? null
                                : () async {
                                    context.read<AuthBloc>().add(const LogOutOfAllAccounts());
                                    context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(anonymousInstances![index].anonymousInstance.instance));
                                    context.read<AuthBloc>().add(InstanceChanged(instance: anonymousInstances![index].anonymousInstance.instance));
                                    context.pop();
                                  },
                            borderRadius: BorderRadius.circular(50),
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    AnimatedCrossFade(
                                      crossFadeState: anonymousInstances![index].instanceIcon == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                                        foregroundImage: anonymousInstances![index].instanceIcon == null ? null : CachedNetworkImageProvider(anonymousInstances![index].instanceIcon!),
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
                                          color: currentAccountId == null && currentAnonymousInstance == anonymousInstances![index].anonymousInstance.instance ? selectedColor : null,
                                        ),
                                      ),
                                    ),
                                    // This is the status indicator
                                    Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child: AnimatedOpacity(
                                        opacity: anonymousInstances![index].alive == null ? 0 : 1,
                                        duration: const Duration(milliseconds: 500),
                                        child: Icon(
                                          anonymousInstances![index].alive == true ? Icons.check_circle_rounded : Icons.remove_circle_rounded,
                                          size: 10,
                                          color: Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.6), anonymousInstances![index].alive == true ? Colors.green : Colors.red),
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
                                    Text(anonymousInstances![index].anonymousInstance.instance),
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 250),
                                      child: anonymousInstances![index].version == null
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
                                                  'v${anonymousInstances![index].version}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 250),
                                      child: anonymousInstances![index].latency == null
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
                                                  '${anonymousInstances![index].latency?.inMilliseconds}ms',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.55),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                                trailing: !widget.quickSelectMode
                                    ? areAnonymousInstancesBeingReordered
                                        ? const Icon(Icons.drag_handle)
                                        : ((accounts?.length ?? 0) > 0 || anonymousInstances!.length > 1)
                                            ? (currentAccountId == null && currentAnonymousInstance == anonymousInstances![index].anonymousInstance.instance)
                                                ? IconButton(
                                                    icon: Icon(Icons.logout, semanticLabel: AppLocalizations.of(context)!.removeInstance),
                                                    onPressed: () async {
                                                      await Account.deleteAnonymousInstance(anonymousInstances![index].anonymousInstance.instance);

                                                      if (anonymousInstances!.length > 1) {
                                                        context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(
                                                            anonymousInstances!.lastWhere((instance) => instance != anonymousInstances![index]).anonymousInstance.instance));
                                                        context.read<AuthBloc>().add(
                                                            InstanceChanged(instance: anonymousInstances!.lastWhere((instance) => instance != anonymousInstances![index]).anonymousInstance.instance));
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
                                                      await Account.deleteAnonymousInstance(anonymousInstances![index].anonymousInstance.instance);
                                                      setState(() {
                                                        anonymousInstances = null;
                                                      });
                                                    })
                                            : null
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: anonymousInstances!.length,
                ),
              if (anonymousInstances?.isNotEmpty != true)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Text(
                      l10n.noAnonymousInstances,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100))
          ],
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

      await Future.delayed(const Duration(milliseconds: 1000), () async {
        if ((anonymousInstances?.length ?? 0) > 0) {
          thunderBloc.add(OnSetCurrentAnonymousInstance(anonymousInstances!.last.anonymousInstance.instance));
          authBloc.add(InstanceChanged(instance: anonymousInstances!.last.anonymousInstance.instance));
        } else if (accountsNotCurrent.isNotEmpty) {
          authBloc.add(SwitchAccount(accountId: accountsNotCurrent.last.id));
        } else {
          // No accounts and no anonymous instances left. Create a new one.
          authBloc.add(const LogOutOfAllAccounts());
          await Account.insertAnonymousInstance(const Account(id: '', instance: 'lemmy.ml', index: -1, anonymous: true));
          thunderBloc.add(const OnSetCurrentAnonymousInstance(null));
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

    List<AccountExtended> accountsExtended = (await Future.wait(accounts.map((Account account) async {
      return AccountExtended(account: account, instance: account.instance, instanceIcon: null);
    })).timeout(const Duration(seconds: 5)))
      ..sort((a, b) => a.account.index.compareTo(b.account.index));

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

  Future<void> fetchAnonymousInstances() async {
    final List<AnonymousInstanceExtended> anonymousInstances = (await Account.anonymousInstances()).map((anonymousInstance) => AnonymousInstanceExtended(anonymousInstance: anonymousInstance)).toList()
      ..sort((a, b) => a.anonymousInstance.index.compareTo(b.anonymousInstance.index));

    fetchAnonymousInstanceInfo(anonymousInstances);
    pingAnonymousInstances(anonymousInstances);

    setState(() => this.anonymousInstances = anonymousInstances);
  }

  Future<void> fetchAnonymousInstanceInfo(List<AnonymousInstanceExtended> anonymousInstancesExtended) async {
    anonymousInstancesExtended.forEach((anonymousInstanceExtended) async {
      final GetInstanceInfoResponse instanceInfoResponse = await getInstanceInfo(anonymousInstanceExtended.anonymousInstance.instance).timeout(
        const Duration(seconds: 5),
        onTimeout: () => const GetInstanceInfoResponse(success: false),
      );
      setState(() {
        anonymousInstanceExtended.instanceIcon = instanceInfoResponse.icon;
        anonymousInstanceExtended.version = instanceInfoResponse.version;
        anonymousInstanceExtended.alive = instanceInfoResponse.success;
      });
    });
  }

  Future<void> pingAnonymousInstances(List<AnonymousInstanceExtended> anonymousInstancesExtended) async {
    anonymousInstancesExtended.forEach((anonymousInstanceExtended) async {
      PingData pingData = await Ping(
        anonymousInstanceExtended.anonymousInstance.instance,
        count: 1,
        timeout: 5,
      ).stream.first;
      setState(() => anonymousInstanceExtended.latency = pingData.response?.time);
    });
  }

  /// Recalculates the indices of all accounts and anonymous instances in the database, given the current order in the UI.
  /// We need to calculate both accounts and anonymous instances, using an offset for the latter,
  /// because they are separate lists in the UI but they are in the same database table.
  void _updateAccountIndices() {
    for (AccountExtended accountExtended in accounts!) {
      Account.updateAccount(accountExtended.account.copyWith(index: accounts!.indexOf(accountExtended)));
    }

    for (AnonymousInstanceExtended anonymousInstanceExtended in anonymousInstances!) {
      Account.updateAccount(anonymousInstanceExtended.anonymousInstance.copyWith(index: (accounts?.length ?? 0) + anonymousInstances!.indexOf(anonymousInstanceExtended)));
    }
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
  Account anonymousInstance;
  String? instanceIcon;
  String? version;
  Duration? latency;
  bool? alive;

  AnonymousInstanceExtended({required this.anonymousInstance, this.instanceIcon});
}
