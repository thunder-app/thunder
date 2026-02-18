import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/feed.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocSelector<ProfileBloc, ProfileState, bool>(
      selector: (state) => state.isLoggedIn,
      builder: (context, isLoggedIn) {
        if (isLoggedIn != true) return const AccountPlaceholder();

        final userId = context.select<ProfileBloc, int?>((bloc) => bloc.state.account.userId);
        return FeedPage(
          feedType: FeedType.account,
          userId: userId,
          postSortType: PostSortType.new_,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
