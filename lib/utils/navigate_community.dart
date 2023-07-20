import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

Future<void> navigateToCommunityByName(BuildContext context, String communityName) async {
  // If we're logged in, get the full community so we have its ID
  int? communityId;
  Account? account = await fetchActiveProfileAccount();
  if (account != null) {
    final getCommunityResponse = await LemmyClient.instance.lemmyApiV3.run(GetCommunity(
      auth: account.jwt,
      name: communityName,
    ));

    communityId = getCommunityResponse.communityView.community.id;
  }

  // Push navigation
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  Navigator.of(context).push(
    MaterialPageRoute(
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
