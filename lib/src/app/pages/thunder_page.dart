import 'dart:async';
import 'dart:io';

// Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

// Internal
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/core/update/check_github_update.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/app/routing/deep_link.dart';
import 'package:thunder/src/app/utils/share_intent_handler.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/app/cubits/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/src/app/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:thunder/src/app/cubits/gesture_preferences_cubit/gesture_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/feed_preferences_cubit/feed_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/comment_preferences_cubit/comment_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/video_preferences_cubit/video_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/fab_preferences_cubit/fab_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/fab_cubit/fab_cubit.dart';
import 'package:thunder/src/app/cubits/nav_bar_state_cubit/nav_bar_state_cubit.dart';
import 'package:thunder/src/app/widgets/bottom_nav_bar.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/core/models/version.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/shared/error_message.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';

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

      // Check for pending notification navigation after account switch
      _checkPendingNotification();
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

  void _navigateToNotification(BuildContext context, NotificationsState state) {
    switch (state.status) {
      case NotificationsStatus.reply:
        navigateToNotificationPage(context, inboxType: InboxType.replies, notificationId: state.notificationId, accountId: state.accountId);
        break;
      case NotificationsStatus.mention:
        navigateToNotificationPage(context, inboxType: InboxType.mentions, notificationId: state.notificationId, accountId: state.accountId);
        break;
      case NotificationsStatus.message:
        navigateToNotificationPage(context, inboxType: InboxType.messages, notificationId: state.notificationId, accountId: state.accountId);
        break;
      case NotificationsStatus.none:
        break;
    }
  }

  /// Checks for pending notification navigation after account switch.
  void _checkPendingNotification() {
    final cubit = context.read<NotificationsCubit>();
    final state = cubit.state;

    if (state.pending && state.status != NotificationsStatus.none) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _navigateToNotification(context, state);
          cubit.clearNotification();
        }
      });
    }
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

    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationsCubit, NotificationsState>(
          listenWhen: (previous, current) {
            final shouldListen = current.status != NotificationsStatus.none && !current.pending;
            return shouldListen;
          },
          listener: (context, state) {
            final currentAccountId = context.read<ProfileBloc>().state.account.id;
            final notificationAccountId = state.accountId;

            // Check if we need to switch accounts first
            if (notificationAccountId != null && notificationAccountId != currentAccountId) {
              // Mark as pending navigation and switch accounts
              context.read<NotificationsCubit>().setPending();
              context.read<ProfileBloc>().add(SwitchProfile(accountId: notificationAccountId, reload: true));
              return;
            }

            // Navigate directly and clear notification state
            _navigateToNotification(context, state);
            context.read<NotificationsCubit>().clearNotification();
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
        BlocListener<ThunderBloc, ThunderState>(
          listenWhen: (previous, current) => previous.status != current.status && current.status == ThunderStatus.success,
          listener: (context, state) {
            // Reload preference cubits when preferences change
            context.read<GesturePreferencesCubit>().reload();
            context.read<FeedPreferencesCubit>().reload();
            context.read<CommentPreferencesCubit>().reload();
            context.read<ThemePreferencesCubit>().reload();
            context.read<VideoPreferencesCubit>().reload();
            context.read<FabPreferencesCubit>().reload();
          },
        ),
      ],
      child: BlocBuilder<ThunderBloc, ThunderState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, thunderBlocState) {
          reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;

          switch (thunderBlocState.status) {
            case ThunderStatus.initial:
              context.read<ThunderBloc>().add(InitializeAppEvent());
              return Container();
            case ThunderStatus.loading:
              return Container();
            case ThunderStatus.refreshing:
            case ThunderStatus.success:
              // Update the variable so that it can be used in _handleBackButtonPress
              _isFabOpen = context.read<FabStateCubit>().state.isFeedFabOpen;

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
                floatingActionButton: context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableFeedsFab)
                    ? AnimatedOpacity(
                        opacity: selectedPageIndex == 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeIn,
                        child: IgnorePointer(ignoring: selectedPageIndex != 0, child: const FeedFAB()),
                      )
                    : null,
                floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
                bottomNavigationBar: Builder(
                  builder: (context) {
                    final reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;
                    final hideBottomBarOnScroll = context.read<ThunderBloc>().state.hideBottomBarOnScroll;
                    return AnimatedSize(
                      duration: Duration(milliseconds: reduceAnimations ? 0 : 200),
                      curve: Curves.easeInOut,
                      clipBehavior: Clip.hardEdge,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: (hideBottomBarOnScroll && !context.select<NavBarStateCubit, bool>((cubit) => cubit.state.isBottomNavBarVisible)) ? 0 : null,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: reduceAnimations ? 0 : 150),
                          curve: Curves.easeOut,
                          opacity: (hideBottomBarOnScroll && !context.select<NavBarStateCubit, bool>((cubit) => cubit.state.isBottomNavBarVisible)) ? 0.0 : 1.0,
                          child: CustomBottomNavigationBar(
                            selectedPageIndex: selectedPageIndex,
                            onPageChange: (int index) {
                              // Reset bottom nav bar visibility when switching pages
                              if (hideBottomBarOnScroll && !context.read<NavBarStateCubit>().state.isBottomNavBarVisible) {
                                context.read<NavBarStateCubit>().setBottomNavBarVisible(true);
                              }
                              setState(() {
                                selectedPageIndex = index;
                                widget.pageController.jumpToPage(index);
                              });
                            },
                          ),
                        ),
                      ),
                    );
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
                    if (context.mounted) context.read<InboxBloc>().add(const GetInboxEvent(reset: true));

                    if (context.read<FeedBloc>().state.status != FeedStatus.initial) {
                      final feedCubit = context.read<FeedPreferencesCubit>();
                      context.read<FeedBloc>().add(
                            FeedFetchedEvent(
                              feedType: FeedType.general,
                              feedListType: state.siteResponse?.myUser?.localUserView.localUser.defaultListingType ?? feedCubit.state.defaultFeedListType,
                              postSortType: state.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType,
                              reset: true,
                              showHidden: feedCubit.state.showHiddenPosts,
                            ),
                          );
                    }
                  },
                  builder: (context, state) {
                    switch (state.status) {
                      case ProfileStatus.initial:
                        return Scaffold(
                          appBar: AppBar(toolbarHeight: APP_BAR_HEIGHT),
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
                                  return FractionallySizedBox(
                                    heightFactor: 0.8,
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
                            Builder(
                              builder: (context) {
                                final feedCubit = context.read<FeedPreferencesCubit>();
                                return FeedPage(
                                  useGlobalFeedBloc: true,
                                  feedType: FeedType.general,
                                  feedListType: state.siteResponse?.myUser?.localUserView.localUser.defaultListingType ?? feedCubit.state.defaultFeedListType,
                                  postSortType: state.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType,
                                  scaffoldStateKey: scaffoldStateKey,
                                  showHidden: feedCubit.state.showHiddenPosts,
                                );
                              },
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
                            title: AppLocalizations.of(context)!.unableToLoadInstance(state.account.instance),
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
