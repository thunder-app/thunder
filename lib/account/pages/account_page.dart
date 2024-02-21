import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/widgets/account_placeholder.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/primitive_wrapper.dart';
import 'package:thunder/user/pages/user_page_old.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with AutomaticKeepAliveClientMixin {
  final List<bool> selectedUserOption = [true, false];
  final PrimitiveWrapper<bool> savedToggle = PrimitiveWrapper<bool>(false);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    AuthState authState = context.read<AuthBloc>().state;
    AccountState accountState = context.read<AccountBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() => authState = state);
          },
        ),
        BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            setState(() => accountState = state);
          },
        ),
      ],
      child: (authState.isLoggedIn && accountState.status == AccountStatus.success && accountState.personView != null)
          ? UserPage(
              userId: accountState.personView!.person.id,
              isAccountUser: true,
              selectedUserOption: selectedUserOption,
              savedToggle: savedToggle,
            )
          : const AccountPlaceholder(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
