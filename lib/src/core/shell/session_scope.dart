import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/inbox/api.dart';
import 'package:thunder/src/features/search/api.dart';

class SessionScope extends StatelessWidget {
  const SessionScope({
    super.key,
    required this.account,
    required this.generation,
    required this.profileBloc,
    required this.inboxBloc,
    required this.searchBloc,
    required this.feedBloc,
    required this.builder,
  });

  /// The [account] for which the session scope is created.
  final Account account;

  /// The [generation] is used to force the recreation of the session scope when the account changes.
  final int generation;

  /// The [profileBloc] is used to create the [ProfileBloc] for the session scope.
  final ProfileBloc Function(Account account) profileBloc;

  /// The [inboxBloc] is used to create the [InboxBloc] for the session scope.
  final InboxBloc Function(Account account) inboxBloc;

  /// The [searchBloc] is used to create the [SearchBloc] for the session scope.
  final SearchBloc Function(Account account) searchBloc;

  /// The [feedBloc] is used to create the [FeedBloc] for the session scope.
  final FeedBloc Function(Account account) feedBloc;

  /// The [builder] is used to build the UI for the session scope.
  final Widget Function(BuildContext context, ProfileState profileState) builder;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey('session_scope_${account.id}_$generation'),
      providers: [
        BlocProvider(create: (context) => profileBloc(account)..add(InitializeAuth())),
        BlocProvider(create: (context) => inboxBloc(account)..add(GetInboxEvent(reset: true))),
        BlocProvider(create: (context) => searchBloc(account)),
        BlocProvider(create: (context) => feedBloc(account)),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(buildWhen: (previous, current) => previous.account.id != current.account.id, builder: builder),
    );
  }
}
