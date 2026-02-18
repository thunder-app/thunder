import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/feed/api.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/shared/gesture_fab.dart';

import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

class FeedFAB extends StatelessWidget {
  const FeedFAB({super.key, this.heroTag});

  final String? heroTag;

  @override
  build(BuildContext context) {
    final theme = Theme.of(context);
    final feedFabSinglePressAction = context.select<FabPreferencesCubit, FeedFabAction>((cubit) => cubit.state.feedFabSinglePressAction);
    final feedFabLongPressAction = context.select<FabPreferencesCubit, FeedFabAction>((cubit) => cubit.state.feedFabLongPressAction);
    final isFabSummoned = context.select<FabStateCubit, bool>((cubit) => cubit.state.isFeedFabSummoned);
    final FeedState feedState = context.watch<FeedBloc>().state;
    final ProfileState profileState = context.read<ProfileBloc>().state;

    // A list of actions that are not supported through the general feed
    List<FeedFabAction> unsupportedGeneralFeedFabActions = [];

    // A list of actions that are not supported through the navigated community feed
    List<FeedFabAction> unsupportedNavigatedCommunityFeedFabActions = [
      FeedFabAction.subscriptions,
    ];

    // A list of actions that are not supported through the navigated user feed
    List<FeedFabAction> unsupportedNavigatedUserFeedFabActions = [
      FeedFabAction.subscriptions,
      FeedFabAction.newPost,
      FeedFabAction.dismissRead,
    ];

    FeedFabAction singlePressAction = feedFabSinglePressAction;
    FeedFabAction longPressAction = feedFabLongPressAction;

    // Check to see if we are in the general feeds
    bool isGeneralFeed = feedState.status != FeedStatus.initial && feedState.feedType == FeedType.general;
    bool isCommunityFeed = feedState.status != FeedStatus.initial && feedState.feedType == FeedType.community;
    bool isUserFeed = feedState.status != FeedStatus.initial && feedState.feedType == FeedType.user;
    bool isNavigatedFeed = Navigator.canPop(context);

    bool isPostLocked = false;

    if (profileState.isLoggedIn && isCommunityFeed) {
      final community = feedState.community;

      if (community!.postingRestrictedToMods && !profileState.moderates.any((c) => c.id == community.id)) {
        isPostLocked = true;
      }
    }

    List<FeedFabAction> disabledActions = [];

    if (isGeneralFeed) {
      disabledActions = unsupportedGeneralFeedFabActions;
    } else if (isCommunityFeed && isNavigatedFeed) {
      disabledActions = unsupportedNavigatedCommunityFeedFabActions;
    } else if (isUserFeed && isNavigatedFeed) {
      disabledActions = unsupportedNavigatedUserFeedFabActions;
    }

    // Check single-press action
    if (isGeneralFeed && unsupportedGeneralFeedFabActions.contains(singlePressAction)) {
      singlePressAction = FeedFabAction.openFab; // Default to open fab on unsupported actions
    } else if (isCommunityFeed && isNavigatedFeed && unsupportedNavigatedCommunityFeedFabActions.contains(singlePressAction)) {
      singlePressAction = FeedFabAction.openFab; // Default to open fab on unsupported actions
    } else if (isUserFeed && unsupportedNavigatedUserFeedFabActions.contains(singlePressAction)) {
      singlePressAction = FeedFabAction.openFab; // Default to open fab on unsupported actions
    }

    // Check long-press action
    if (isGeneralFeed && unsupportedGeneralFeedFabActions.contains(longPressAction)) {
      longPressAction = FeedFabAction.openFab; // Default to open fab on unsupported actions
    } else if (isCommunityFeed && isNavigatedFeed && unsupportedNavigatedCommunityFeedFabActions.contains(longPressAction)) {
      longPressAction = FeedFabAction.openFab; // Default to open fab on unsupported actions
    } else if (isUserFeed && unsupportedNavigatedUserFeedFabActions.contains(longPressAction)) {
      longPressAction = FeedFabAction.openFab; // Default to open fab on unsupported actions
    }

    return AnimatedSwitcher(
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
              heroTag: heroTag,
              distance: 60,
              fabBackgroundColor: (singlePressAction == FeedFabAction.newPost && isPostLocked) ? theme.colorScheme.errorContainer : null,
              icon: Icon(
                (singlePressAction == FeedFabAction.newPost && isPostLocked) ? Icons.lock : singlePressAction.icon,
                semanticLabel: singlePressAction.title,
                size: 35,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();

                switch (singlePressAction) {
                  case FeedFabAction.openFab:
                    triggerOpenFab(context);
                    break;
                  case FeedFabAction.dismissRead:
                    triggerDismissRead(context);
                    break;
                  case FeedFabAction.refresh:
                    triggerRefresh(context);
                    break;
                  case FeedFabAction.changeSort:
                    triggerChangeSort(context);
                    break;
                  case FeedFabAction.subscriptions:
                    triggerOpenDrawer(context);
                    break;
                  case FeedFabAction.backToTop:
                    triggerScrollToTop(context);
                    break;
                  case FeedFabAction.newPost:
                    triggerNewPost(context, isPostingLocked: isPostLocked);
                    break;
                }
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();

                switch (longPressAction) {
                  case FeedFabAction.openFab:
                    triggerOpenFab(context);
                    break;
                  case FeedFabAction.dismissRead:
                    triggerDismissRead(context);
                    break;
                  case FeedFabAction.refresh:
                    triggerRefresh(context);
                    break;
                  case FeedFabAction.changeSort:
                    triggerChangeSort(context);
                    break;
                  case FeedFabAction.subscriptions:
                    triggerOpenDrawer(context);
                    break;
                  case FeedFabAction.backToTop:
                    triggerScrollToTop(context);
                    break;
                  case FeedFabAction.newPost:
                    triggerNewPost(context, isPostingLocked: isPostLocked);
                    break;
                }
              },
              fabType: FabType.feed,
              children: getEnabledActions(context, isPostingLocked: isPostLocked, disabledActions: disabledActions),
            )
          : Stack(
              // This creates an invisible touch target to summon the FAB
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                SizedBox(
                  width: 75,
                  height: 75,
                  child: GestureDetector(
                    onVerticalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity! < 0) {
                        context.read<FabStateCubit>().setFeedFabSummoned(true);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  List<ActionButton> getEnabledActions(BuildContext context, {bool isPostingLocked = false, List<FeedFabAction> disabledActions = const []}) {
    final theme = Theme.of(context);
    final enableBackToTop = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableBackToTop) && !disabledActions.contains(FeedFabAction.backToTop);
    final enableSubscriptions = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableSubscriptions) && !disabledActions.contains(FeedFabAction.subscriptions);
    final enableChangeSort = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableChangeSort) && !disabledActions.contains(FeedFabAction.changeSort);
    final enableRefresh = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableRefresh) && !disabledActions.contains(FeedFabAction.refresh);
    final enableDismissRead = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableDismissRead) && !disabledActions.contains(FeedFabAction.dismissRead);
    final enableNewPost = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableNewPost) && !disabledActions.contains(FeedFabAction.newPost);

    List<ActionButton> actions = [
      if (enableDismissRead)
        ActionButton(
          title: FeedFabAction.dismissRead.title,
          icon: Icon(FeedFabAction.dismissRead.icon),
          onPressed: () {
            HapticFeedback.lightImpact();
            triggerDismissRead(context);
          },
        ),
      if (enableRefresh)
        ActionButton(
          title: FeedFabAction.refresh.title,
          icon: Icon(FeedFabAction.refresh.icon),
          onPressed: () {
            HapticFeedback.lightImpact();
            triggerRefresh(context);
          },
        ),
      if (enableChangeSort)
        ActionButton(
          title: FeedFabAction.changeSort.title,
          icon: Icon(FeedFabAction.changeSort.icon),
          onPressed: () {
            HapticFeedback.lightImpact();
            triggerChangeSort(context);
          },
        ),
      if (enableSubscriptions && Scaffold.maybeOf(context) != null)
        ActionButton(
          title: FeedFabAction.subscriptions.title,
          icon: Icon(FeedFabAction.subscriptions.icon),
          onPressed: () {
            HapticFeedback.lightImpact();
            triggerOpenDrawer(context);
          },
        ),
      if (enableBackToTop)
        ActionButton(
          title: FeedFabAction.backToTop.title,
          icon: Icon(FeedFabAction.backToTop.icon),
          onPressed: () {
            HapticFeedback.lightImpact();
            triggerScrollToTop(context);
          },
        ),
      if (enableNewPost)
        ActionButton(
          title: FeedFabAction.newPost.title,
          icon: Icon(isPostingLocked ? Icons.lock : FeedFabAction.newPost.icon),
          backgroundColor: isPostingLocked ? theme.colorScheme.errorContainer : null,
          onPressed: () {
            HapticFeedback.lightImpact();
            triggerNewPost(context, isPostingLocked: isPostingLocked);
          },
        ),
    ];

    return actions;
  }

  Future<void> triggerOpenFab(BuildContext context) async {
    context.read<FabStateCubit>().setFeedFabOpen(true);
  }

  Future<void> triggerDismissRead(BuildContext context) async {
    context.read<FeedUiCubit>().dismissRead();
  }

  Future<void> triggerChangeSort(BuildContext context) async {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      builder: (builderContext) => SortPicker<PostSortType>(
        account: feedBloc.account,
        title: l10n.sortOptions,
        onSelect: (selected) async => context.read<FeedBloc>().add(FeedChangePostSortTypeEvent(selected.payload)),
        previouslySelected: context.read<FeedBloc>().state.postSortType,
      ),
    );
  }

  Future<void> triggerOpenDrawer(BuildContext context) async {
    Scaffold.of(context).openDrawer();
  }

  Future<void> triggerScrollToTop(BuildContext context) async {
    context.read<FeedUiCubit>().scrollToTop();
  }

  Future<void> triggerNewPost(BuildContext context, {bool isPostingLocked = false}) async {
    final l10n = AppLocalizations.of(context)!;

    if (!context.read<ProfileBloc>().state.isLoggedIn) {
      return showSnackbar(l10n.mustBeLoggedInPost);
    }

    if (isPostingLocked) {
      return showSnackbar(l10n.onlyModsCanPostInCommunity);
    }

    FeedBloc feedBloc = context.read<FeedBloc>();
    navigateToCreatePostPage(context, communityId: feedBloc.state.communityId, community: feedBloc.state.community);
  }
}
