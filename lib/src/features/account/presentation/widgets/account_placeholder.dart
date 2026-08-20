import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/config/global_context.dart';

/// A widget that displays a placeholder when no user account is logged in.
///
/// The widget is used in the Account page to prompt the user to login to an account.
class AccountPlaceholder extends StatelessWidget {
  const AccountPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;
    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);
    final bodyStyle = theme.textTheme.bodyMedium;

    return ThunderStateView(
      mode: ThunderStateViewMode.custom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ThunderStateIcon(icon: Icons.people_rounded, color: theme.dividerColor),
          const SizedBox(height: 16),
          ThunderStateText(title: l10n.browsingAnonymously(account.instance), message: l10n.addAccountToSeeProfile, titleStyle: bodyStyle, messageStyle: bodyStyle),
          const SizedBox(height: 24),
          ThunderStateActions(
            actions: [ThunderStateAction(label: l10n.manageAccounts, onPressed: () => showProfileModalSheet(context), primary: true)],
          ),
        ],
      ),
    );
  }
}
