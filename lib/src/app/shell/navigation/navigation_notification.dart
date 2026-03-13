part of 'navigation_utils.dart';

/// Navigates to a notifications page for the given [inboxType].
///
/// The [notificationId] is used to find and display a specific notification.
/// If [notificationId] is null, all unread notifications of the given type will be shown.
void navigateToNotificationPage(
  BuildContext context, {
  required InboxType inboxType,
  required int? notificationId,
  required String? accountId,
}) async {
  assert(inboxType == InboxType.replies || inboxType == InboxType.mentions || inboxType == InboxType.messages);

  // It can take a little while to set up notifications, so show a loading page
  showLoadingPage(context);

  final thunderBloc = context.read<ThunderCubit>();
  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;

  if (accountId == null) {
    hideLoadingPage(context);
    return; // No account ID provided, so we can't do anything.
  }

  final account = await Account.fetchAccount(accountId);
  if (account == null) {
    if (context.mounted) hideLoadingPage(context);
    return; // No account found, so we can't do anything.
  }

  final notificationRepository = NotificationRepositoryImpl(account: account);

  late final NotificationsPage notificationsPage;

  if (inboxType == InboxType.messages) {
    final messages = <ThunderPrivateMessage>[];
    ThunderPrivateMessage? message;

    bool doneFetching = false;
    int currentPage = 1;

    while (!doneFetching) {
      final response = await notificationRepository.messages(
        unread: notificationId == null,
        limit: 50,
        page: currentPage,
      );

      messages.addAll(response);
      message ??= response.firstWhereOrNull((m) => m.id == notificationId);

      doneFetching = message != null || response.isEmpty;
      ++currentPage;
    }

    notificationsPage = NotificationsPage.messages(messages: message == null ? messages : [message]);
  } else {
    final comments = <ThunderComment>[];
    ThunderComment? comment;

    bool doneFetching = false;
    int currentPage = 1;

    while (!doneFetching) {
      final response = inboxType == InboxType.replies
          ? await notificationRepository.replies(unread: notificationId == null, limit: 50, sort: CommentSortType.new_, page: currentPage)
          : await notificationRepository.mentions(unread: notificationId == null, limit: 50, sort: CommentSortType.new_, page: currentPage);

      comments.addAll(response);
      comment ??= response.firstWhereOrNull((c) => c.id == notificationId);

      doneFetching = comment != null || response.isEmpty;
      ++currentPage;
    }

    notificationsPage =
        inboxType == InboxType.replies ? NotificationsPage.replies(replies: comment == null ? comments : [comment]) : NotificationsPage.mentions(mentions: comment == null ? comments : [comment]);
  }

  if (context.mounted) {
    final route = SwipeablePageRoute(
      transitionDuration: isLoadingPageShown
          ? Duration.zero
          : reduceAnimations
              ? const Duration(milliseconds: 100)
              : null,
      reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
      backGestureDetectionWidth: 45,
      canSwipe: !kIsWeb && Platform.isIOS || gestureCubit.state.enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: !gestureCubit.state.enableFullScreenSwipeNavigationGesture,
      builder: (context) => MultiBlocProvider(
        providers: [BlocProvider.value(value: thunderBloc)],
        child: notificationsPage,
      ),
    );

    pushOnTopOfLoadingPage(context, route).then((_) {
      context.read<InboxBloc>().add(const GetInboxEvent(reset: true, inboxType: InboxType.all));
    });
  }
}
