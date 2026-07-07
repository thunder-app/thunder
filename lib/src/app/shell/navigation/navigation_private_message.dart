import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/app/shell/navigation/loading_page.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/app/shell/navigation/swipeable_page_route.dart';
import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/features/private_message/presentation/pages/create_private_message_page.dart';
import 'package:thunder/src/features/private_message/presentation/pages/private_message_thread_page.dart';
import 'package:thunder/src/features/private_message/presentation/state/create_private_message_cubit.dart';
import 'package:thunder/src/features/private_message/presentation/state/private_message_thread_cubit.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Opens the full direct-message editor and returns the sent message, if any.
Future<ThunderPrivateMessage?> navigateToCreatePrivateMessagePage(
  BuildContext context, {
  Account? account,
  ThunderUser? recipient,
  String? initialContent,
  void Function(ThunderPrivateMessage message)? onMessageSent,
}) async {
  try {
    final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
    final effectiveAccount = routeScope.account;
    final createPrivateMessageCubit = createCreatePrivateMessageCubit(effectiveAccount);
    final themeCubit = context.read<ThemePreferencesCubit>();
    final gestureCubit = context.read<GesturePreferencesCubit>();
    final reduceAnimations = themeCubit.state.reduceAnimations;
    final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

    final route = SwipeablePageRoute(
      transitionDuration: isLoadingPageShown
          ? Duration.zero
          : reduceAnimations
              ? const Duration(milliseconds: 100)
              : null,
      reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (context) => MultiBlocProvider(
        providers: routeScope.providers(
          provideThunderCubit: true,
          extraProviders: [
            BlocProvider<CreatePrivateMessageCubit>.value(value: createPrivateMessageCubit),
          ],
        ),
        child: CreatePrivateMessagePage(
          account: effectiveAccount,
          recipient: recipient,
          initialContent: initialContent,
          onMessageSent: onMessageSent,
        ),
      ),
    );

    final result = await pushOnTopOfLoadingPage(context, route);
    if (result is ThunderPrivateMessage) return result;
  } catch (e) {
    showThunderSnackbar(e.toString());
  }

  return null;
}

/// Opens a direct-message thread with [participant].
Future<void> navigateToPrivateMessageThreadPage(
  BuildContext context, {
  Account? account,
  required ThunderUser participant,
  List<ThunderPrivateMessage> initialMessages = const <ThunderPrivateMessage>[],
  int? conversationId,
  ValueChanged<List<ThunderPrivateMessage>>? onThreadUpdated,
}) async {
  final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
  final effectiveAccount = routeScope.account;
  final threadCubit = createPrivateMessageThreadCubit(
    effectiveAccount,
    participant: participant,
    initialMessages: initialMessages,
    conversationId: conversationId,
  );
  final themeCubit = context.read<ThemePreferencesCubit>();
  final gestureCubit = context.read<GesturePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  await Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (context) => MultiBlocProvider(
        providers: routeScope.providers(
          provideThunderCubit: true,
          extraProviders: [
            BlocProvider<PrivateMessageThreadCubit>.value(value: threadCubit),
          ],
        ),
        child: PrivateMessageThreadPage(
          account: effectiveAccount,
          participant: participant,
          onThreadUpdated: onThreadUpdated,
        ),
      ),
    ),
  );
}
