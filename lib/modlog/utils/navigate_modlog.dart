import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/modlog/view/modlog_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

Future<void> navigateToModlogPage(
  BuildContext context, {
  required FeedBloc feedBloc,
  ModlogActionType? modlogActionType,
  int? communityId,
  int? userId,
  int? moderatorId,
  LemmyClient? lemmyClient,
}) async {
  final ThunderBloc thunderBloc = context.read<ThunderBloc>();
  final bool reduceAnimations = thunderBloc.state.reduceAnimations;

  bool canOnlySwipeFromEdge = true;
  try {
    AuthBloc authBloc = context.read<AuthBloc>();
    canOnlySwipeFromEdge = disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: false) || !thunderBloc.state.enableFullScreenSwipeNavigationGesture;
  } catch (e) {}

  await Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      backGestureDetectionStartOffset: !kIsWeb && Platform.isAndroid ? 45 : 0,
      canOnlySwipeFromEdge: canOnlySwipeFromEdge,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: feedBloc),
          BlocProvider.value(value: thunderBloc),
        ],
        child: ModlogFeedPage(
          modlogActionType: modlogActionType,
          communityId: communityId,
          userId: userId,
          moderatorId: moderatorId,
          lemmyClient: lemmyClient,
        ),
      ),
    ),
  );
}
