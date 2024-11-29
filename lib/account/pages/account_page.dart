import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/widgets/account_placeholder.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/shared/primitive_wrapper.dart';
import 'package:thunder/user/pages/old_user_page.dart';

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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.isLoggedIn != true) return const AccountPlaceholder();

        return FeedPage(
          feedType: FeedType.account,
          userId: state.account?.userId,
          sortType: SortType.new_,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
