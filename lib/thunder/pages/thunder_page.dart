import 'dart:async';
import 'dart:io';

// Flutter
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/models/account.dart';

import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/community/widgets/community_drawer.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:collection/collection.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';

// Internal
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/feed/widgets/feed_fab.dart';
import 'package:thunder/modlog/utils/navigate_modlog.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/cubits/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/thunder/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:thunder/thunder/enums/deep_link_enums.dart';
import 'package:thunder/thunder/widgets/bottom_nav_bar.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/inbox.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/settings/pages/settings_page.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/post/utils/navigate_create_post.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/post/utils/navigate_post.dart';
import 'package:thunder/notification/utils/navigate_notification.dart';
import 'package:thunder/utils/settings_utils.dart';

String? currentIntent;

class Thunder extends StatefulWidget {
  final PageController pageController;

  const Thunder({super.key, required this.pageController});

  @override
  State<Thunder> createState() => _ThunderState();
}

class _ThunderState extends State<Thunder> {
  int selectedPageIndex = 0;
  int appExitCounter = 0;

  bool hasShownUpdateDialog = false;
  bool hasShownChangelogDialog = false;

  bool _isFabOpen = false;

  bool reduceAnimations = false;

  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();

  late final StreamSubscription mediaIntentDataStreamSubscription;

  late final StreamSubscription textIntentDataStreamSubscription;

  final ScrollController _changelogScrollController = ScrollController();

  bool errorMessageLoading = false;

  @override
  void initState() {
    super.initState();

    selectedPageIndex = widget.pageController.initialPage;

    // Listen for callbacks from Android native code
    if (!kIsWeb && Platform.isAndroid) {
      const MethodChannel('com.hjiangsu.thunder/method_channel').setMethodCallHandler((MethodCall call) {
        if (call.method == 'set_intent') {
          currentIntent = call.arguments;
        }
        return Future.value(null);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      handleSharedFilesAndText();
      if (Platform.isAndroid || Platform.isIOS) {
        BlocProvider.of<DeepLinksCubit>(context).handleIncomingLinks();
        BlocProvider.of<DeepLinksCubit>(context).handleInitialURI();
        BlocProvider.of<NotificationsCubit>(context).handleNotifications();
      }
    });

    BackButtonInterceptor.add(_handleBackButtonPress);
  }

  @override
  void dispose() {
    textIntentDataStreamSubscription.cancel();
    mediaIntentDataStreamSubscription.cancel();
    BackButtonInterceptor.remove(_handleBackButtonPress);
    super.dispose();
  }

  // Handle sharing media (image/text/url)
  void handleSharedFilesAndText() async {
    try {
      // For sharing files from outside the app while the app is closed
      List<SharedFile> sharedFiles = await FlutterSharingIntent.instance.getInitialSharing();
      if (sharedFiles.isNotEmpty && currentIntent != ANDROID_INTENT_ACTION_VIEW) handleSharedItems(sharedFiles.first);

      // For sharing files while the app is in the memory
      mediaIntentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream().listen((List<SharedFile> sharedFiles) {
        if (!context.mounted || sharedFiles.isEmpty || currentIntent == ANDROID_INTENT_ACTION_VIEW) return;
        handleSharedItems(sharedFiles.first);
      });
    } catch (e) {
      if (context.mounted) showSnackbar(AppLocalizations.of(context)!.unexpectedError);
    }
  }

  void handleSharedItems(SharedFile sharedFile) {
    switch (sharedFile.type) {
      case SharedMediaType.IMAGE:
        navigateToCreatePostPage(context, image: File(sharedFile.value!), prePopulated: true);
        break;
      case SharedMediaType.URL:
        navigateToCreatePostPage(context, url: sharedFile.value!, prePopulated: true);
        break;
      case SharedMediaType.TEXT:
        navigateToCreatePostPage(context, text: sharedFile.value, prePopulated: true);
        break;
      default:
        break;
    }
  }

  void _showExitWarning() {
    showSnackbar(
      AppLocalizations.of(context)!.tapToExit,
      duration: const Duration(milliseconds: 3500),
    );
  }

  FutureOr<bool> _handleBackButtonPress(bool stopDefaultButtonEvent, RouteInfo info) async {
    final bool topOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (!topOfNavigationStack) return false;
    if (stopDefaultButtonEvent) return false;

    if (selectedPageIndex != 0) {
      setState(() {
        selectedPageIndex = 0;
        widget.pageController.jumpToPage(selectedPageIndex);
      });
      return true;
    }

    // If any modal is open (i.e., community drawer) close it now
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return true;
    }

    if (_isFabOpen == true) {
      return true;
    }

    if (appExitCounter == 0) {
      appExitCounter++;
      _showExitWarning();
      Timer(const Duration(milliseconds: 3500), () {
        appExitCounter = 0;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<void> _handleDeepLinkNavigation(
    BuildContext context, {
    required LinkType linkType,
    String? link,
  }) async {
    // Start by retrieving the active account, if any, and setting the Lemmy base domain
    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    String? activeProfileId = prefs.getString('active_profile_id');
    List<Account> accounts = await Account.accounts();
    Account? activeAccount = accounts.firstWhereOrNull((Account account) => account.id == activeProfileId);

    if (activeAccount?.username != null && activeAccount?.jwt != null && activeAccount?.instance != null) {
      // Set lemmy client to use the instance
      LemmyClient.instance.changeBaseUrl(activeAccount!.instance!.replaceAll('https://', ''));
    }

    // If the incoming link is a custom URL, replace it back with https://
    link = link?.replaceAll('thunder://', 'https://') ?? "";

    switch (linkType) {
      case LinkType.comment:
        if (context.mounted) await _navigateToComment(link);
      case LinkType.user:
        if (context.mounted) await _navigateToUser(link);
      case LinkType.post:
        if (context.mounted) await _navigateToPost(link);
      case LinkType.community:
        if (context.mounted) await _navigateToCommunity(link);
      case LinkType.modlog:
        if (context.mounted) await _navigateToModlog(link);
      case LinkType.instance:
        if (context.mounted) await _navigateToInstance(link);
      case LinkType.thunder:
        if (context.mounted) await _navigateToInternal(link);
      case LinkType.unknown:
        if (context.mounted) {
          _showLinkProcessingError(context, AppLocalizations.of(context)!.uriNotSupported, link);
        }
    }
  }

  Future<void> _navigateToInstance(String link) async {
    try {
      await navigateToInstancePage(
        context,
        instanceHost: link.replaceAll(RegExp(r'https?:\/\/'), '').replaceAll('/', ''),
        // We have no context here to determine what the id of this instance would be on our server.
        // It just means we can't block through this flow, which is ok.
        instanceId: null,
      );
    } catch (e) {
      if (context.mounted) {
        _showLinkProcessingError(context, AppLocalizations.of(context)!.exceptionProcessingUri, link);
      }
    }
  }

  Future<void> _navigateToPost(String link) async {
    final postId = await getLemmyPostId(context, link);
    if (context.mounted && postId != null) {
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
      Account? account = await fetchActiveProfileAccount();

      try {
        GetPostResponse fullPostView = await lemmy.run(GetPost(
          id: postId,
          auth: account?.jwt,
        ));
        if (context.mounted) {
          navigateToPost(context, postViewMedia: (await parsePostViews([fullPostView.postView])).first);
          return;
        }
      } catch (e) {
        // Ignore exception, if it's not a valid comment, we'll perform the next fallback
      }
    }

    // postId not found or could not resolve link.
    // show a snackbar with option to open link
    if (context.mounted) {
      _showLinkProcessingError(context, AppLocalizations.of(context)!.exceptionProcessingUri, link);
    }
  }

  Future<void> _navigateToCommunity(String link) async {
    final String? communityName = await getLemmyCommunity(link);
    if (context.mounted && communityName != null) {
      try {
        await navigateToFeedPage(context, feedType: FeedType.community, communityName: communityName);
        return;
      } catch (e) {
        // Ignore exception, if it's not a valid community, we'll perform the next fallback
      }
    }

    // community not found or could not resolve link.
    // show a snackbar with option to open link
    if (context.mounted) {
      _showLinkProcessingError(context, AppLocalizations.of(context)!.exceptionProcessingUri, link);
    }
  }

  Future<void> _navigateToModlog(String link) async {
    try {
      Uri? uri = Uri.tryParse(link);
      if (uri != null) {
        final LemmyClient lemmyClient = LemmyClient()..changeBaseUrl(uri.host);
        FeedBloc feedBloc = FeedBloc(lemmyClient: lemmyClient);
        await navigateToModlogPage(
          context,
          feedBloc: feedBloc,
          modlogActionType: ModlogActionType.fromJson(uri.queryParameters['actionType'] ?? ModlogActionType.all.value),
          communityId: int.tryParse(uri.queryParameters['communityId'] ?? ''),
          userId: int.tryParse(uri.queryParameters['userId'] ?? ''),
          moderatorId: int.tryParse(uri.queryParameters['modId'] ?? ''),
          lemmyClient: lemmyClient,
        );
        return;
      }
    } catch (e) {}

    // Show an error for any issues processing the link
    if (context.mounted) {
      _showLinkProcessingError(context, AppLocalizations.of(context)!.exceptionProcessingUri, link);
    }
  }

  Future<void> _navigateToComment(String link) async {
    final commentId = await getLemmyCommentId(context, link);
    if (context.mounted && commentId != null) {
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
      Account? account = await fetchActiveProfileAccount();

      try {
        CommentResponse fullCommentView = await lemmy.run(GetComment(
          id: commentId,
          auth: account?.jwt,
        ));
        if (context.mounted) {
          navigateToComment(context, fullCommentView.commentView);
          return;
        }
      } catch (e) {
        // Ignore exception, if it's not a valid comment, we'll perform the next fallback
      }
    }

    // commentId not found or could not resolve link.
    // show a snackbar with option to open link
    if (context.mounted) {
      _showLinkProcessingError(context, AppLocalizations.of(context)!.exceptionProcessingUri, link);
    }
  }

  Future<void> _navigateToUser(String link) async {
    final String? username = await getLemmyUser(link);
    if (context.mounted && username != null) {
      try {
        await navigateToFeedPage(context, feedType: FeedType.user, username: username);
        return;
      } catch (e) {
        // Ignore exception, if it's not a valid comment, we'll perform the next fallback
      }
    }

    if (context.mounted) {
      _showLinkProcessingError(context, AppLocalizations.of(context)!.exceptionProcessingUri, link);
    }
  }

  Future<void> _navigateToInternal(String link) async {
    link = link.replaceFirst('https://', '');
    if (link.startsWith('setting-')) {
      String setting = link.replaceFirst('setting-', '');
      navigateToSetting(context, LocalSettings.values.firstWhere((localSetting) => localSetting.name == setting));
    }
  }

  void _showLinkProcessingError(BuildContext context, String error, String link) {
    showSnackbar(
      error,
      trailingIcon: Icons.open_in_browser_rounded,
      duration: const Duration(seconds: 10),
      trailingAction: () => handleLink(context, url: link),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InboxBloc()),
        BlocProvider(create: (context) => SearchBloc()),
        BlocProvider(create: (context) => FeedBloc(lemmyClient: LemmyClient.instance)),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotificationsCubit, NotificationsState>(
            listener: (context, state) {
              if (state.status == NotificationsStatus.reply) {
                navigateToNotificationReplyPage(context, replyId: state.replyId, accountId: state.accountId);
              }
            },
          ),
          BlocListener<DeepLinksCubit, DeepLinksState>(
            listener: (context, state) {
              switch (state.deepLinkStatus) {
                case DeepLinkStatus.loading:
                  return;
                case DeepLinkStatus.empty:
                  showSnackbar(state.error ?? l10n.emptyUri);
                case DeepLinkStatus.error:
                  showSnackbar(state.error ?? l10n.exceptionProcessingUri);

                case DeepLinkStatus.success:
                  try {
                    _handleDeepLinkNavigation(context, linkType: state.linkType, link: state.link);
                  } catch (e) {
                    _showLinkProcessingError(context, AppLocalizations.of(context)!.uriNotSupported, state.link!);
                  }

                case DeepLinkStatus.unknown:
                  showSnackbar(state.error ?? l10n.uriNotSupported);
              }
            },
          ),
        ],
        child: BlocBuilder<ThunderBloc, ThunderState>(
          builder: (context, thunderBlocState) {
            reduceAnimations = thunderBlocState.reduceAnimations;

            switch (thunderBlocState.status) {
              case ThunderStatus.initial:
                context.read<ThunderBloc>().add(InitializeAppEvent());
                return Container();
              case ThunderStatus.loading:
                return Container();
              case ThunderStatus.refreshing:
              case ThunderStatus.success:
                FlutterNativeSplash.remove();

                // Update the variable so that it can be used in _handleBackButtonPress
                _isFabOpen = thunderBlocState.isFabOpen;

                return Scaffold(
                  key: scaffoldStateKey,
                  drawer: selectedPageIndex == 0
                      ? CommunityDrawer(
                          navigateToAccount: () {
                            Navigator.of(context).pop();
                            widget.pageController.jumpToPage(2);
                          },
                        )
                      : null,
                  floatingActionButton: thunderBlocState.enableFeedsFab
                      ? AnimatedOpacity(
                          opacity: selectedPageIndex == 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeIn,
                          child: IgnorePointer(ignoring: selectedPageIndex != 0, child: const FeedFAB()),
                        )
                      : null,
                  floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
                  bottomNavigationBar: CustomBottomNavigationBar(
                    selectedPageIndex: selectedPageIndex,
                    onPageChange: (int index) {
                      setState(() {
                        selectedPageIndex = index;
                        widget.pageController.jumpToPage(index);
                      });
                    },
                  ),
                  body: BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (AuthState previous, AuthState current) {
                      if (previous.isLoggedIn != current.isLoggedIn || previous.status == AuthStatus.initial) return true;
                      return false;
                    },
                    buildWhen: (previous, current) => current.status != AuthStatus.failure && current.status != AuthStatus.loading,
                    listener: (context, state) {
                      // Although the buildWhen delegate exlcudes this state,
                      // there seems to be a timing issue where we can end up here anyway.
                      // So just return.
                      if (state.status == AuthStatus.loading) return;

                      context.read<AccountBloc>().add(RefreshAccountInformation(reload: state.reload));

                      // If we have not been requested to reload, don't!
                      if (!state.reload) return;

                      // Add a bit of artificial delay to allow preferences to set the proper active profile
                      Future.delayed(const Duration(milliseconds: 500), () => context.read<InboxBloc>().add(const GetInboxEvent(reset: true)));
                      if (context.read<FeedBloc>().state.status != FeedStatus.initial) {
                        context.read<FeedBloc>().add(
                              FeedFetchedEvent(
                                feedType: FeedType.general,
                                postListingType: thunderBlocState.defaultListingType,
                                sortType: thunderBlocState.sortTypeForInstance,
                                reset: true,
                              ),
                            );
                      }
                    },
                    builder: (context, state) {
                      switch (state.status) {
                        case AuthStatus.initial:
                          context.read<AuthBloc>().add(CheckAuth());
                          return Scaffold(
                            appBar: AppBar(),
                            body: Center(
                              child: Container(),
                            ),
                          );
                        case AuthStatus.success:
                          Version? version = thunderBlocState.version;
                          bool showInAppUpdateNotification = thunderBlocState.showInAppUpdateNotification;

                          if (version?.hasUpdate == true && hasShownUpdateDialog == false && showInAppUpdateNotification == true) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showUpdateNotification(context, version);
                              setState(() => hasShownUpdateDialog = true);
                            });
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            if (hasShownChangelogDialog) return;

                            // Only ever come in here once per run
                            hasShownChangelogDialog = true;

                            // Check the last known version and the current version.
                            // If the last known version is not null (meaning we've run before)
                            // and the current version is different (meaning we've updated)
                            // show the changelog (if we are configured to do so).
                            SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
                            String? lastKnownVersion = prefs.getString('current_version');
                            String currentVersion = getCurrentVersion(removeInternalBuildNumber: true, trimV: true);

                            // Immediately update the current version for next time.
                            prefs.setString('current_version', currentVersion);

                            if (lastKnownVersion != null && lastKnownVersion != currentVersion && thunderBlocState.showUpdateChangelogs) {
                              final String changelog = await fetchCurrentVersionChangelog();

                              if (context.mounted) {
                                showModalBottomSheet(
                                  context: context,
                                  showDragHandle: true,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    bool isChangelogExpanded = false;

                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AnimatedSize(
                                          alignment: Alignment.bottomCenter,
                                          duration: const Duration(milliseconds: 100),
                                          child: FractionallySizedBox(
                                            heightFactor: isChangelogExpanded ? 0.9 : 0.6,
                                            child: Container(
                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 26.0, right: 16.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      l10n.thunderHasBeenUpdated(currentVersion),
                                                      style: theme.textTheme.titleLarge,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24.0),
                                                  Expanded(
                                                    child: FadingEdgeScrollView.fromSingleChildScrollView(
                                                      gradientFractionOnStart: 0.1,
                                                      gradientFractionOnEnd: 0.1,
                                                      child: SingleChildScrollView(
                                                        controller: _changelogScrollController,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: [
                                                            CommonMarkdownBody(body: changelog),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16.0),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                          prefs.setBool(LocalSettings.showUpdateChangelogs.name, false);
                                                        },
                                                        child: Text(l10n.doNotShowAgain),
                                                      ),
                                                      const SizedBox(width: 6.0),
                                                      FilledButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: Text(l10n.close),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            }
                          });

                          return PageView(
                            controller: widget.pageController,
                            onPageChanged: (index) => setState(() => selectedPageIndex = index),
                            physics: const NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              FeedPage(
                                useGlobalFeedBloc: true,
                                feedType: FeedType.general,
                                postListingType: thunderBlocState.defaultListingType,
                                sortType: thunderBlocState.sortTypeForInstance,
                                scaffoldStateKey: scaffoldStateKey,
                              ),
                              const SearchPage(),
                              const AccountPage(),
                              const InboxPage(),
                              const SettingsPage(),
                            ],
                          );

                        // Should never hit these, they're handled by the login page
                        case AuthStatus.failure:
                        case AuthStatus.loading:
                          return Container();
                        case AuthStatus.failureCheckingInstance:
                          showSnackbar(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage);
                          errorMessageLoading = false;
                          return StatefulBuilder(
                            builder: (context, setState) => ErrorMessage(
                              title: AppLocalizations.of(context)!.unableToLoadInstance(LemmyClient.instance.lemmyApiV3.host),
                              message: AppLocalizations.of(context)!.internetOrInstanceIssues,
                              actions: [
                                (
                                  text: AppLocalizations.of(context)!.retry,
                                  action: () {
                                    context.read<AuthBloc>().add(CheckAuth());
                                    setState(() => errorMessageLoading = true);
                                  },
                                  loading: errorMessageLoading,
                                ),
                                (
                                  text: AppLocalizations.of(context)!.accountSettings,
                                  action: () => showProfileModalSheet(context),
                                  loading: false,
                                ),
                              ],
                            ),
                          );
                      }
                    },
                  ),
                );
              case ThunderStatus.failure:
                FlutterNativeSplash.remove();
                return ErrorMessage(
                  message: thunderBlocState.errorMessage,
                  actions: [
                    (
                      text: AppLocalizations.of(context)!.refreshContent,
                      action: () => context.read<AuthBloc>().add(CheckAuth()),
                      loading: false,
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  // Update notification
  void showUpdateNotification(BuildContext context, Version? version) {
    final theme = Theme.of(context);

    showSimpleNotification(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.updateReleased(version?.latestVersion ?? ''),
              style: theme.textTheme.titleMedium,
            ),
            Icon(
              Icons.arrow_forward,
              color: theme.colorScheme.onBackground,
            ),
          ],
        ),
        onTap: () {
          handleLink(context, url: version?.latestVersionUrl ?? 'https://github.com/thunder-app/thunder/releases');
        },
      ),
      background: theme.cardColor,
      autoDismiss: true,
      duration: const Duration(seconds: 5),
      slideDismissDirection: DismissDirection.vertical,
    );
  }
}
