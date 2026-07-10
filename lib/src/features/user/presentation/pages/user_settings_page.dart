import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/presentation/pages/lemmy_user_settings_page.dart';
import 'package:thunder/src/features/user/presentation/pages/piefed_user_settings_page.dart';
import 'package:thunder/src/core/domain/enums/enums.dart';

/// Routes the account settings view to the platform-specific implementation.
class UserSettingsPage extends StatelessWidget {
  /// The setting to be highlighted when searching.
  final LocalSettings? settingToHighlight;

  const UserSettingsPage({super.key, this.settingToHighlight});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureAccountCubit, FeatureAccountState>(
      builder: (context, state) {
        final account = state.effectiveAccount;

        return KeyedSubtree(
          key: ValueKey('user-settings-${account.id}-${account.instance}-${account.platform?.name ?? 'unknown'}-${account.anonymous}'),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => createProfileBloc(account)..add(InitializeAuth())),
              BlocProvider(create: (_) => createAccountSettingsCubit(account)),
            ],
            child: switch (account.platform) {
              ThreadiversePlatform.piefed => PiefedUserSettingsPage(settingToHighlight: settingToHighlight),
              _ => LemmyUserSettingsPage(settingToHighlight: settingToHighlight),
            },
          ),
        );
      },
    );
  }
}
