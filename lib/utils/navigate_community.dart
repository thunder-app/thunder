import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

/// Navigates to a [CommunityPage] with a given [communityName] or [communityId]
///
/// Note: only one of [communityName] or [communityId] should be provided
/// If both are provided, the [communityId] will take precedence
///
/// The [context] parameter should contain the following blocs within its widget tree: [AccountBloc], [AuthBloc], [ThunderBloc]
Future<void> navigateToCommunityPage(BuildContext context, {String? communityName, int? communityId}) async {
  if (communityName == null && communityId == null) return; // Return early since there's nothing to do

  int? _communityId = communityId;

  if (_communityId == null) {
    // Get the id from the name
    Account? account = await fetchActiveProfileAccount();

    final getCommunityResponse = await LemmyClient.instance.lemmyApiV3.run(GetCommunity(
      auth: account?.jwt,
      name: communityName,
    ));

    _communityId = getCommunityResponse.communityView.community.id;
  }

  // Push navigation
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  Navigator.of(context).push(
    SwipeablePageRoute(
      backGestureDetectionWidth: 45,
      canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isFeedPage: true),
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: accountBloc),
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: thunderBloc),
        ],
        child: CommunityPage(communityName: communityName, communityId: communityId),
      ),
    ),
  );
}
