import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/user/presentation/state/account_settings_cubit.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that listens to the [AccountSettingsCubit] and shows a snackbar on failure or success.
/// When the account settings are successfully updated, it also triggers a refresh of the profile settings in the [ProfileBloc].
class AccountSettingsListener extends StatelessWidget {
  const AccountSettingsListener({super.key, required this.child});

  /// The child widget to wrap with the account settings listener.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocListener<AccountSettingsCubit, AccountSettingsState>(
      listenWhen: (previous, current) => previous.status != current.status && (current.status == AccountSettingsStatus.failure || current.status == AccountSettingsStatus.success),
      listener: (context, state) {
        if (state.status == AccountSettingsStatus.failure) {
          showThunderSnackbar(state.errorMessage ?? l10n.unexpectedError);
        } else if (state.status == AccountSettingsStatus.success) {
          context.read<ProfileBloc>().add(FetchProfileSettings());
        }
      },
      child: child,
    );
  }
}
