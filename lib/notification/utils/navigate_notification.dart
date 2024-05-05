// Flutter imports
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

// Project imports
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/pages/notifications_pages.dart';

void navigateToNotificationReplyPage(BuildContext context, {required int? replyId}) async {
  final ThunderBloc thunderBloc = context.read<ThunderBloc>();
  final bool reduceAnimations = thunderBloc.state.reduceAnimations;
  final Account? account = await fetchActiveProfileAccount();

  List<CommentReplyView> allReplies = [];
  CommentReplyView? specificReply;

  bool doneFetching = false;
  int currentPage = 1;

  // Load the notifications
  while (!doneFetching) {
    final GetRepliesResponse getRepliesResponse = await LemmyClient.instance.lemmyApiV3.run(GetReplies(
      sort: CommentSortType.new_,
      page: currentPage,
      limit: 50,
      unreadOnly: replyId == null,
      auth: account?.jwt,
    ));

    allReplies.addAll(getRepliesResponse.replies);
    specificReply ??= getRepliesResponse.replies.firstWhereOrNull((crv) => crv.commentReply.id == replyId);

    doneFetching = specificReply != null || getRepliesResponse.replies.isEmpty;
    ++currentPage;
  }

  if (context.mounted) {
    final NotificationsReplyPage notificationsReplyPage = NotificationsReplyPage(replies: specificReply == null ? allReplies : [specificReply]);

    Navigator.of(context)
        .push(
          SwipeablePageRoute(
            transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
            backGestureDetectionWidth: 45,
            canSwipe: Platform.isIOS || thunderBloc.state.enableFullScreenSwipeNavigationGesture,
            canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: thunderBloc),
              ],
              child: notificationsReplyPage,
            ),
          ),
        )
        .then((_) => context.read<InboxBloc>().add(const GetInboxEvent(reset: true)));
  }
}
