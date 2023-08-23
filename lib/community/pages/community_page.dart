import 'dart:async';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External Packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

// Internal
import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/community/widgets/community_drawer.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';

import '../../shared/gesture_fab.dart';

class CommunityPage extends StatefulWidget {
  final int? communityId;
  final String? communityName;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final PageController? pageController;

  const CommunityPage({super.key, this.communityId, this.communityName, this.scaffoldKey, this.pageController});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with AutomaticKeepAliveClientMixin<CommunityPage> {
  @override
  bool get wantKeepAlive => true;

  SortType? sortType;
  IconData? sortTypeIcon;
  String? sortTypeLabel;
  CommunityBloc? currentCommunityBloc;
  bool _previousIsFabOpen = false;
  bool isFabOpen = false;
  bool _previousIsFabSummoned = true;
  bool isFabSummoned = true;
  bool enableFab = false;
  bool isActivePage = true;

  @override
  void initState() {
    super.initState();
    widget.pageController?.addListener(() {
      // This ensures that our back button handling only goes into effect when we're on the home page
      isActivePage = widget.pageController!.page == 0;
    });
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    final theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    enableFab = state.enableFeedsFab;
    bool enableBackToTop = state.enableBackToTop;
    bool enableSubscriptions = state.enableSubscriptions;
    bool enableChangeSort = state.enableChangeSort;
    bool enableRefresh = state.enableRefresh;
    bool enableDismissRead = state.enableDismissRead;
    bool enableNewPost = state.enableNewPost;
    FeedFabAction singlePressAction = state.feedFabSinglePressAction;
    FeedFabAction longPressAction = state.feedFabLongPressAction;

    if (state.isFabOpen != _previousIsFabOpen) {
      isFabOpen = state.isFabOpen;
      _previousIsFabOpen = isFabOpen;
    }
    if (state.isFabSummoned != _previousIsFabSummoned) {
      isFabSummoned = state.isFabSummoned;
      _previousIsFabSummoned = isFabSummoned;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => currentCommunityBloc = CommunityBloc()),
        BlocProvider(create: (context) => AnonymousSubscriptionsBloc()..add(GetSubscribedCommunitiesEvent())),
      ],
      child: BlocConsumer<CommunityBloc, CommunityState>(
        listenWhen: (previousState, currentState) {
          if (previousState.subscribedType != currentState.subscribedType) {
            context.read<account_bloc.AccountBloc>().add(account_bloc.GetAccountInformation());
          }

          if (previousState.sortType != currentState.sortType) {
            setState(() {
              sortType = currentState.sortType;
              final sortTypeItem = allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == currentState.sortType);
              sortTypeIcon = sortTypeItem.icon;
              sortTypeLabel = sortTypeItem.label;
            });
          }

          return true;
        },
        listener: (context, state) {
          if (state.status == CommunityStatus.failure) {
            showSnackbar(context, state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage);
          }

          if (state.status == CommunityStatus.success && state.blockedCommunity != null) {
            if (state.blockedCommunity?.blocked == true) {
              showSnackbar(
                context,
                AppLocalizations.of(context)!.successfullyBlockedCommunity(state.blockedCommunity?.communityView.community.title ?? AppLocalizations.of(context)!.missingErrorMessage),
                trailingIcon: Icons.undo_rounded,
                trailingAction: () {
                  context.read<CommunityBloc>().add(BlockCommunityEvent(communityId: state.blockedCommunity!.communityView.community.id, block: false));
                },
              );
            } else {
              showSnackbar(
                  context, AppLocalizations.of(context)!.successfullyUnblockedCommunity(state.blockedCommunity?.communityView.community.title ?? AppLocalizations.of(context)!.missingErrorMessage));
            }
          }
        },
        builder: (context, state) {
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) {
              if (previous.account == null && current.account != null && previous.account?.id != current.account?.id) {
                context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, sortType: sortType));
                return true;
              }

              return false;
            },
            listener: (context, state) {},
            child: BlocConsumer<AnonymousSubscriptionsBloc, AnonymousSubscriptionsState>(
                listener: (c, s) {},
                builder: (c, subscriptionsState) {
                  return Scaffold(
                    key: widget.scaffoldKey,
                    appBar: AppBar(
                      title: ListTile(
                        title: Text(getCommunityName(state), style: theme.textTheme.titleLarge),
                        subtitle: Text(getSortName(state)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      centerTitle: false,
                      toolbarHeight: 70.0,
                      flexibleSpace: GestureDetector(
                        onTap: () {
                          if (context.read<ThunderBloc>().state.isFabOpen) {
                            context.read<ThunderBloc>().add(const OnFabToggle(false));
                          }
                        },
                      ),
                      leading: Navigator.of(context).canPop() && currentCommunityBloc?.state.communityId != null
                          ? IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                semanticLabel: AppLocalizations.of(context)!.back,
                              ),
                              onPressed: () {
                                if (context.read<ThunderBloc>().state.isFabOpen) {
                                  context.read<ThunderBloc>().add(const OnFabToggle(false));
                                }
                                Navigator.pop(context);
                              })
                          : null,
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (state.communityId != null || state.communityName != null)
                              IconButton(
                                icon: Icon(
                                  switch (_getSubscriptionStatus(state, isUserLoggedIn, subscriptionsState)) {
                                    SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                                    SubscribedType.pending => Icons.pending_outlined,
                                    SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                                    _ => Icons.add_circle_outline_rounded,
                                  },
                                  semanticLabel: (_getSubscriptionStatus(state, isUserLoggedIn, subscriptionsState) == SubscribedType.notSubscribed || state.subscribedType == null)
                                      ? AppLocalizations.of(context)!.subscribe
                                      : AppLocalizations.of(context)!.unsubscribe,
                                ),
                                tooltip: switch (_getSubscriptionStatus(state, isUserLoggedIn, subscriptionsState)) {
                                  SubscribedType.notSubscribed => AppLocalizations.of(context)!.subscribe,
                                  SubscribedType.pending => AppLocalizations.of(context)!.unsubscribePending,
                                  SubscribedType.subscribed => AppLocalizations.of(context)!.unsubscribe,
                                  _ => null,
                                },
                                onPressed: () {
                                  if (context.read<ThunderBloc>().state.isFabOpen) {
                                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                                  }
                                  HapticFeedback.mediumImpact();
                                  _onSubscribeIconPressed(isUserLoggedIn, context, state);
                                },
                              ),
                            IconButton(
                                icon: Icon(Icons.refresh_rounded, semanticLabel: AppLocalizations.of(context)!.refresh),
                                onPressed: () {
                                  if (context.read<ThunderBloc>().state.isFabOpen) {
                                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                                  }
                                  HapticFeedback.mediumImpact();
                                  context.read<AccountBloc>().add(GetAccountInformation());
                                  return context.read<CommunityBloc>().add(GetCommunityPostsEvent(
                                        reset: true,
                                        sortType: sortType,
                                        communityId: state.communityId,
                                        listingType: state.listingType,
                                        communityName: state.communityName,
                                      ));
                                }),
                            IconButton(
                                icon: Icon(Icons.sort, semanticLabel: AppLocalizations.of(context)!.sortBy),
                                tooltip: AppLocalizations.of(context)!.sortBy,
                                onPressed: () {
                                  if (context.read<ThunderBloc>().state.isFabOpen) {
                                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                                  }
                                  HapticFeedback.mediumImpact();
                                  showSortBottomSheet(context, state);
                                }),
                            const SizedBox(width: 8.0),
                          ],
                        )
                      ],
                    ),
                    drawer: (widget.communityId != null || widget.communityName != null) ? null : const CommunityDrawer(),
                    floatingActionButton: enableFab
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.ease,
                            switchOutCurve: Curves.ease,
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0, 0.2), end: const Offset(0, 0)).animate(animation),
                                child: child,
                              );
                            },
                            child: isFabSummoned
                                ? GestureFab(
                                    distance: 60,
                                    icon: Icon(
                                      singlePressAction.isAllowed(state: state, widget: widget)
                                          ? singlePressAction.getIcon(override: singlePressAction == FeedFabAction.changeSort ? sortTypeIcon : null)
                                          : FeedFabAction.dismissRead.getIcon(),
                                      semanticLabel: singlePressAction.isAllowed(state: state) ? singlePressAction.getTitle(context) : FeedFabAction.dismissRead.getTitle(context),
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      singlePressAction.isAllowed(state: state, widget: widget)
                                          ? singlePressAction.execute(context, state,
                                              bloc: context.read<CommunityBloc>(),
                                              widget: widget,
                                              override: singlePressAction == FeedFabAction.changeSort ? () => showSortBottomSheet(context, state) : null,
                                              sortType: sortType)
                                          : FeedFabAction.dismissRead.execute(context, state);
                                    },
                                    onLongPress: () {
                                      longPressAction.isAllowed(state: state, widget: widget)
                                          ? longPressAction.execute(context, state,
                                              bloc: context.read<CommunityBloc>(),
                                              widget: widget,
                                              override: longPressAction == FeedFabAction.changeSort ? () => showSortBottomSheet(context, state) : null,
                                              sortType: sortType)
                                          : FeedFabAction.openFab.execute(context, state);
                                    },
                                    children: [
                                      if (FeedFabAction.dismissRead.isAllowed() == true && enableDismissRead)
                                        ActionButton(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            FeedFabAction.dismissRead.execute(context, state);
                                          },
                                          title: FeedFabAction.dismissRead.getTitle(context),
                                          icon: Icon(
                                            FeedFabAction.dismissRead.getIcon(),
                                          ),
                                        ),
                                      if (FeedFabAction.refresh.isAllowed() == true && enableRefresh)
                                        ActionButton(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            FeedFabAction.refresh.execute(context, state, bloc: context.read<CommunityBloc>(), sortType: sortType);
                                          },
                                          title: FeedFabAction.refresh.getTitle(context),
                                          icon: Icon(
                                            FeedFabAction.refresh.getIcon(),
                                          ),
                                        ),
                                      if (FeedFabAction.changeSort.isAllowed() == true && enableChangeSort)
                                        ActionButton(
                                          onPressed: () {
                                            HapticFeedback.mediumImpact();
                                            FeedFabAction.changeSort.execute(context, state, override: () => showSortBottomSheet(context, state));
                                          },
                                          title: FeedFabAction.changeSort.getTitle(context),
                                          icon: Icon(
                                            FeedFabAction.changeSort.getIcon(override: sortTypeIcon),
                                          ),
                                        ),
                                      if (FeedFabAction.subscriptions.isAllowed(widget: widget) == true && enableSubscriptions)
                                        ActionButton(
                                          onPressed: () => FeedFabAction.subscriptions.execute(context, state, widget: widget),
                                          title: FeedFabAction.subscriptions.getTitle(context),
                                          icon: Icon(
                                            FeedFabAction.subscriptions.getIcon(),
                                          ),
                                        ),
                                      if (FeedFabAction.backToTop.isAllowed() && enableBackToTop)
                                        ActionButton(
                                          onPressed: () {
                                            FeedFabAction.backToTop.execute(context, state);
                                          },
                                          title: FeedFabAction.backToTop.getTitle(context),
                                          icon: Icon(
                                            FeedFabAction.backToTop.getIcon(),
                                          ),
                                        ),
                                      if (FeedFabAction.newPost.isAllowed(state: state) && enableNewPost)
                                        ActionButton(
                                          onPressed: () {
                                            FeedFabAction.newPost.execute(context, state, bloc: context.read<CommunityBloc>());
                                          },
                                          title: FeedFabAction.newPost.getTitle(context),
                                          icon: Icon(
                                            FeedFabAction.newPost.getIcon(),
                                          ),
                                        ),
                                    ],
                                  )
                                : null,
                          )
                        : null,
                    body: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        SafeArea(child: _getBody(context, state)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isFabOpen
                              ? Listener(
                                  onPointerUp: (details) {
                                    context.read<ThunderBloc>().add(const OnFabToggle(false));
                                  },
                                  child: Container(
                                    color: theme.colorScheme.background.withOpacity(0.85),
                                  ),
                                )
                              : null,
                        ),
                        if (enableFab)
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                if (details.delta.dy < -5) {
                                  context.read<ThunderBloc>().add(const OnFabSummonToggle(true));
                                }
                              },
                            ),
                          )
                      ],
                    ),
                  );
                }),
          );
        },
      ),
    );
  }

  Widget _getBody(BuildContext context, CommunityState state) {
    switch (state.status) {
      case CommunityStatus.initial:
        // communityId and communityName are mutually exclusive - only one of the two should be passed in
        context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, communityId: widget.communityId, communityName: widget.communityName));
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.refreshing:
      case CommunityStatus.success:
      case CommunityStatus.failure:
        return PostCardList(
          subscribeType: state.subscribedType,
          postViews: state.postViews,
          listingType: state.communityId != null ? null : state.listingType,
          communityId: widget.communityId ?? state.communityId,
          communityName: widget.communityName ?? state.communityName,
          hasReachedEnd: state.hasReachedEnd,
          communityInfo: state.communityInfo,
          blockedCommunity: state.blockedCommunity,
          sortType: state.sortType,
          onScrollEndReached: () => context.read<CommunityBloc>().add(GetCommunityPostsEvent(communityId: widget.communityId)),
          onSaveAction: (int postId, bool save) => context.read<CommunityBloc>().add(SavePostEvent(postId: postId, save: save)),
          onVoteAction: (int postId, VoteType voteType) => context.read<CommunityBloc>().add(VotePostEvent(postId: postId, score: voteType)),
          onToggleReadAction: (int postId, bool read) => context.read<CommunityBloc>().add(MarkPostAsReadEvent(postId: postId, read: read)),
          tagline: state.tagline,
        );
      case CommunityStatus.empty:
        return Center(child: Text(AppLocalizations.of(context)!.noPosts));
    }
  }

  void showSortBottomSheet(BuildContext context, CommunityState state) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (builderContext) => SortPicker(
        title: AppLocalizations.of(context)!.sortOptions,
        onSelect: (selected) {
          setState(() {
            sortType = selected.payload;
            sortTypeIcon = selected.icon;
          });

          context.read<CommunityBloc>().add(
                GetCommunityPostsEvent(
                  sortType: selected.payload,
                  reset: true,
                  listingType: state.communityId != null ? null : state.listingType,
                  communityId: widget.communityId ?? state.communityId,
                ),
              );
        },
      ),
    );
  }

  String getCommunityName(CommunityState state) {
    if (state.status == CommunityStatus.initial || state.status == CommunityStatus.loading) {
      return '';
    }

    if (state.communityId != null || state.communityName != null) {
      return '';
    }

    return (state.listingType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.listingType).label) : '';
  }

  String getSortName(CommunityState state) {
    if (state.status == CommunityStatus.initial || state.status == CommunityStatus.loading) {
      return '';
    }

    return sortTypeLabel ?? '';
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (context.read<ThunderBloc>().state.isFabOpen) {
      context.read<ThunderBloc>().add(const OnFabToggle(false));
    }

    if (currentCommunityBloc != null) {
      // This restricts back button handling to when we're already at the top level of navigation
      final canPop = Navigator.of(context).canPop();

      final prefs = (await UserPreferences.instance).sharedPreferences;
      final desiredPostListingType = PostListingType.values.byName(prefs.getString(LocalSettings.defaultFeedListingType.name) ?? DEFAULT_LISTING_TYPE.name);
      final currentPostListingType = currentCommunityBloc!.state.listingType;
      final currentCommunityId = currentCommunityBloc!.state.communityId;

      // If we are either (a) not on the desired listing or (b) not on the main feed (on a community instead)
      // then go back to the main feed using the desired listing.
      if (!canPop && isActivePage && (desiredPostListingType != currentPostListingType || currentCommunityId != null)) {
        currentCommunityBloc!.add(
          GetCommunityPostsEvent(
            sortType: currentCommunityBloc!.state.sortType,
            reset: true,
            listingType: desiredPostListingType,
            communityId: null,
          ),
        );

        return true;
      }
    }

    return false;
  }
}

SubscribedType? _getSubscriptionStatus(CommunityState state, bool isLoggedIn, AnonymousSubscriptionsState subscriptionsState) {
  if (isLoggedIn) {
    return state.subscribedType;
  }
  return subscriptionsState.ids.contains(state.communityId) ? SubscribedType.subscribed : SubscribedType.notSubscribed;
}

void _onSubscribeIconPressed(bool isUserLoggedIn, BuildContext context, CommunityState state) {
  if (isUserLoggedIn) {
    context.read<CommunityBloc>().add(
          ChangeCommunitySubsciptionStatusEvent(
            communityId: state.communityId!,
            follow: (state.subscribedType == null) ? true : (state.subscribedType == SubscribedType.notSubscribed ? true : false),
          ),
        );
    return;
  }
  CommunitySafe? community = state.communityInfo?.communityView.community;
  if (community == null) return;

  Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;

  if (currentSubscriptions.contains(state.communityId)) {
    context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(ids: {state.communityId!}));
    showSnackbar(context, AppLocalizations.of(context)!.unsubscribed);
  } else {
    context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {state.communityInfo!.communityView.community}));
    showSnackbar(context, AppLocalizations.of(context)!.subscribed);
  }
}
