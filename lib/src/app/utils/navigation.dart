import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/models/thunder_site_response.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/shared/pages/loading_page.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/shared/widgets/webview.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/app/pages/notifications_pages.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/shared/utils/swipe.dart';
import 'package:thunder/src/features/post/presentation/bloc/post_bloc.dart' as post_bloc;

({String postApId, post_bloc.PostBloc postBloc})? _cachedPostBloc;

/// Navigates to the instance page for the given [instanceHost].
///
/// When [instanceId] is provided, the instance page will allow the option to block that given instance. This value represents
/// the id of the navigated instance from the original instance (e.g., lemmy.ml's instance id from lemmy.world).
Future<void> navigateToInstancePage(
  BuildContext context, {
  required String instanceHost,
  required int? instanceId,
}) async {
  assert(instanceHost.isNotEmpty);

  showLoadingPage(context);

  final l10n = AppLocalizations.of(context)!;

  final profileBloc = context.read<ProfileBloc>();
  final thunderBloc = context.read<ThunderBloc>();
  final state = thunderBloc.state;

  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  ThunderSiteResponse? getSiteResponse;
  bool? isBlocked;

  final platform = await detectPlatformFromNodeInfo(instanceHost);

  try {
    // Get the site information by connecting to the given instance
    final account = Account(id: '', index: -1, instance: instanceHost, platform: platform);
    getSiteResponse = await InstanceRepositoryImpl(account: account).getSiteInfo().timeout(const Duration(seconds: 5));

    // Check whether this instance is blocked (we have to get our user from our current site first).
    isBlocked = profileBloc.state.siteResponse?.myUser?.instanceBlocks.any((i) => i.instance['domain'] == instanceHost);
  } catch (e) {
    // Continue if we can't get the site
  }

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => BlocProvider.value(
      value: thunderBloc,
      child: InstancePage(
        platform: platform!,
        site: getSiteResponse!,
        isBlocked: isBlocked,
        instanceId: instanceId,
      ),
    ),
  );

  if (getSiteResponse != null) {
    pushOnTopOfLoadingPage(context, route);
  } else {
    showSnackbar(
      l10n.unableToNavigateToInstance(instanceHost),
      trailingAction: () => handleLink(context, url: "https://$instanceHost", forceOpenInBrowser: true),
      trailingIcon: Icons.open_in_browser_rounded,
    );
    hideLoadingPage(context);
  }
}

/// Navigates to the post page with the given [post] or [postId].
///
/// One of [post] or [postId] must be provided. If [post] is provided, the post page will use that data to display the post.
/// Otherwise, the post page will fetch the post with the given [postId].
Future<void> navigateToPost(
  BuildContext context, {
  int? postId,
  ThunderPost? post,
  int? highlightedCommentId,
  Function(ThunderPost post)? onPostUpdated,
}) async {
  assert((postId != null || post != null), 'One of the parameters must be provided');

  // Required blocs
  final profileBloc = context.read<ProfileBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : null;

  ThunderPost? pvm = post;

  final account = context.read<ProfileBloc>().state.account;

  if (pvm == null) {
    final response = await PostRepositoryImpl(account: account).getPost(postId!);
    pvm = response?['post'];
  }

  // Mark post as read when tapped
  if (profileBloc.state.isLoggedIn) {
    feedBloc?.add(FeedItemActionedEvent(postId: pvm!.id, postAction: PostAction.read, value: true));
  }

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  final post_bloc.PostBloc postBloc = _cachedPostBloc?.postApId == pvm!.apId
      ? _cachedPostBloc!.postBloc
      : (_cachedPostBloc = (
          postApId: pvm.apId,
          postBloc: post_bloc.PostBloc(account: account),
        ))
          .postBloc;

  final route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionStartOffset: !kIsWeb && Platform.isAndroid ? 45 : 0,
    backGestureDetectionWidth: 45,
    canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: profileBloc.state.isLoggedIn, state: state, isPostPage: true) || !enableFullScreenSwipeNavigationGesture,
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: profileBloc),
          BlocProvider.value(value: thunderBloc),
          BlocProvider.value(value: postBloc),
          BlocProvider(create: (context) => AnonymousSubscriptionsBloc()),
        ],
        child: PostPage(
          initialPost: postBloc.state.post ?? pvm!,
          onPostUpdated: (ThunderPost post) {
            // Manually marking the read attribute as true when navigating to post since there is a case where the API call to mark the post as read from the feed page is not completed in time
            feedBloc?.add(FeedItemUpdatedEvent(post: post.copyWith(read: true)));
          },
        ),
      );
    },
  );

  pushOnTopOfLoadingPage(context, route);
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
}) async {
  final thunderBloc = context.read<ThunderBloc>();
  final account = context.read<ProfileBloc>().state.account;

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : FeedBloc(account: account);

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
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
        commentId: commentId,
        subtitle: subtitle,
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<ThunderPost> getPostFromComment(ThunderComment comment, Account account) async {
  if (comment.post != null) return comment.post!;

  final response = await PostRepositoryImpl(account: account).getPost(comment.postId, commentId: comment.id);
  return response!['post'] as ThunderPost;
}

Future<void> navigateToComment(BuildContext context, ThunderComment comment) async {
  final profileBloc = context.read<ProfileBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  final account = context.read<ProfileBloc>().state.account;

  final state = context.read<ThunderBloc>().state;
  final reduceAnimations = state.reduceAnimations;

  final route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionWidth: 45,
    canSwipe: Platform.isIOS || state.enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: profileBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true) || !state.enableFullScreenSwipeNavigationGesture,
    builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: profileBloc),
          BlocProvider.value(value: thunderBloc),
          BlocProvider(create: (context) => PostBloc(account: account)),
        ],
        child: FutureBuilder<ThunderPost>(
          future: getPostFromComment(comment, account),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PostPage(
                initialPost: snapshot.data!,
                highlightedCommentId: comment.id,
                commentPath: comment.path,
                onPostUpdated: (ThunderPost post) {},
              );
            }

            return LoadingPage();
          },
        ),
      );
    },
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<ThunderComment?> navigateToCreateCommentPage(
  BuildContext context, {
  ThunderPost? post,
  ThunderComment? comment,
  ThunderComment? parentComment,
  Function(ThunderComment comment, bool userChanged)? onCommentSuccess,
}) async {
  assert(!(post == null && parentComment == null && comment == null));
  assert(!(post != null && (parentComment != null || comment != null)));

  final profileBloc = context.read<ProfileBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider<ThunderBloc>.value(value: thunderBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
      ],
      child: CreateCommentPage(
        post: post,
        comment: comment,
        parentComment: parentComment,
        onCommentSuccess: onCommentSuccess,
      ),
    ),
  );

  final result = await pushOnTopOfLoadingPage(context, route);
  if (result is ThunderComment) return result;
  return null;
}

Future<void> navigateToCreatePostPage(
  BuildContext context, {
  String? title,
  String? text,
  File? image,
  String? url,
  bool? prePopulated,
  int? communityId,
  ThunderCommunity? community,
  ThunderPost? post,
  bool isCrossPost = false,
  Function(ThunderPost post, bool)? onPostSuccess,
}) async {
  try {
    final l10n = AppLocalizations.of(context)!;
    final account = context.read<ProfileBloc>().state.account;

    FeedBloc? feedBloc;
    PostBloc? postBloc;
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    ProfileBloc profileBloc = context.read<ProfileBloc>();
    CreatePostCubit createPostCubit = CreatePostCubit(account: account);

    final ThunderState thunderState = context.read<ThunderBloc>().state;
    final bool reduceAnimations = thunderState.reduceAnimations;
    final bool enableFullScreenSwipeNavigationGesture = thunderState.enableFullScreenSwipeNavigationGesture;

    try {
      feedBloc = context.read<FeedBloc>();
    } catch (e) {
      // Don't need feed block if we're not opening post in the context of a feed.
    }

    try {
      postBloc = context.read<PostBloc>();
    } catch (e) {
      // It's ok if we don't get the PostBloc
    }

    ThunderCommunity? pvmCommunity;

    if (post != null) {
      pvmCommunity = post.community;
    }

    await Navigator.of(context).push(SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (navigatorContext) {
        return MultiBlocProvider(
          providers: [
            feedBloc != null ? BlocProvider<FeedBloc>.value(value: feedBloc) : BlocProvider(create: (context) => FeedBloc(account: account)),
            if (postBloc != null) BlocProvider<PostBloc>.value(value: postBloc),
            BlocProvider<ThunderBloc>.value(value: thunderBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<CreatePostCubit>.value(value: createPostCubit),
          ],
          child: CreatePostPage(
            title: title,
            text: text,
            image: image,
            url: url,
            prePopulated: prePopulated,
            communityId: communityId ?? post?.community!.id,
            community: community ?? (post != null ? pvmCommunity : null),
            post: post,
            isCrossPost: isCrossPost,
            onPostSuccess: (ThunderPost updatedPost, bool userChanged) {
              // Update the existing post view media if it exists
              if (feedBloc != null) {
                feedBloc.add(FeedItemUpdatedEvent(post: updatedPost));
              }
              if (postBloc != null) {
                postBloc.add(PostUpdatedEvent(post: updatedPost));
              }

              // Show snackbar message if the post was just created
              if (!userChanged && post == null) {
                try {
                  showSnackbar(
                    l10n.postCreatedSuccessfully,
                    trailingIcon: Icons.remove_red_eye_rounded,
                    trailingAction: () {
                      navigateToPost(context, post: updatedPost);
                    },
                  );
                } catch (e) {
                  if (context.mounted) showSnackbar("${AppLocalizations.of(context)!.unexpectedError}: $e");
                }
              }

              if (onPostSuccess != null) onPostSuccess(updatedPost, userChanged);
            },
          ),
        );
      },
    ));
  } catch (e) {
    if (context.mounted) showSnackbar(AppLocalizations.of(context)!.unexpectedError);
  }
}

void navigateToNotificationReplyPage(BuildContext context, {required int? replyId, required String? accountId}) async {
  // It can take a little while to set up notifications, so show a loading page
  showLoadingPage(context);

  final ThunderBloc thunderBloc = context.read<ThunderBloc>();
  final bool reduceAnimations = thunderBloc.state.reduceAnimations;
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  Account? account = await fetchActiveProfile();

  if (account.id != accountId && accountId != null && context.mounted) {
    // Switch to the notification's account without reloading the app
    context.read<ProfileBloc>().add(SwitchProfile(accountId: accountId, reload: false));

    // Set the account locally here so we don't have to wait for the event to complete
    account = await Account.fetchAccount(accountId);

    // Show the user a message indicating that we switched
    showSnackbar(l10n.switchedAccount(generateUserFullName(context, account?.username, account?.displayName, account?.instance)));
  }

  // If account is still null, we can't do anything.
  if (account == null || account.anonymous) return;

  List<ThunderComment> allReplies = [];
  ThunderComment? specificReply;

  bool doneFetching = false;
  int currentPage = 1;

  // Load the notifications
  while (!doneFetching) {
    final getRepliesResponse = await NotificationRepositoryImpl(account: account).replies(
      unread: replyId == null,
      limit: 50,
      sort: CommentSortType.new_,
      page: currentPage,
    );

    allReplies.addAll(getRepliesResponse);
    specificReply ??= getRepliesResponse.firstWhereOrNull((crv) => crv.id == replyId);

    doneFetching = specificReply != null || getRepliesResponse.isEmpty;
    ++currentPage;
  }

  if (context.mounted) {
    final NotificationsReplyPage notificationsReplyPage = NotificationsReplyPage(replies: specificReply == null ? allReplies : [specificReply]);

    final SwipeablePageRoute route = SwipeablePageRoute(
      transitionDuration: isLoadingPageShown
          ? Duration.zero
          : reduceAnimations
              ? const Duration(milliseconds: 100)
              : null,
      reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
      backGestureDetectionWidth: 45,
      canSwipe: Platform.isIOS || thunderBloc.state.enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: thunderBloc),
        ],
        child: notificationsReplyPage,
      ),
    );

    pushOnTopOfLoadingPage(context, route).then((_) {
      context.read<InboxBloc>().add(const GetInboxEvent(reset: true, inboxType: InboxType.all));
    });
  }
}

/// Navigates to the [ReportFeedPage] page.
///
/// The [context] parameter should contain the following blocs within its widget tree: [FeedBloc], [ThunderBloc]
void navigateToReportPage(BuildContext context) {
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
  assert(hasFeedBloc == true);

  final feedBloc = context.read<FeedBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: feedBloc),
            BlocProvider.value(value: thunderBloc),
          ],
          child: const ReportFeedPage(),
        );
      },
    ),
  );
}

/// Navigates to a [FeedPage] with the given parameters
///
/// [feedType] must be provided.
/// If [feedType] is [FeedType.general], [feedListType] must be provided
/// If [feedType] is [FeedType.community], one of [communityId] or [communityName] must be provided
/// If [feedType] is [FeedType.user], one of [userId] or [username] must be provided
///
/// The [context] parameter should contain the following blocs within its widget tree: [AccountBloc], [AuthBloc], [ThunderBloc]
Future<void> navigateToFeedPage(
  BuildContext context, {
  required FeedType feedType,
  FeedListType? feedListType,
  PostSortType? postSortType,
  String? communityName,
  int? communityId,
  String? username,
  int? userId,
}) async {
  // Push navigation
  ProfileBloc profileBloc = context.read<ProfileBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();
  AnonymousSubscriptionsBloc anonymousSubscriptionsBloc = context.read<AnonymousSubscriptionsBloc>();

  ThunderState thunderState = thunderBloc.state;
  final bool reduceAnimations = thunderState.reduceAnimations;

  if (feedType == FeedType.general) {
    return context.read<FeedBloc>().add(
          FeedFetchedEvent(
            feedType: feedType,
            feedListType: feedListType,
            postSortType: postSortType ??
                (profileBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType != null
                    ? profileBloc.state.siteResponse!.myUser!.localUserView.localUser.defaultSortType
                    : thunderBloc.state.postSortTypeForInstance),
            communityId: communityId,
            communityName: communityName,
            userId: userId,
            username: username,
            reset: true,
            showHidden: thunderBloc.state.showHiddenPosts,
          ),
        );
  }

  SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionWidth: 45,
    canSwipe: Platform.isIOS || thunderState.enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: profileBloc.state.isLoggedIn, state: thunderBloc.state, isFeedPage: true) || !thunderState.enableFullScreenSwipeNavigationGesture,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profileBloc),
        BlocProvider.value(value: thunderBloc),
        BlocProvider.value(value: anonymousSubscriptionsBloc),
      ],
      child: Material(
        child: FeedPage(
          feedType: feedType,
          postSortType: postSortType ??
              (profileBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType != null
                  ? profileBloc.state.siteResponse!.myUser!.localUserView.localUser.defaultSortType
                  : thunderBloc.state.postSortTypeForInstance),
          communityName: communityName,
          communityId: communityId,
          userId: userId,
          username: username,
          feedListType: feedListType,
          showHidden: thunderBloc.state.showHiddenPosts,
        ),
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}

/// Navigates to the search page
///
/// The [context] parameter should contain the following blocs within its widget tree: [FeedBloc], [ThunderBloc]
void navigateToSearchPage(BuildContext context) {
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
  assert(hasFeedBloc == true);

  final feedBloc = context.read<FeedBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  final account = context.read<ProfileBloc>().state.account;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SearchBloc(account: account)),
          BlocProvider.value(value: thunderBloc),
        ],
        child: SearchPage(communityToSearch: feedBloc.state.community, isInitiallyFocused: true),
      ),
    ),
  );
}

/// Navigates to a given Setting page. This includes sub-pages (e.g., Account -> Blocklist, Appearance -> Posts, etc.)
///
/// Additionally, the [settingToHighlight] parameter can be used to highlight a specific setting when the page is opened.
void navigateToSettingPage(BuildContext context, LocalSettings setting, {LocalSettings? settingToHighlight}) {
  final thunderBloc = context.read<ThunderBloc>();
  final profileBloc = context.read<ProfileBloc>();

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  final account = context.read<ProfileBloc>().state.account;

  String pageToNav = {
        LocalSettingsCategories.posts: SETTINGS_APPEARANCE_POSTS_PAGE,
        LocalSettingsCategories.comments: SETTINGS_APPEARANCE_COMMENTS_PAGE,
        LocalSettingsCategories.general: SETTINGS_GENERAL_PAGE,
        LocalSettingsCategories.gestures: SETTINGS_GESTURES_PAGE,
        LocalSettingsCategories.floatingActionButton: SETTINGS_FAB_PAGE,
        LocalSettingsCategories.filters: SETTINGS_FILTERS_PAGE,
        LocalSettingsCategories.accessibility: SETTINGS_ACCESSIBILITY_PAGE,
        LocalSettingsCategories.account: SETTINGS_ACCOUNT_PAGE,
        LocalSettingsCategories.accountBlocklist: SETTINGS_ACCOUNT_BLOCKLIST_PAGE,
        LocalSettingsCategories.accountLanguages: SETTINGS_ACCOUNT_LANGUAGES_PAGE,
        LocalSettingsCategories.accountMediaManagement: SETTINGS_ACCOUNT_MEDIA_PAGE,
        LocalSettingsCategories.userLabels: SETTINGS_USER_LABELS_PAGE,
        LocalSettingsCategories.theming: SETTINGS_APPEARANCE_THEMES_PAGE,
        LocalSettingsCategories.debug: SETTINGS_DEBUG_PAGE,
        LocalSettingsCategories.about: SETTINGS_ABOUT_PAGE,
        LocalSettingsCategories.videoPlayer: SETTINGS_VIDEO_PAGE,
        LocalSettingsCategories.appearance: SETTINGS_APPEARANCE_PAGE,
      }[setting.category] ??
      SETTINGS_GENERAL_PAGE;

  if (pageToNav == SETTINGS_ABOUT_PAGE) {
    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: profileBloc),
            BlocProvider.value(value: thunderBloc),
          ],
          child: AboutSettingsPage(settingToHighlight: settingToHighlight ?? setting),
        ),
      ),
    );
  } else if (pageToNav == SETTINGS_ACCOUNT_MEDIA_PAGE) {
    final hasUserSettingsBloc = context.findAncestorWidgetOfExactType<BlocProvider<UserSettingsBloc>>() != null;

    final userSettingsBloc = hasUserSettingsBloc ? context.read<UserSettingsBloc>() : UserSettingsBloc(account: account);

    userSettingsBloc.add(const ListMediaEvent());

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: userSettingsBloc),
          ],
          child: MediaManagementPage(),
        ),
      ),
    );
  } else {
    final hasUserSettingsBloc = context.findAncestorWidgetOfExactType<BlocProvider<UserSettingsBloc>>() != null;
    final userSettingsBloc = hasUserSettingsBloc ? context.read<UserSettingsBloc>() : UserSettingsBloc(account: account);

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: profileBloc),
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: userSettingsBloc),
          ],
          child: switch (pageToNav) {
            SETTINGS_GENERAL_PAGE => GeneralSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_POSTS_PAGE => PostAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_COMMENTS_PAGE => CommentAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_GESTURES_PAGE => GestureSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FAB_PAGE => FabSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FILTERS_PAGE => FilterSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCOUNT_PAGE => UserSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCOUNT_LANGUAGES_PAGE => DiscussionLanguageSelector(),
            SETTINGS_ACCOUNT_BLOCKLIST_PAGE => UserSettingsBlockPage(),
            SETTINGS_APPEARANCE_THEMES_PAGE => ThemeSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_DEBUG_PAGE => DebugSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_VIDEO_PAGE => VideoPlayerSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_USER_LABELS_PAGE => UserLabelSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCESSIBILITY_PAGE => AccessibilitySettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_PAGE => AppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            _ => Container(),
          },
        ),
      ),
    );
  }
}

/// Navigates to the given [url] in a webview.
void navigateToWebView(BuildContext context, String url) {
  final thunderBloc = context.read<ThunderBloc>();

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => WebView(url: url),
  );

  pushOnTopOfLoadingPage(context, route);
}
