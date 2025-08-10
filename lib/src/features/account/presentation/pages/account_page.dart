import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
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

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.isLoggedIn != true) return const AccountPlaceholder();

        return FeedPage(
          feedType: FeedType.account,
          userId: state.account.userId,
          postSortType: PostSortType.new_,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
