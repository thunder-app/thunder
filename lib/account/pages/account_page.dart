import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/widgets/account_placeholder.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/feed.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    AuthState authState = context.read<AuthBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.isLoggedIn && !state.reload) return;
            setState(() => authState = state);
          },
        ),
        BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (authState.isLoggedIn && !state.reload) return;
          },
        ),
      ],
      child: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (authState.isLoggedIn != true) return const AccountPlaceholder();

          return FeedPage(
            feedType: FeedType.account,
            userId: authState.account?.userId,
            sortType: SortType.new_,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
