import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_anonymous_instances_sliver.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_authenticated_accounts_sliver.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_modal_load_state.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/user/presentation/utils/user_session_utils.dart';
import 'package:thunder/src/core/domain/models/account.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Displays profile sections and coordinates profile-modal user actions.
class ProfileSelect extends StatefulWidget {
  const ProfileSelect({
    super.key,
    required this.pushRegister,
    this.showLogoutDialog = false,
    this.quickSelectMode = false,
    this.customHeading,
  });

  /// Opens the login flow.
  ///
  /// Set `anonymous` to `true` to open the anonymous-instance flow.
  final void Function({bool anonymous}) pushRegister;

  /// Whether to show the logout confirmation dialog after this widget mounts.
  final bool showLogoutDialog;

  /// Whether to hide anonymous instances and profile-management actions.
  final bool quickSelectMode;

  /// Optional title displayed above the authenticated account list.
  final String? customHeading;

  @override
  State<ProfileSelect> createState() => _ProfileSelectState();
}

class _ProfileSelectState extends State<ProfileSelect> {
  @override
  void initState() {
    super.initState();

    if (widget.showLogoutDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (mounted) await _logOutOfActiveAccount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final darkTheme = context.read<ThemePreferencesCubit>().state.useDarkTheme;
    final selectedColor = darkTheme ? theme.colorScheme.primaryContainer : HSLColor.fromColor(theme.colorScheme.primaryContainer).withLightness(0.95).toColor();
    final activeSession = context.select<SessionBloc, Account?>((bloc) => bloc.state.activeAccount);

    return MultiBlocListener(
      listeners: [
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) =>
              previous.generation != current.generation || (previous.mutationStatus != current.mutationStatus && current.mutationStatus == SessionMutationStatus.failure),
          listener: (context, state) {
            final modalCubit = context.read<ProfileModalCubit>();
            if (state.mutationStatus == SessionMutationStatus.failure) {
              modalCubit.clearPendingSession();
              showThunderSnackbar(l10n.somethingWentWrong);
              return;
            }

            unawaited(modalCubit.load());
          },
        ),
        BlocListener<ProfileModalCubit, ProfileModalState>(
          listenWhen: (previous, current) => previous.operationError != current.operationError || (previous.loadError != current.loadError && current.status == ProfileModalStatus.success),
          listener: (context, state) {
            if (state.operationError != null) {
              showThunderSnackbar(l10n.somethingWentWrong);
              context.read<ProfileModalCubit>().clearOperationError();
            }
            if (state.loadError != null && state.status == ProfileModalStatus.success) {
              showThunderSnackbar(l10n.somethingWentWrong);
              context.read<ProfileModalCubit>().clearLoadError();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocSelector<ProfileModalCubit, ProfileModalState, _ProfileScaffoldState>(
          selector: _ProfileScaffoldState.fromState,
          builder: (context, scaffoldState) {
            final interactionsEnabled = scaffoldState.pendingSessionKey == null && !scaffoldState.isPersistingOrder;

            return CustomScrollView(
              slivers: [
                if (scaffoldState.status != ProfileModalStatus.success)
                  ThunderSectionHeader(
                    title: widget.customHeading ?? l10n.account(2),
                    variant: ThunderSectionHeaderVariant.sliver,
                  ),
                if (scaffoldState.status == ProfileModalStatus.loading || scaffoldState.status == ProfileModalStatus.initial) ...[
                  const ProfileModalLoadState.loading(),
                ] else if (scaffoldState.status == ProfileModalStatus.failure) ...[
                  ProfileModalLoadState.failure(onRetry: () => context.read<ProfileModalCubit>().load()),
                ] else ...[
                  if (scaffoldState.isRefreshing || scaffoldState.isPersistingOrder)
                    SliverToBoxAdapter(
                      child: Semantics(
                        label: scaffoldState.isPersistingOrder ? l10n.profileOperationInProgress : l10n.loading,
                        child: const LinearProgressIndicator(),
                      ),
                    ),
                  _AuthenticatedProfileSection(
                    activeSession: activeSession,
                    selectedColor: selectedColor,
                    quickSelectMode: widget.quickSelectMode,
                    customHeading: widget.customHeading,
                    interactionsEnabled: interactionsEnabled,
                    pushRegister: widget.pushRegister,
                    onSwitch: (sessionKey) => _switchSession(context, sessionKey),
                    onLogout: (sessionKey) => _logOutOfActiveAccount(activeSessionKey: sessionKey),
                    onRemove: (sessionKey) => _removeSession(context, sessionKey),
                  ),
                  if (!widget.quickSelectMode)
                    _AnonymousProfileSection(
                      activeSession: activeSession,
                      selectedColor: selectedColor,
                      interactionsEnabled: interactionsEnabled,
                      pushRegister: widget.pushRegister,
                      onSwitch: (sessionKey) => _switchSession(context, sessionKey),
                      onRemove: (sessionKey) => _removeSession(context, sessionKey),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _switchSession(BuildContext context, String sessionKey) {
    context.read<ProfileModalCubit>().markSessionPending(sessionKey);
    context.read<SessionBloc>().add(SessionSwitched(sessionKey: sessionKey));
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _removeSession(BuildContext context, String sessionKey) {
    context.read<ProfileModalCubit>().markSessionPending(sessionKey);
    context.read<SessionBloc>().add(SessionRemoved(sessionKey: sessionKey));
  }

  Future<void> _logOutOfActiveAccount({String? activeSessionKey}) async {
    final activeAccount = context.read<SessionBloc>().state.activeAccount;
    final sessionKey = activeSessionKey ?? (activeAccount?.anonymous == true ? activeAccount?.instance : activeAccount?.id);
    if (sessionKey == null) return;

    final modalCubit = context.read<ProfileModalCubit>()..markSessionPending(sessionKey);
    final confirmed = await showLogOutDialog(context);
    if (!mounted) return;

    if (!confirmed) {
      modalCubit.clearPendingSession();
      return;
    }

    context.read<SessionBloc>().add(SessionRemoved(sessionKey: sessionKey));
  }
}

class _AuthenticatedProfileSection extends StatelessWidget {
  const _AuthenticatedProfileSection({
    required this.activeSession,
    required this.selectedColor,
    required this.quickSelectMode,
    required this.customHeading,
    required this.interactionsEnabled,
    required this.pushRegister,
    required this.onSwitch,
    required this.onLogout,
    required this.onRemove,
  });

  final Account? activeSession;
  final Color selectedColor;
  final bool quickSelectMode;
  final String? customHeading;
  final bool interactionsEnabled;
  final void Function({bool anonymous}) pushRegister;
  final ValueChanged<String> onSwitch;
  final ValueChanged<String> onLogout;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<ProfileModalCubit, ProfileModalState, _AuthenticatedSectionState>(
      selector: _AuthenticatedSectionState.fromState,
      builder: (context, state) {
        return SliverMainAxisGroup(
          slivers: [
            ThunderSectionHeader(
              title: customHeading ?? l10n.account(2),
              variant: ThunderSectionHeaderVariant.sliver,
              actions: quickSelectMode
                  ? const []
                  : [
                      if (state.rows.length > 1)
                        IconButton(
                          icon: state.areReordering ? const Icon(Icons.check_rounded) : const Icon(Icons.edit_note_rounded),
                          tooltip: l10n.reorder,
                          onPressed: interactionsEnabled ? () => context.read<ProfileModalCubit>().toggleAuthenticatedReordering() : null,
                        ),
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        tooltip: l10n.addAccount,
                        onPressed: interactionsEnabled ? () => pushRegister() : null,
                      ),
                      const SizedBox(width: 12.0),
                    ],
            ),
            if (state.rows.isNotEmpty)
              ProfileAuthenticatedAccountsSliver(
                rows: state.rows,
                activeSession: activeSession,
                selectedColor: selectedColor,
                quickSelectMode: quickSelectMode,
                areReordering: state.areReordering,
                reorderIndex: state.reorderIndex,
                pendingSessionKey: state.pendingSessionKey,
                interactionsEnabled: interactionsEnabled,
                onSwitch: onSwitch,
                onLogout: onLogout,
                onRemove: onRemove,
              )
            else
              ThunderSliverAdapter(
                sliver: true,
                child: ThunderEmptyText(message: l10n.noAccountsAdded),
              )
          ],
        );
      },
    );
  }
}

class _AnonymousProfileSection extends StatelessWidget {
  const _AnonymousProfileSection({
    required this.activeSession,
    required this.selectedColor,
    required this.interactionsEnabled,
    required this.pushRegister,
    required this.onSwitch,
    required this.onRemove,
  });

  final Account? activeSession;
  final Color selectedColor;
  final bool interactionsEnabled;
  final void Function({bool anonymous}) pushRegister;
  final ValueChanged<String> onSwitch;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocSelector<ProfileModalCubit, ProfileModalState, _AnonymousSectionState>(
      selector: _AnonymousSectionState.fromState,
      builder: (context, state) {
        return SliverMainAxisGroup(
          slivers: [
            ThunderSectionHeader(
              title: l10n.anonymousInstances,
              variant: ThunderSectionHeaderVariant.sliver,
              actions: [
                if (state.rows.length > 1)
                  IconButton(
                    icon: state.areReordering ? const Icon(Icons.check_rounded) : const Icon(Icons.edit_note_rounded),
                    tooltip: l10n.reorder,
                    onPressed: interactionsEnabled ? () => context.read<ProfileModalCubit>().toggleAnonymousReordering() : null,
                  ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: l10n.addAnonymousInstance,
                  onPressed: interactionsEnabled ? () => pushRegister(anonymous: true) : null,
                ),
                const SizedBox(width: 12.0),
              ],
            ),
            if (state.rows.isNotEmpty)
              ProfileAnonymousInstancesSliver(
                rows: state.rows,
                activeSession: activeSession,
                selectedColor: selectedColor,
                authenticatedAccountCount: state.authenticatedAccountCount,
                areReordering: state.areReordering,
                reorderIndex: state.reorderIndex,
                pendingSessionKey: state.pendingSessionKey,
                interactionsEnabled: interactionsEnabled,
                onSwitch: onSwitch,
                onRemove: onRemove,
              )
            else
              ThunderSliverAdapter(
                sliver: true,
                child: ThunderEmptyText(message: l10n.noAnonymousInstances),
              )
          ],
        );
      },
    );
  }
}

class _ProfileScaffoldState {
  const _ProfileScaffoldState({
    required this.status,
    required this.isRefreshing,
    required this.isPersistingOrder,
    required this.pendingSessionKey,
  });

  factory _ProfileScaffoldState.fromState(ProfileModalState state) => _ProfileScaffoldState(
        status: state.status,
        isRefreshing: state.isRefreshing,
        isPersistingOrder: state.isPersistingOrder,
        pendingSessionKey: state.pendingSessionKey,
      );

  final ProfileModalStatus status;
  final bool isRefreshing;
  final bool isPersistingOrder;
  final String? pendingSessionKey;

  @override
  bool operator ==(Object other) {
    return other is _ProfileScaffoldState &&
        other.status == status &&
        other.isRefreshing == isRefreshing &&
        other.isPersistingOrder == isPersistingOrder &&
        other.pendingSessionKey == pendingSessionKey;
  }

  @override
  int get hashCode => Object.hash(status, isRefreshing, isPersistingOrder, pendingSessionKey);
}

class _AuthenticatedSectionState {
  const _AuthenticatedSectionState({
    required this.rows,
    required this.areReordering,
    required this.reorderIndex,
    required this.pendingSessionKey,
  });

  factory _AuthenticatedSectionState.fromState(ProfileModalState state) => _AuthenticatedSectionState(
        rows: state.authenticatedAccounts,
        areReordering: state.areAuthenticatedAccountsBeingReordered,
        reorderIndex: state.authenticatedAccountBeingReorderedIndex,
        pendingSessionKey: state.pendingSessionKey,
      );

  final List<ProfileModalAuthenticatedAccountRow> rows;
  final bool areReordering;
  final int? reorderIndex;
  final String? pendingSessionKey;

  @override
  bool operator ==(Object other) {
    return other is _AuthenticatedSectionState &&
        identical(other.rows, rows) &&
        other.areReordering == areReordering &&
        other.reorderIndex == reorderIndex &&
        other.pendingSessionKey == pendingSessionKey;
  }

  @override
  int get hashCode => Object.hash(identityHashCode(rows), areReordering, reorderIndex, pendingSessionKey);
}

class _AnonymousSectionState {
  const _AnonymousSectionState({
    required this.rows,
    required this.authenticatedAccountCount,
    required this.areReordering,
    required this.reorderIndex,
    required this.pendingSessionKey,
  });

  factory _AnonymousSectionState.fromState(ProfileModalState state) => _AnonymousSectionState(
        rows: state.anonymousInstances,
        authenticatedAccountCount: state.authenticatedAccounts.length,
        areReordering: state.areAnonymousInstancesBeingReordered,
        reorderIndex: state.anonymousInstanceBeingReorderedIndex,
        pendingSessionKey: state.pendingSessionKey,
      );

  final List<ProfileModalAnonymousInstanceRow> rows;
  final int authenticatedAccountCount;
  final bool areReordering;
  final int? reorderIndex;
  final String? pendingSessionKey;

  @override
  bool operator ==(Object other) {
    return other is _AnonymousSectionState &&
        identical(other.rows, rows) &&
        other.authenticatedAccountCount == authenticatedAccountCount &&
        other.areReordering == areReordering &&
        other.reorderIndex == reorderIndex &&
        other.pendingSessionKey == pendingSessionKey;
  }

  @override
  int get hashCode => Object.hash(identityHashCode(rows), authenticatedAccountCount, areReordering, reorderIndex, pendingSessionKey);
}
