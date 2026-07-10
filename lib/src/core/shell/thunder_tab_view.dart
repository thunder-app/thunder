import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/settings/settings.dart';

class ThunderTabView extends StatelessWidget {
  const ThunderTabView({
    super.key,
    required this.pageController,
    required this.actionController,
    required this.scaffoldStateKey,
    required this.profileState,
    required this.selectedPageIndex,
    required this.onPageChanged,
  });

  final PageController pageController;
  final FeedActionController actionController;
  final GlobalKey<ScaffoldState> scaffoldStateKey;
  final ProfileState profileState;
  final int selectedPageIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        Builder(
          builder: (context) {
            final feedCubit = context.read<FeedPreferencesCubit>();
            return FeedPage(
              actionController: actionController,
              useGlobalFeedBloc: true,
              feedType: FeedType.general,
              feedListType: profileState.siteResponse?.myUser?.localUserView.localUser.defaultListingType ?? feedCubit.state.defaultFeedListType,
              postSortType: profileState.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType,
              scaffoldStateKey: scaffoldStateKey,
              showHidden: feedCubit.state.showHiddenPosts,
              isActive: selectedPageIndex == 0,
            );
          },
        ),
        SearchPage(account: profileState.account),
        const AccountPage(),
        const InboxPage(),
        const SettingsPage(),
      ],
    );
  }
}
