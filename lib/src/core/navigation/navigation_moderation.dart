import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/loading_page.dart';
import 'package:thunder/src/core/navigation/route_scope.dart';
import 'package:thunder/src/core/navigation/swipeable_page_route.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/settings/settings.dart';

/// Navigates to the [ReportFeedPage] page.
///
/// The [context] parameter should contain the following blocs within its widget tree: [FeedBloc], [ThunderCubit]
void navigateToReportPage(BuildContext context) {
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
  assert(hasFeedBloc == true);

  final routeScope = resolveAccountAwareRouteScope(context, useActiveAccount: true, includeThunderCubit: true);
  final feedBloc = context.read<FeedBloc>();

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (_) {
        return MultiBlocProvider(
          providers: routeScope.providers(provideThunderCubit: true, extraProviders: [BlocProvider<FeedBloc>.value(value: feedBloc)]),
          child: const ReportFeedPage(),
        );
      },
    ),
  );
}

/// Navigates to the modlog page with the given parameters.
Future<void> navigateToModlogPage(
  BuildContext context, {
  ModlogActionType? modlogActionType,
  int? communityId,
  int? userId,
  int? moderatorId,
  int? commentId,
  required String subtitle,
  Account? account,
}) async {
  final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
  final effectiveAccount = routeScope.account;

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : createFeedBloc(effectiveAccount);

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
        ? const Duration(milliseconds: 100)
        : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => MultiBlocProvider(
      providers: routeScope.providers(provideThunderCubit: true, extraProviders: [BlocProvider<FeedBloc>.value(value: feedBloc)]),
      child: ModlogFeedPage(
        account: effectiveAccount,
        modlogActionType: modlogActionType,
        communityId: communityId,
        userId: userId,
        moderatorId: moderatorId,
        commentId: commentId,
        subtitle: subtitle,
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}
