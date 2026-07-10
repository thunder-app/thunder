import 'dart:async';
import 'dart:io';

// Flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter/services.dart';

// Packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

// Internal
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/shell/shell_chrome_cubit.dart';
import 'package:thunder/src/core/shell/thunder_tab_view.dart';
import 'package:thunder/src/core/shell/update_prompts.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/app_version_service.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/core/navigation/deep_link.dart';
import 'package:thunder/src/core/app/share_intent_handler.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/core/state/deep_links_cubit.dart';
import 'package:thunder/src/features/notification/application/state/notifications_cubit.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/core/shell/bottom_nav_bar.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/core/state/app_version_cubit.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/services/preferences_store.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

class Thunder extends StatefulWidget {
  final PageController pageController;

  const Thunder({super.key, required this.pageController});

  @override
  State<Thunder> createState() => _ThunderState();
}

class _ThunderState extends State<Thunder> {
  final FeedActionController _rootFeedActionController = FeedActionController();

  int selectedPageIndex = 0;
  int appExitCounter = 0;

  bool hasShownChangelogDialog = false;
  bool hasShownPageView = false;

  bool _isFabOpen = false;
  bool _hasAttemptedDraftRestore = false;
  String? _currentIntent;

  bool reduceAnimations = false;

  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();

  ShareIntentHandler? _shareIntentHandler;

  final ScrollController _changelogScrollController = ScrollController();

  bool errorMessageLoading = false;

  final DraftRepository _draftRepository = createDraftRepository();
  final UpdateNotificationCoordinator _updateNotificationCoordinator = UpdateNotificationCoordinator();

  @override
  void initState() {
    super.initState();

    selectedPageIndex = widget.pageController.initialPage;

    // Listen for callbacks from Android native code
    if (!kIsWeb && Platform.isAndroid) {
      const MethodChannel('com.hjiangsu.thunder/method_channel').setMethodCallHandler((MethodCall call) {
        if (call.method == 'set_intent') {
          _currentIntent = call.arguments;
        }
        return Future.value(null);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _shareIntentHandler = ShareIntentHandler(context);
        _shareIntentHandler?.handleSharedFilesAndText(_currentIntent);
      }

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
        BlocProvider.of<DeepLinksCubit>(context).initialize();
        BlocProvider.of<NotificationsCubit>(context).handleNotifications();
      }

      // Check for pending notification navigation after account switch
      _checkPendingNotification();

      context.read<AppVersionCubit>().checkForUpdate();
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
    showThunderSnackbar(
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

  void _restoreDraftSession(ProfileState profileState) {
    if (_hasAttemptedDraftRestore) {
      return;
    }

    _hasAttemptedDraftRestore = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final launchedFromExternalIntent = _currentIntent == ANDROID_INTENT_ACTION_VIEW || _currentIntent == 'android.intent.action.SEND' || _currentIntent == 'android.intent.action.SEND_MULTIPLE';

      if (!mounted || launchedFromExternalIntent) {
        return;
      }

      if (Navigator.of(context).canPop()) {
        return;
      }

      await restoreActiveDraftSession(
        repository: _draftRepository,
        account: profileState.account,
        onPostCreateRestore: (account, communityId, community) async {
          if (!mounted || Navigator.of(context).canPop()) {
            return;
          }

          await navigateToCreatePostPage(context, account: account, communityId: communityId, community: community);
        },
        onPostEditRestore: (account, post) async {
          if (!mounted || Navigator.of(context).canPop()) {
            return;
          }

          await navigateToCreatePostPage(context, account: account, post: post);
        },
        onCommentCreateFromPostRestore: (account, post) async {
          if (!mounted || Navigator.of(context).canPop()) {
            return;
          }

          await navigateToCreateCommentPage(context, account: account, post: post);
        },
        onCommentCreateFromCommentRestore: (account, comment) async {
          if (!mounted || Navigator.of(context).canPop()) {
            return;
          }

          await navigateToCreateCommentPage(context, account: account, parentComment: comment);
        },
        onCommentEditRestore: (account, comment) async {
          if (!mounted || Navigator.of(context).canPop()) {
            return;
          }

          await navigateToCreateCommentPage(context, account: account, comment: comment);
        },
      );
    });
  }

  void _maybeShowUpdateNotification() {
    if (!mounted) return;

    final profileStatus = context.read<ProfileBloc>().state.status;
    final version = _updateNotificationCoordinator.nextNotification(
      version: context.read<AppVersionCubit>().state.version,
      profileIsUsable: profileStatus == ProfileStatus.success || profileStatus == ProfileStatus.contentWarning,
      enabled: context.read<ThunderCubit>().state.showInAppUpdateNotification,
    );

    if (version == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showUpdateNotification(context, version);
    });
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
            final currentAccountId = context.read<SessionBloc>().state.activeAccount?.id;
            final notificationAccountId = state.accountId;

            // Check if we need to switch accounts first
            if (notificationAccountId != null && notificationAccountId != currentAccountId) {
              // Mark as pending navigation and switch accounts
              context.read<NotificationsCubit>().setPending();
              context.read<SessionBloc>().add(SessionSwitched(sessionKey: notificationAccountId));
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
                showThunderSnackbar(state.error ?? l10n.emptyUri);
              case DeepLinkStatus.error:
                showThunderSnackbar(state.error ?? l10n.exceptionProcessingUri);

              case DeepLinkStatus.success:
                try {
                  handleDeepLinkNavigation(context, linkType: state.linkType, link: state.link);
                } catch (e) {
                  showNavigationError(context, AppLocalizations.of(context)!.uriNotSupported, state.link!);
                }

              case DeepLinkStatus.unknown:
                showThunderSnackbar(state.error ?? l10n.uriNotSupported);
            }
          },
        ),
        BlocListener<AppVersionCubit, AppVersionState>(
          listenWhen: (previous, current) => previous.status != current.status && current.status == AppVersionStatus.success,
          listener: (context, state) => _maybeShowUpdateNotification(),
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) => previous.status != current.status && (current.status == ProfileStatus.success || current.status == ProfileStatus.contentWarning),
          listener: (context, state) => _maybeShowUpdateNotification(),
        ),
        BlocListener<ThunderCubit, ThunderState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, state) {
            // Reload preference cubits when preferences change
            context.read<GesturePreferencesCubit>().reload();
            context.read<FeedPreferencesCubit>().reload();
            context.read<CommentPreferencesCubit>().reload();
            context.read<ThemePreferencesCubit>().reload();
            context.read<VideoPreferencesCubit>().reload();
            context.read<FabPreferencesCubit>().reload();
            _maybeShowUpdateNotification();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;
          final thunderState = context.watch<ThunderCubit>().state;

          // Update the variable so that it can be used in _handleBackButtonPress
          _isFabOpen = context.read<ShellChromeCubit>().state.isFeedFabOpen;

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
                    child: IgnorePointer(ignoring: selectedPageIndex != 0, child: FeedFAB(actionController: _rootFeedActionController)),
                  )
                : null,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            bottomNavigationBar: Builder(
              builder: (context) {
                final reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;
                final hideBottomBarOnScroll = thunderState.hideBottomBarOnScroll;
                return AnimatedSize(
                  duration: Duration(milliseconds: reduceAnimations ? 0 : 200),
                  curve: Curves.easeInOut,
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: (hideBottomBarOnScroll && !context.select<ShellChromeCubit, bool>((cubit) => cubit.state.isBottomNavBarVisible)) ? 0 : null,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: reduceAnimations ? 0 : 150),
                      curve: Curves.easeOut,
                      opacity: (hideBottomBarOnScroll && !context.select<ShellChromeCubit, bool>((cubit) => cubit.state.isBottomNavBarVisible)) ? 0.0 : 1.0,
                      child: BottomNavigationBar(
                        feedActionController: _rootFeedActionController,
                        selectedPageIndex: selectedPageIndex,
                        onPageChange: (int index) {
                          // Reset bottom nav bar visibility when switching pages
                          if (hideBottomBarOnScroll && !context.read<ShellChromeCubit>().state.isBottomNavBarVisible) {
                            context.read<ShellChromeCubit>().setBottomNavBarVisible(true);
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
                if (previous.isLoggedIn != current.isLoggedIn || previous.status == ProfileStatus.initial) {
                  return true;
                }
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
                if (context.mounted) {
                  context.read<InboxBloc>().add(const GetInboxEvent(reset: true));
                }

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
                    _restoreDraftSession(state);

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (hasShownChangelogDialog) return;

                      // Only ever come in here once per run
                      hasShownChangelogDialog = true;

                      // Check the last known version and the current version.
                      // If the last known version is not null (meaning we've run before)
                      // and the current version is different (meaning we've updated)
                      // show the changelog (if we are configured to do so).
                      final prefs = const UserPreferencesStore();
                      String? lastKnownVersion = prefs.getString('current_version');
                      String currentVersion = getCurrentVersion(removeInternalBuildNumber: true, trimV: true);

                      // Immediately update the current version for next time.
                      prefs.setString('current_version', currentVersion);

                      if (lastKnownVersion != null && lastKnownVersion != currentVersion && thunderState.showUpdateChangelogs) {
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
                                              prefs.setSetting(LocalSettings.showUpdateChangelogs, false);
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

                    return ThunderTabView(
                      pageController: widget.pageController,
                      actionController: _rootFeedActionController,
                      scaffoldStateKey: scaffoldStateKey,
                      profileState: state,
                      selectedPageIndex: selectedPageIndex,
                      onPageChanged: (index) => setState(() => selectedPageIndex = index),
                    );

                  // Should never hit these, they're handled by the login page
                  case ProfileStatus.failure:
                  case ProfileStatus.loading:
                    return Container();
                  case ProfileStatus.failureCheckingInstance:
                    showThunderSnackbar(state.error ?? AppLocalizations.of(context)!.missingErrorMessage);
                    errorMessageLoading = false;

                    return StatefulBuilder(
                      builder: (context, setState) => ThunderStateView(
                        title: AppLocalizations.of(context)!.unableToLoadInstance(state.account.instance),
                        message: AppLocalizations.of(context)!.internetOrInstanceIssues,
                        actions: [
                          ThunderStateAction(
                            label: AppLocalizations.of(context)!.retry,
                            onPressed: () {
                              context.read<ProfileBloc>().add(InitializeAuth());
                              setState(() => errorMessageLoading = true);
                            },
                            loading: errorMessageLoading,
                            primary: true,
                          ),
                          ThunderStateAction(
                            label: AppLocalizations.of(context)!.accountSettings,
                            onPressed: () => showProfileModalSheet(context),
                          ),
                        ],
                      ),
                    );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
