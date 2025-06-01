import 'dart:async';
import 'dart:io';

// Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:thunder/localizations/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

// Internal
import 'package:thunder/account/account.dart';
import 'package:thunder/community/widgets/community_drawer.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/thunder/utils/deep_link.dart';
import 'package:thunder/thunder/utils/share_intent_handler.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/cubits/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/thunder/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:thunder/thunder/widgets/bottom_nav_bar.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/inbox/inbox.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/search/pages/search_page.dart';
import 'package:thunder/settings/pages/settings_page.dart';
import 'package:thunder/shared/error_message.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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
  bool hasShownPageView = false;

  bool _isFabOpen = false;

  bool reduceAnimations = false;

  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();

  ShareIntentHandler? _shareIntentHandler;

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
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _shareIntentHandler = ShareIntentHandler(context);
        _shareIntentHandler?.handleSharedFilesAndText(currentIntent);
      }

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
        BlocProvider.of<DeepLinksCubit>(context).initialize();
        BlocProvider.of<NotificationsCubit>(context).handleNotifications();
      }
    });

    BackButtonInterceptor.add(_handleBackButtonPress);
  }

  @override
  void dispose() {
    _shareIntentHandler?.dispose();
    BackButtonInterceptor.remove(_handleBackButtonPress);
    super.dispose();
  }

  void _showExitWarning() {
    showSnackbar(
      AppLocalizations.of(context)!.tapToExit,
      duration: const Duration(milliseconds: 3500),
      closable: false,
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
                    handleDeepLinkNavigation(context, linkType: state.linkType, link: state.link);
                  } catch (e) {
                    showNavigationError(context, AppLocalizations.of(context)!.uriNotSupported, state.link!);
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
                  body: BlocConsumer<ProfileBloc, ProfileState>(
                    listenWhen: (ProfileState previous, ProfileState current) {
                      if (previous.isLoggedIn != current.isLoggedIn || previous.status == ProfileStatus.initial) return true;
                      return false;
                    },
                    buildWhen: (previous, current) {
                      // Don't rebuild on ProfileStatus.initial after we've shown the PageView once. This prevents PageView rebuilds during profile switching
                      if (current.status == ProfileStatus.initial && hasShownPageView) {
                        return false;
                      }
                      return current.status != ProfileStatus.failure && current.status != ProfileStatus.loading;
                    },
                    listener: (context, state) {
                      // Although the buildWhen delegate exlcudes this state,
                      // there seems to be a timing issue where we can end up here anyway.
                      // So just return.
                      if (state.status == ProfileStatus.loading) return;

                      // If we have not been requested to reload, don't!
                      if (!state.reload) return;

                      // Add a bit of artificial delay to allow preferences to set the proper active profile
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (context.mounted) context.read<InboxBloc>().add(const GetInboxEvent(reset: true));
                      });

                      if (context.read<FeedBloc>().state.status != FeedStatus.initial) {
                        context.read<FeedBloc>().add(
                              FeedFetchedEvent(
                                feedType: FeedType.general,
                                feedListType: FeedListType.fromLemmyType(state.getSiteResponse?.myUser?.localUserView.localUser.defaultListingType) ?? thunderBlocState.defaultFeedListType,
                                sortType: state.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderBlocState.sortTypeForInstance,
                                reset: true,
                                showHidden: thunderBlocState.showHiddenPosts,
                              ),
                            );
                      }
                    },
                    builder: (context, state) {
                      switch (state.status) {
                        case ProfileStatus.initial:
                          context.read<ProfileBloc>().add(InitializeAuth());
                          return Scaffold(
                            appBar: AppBar(toolbarHeight: 70.0),
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case ProfileStatus.contentWarning:
                        case ProfileStatus.success:
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
                            final prefs = UserPreferences.instance.preferences;
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

                          hasShownPageView = true; // Set to true to prevent PageView rebuilds during profile switching

                          return PageView(
                            controller: widget.pageController,
                            onPageChanged: (index) => setState(() => selectedPageIndex = index),
                            physics: const NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              FeedPage(
                                useGlobalFeedBloc: true,
                                feedType: FeedType.general,
                                feedListType: FeedListType.fromLemmyType(state.getSiteResponse?.myUser?.localUserView.localUser.defaultListingType) ?? thunderBlocState.defaultFeedListType,
                                sortType: state.getSiteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderBlocState.sortTypeForInstance,
                                scaffoldStateKey: scaffoldStateKey,
                                showHidden: thunderBlocState.showHiddenPosts,
                              ),
                              const SearchPage(),
                              const AccountPage(),
                              const InboxPage(),
                              const SettingsPage(),
                            ],
                          );

                        // Should never hit these, they're handled by the login page
                        case ProfileStatus.failure:
                        case ProfileStatus.loading:
                          return Container();
                        case ProfileStatus.failureCheckingInstance:
                          showSnackbar(state.error ?? AppLocalizations.of(context)!.missingErrorMessage);
                          errorMessageLoading = false;
                          return StatefulBuilder(
                            builder: (context, setState) => ErrorMessage(
                              title: AppLocalizations.of(context)!.unableToLoadInstance(LemmyClient.instance.lemmyApiV3.host),
                              message: AppLocalizations.of(context)!.internetOrInstanceIssues,
                              actions: [
                                (
                                  text: AppLocalizations.of(context)!.retry,
                                  action: () {
                                    context.read<ProfileBloc>().add(InitializeAuth());
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
                      action: () => context.read<ProfileBloc>().add(InitializeAuth()),
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
              color: theme.colorScheme.onSurface,
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
