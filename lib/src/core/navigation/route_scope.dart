import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/session/session.dart';

import 'package:thunder/src/core/state/thunder_bloc.dart';

bool _matchesAccount(Account first, Account second) => first.id == second.id && first.instance == second.instance && first.anonymous == second.anonymous;

class AccountAwareRouteScope {
  const AccountAwareRouteScope._({required this.account, this.profileBloc, this.thunderCubit});

  final Account account;
  final ProfileBloc? profileBloc;
  final ThunderCubit? thunderCubit;

  List<BlocProvider> providers({
    bool provideFeatureAccountCubit = true,
    bool provideThunderCubit = false,
    List<BlocProvider> extraProviders = const [],
  }) {
    return [
      if (profileBloc != null) BlocProvider<ProfileBloc>.value(value: profileBloc!) else BlocProvider(create: (_) => createProfileBloc(account)..add(InitializeAuth())),
      if (provideThunderCubit && thunderCubit != null) BlocProvider<ThunderCubit>.value(value: thunderCubit!),
      if (provideFeatureAccountCubit) BlocProvider<FeatureAccountCubit>(create: (_) => FeatureAccountCubit(baseAccount: account)),
      ...extraProviders,
    ];
  }
}

AccountAwareRouteScope resolveAccountAwareRouteScope(
  BuildContext context, {
  Account? account,
  Account? fallbackAccount,
  bool useActiveAccount = false,
  bool includeThunderCubit = false,
}) {
  final resolvedAccount = account ?? (useActiveAccount ? resolveActiveAccount(context, fallbackAccount: fallbackAccount) : resolveEffectiveAccount(context, fallbackAccount: fallbackAccount));

  return AccountAwareRouteScope._(
    account: resolvedAccount,
    profileBloc: fetchProfileBloc(context, resolvedAccount),
    thunderCubit: includeThunderCubit ? context.read<ThunderCubit>() : null,
  );
}

ProfileBloc? fetchProfileBloc(BuildContext context, Account account) {
  try {
    final profileBloc = context.read<ProfileBloc>();
    return _matchesAccount(profileBloc.state.account, account) ? profileBloc : null;
  } catch (_) {
    return null;
  }
}

AnonymousSubscriptionsCubit? fetchAnonymousSubscriptionsCubit(BuildContext context) {
  try {
    return context.read<AnonymousSubscriptionsCubit>();
  } catch (_) {
    return null;
  }
}
