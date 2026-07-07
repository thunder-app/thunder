import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/presentation/state/account_settings_cubit.dart';
import 'package:thunder/src/features/user/presentation/widgets/account_picker_sheet.dart';
import 'package:thunder/src/features/user/presentation/widgets/account_settings_listener.dart';
import 'package:thunder/src/features/user/presentation/widgets/user_indicator.dart';
import 'package:thunder/src/foundation/config/app_constants.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

typedef UserSettingsChildrenBuilder = List<Widget> Function(
  BuildContext context,
  AccountSettingsState state,
);

/// Shared scaffold and loading shell for account settings pages.
class UserSettingsPageScaffold extends StatelessWidget {
  const UserSettingsPageScaffold({
    super.key,
    required this.childrenBuilder,
  });

  final UserSettingsChildrenBuilder childrenBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (_, state) => state.status == ProfileStatus.success && state.siteResponse != null,
          listener: (context, state) {
            if (!context.mounted) return;
            context.read<AccountSettingsCubit>().hydrateFromProfile(
                  state.siteResponse,
                );
          },
          child: AccountSettingsListener(
            child: BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
              builder: (context, state) {
                final isUpdating = state.status == AccountSettingsStatus.updating;

                return CustomScrollView(
                  physics: state.status == AccountSettingsStatus.notLoggedIn ? const NeverScrollableScrollPhysics() : null,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      centerTitle: false,
                      toolbarHeight: APP_BAR_HEIGHT,
                      title: Text(l10n.accountSettings),
                      actions: [
                        if (isUpdating)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.people_alt_rounded),
                          onPressed: () async {
                            final selectedAccount = await showAccountPickerSheet(
                              context,
                              currentAccount: resolveEffectiveAccount(context),
                              title: l10n.account(2),
                            );

                            if (!context.mounted || selectedAccount == null) {
                              return;
                            }
                            context.read<FeatureAccountCubit>().setOverride(selectedAccount);
                          },
                        ),
                      ],
                    ),
                    switch (state.status) {
                      AccountSettingsStatus.notLoggedIn => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: AccountPlaceholder(),
                        ),
                      AccountSettingsStatus.initial => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      _ => SliverList.list(
                          children: [
                            const _AccountSummaryHeader(),
                            ...childrenBuilder(context, state),
                            const SizedBox(height: 100.0),
                          ],
                        ),
                    },
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSummaryHeader extends StatelessWidget {
  const _AccountSummaryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const UserIndicator(),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => showProfileModalSheet(context, showLogoutDialog: true),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16.0, right: 16.0),
          child: Text(
            l10n.userSettingDescription,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}
