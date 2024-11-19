import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/widgets/account_placeholder.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/primitive_wrapper.dart';
import 'package:thunder/user/pages/user_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with AutomaticKeepAliveClientMixin {
  final List<bool> selectedUserOption = [true, false];
  final PrimitiveWrapper<bool> savedToggle = PrimitiveWrapper<bool>(false);

  /// Whether experimental features are enabled. When true, the new account page will be shown.
  bool enableExperimentalFeatures = false;

  void checkExperimentalFeatures() async {
    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      enableExperimentalFeatures = prefs.getBool(LocalSettings.enableExperimentalFeatures.name) ?? false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      checkExperimentalFeatures();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    AuthState authState = context.read<AuthBloc>().state;
    AccountState accountState = context.read<AccountBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.isLoggedIn && !state.reload) return;
            setState(() => authState = state);
            checkExperimentalFeatures();
          },
        ),
        BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (authState.isLoggedIn && !state.reload) return;
            setState(() => accountState = state);
            checkExperimentalFeatures();
          },
        ),
      ],
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (authState.isLoggedIn != true) return const AccountPlaceholder();

          if (enableExperimentalFeatures) {
            return FeedPage(
              feedType: FeedType.account,
              userId: authState.account?.userId,
              sortType: SortType.new_,
            );
          }

          return UserPage(
            userId: accountState.personView?.person.id,
            isAccountUser: true,
            selectedUserOption: selectedUserOption,
            savedToggle: savedToggle,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
