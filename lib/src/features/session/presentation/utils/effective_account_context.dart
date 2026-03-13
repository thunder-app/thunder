import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/presentation/state/feature_account_cubit.dart';
import 'package:thunder/src/features/session/presentation/state/session_bloc.dart';

class CapturedAccountContext {
  const CapturedAccountContext({
    required this.effectiveAccount,
    this.sessionBloc,
    this.profileBloc,
    this.featureAccountCubit,
  });

  final Account effectiveAccount;
  final SessionBloc? sessionBloc;
  final ProfileBloc? profileBloc;
  final FeatureAccountCubit? featureAccountCubit;

  factory CapturedAccountContext.capture(BuildContext context, {Account? fallbackAccount}) {
    SessionBloc? sessionBloc;
    ProfileBloc? profileBloc;
    FeatureAccountCubit? featureAccountCubit;

    try {
      sessionBloc = context.read<SessionBloc>();
    } catch (_) {
      sessionBloc = null;
    }

    try {
      profileBloc = context.read<ProfileBloc>();
    } catch (_) {
      profileBloc = null;
    }

    try {
      featureAccountCubit = context.read<FeatureAccountCubit>();
    } catch (_) {
      featureAccountCubit = null;
    }

    return CapturedAccountContext(
      effectiveAccount: resolveEffectiveAccount(context, fallbackAccount: fallbackAccount),
      sessionBloc: sessionBloc,
      profileBloc: profileBloc,
      featureAccountCubit: featureAccountCubit,
    );
  }

  Widget wrap(Widget child) {
    return MultiBlocProvider(
      providers: [
        if (sessionBloc != null) BlocProvider<SessionBloc>.value(value: sessionBloc!),
        if (profileBloc != null) BlocProvider<ProfileBloc>.value(value: profileBloc!),
        if (featureAccountCubit != null)
          BlocProvider<FeatureAccountCubit>.value(value: featureAccountCubit!)
        else
          BlocProvider<FeatureAccountCubit>(create: (_) => FeatureAccountCubit(baseAccount: effectiveAccount)),
      ],
      child: child,
    );
  }
}

Widget wrapWithCapturedAccountContext(BuildContext context, Widget child, {Account? fallbackAccount}) {
  return CapturedAccountContext.capture(context, fallbackAccount: fallbackAccount).wrap(child);
}

Account resolveActiveAccount(BuildContext context, {Account? fallbackAccount}) {
  try {
    final activeAccount = context.read<SessionBloc>().state.activeAccount;
    if (activeAccount != null) {
      return activeAccount;
    }
  } catch (_) {
    // Fall through to older account providers while the app finishes migrating.
  }

  if (fallbackAccount != null) {
    return fallbackAccount;
  }

  try {
    return context.read<ProfileBloc>().state.account;
  } catch (_) {
    throw StateError('No active account available in the current widget tree.');
  }
}

Account resolveEffectiveAccount(BuildContext context, {Account? fallbackAccount}) {
  try {
    return context.read<FeatureAccountCubit>().state.effectiveAccount;
  } catch (_) {
    return resolveActiveAccount(context, fallbackAccount: fallbackAccount);
  }
}
