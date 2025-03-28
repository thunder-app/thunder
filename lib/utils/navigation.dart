import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/view/create_comment_page.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/models/thunder_community.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/enums/inbox_type.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/pages/instance_page.dart';
import 'package:thunder/moderator/view/report_page.dart';
import 'package:thunder/modlog/view/modlog_page.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/cubit/create_post_cubit.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/settings/pages/about_settings_page.dart';
import 'package:thunder/settings/pages/accessibility_settings_page.dart';
import 'package:thunder/settings/pages/appearance_settings_page.dart';
import 'package:thunder/settings/pages/comment_appearance_settings_page.dart';
import 'package:thunder/settings/pages/debug_settings_page.dart';
import 'package:thunder/settings/pages/filter_settings_page.dart';
import 'package:thunder/settings/pages/general_settings_page.dart';
import 'package:thunder/settings/pages/gesture_settings_page.dart';
import 'package:thunder/settings/pages/post_appearance_settings_page.dart';
import 'package:thunder/settings/pages/theme_settings_page.dart';
import 'package:thunder/settings/pages/user_labels_settings_page.dart';
import 'package:thunder/settings/pages/video_player_settings.dart';
import 'package:thunder/settings/widgets/discussion_language_selector.dart';
import 'package:thunder/shared/pages/loading_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/pages/notifications_pages.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/user/pages/media_management_page.dart';
import 'package:thunder/user/pages/user_settings_block_page.dart';
import 'package:thunder/user/pages/user_settings_page.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/utils/swipe.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc;

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

  final authBloc = context.read<AuthBloc>();
  final thunderBloc = context.read<ThunderBloc>();
  final state = thunderBloc.state;

  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  GetSiteResponse? getSiteResponse;
  bool? isBlocked;

  try {
    // Get the site information by connecting to the given instance
    getSiteResponse = await LemmyApiV3(instanceHost).run(const GetSite()).timeout(const Duration(seconds: 5));

    // Check whether this instance is blocked (we have to get our user from our current site first).
    isBlocked = authBloc.state.getSiteResponse?.myUser?.instanceBlocks?.any((i) => i.instance.domain == instanceHost);
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
        getSiteResponse: getSiteResponse!,
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

/// Navigates to the post page with the given [postViewMedia] or [postId].
///
/// One of [postViewMedia] or [postId] must be provided. If [postViewMedia] is provided, the post page will use that data to display the post.
/// Otherwise, the post page will fetch the post with the given [postId].
Future<void> navigateToPost(
  BuildContext context, {
  int? postId,
  PostViewMedia? postViewMedia,
  int? selectedCommentId,
  String? selectedCommentPath,
  Function(PostViewMedia)? onPostUpdated,
}) async {
  assert((postId != null || postViewMedia != null), 'One of the parameters must be provided');

  // Required blocs
  final accountBloc = context.read<AccountBloc>();
  final authBloc = context.read<AuthBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : null;

  PostViewMedia? pvm = postViewMedia;

  if (pvm == null) {
    final client = LemmyClient.instance.lemmyApiV3;
    final account = await fetchActiveProfileAccount();

    GetPostResponse getPostResponse = await client.run(
      GetPost(
        auth: account?.jwt,
        id: postId,
      ),
    );

    List<PostViewMedia> postViewMedias = await parsePostViews([getPostResponse.postView]);

    pvm = postViewMedias.first;
  }

  // Mark post as read when tapped
  if (authBloc.state.isLoggedIn) {
    feedBloc?.add(FeedItemActionedEvent(postId: pvm.postView.post.id, postAction: PostAction.read, value: true));
  }

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

  final post_bloc.PostBloc postBloc = _cachedPostBloc?.postApId == postViewMedia!.postView.post.apId
      ? _cachedPostBloc!.postBloc
      : (_cachedPostBloc = (
          postApId: postViewMedia.postView.post.apId,
          postBloc: post_bloc.PostBloc(),
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
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: state, isPostPage: true) || !enableFullScreenSwipeNavigationGesture,
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: accountBloc),
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: thunderBloc),
          BlocProvider.value(value: postBloc),
          BlocProvider(create: (context) => InstanceBloc(lemmyClient: LemmyClient.instance)),
          BlocProvider(create: (context) => CommunityBloc(lemmyClient: LemmyClient.instance)),
          BlocProvider(create: (context) => AnonymousSubscriptionsBloc()),
        ],
        child: PostPage(
          initialPostViewMedia: postBloc.state.postView ?? pvm!,
          onPostUpdated: (PostViewMedia postViewMedia) {
            // Manually marking the read attribute as true when navigating to post since there is a case where the API call to mark the post as read from the feed page is not completed in time
            feedBloc?.add(FeedItemUpdatedEvent(
              postViewMedia: PostViewMedia(
                postView: postViewMedia.postView.copyWith(read: true),
                media: postViewMedia.media,
              ),
            ));
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
  LemmyClient? lemmyClient,
  Widget? subtitle,
}) async {
  final thunderBloc = context.read<ThunderBloc>();

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : FeedBloc(lemmyClient: lemmyClient ?? LemmyClient.instance);

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
        lemmyClient: lemmyClient,
        subtitle: subtitle,
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<void> navigateToComment(BuildContext context, CommentView commentView) async {
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  final ThunderState state = context.read<ThunderBloc>().state;
  final bool reduceAnimations = state.reduceAnimations;

  final client = LemmyClient.instance.lemmyApiV3;
  final account = await fetchActiveProfileAccount();

  GetPostResponse getPostResponse = await client.run(
    GetPost(
      auth: account?.jwt,
      id: commentView.post.id,
      commentId: commentView.comment.id,
    ),
  );

  List<PostViewMedia> postViewMedias = await parsePostViews([getPostResponse.postView]);

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionWidth: 45,
    canSwipe: Platform.isIOS || state.enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true) || !state.enableFullScreenSwipeNavigationGesture,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: accountBloc),
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: thunderBloc),
        BlocProvider(create: (context) => PostBloc()),
      ],
      child: PostPage(
        initialPostViewMedia: postViewMedias.first,
        highlightedCommentId: commentView.comment.id,
        commentPath: commentView.comment.path,
        onPostUpdated: (PostViewMedia postViewMedia) {},
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<void> navigateToCreateCommentPage(
  BuildContext context, {
  PostViewMedia? postViewMedia,
  CommentView? commentView,
  CommentView? parentCommentView,
  Function(CommentView commentView, bool userChanged)? onCommentSuccess,
}) async {
  assert(!(postViewMedia == null && parentCommentView == null && commentView == null));
  assert(!(postViewMedia != null && (parentCommentView != null || commentView != null)));

  final accountBloc = context.read<AccountBloc>();
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
        BlocProvider<AccountBloc>.value(value: accountBloc),
      ],
      child: CreateCommentPage(
        postViewMedia: postViewMedia,
        commentView: commentView,
        parentCommentView: parentCommentView,
        onCommentSuccess: onCommentSuccess,
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
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
  PostViewMedia? postViewMedia,
  bool isCrossPost = false,
  Function(PostViewMedia, bool)? onPostSuccess,
}) async {
  try {
    final l10n = AppLocalizations.of(context)!;

    FeedBloc? feedBloc;
    PostBloc? postBloc;
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    AccountBloc accountBloc = context.read<AccountBloc>();
    CreatePostCubit createPostCubit = CreatePostCubit();

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

    if (postViewMedia != null) {
      final cv = CommunityView(
        community: postViewMedia.postView.community,
        subscribed: postViewMedia.postView.subscribed,
        blocked: false,
        counts: CommunityAggregates(
          communityId: postViewMedia.postView.community.id,
          subscribers: 0,
          posts: 0,
          comments: 0,
          published: DateTime.now(),
          usersActiveDay: 0,
          usersActiveWeek: 0,
          usersActiveMonth: 0,
          usersActiveHalfYear: 0,
        ),
      );

      pvmCommunity = ThunderCommunity(cv.community, communityView: cv);
    }

    await Navigator.of(context).push(SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (navigatorContext) {
        return MultiBlocProvider(
          providers: [
            feedBloc != null ? BlocProvider<FeedBloc>.value(value: feedBloc) : BlocProvider(create: (context) => FeedBloc(lemmyClient: LemmyClient.instance)),
            if (postBloc != null) BlocProvider<PostBloc>.value(value: postBloc),
            BlocProvider<ThunderBloc>.value(value: thunderBloc),
            BlocProvider<AccountBloc>.value(value: accountBloc),
            BlocProvider<CreatePostCubit>.value(value: createPostCubit),
          ],
          child: CreatePostPage(
            title: title,
            text: text,
            image: image,
            url: url,
            prePopulated: prePopulated,
            communityId: communityId ?? postViewMedia?.postView.community.id,
            community: community ?? (postViewMedia != null ? pvmCommunity : null),
            postView: postViewMedia?.postView,
            isCrossPost: isCrossPost,
            onPostSuccess: (PostViewMedia pvm, bool userChanged) {
              // Update the existing post view media if it exists
              if (postViewMedia != null) {
                if (feedBloc != null) {
                  feedBloc.add(FeedItemUpdatedEvent(postViewMedia: pvm));
                }
                if (postBloc != null) {
                  postBloc.add(PostUpdatedEvent(postViewMedia: pvm));
                }
              }

              // Show snackbar message if the post was just created
              if (!userChanged && postViewMedia == null) {
                try {
                  showSnackbar(
                    l10n.postCreatedSuccessfully,
                    trailingIcon: Icons.remove_red_eye_rounded,
                    trailingAction: () {
                      navigateToPost(context, postViewMedia: pvm);
                    },
                  );
                } catch (e) {
                  if (context.mounted) showSnackbar("${AppLocalizations.of(context)!.unexpectedError}: $e");
                }
              }

              if (onPostSuccess != null) onPostSuccess(pvm, userChanged);
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
  Account? account = await fetchActiveProfileAccount();

  bool switchedAccount = false;
  String? originalAccount = account?.id;
  String? originalAnonymousInstance = context.mounted ? context.read<ThunderBloc>().state.currentAnonymousInstance : null;

  if (account?.id != accountId && accountId != null && context.mounted) {
    // Switch to the notification's account without reloading the app
    context.read<AuthBloc>().add(SwitchAccount(accountId: accountId, reload: false));

    // Set the account locally here so we don't have to wait for the event to complete
    account = await Account.fetchAccount(accountId);

    // Note that we switched so we can switch back
    switchedAccount = true;
  }

  // If account is still null, we can't do anything.
  if (account == null) return;

  List<CommentReplyView> allReplies = [];
  CommentReplyView? specificReply;

  bool doneFetching = false;
  int currentPage = 1;

  // Load the notifications
  while (!doneFetching) {
    final GetRepliesResponse getRepliesResponse = await (LemmyClient()..changeBaseUrl(account.instance)).lemmyApiV3.run(GetReplies(
          sort: CommentSortType.new_,
          page: currentPage,
          limit: 50,
          unreadOnly: replyId == null,
          auth: account.jwt,
        ));

    allReplies.addAll(getRepliesResponse.replies);
    specificReply ??= getRepliesResponse.replies.firstWhereOrNull((crv) => crv.commentReply.id == replyId);

    doneFetching = specificReply != null || getRepliesResponse.replies.isEmpty;
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
      // If needed, switch back to the original account or anonymous instance
      if (switchedAccount) {
        if (originalAccount != null) {
          // We switched from an account, so switch back
          context.read<AuthBloc>().add(SwitchAccount(accountId: originalAccount, reload: false));
        } else if (originalAnonymousInstance != null) {
          // We switched from anonymous, so switch back
          context.read<AuthBloc>().add(const LogOutOfAllAccounts());
          context.read<ThunderBloc>().add(OnSetCurrentAnonymousInstance(originalAnonymousInstance));
          context.read<AuthBloc>().add(InstanceChanged(instance: originalAnonymousInstance));
        }
      }

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
/// If [feedType] is [FeedType.general], [postListingType] must be provided
/// If [feedType] is [FeedType.community], one of [communityId] or [communityName] must be provided
/// If [feedType] is [FeedType.user], one of [userId] or [username] must be provided
///
/// The [context] parameter should contain the following blocs within its widget tree: [AccountBloc], [AuthBloc], [ThunderBloc]
Future<void> navigateToFeedPage(
  BuildContext context, {
  required FeedType feedType,
  ListingType? postListingType,
  SortType? sortType,
  String? communityName,
  int? communityId,
  String? username,
  int? userId,
}) async {
  // Push navigation
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();
  CommunityBloc communityBloc = context.read<CommunityBloc>();
  InstanceBloc instanceBloc = context.read<InstanceBloc>();
  AnonymousSubscriptionsBloc anonymousSubscriptionsBloc = context.read<AnonymousSubscriptionsBloc>();

  ThunderState thunderState = thunderBloc.state;
  final bool reduceAnimations = thunderState.reduceAnimations;

  if (feedType == FeedType.general) {
    return context.read<FeedBloc>().add(
          FeedFetchedEvent(
            feedType: feedType,
            postListingType: postListingType,
            sortType: sortType ?? authBloc.state.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderBloc.state.sortTypeForInstance,
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
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isFeedPage: true) || !thunderState.enableFullScreenSwipeNavigationGesture,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: accountBloc),
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: thunderBloc),
        BlocProvider.value(value: instanceBloc),
        BlocProvider.value(value: anonymousSubscriptionsBloc),
        BlocProvider.value(value: communityBloc),
      ],
      child: Material(
        child: FeedPage(
          feedType: feedType,
          sortType: sortType ?? authBloc.state.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderBloc.state.sortTypeForInstance,
          communityName: communityName,
          communityId: communityId,
          userId: userId,
          username: username,
          postListingType: postListingType,
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

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SearchBloc()),
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
  final accountBloc = context.read<AccountBloc>();

  final state = thunderBloc.state;
  final reduceAnimations = state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = state.enableFullScreenSwipeNavigationGesture;

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
    final authBloc = context.read<AuthBloc>();

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: authBloc),
          ],
          child: AboutSettingsPage(settingToHighlight: settingToHighlight ?? setting),
        ),
      ),
    );
  } else if (pageToNav == SETTINGS_ACCOUNT_MEDIA_PAGE) {
    final hasUserSettingsBloc = context.findAncestorWidgetOfExactType<BlocProvider<UserSettingsBloc>>() != null;

    final userSettingsBloc = hasUserSettingsBloc ? context.read<UserSettingsBloc>() : UserSettingsBloc();
    final authBloc = context.read<AuthBloc>();

    userSettingsBloc.add(const ListMediaEvent());

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: userSettingsBloc),
          ],
          child: MediaManagementPage(),
        ),
      ),
    );
  } else {
    final hasUserSettingsBloc = context.findAncestorWidgetOfExactType<BlocProvider<UserSettingsBloc>>() != null;
    final userSettingsBloc = hasUserSettingsBloc ? context.read<UserSettingsBloc>() : UserSettingsBloc();

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: userSettingsBloc),
          ],
          child: switch (pageToNav) {
            SETTINGS_GENERAL_PAGE => GeneralSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_POSTS_PAGE => PostAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_COMMENTS_PAGE => CommentAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_GESTURES_PAGE => GestureSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FAB_PAGE => GestureSettingsPage(settingToHighlight: settingToHighlight ?? setting),
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
