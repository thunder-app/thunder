import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/pages/user_page.dart';

Future<void> navigateToUserByName(BuildContext context, String username) async {
  // Get the id from the name
  int? userId;
  Account? account = await fetchActiveProfileAccount();
  final fullPersonView = await LemmyClient.instance.lemmyApiV3.run(GetPersonDetails(
    auth: account?.jwt,
    username: username,
  ));

  userId = fullPersonView.personView.person.id;

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
        child: UserPage(
          userId: userId,
          username: username,
        ),
      ),
    ),
  );
}
