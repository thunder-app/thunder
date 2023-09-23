import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/shared/gesture_fab.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class FeedFAB extends StatelessWidget {
  const FeedFAB({super.key});

  @override
  build(BuildContext context) {
    final ThunderState state = context.watch<ThunderBloc>().state;

    FeedFabAction singlePressAction = state.feedFabSinglePressAction;
    FeedFabAction longPressAction = state.feedFabLongPressAction;

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
      child: GestureFab(
        distance: 60,
        icon: Icon(
          singlePressAction.icon,
          semanticLabel: singlePressAction.title,
          size: 35,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();

          switch (singlePressAction) {
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
              triggerNewPost(context);
              break;
            default:
              break;
          }
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();

          switch (longPressAction) {
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
              triggerNewPost(context);
              break;
            default:
              break;
          }
        },
        children: [
          ActionButton(
            title: FeedFabAction.dismissRead.title,
            icon: Icon(FeedFabAction.dismissRead.icon),
            onPressed: () {
              HapticFeedback.lightImpact();
              triggerDismissRead(context);
            },
          ),
          ActionButton(
            title: FeedFabAction.refresh.title,
            icon: Icon(FeedFabAction.refresh.icon),
            onPressed: () {
              HapticFeedback.lightImpact();
              triggerRefresh(context);
            },
          ),
          ActionButton(
            title: FeedFabAction.changeSort.title,
            icon: Icon(FeedFabAction.changeSort.icon),
            onPressed: () {
              HapticFeedback.lightImpact();
              triggerChangeSort(context);
            },
          ),
          ActionButton(
            title: FeedFabAction.subscriptions.title,
            icon: Icon(FeedFabAction.subscriptions.icon),
            onPressed: () {
              HapticFeedback.lightImpact();
              triggerOpenDrawer(context);
            },
          ),
          ActionButton(
            title: FeedFabAction.backToTop.title,
            icon: Icon(FeedFabAction.backToTop.icon),
            onPressed: () {
              HapticFeedback.lightImpact();
              triggerScrollToTop(context);
            },
          ),
          ActionButton(
            title: FeedFabAction.newPost.title,
            icon: Icon(FeedFabAction.newPost.icon),
            onPressed: () {
              HapticFeedback.lightImpact();
              triggerNewPost(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> triggerDismissRead(BuildContext context) async {
    context.read<FeedBloc>().add(FeedDismissReadEvent());
  }

  Future<void> triggerRefresh(BuildContext context) async {
    FeedState state = context.read<FeedBloc>().state;

    context.read<AccountBloc>().add(GetAccountInformation());
    context.read<FeedBloc>().add(
          FeedFetchedEvent(
            feedType: state.feedType,
            postListingType: state.postListingType,
            sortType: state.sortType,
            communityId: state.communityId,
            communityName: state.communityName,
            userId: state.userId,
            username: state.username,
            reset: true,
          ),
        );
  }

  Future<void> triggerChangeSort(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (builderContext) => SortPicker(
        title: l10n.sortOptions,
        onSelect: (selected) => context.read<FeedBloc>().add(FeedChangeSortTypeEvent(selected.payload)),
        previouslySelected: context.read<FeedBloc>().state.sortType,
      ),
    );
  }

  Future<void> triggerOpenDrawer(BuildContext context) async {
    Scaffold.of(context).openDrawer();
  }

  Future<void> triggerScrollToTop(BuildContext context) async {
    context.read<FeedBloc>().add(ScrollToTopEvent());
  }

  Future<void> triggerNewPost(BuildContext context) async {
    FeedBloc feedBloc = context.read<FeedBloc>();

    if (!context.read<AuthBloc>().state.isLoggedIn) {
      showSnackbar(context, AppLocalizations.of(context)!.mustBeLoggedInPost);
    } else {
      ThunderBloc thunderBloc = context.read<ThunderBloc>();
      AccountBloc accountBloc = context.read<AccountBloc>();

      final ThunderState thunderState = context.read<ThunderBloc>().state;
      final bool reduceAnimations = thunderState.reduceAnimations;

      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      DraftPost? newDraftPost;
      DraftPost? previousDraftPost;
      String draftId = '${LocalSettings.draftsCache.name}-${feedBloc.state.communityId}';
      String? draftPostJson = prefs.getString(draftId);
      if (draftPostJson != null) {
        previousDraftPost = DraftPost.fromJson(jsonDecode(draftPostJson));
      }
      Timer timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
        if (newDraftPost?.isNotEmpty == true) {
          prefs.setString(draftId, jsonEncode(newDraftPost!.toJson()));
        }
      });

      Navigator.of(context)
          .push(
        SwipeablePageRoute(
          transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
          canOnlySwipeFromEdge: true,
          backGestureDetectionWidth: 45,
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<FeedBloc>.value(value: feedBloc),
                BlocProvider<ThunderBloc>.value(value: thunderBloc),
                BlocProvider<AccountBloc>.value(value: accountBloc),
              ],
              child: CreatePostPage(
                communityId: feedBloc.state.communityId!,
                communityInfo: feedBloc.state.fullCommunityView,
                previousDraftPost: previousDraftPost,
                onUpdateDraft: (p) => newDraftPost = p,
              ),
            );
          },
        ),
      )
          .whenComplete(() async {
        timer.cancel();

        if (newDraftPost?.saveAsDraft == true && newDraftPost?.isNotEmpty == true) {
          await Future.delayed(const Duration(milliseconds: 300));
          showSnackbar(context, AppLocalizations.of(context)!.postSavedAsDraft);
          prefs.setString(draftId, jsonEncode(newDraftPost!.toJson()));
        } else {
          prefs.remove(draftId);
        }
      });
    }
  }
}
