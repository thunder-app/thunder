import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/app/shell/navigation/swipeable_page_route.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/features/private_message/private_message.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/session/session.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/app/shell/navigation/loading_page.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/shared/gestures/swipe_utils.dart';
import 'package:thunder/src/shared/webview/webview.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/notification/presentation/pages/notifications_page.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/utils/cache/platform_version_cache.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;
import 'package:thunder/src/features/post/presentation/state/post_bloc.dart' as post_bloc;

part 'navigation_feed.dart';
part 'navigation_instance.dart';
part 'navigation_misc.dart';
part 'navigation_notification.dart';
part 'navigation_post.dart';
part 'navigation_settings.dart';

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
