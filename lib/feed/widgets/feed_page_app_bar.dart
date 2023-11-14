import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/utils/profiles.dart';

import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/widgets/community_header.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/pages/user_settings_page.dart';
import 'package:thunder/user/utils/logout_dialog.dart';
import 'package:thunder/user/widgets/user_header.dart';
import 'package:thunder/utils/global_context.dart';

class FeedPageAppBar extends StatefulWidget {
  const FeedPageAppBar({
    super.key,
    this.showAppBarTitle = true,
    this.showSidebar = false,
    this.innerBoxIsScrolled = false,
    this.isAccountPage = false,
    this.onHeaderTapped,
    this.onSelectViewType,
    this.onShowSaved,
  });

  /// Boolean which indicates whether the title on the app bar should be shown
  final bool showAppBarTitle;

  /// Boolean which indicates whether the community/user sidebar should be shown
  final bool showSidebar;

  /// Boolean which indicates whether the feed body has been scrolled
  final bool innerBoxIsScrolled;

  /// Boolean which indicates whether the account page is being displayed.
  /// When displayed, the actions on the app bar will be different
  final bool isAccountPage;

  /// Callback function which is triggered when the header is tapped
  final Function(bool)? onHeaderTapped;

  /// Callback function which is triggered when the feed view type (posts/comments) is selected
  final Function(FeedViewType)? onSelectViewType;

  /// Callback function which is triggered when the saved items should be shown
  final Function(bool)? onShowSaved;

  @override
  State<FeedPageAppBar> createState() => _FeedPageAppBarState();
}

class _FeedPageAppBarState extends State<FeedPageAppBar> {
  @override
  Widget build(BuildContext context) {
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    double? getExpandedHeight(FeedType? feedType) {
      switch (feedType) {
        case FeedType.community:
          return 200;
        case FeedType.user:
          return 255;
        default:
          return null;
      }
    }

    double? getFlexibleHeight(FeedType? feedType) {
      switch (feedType) {
        case FeedType.user:
          return 60;
        default:
          return 0;
      }
    }

    return SliverAppBar(
      title: FeedAppBarTitle(visible: widget.showAppBarTitle),
      pinned: true,
      centerTitle: false,
      toolbarHeight: 70.0,
      expandedHeight: getExpandedHeight(feedBloc.state.feedType),
      forceElevated: widget.innerBoxIsScrolled,
      leading: FeedAppBarLeadingActions(isAccountPage: widget.isAccountPage),
      actions: [FeedAppBarTrailingActions(isAccountPage: widget.isAccountPage)],
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        collapseMode: CollapseMode.pin,
        background: (feedBloc.state.getPersonDetailsResponse != null || feedBloc.state.fullCommunityView != null)
            ? Padding(
                padding: EdgeInsets.only(top: 70.0 + MediaQuery.of(context).viewPadding.top, bottom: getFlexibleHeight(feedBloc.state.feedType) ?? 0.0),
                child: AnimatedOpacity(
                  opacity: widget.showAppBarTitle ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Visibility(
                    visible: feedBloc.state.feedType == FeedType.user || feedBloc.state.feedType == FeedType.community,
                    child: feedBloc.state.getPersonDetailsResponse != null
                        ? UserHeader(
                            personView: feedBloc.state.getPersonDetailsResponse!.personView,
                            showUserSidebar: widget.showSidebar,
                            onToggle: (bool toggled) => widget.onHeaderTapped?.call(toggled),
                          )
                        : CommunityHeader(
                            getCommunityResponse: feedBloc.state.fullCommunityView!,
                            showCommunitySidebar: widget.showSidebar,
                            onToggle: (bool toggled) => widget.onHeaderTapped?.call(toggled),
                          ),
                  ),
                ),
              )
            : null,
      ),
      bottom: feedBloc.state.feedType == FeedType.user
          ? PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: FeedAppBarTypeSelector(
                onSelectViewType: widget.onSelectViewType,
                onShowSaved: widget.onShowSaved,
              ),
            )
          : null,
    );
  }
}

/// Holds the leading actions on the app bar. The actions will be different depending on where the feed page is shown.
///
/// When the feed page is shown in the account page, the main action will be logout.
/// Otherwise, it will show either the drawer menu or the back button.
class FeedAppBarLeadingActions extends StatelessWidget {
  const FeedAppBarLeadingActions({super.key, this.isAccountPage = false});

  /// Boolean which indicates whether the account page is being displayed.
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    if (isAccountPage) {
      return IconButton(
        onPressed: () => showLogOutDialog(context),
        icon: Icon(
          Icons.logout,
          semanticLabel: AppLocalizations.of(context)!.logOut,
        ),
        tooltip: AppLocalizations.of(context)!.logOut,
      );
    }

    if (feedBloc.state.status != FeedStatus.initial) {
      return IconButton(
        icon: Navigator.of(context).canPop() && feedBloc.state.feedType != FeedType.general
            ? (Platform.isIOS
                ? Icon(
                    Icons.arrow_back_ios_new_rounded,
                    semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                  )
                : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip))
            : Icon(Icons.menu, semanticLabel: MaterialLocalizations.of(context).openAppDrawerTooltip),
        onPressed: () {
          HapticFeedback.mediumImpact();
          (Navigator.of(context).canPop() && feedBloc.state.feedType != FeedType.general) ? Navigator.of(context).maybePop() : Scaffold.of(context).openDrawer();
        },
      );
    }

    return Container();
  }
}

/// Holds the trailing actions on the app bar. The actions will be different depending on where the feed page is shown.
///
/// When the feed page is shown in the account page, additional actions will be shown.
/// Otherwise, it will show either the refresh and sort actions.
class FeedAppBarTrailingActions extends StatelessWidget {
  const FeedAppBarTrailingActions({super.key, this.isAccountPage = false});

  /// Boolean which indicates whether the account page is being displayed.
  final bool isAccountPage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final ThunderBloc thunderBloc = context.read<ThunderBloc>();
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    if (isAccountPage) {
      return Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              triggerRefresh(context);
            },
            icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
          ),
          IconButton(
            icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
            onPressed: () {
              HapticFeedback.mediumImpact();

              showModalBottomSheet<void>(
                showDragHandle: true,
                context: context,
                isScrollControlled: true,
                builder: (builderContext) => SortPicker(
                  title: l10n.sortOptions,
                  onSelect: (selected) => feedBloc.add(FeedChangeSortTypeEvent(selected.payload)),
                  previouslySelected: feedBloc.state.sortType,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              final AccountBloc accountBloc = context.read<AccountBloc>();
              final ThunderBloc thunderBloc = context.read<ThunderBloc>();

              Navigator.of(context).push(
                SwipeablePageRoute(
                  transitionDuration: thunderBloc.state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                  canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: accountBloc),
                      BlocProvider.value(value: thunderBloc),
                    ],
                    child: UserSettingsPage(accountBloc.state.personView!.person.id),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.settings_rounded,
              semanticLabel: AppLocalizations.of(context)!.accountSettings,
            ),
            tooltip: AppLocalizations.of(context)!.accountSettings,
          ),
          IconButton(
            onPressed: () => showProfileModalSheet(context),
            icon: Icon(
              Icons.people_alt_rounded,
              semanticLabel: AppLocalizations.of(context)!.profiles,
            ),
            tooltip: AppLocalizations.of(context)!.profiles,
          ),
          const SizedBox(width: 8.0),
        ],
      );
    }

    if (feedBloc.state.status != FeedStatus.initial) {
      return Row(
        children: [
          if (feedBloc.state.feedType == FeedType.community)
            BlocListener<CommunityBloc, CommunityState>(
              listener: (context, state) {
                if (state.status == CommunityStatus.success && state.communityView != null) {
                  feedBloc.add(FeedCommunityViewUpdatedEvent(communityView: state.communityView!));
                }
              },
              child: IconButton(
                icon: Icon(
                    switch (_getSubscriptionStatus(context)) {
                      SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                      SubscribedType.pending => Icons.pending_outlined,
                      SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                      _ => Icons.add_circle_outline_rounded,
                    },
                    semanticLabel: (_getSubscriptionStatus(context) == SubscribedType.notSubscribed) ? AppLocalizations.of(context)!.subscribe : AppLocalizations.of(context)!.unsubscribe),
                tooltip: switch (_getSubscriptionStatus(context)) {
                  SubscribedType.notSubscribed => AppLocalizations.of(context)!.subscribe,
                  SubscribedType.pending => AppLocalizations.of(context)!.unsubscribePending,
                  SubscribedType.subscribed => AppLocalizations.of(context)!.unsubscribe,
                  _ => null,
                },
                onPressed: () {
                  if (thunderBloc.state.isFabOpen) thunderBloc.add(const OnFabToggle(false));

                  HapticFeedback.mediumImpact();
                  _onSubscribeIconPressed(context);
                },
              ),
            ),
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              triggerRefresh(context);
            },
            icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.sort, semanticLabel: l10n.sortBy),
              onPressed: () {
                HapticFeedback.mediumImpact();

                showModalBottomSheet<void>(
                  showDragHandle: true,
                  context: context,
                  isScrollControlled: true,
                  builder: (builderContext) => SortPicker(
                    title: l10n.sortOptions,
                    onSelect: (selected) => feedBloc.add(FeedChangeSortTypeEvent(selected.payload)),
                    previouslySelected: feedBloc.state.sortType,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Container();
  }
}

class FeedAppBarTitle extends StatelessWidget {
  const FeedAppBarTitle({super.key, this.visible = true});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: ListTile(
        title: Text(
          feedBloc.state.feedType == FeedType.user ? getUserName(feedBloc.state) : getCommunityName(feedBloc.state),
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Icon(getSortIcon(feedBloc.state), size: 13),
            const SizedBox(width: 4),
            Text(getSortName(feedBloc.state)),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}

class FeedAppBarTypeSelector extends StatefulWidget {
  const FeedAppBarTypeSelector({
    super.key,
    this.onSelectViewType,
    this.onShowSaved,
  });

  final Function(FeedViewType)? onSelectViewType;
  final Function(bool)? onShowSaved;

  @override
  State<FeedAppBarTypeSelector> createState() => _FeedAppBarTypeSelectorState();
}

class _FeedAppBarTypeSelectorState extends State<FeedAppBarTypeSelector> {
  List<Widget> userOptionTypes = <Widget>[
    Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.posts)),
    Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.comments)),
  ];

  int selectedUserOption = 0;
  List<bool> _selectedUserOption = <bool>[true, false];
  bool showSavedItems = false;

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = context.watch<AuthBloc>();

    bool isAccountUser = authBloc.state.isLoggedIn && (authBloc.state.account?.userId == context.read<FeedBloc>().state.getPersonDetailsResponse?.personView.person.id);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            switchOutCurve: Curves.easeInOut,
            switchInCurve: Curves.easeInOut,
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                axis: Axis.horizontal,
                sizeFactor: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: !showSavedItems
                ? ToggleButtons(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < _selectedUserOption.length; i++) {
                          _selectedUserOption[i] = i == index;
                        }
                        selectedUserOption = index;
                      });

                      widget.onSelectViewType?.call(index == 0 ? FeedViewType.post : FeedViewType.comment);
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length + (isAccountUser ? 0.8 : 0.1))) - 12.0),
                    isSelected: _selectedUserOption,
                    children: userOptionTypes,
                  )
                : null,
          ),
          if (isAccountUser)
            Expanded(
              child: Padding(
                padding: showSavedItems ? const EdgeInsets.only(right: 8.0) : const EdgeInsets.only(left: 8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() => showSavedItems = !showSavedItems);
                    widget.onShowSaved?.call(showSavedItems);
                  },
                  style: TextButton.styleFrom(
                    fixedSize: const Size.fromHeight(35),
                    padding: EdgeInsets.zero,
                  ),
                  child: !showSavedItems
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8.0),
                            Text(AppLocalizations.of(context)!.saved),
                            const Icon(Icons.chevron_right),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chevron_left),
                            Text(
                              AppLocalizations.of(context)!.overview,
                              semanticsLabel: '${AppLocalizations.of(context)!.overview}, ${AppLocalizations.of(context)!.back}',
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        ),
                ),
              ),
            ),
          if (isAccountUser)
            AnimatedSwitcher(
              switchOutCurve: Curves.easeInOut,
              switchInCurve: Curves.easeInOut,
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: showSavedItems
                  ? ToggleButtons(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        setState(() {
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < _selectedUserOption.length; i++) {
                            _selectedUserOption[i] = i == index;
                          }

                          selectedUserOption = index;
                        });

                        widget.onSelectViewType?.call(index == 0 ? FeedViewType.post : FeedViewType.comment);
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length + (isAccountUser ? 0.8 : 0))) - 12.0),
                      isSelected: _selectedUserOption,
                      children: userOptionTypes,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// Get the subscription status for the current user and community
/// The logic works for anonymous accounts and for logged in accounts
SubscribedType? _getSubscriptionStatus(BuildContext context) {
  final AuthBloc authBloc = context.read<AuthBloc>();
  final FeedBloc feedBloc = context.read<FeedBloc>();
  final AnonymousSubscriptionsBloc anonymousSubscriptionsBloc = context.read<AnonymousSubscriptionsBloc>();

  if (authBloc.state.isLoggedIn) {
    return feedBloc.state.fullCommunityView?.communityView.subscribed;
  }

  return anonymousSubscriptionsBloc.state.ids.contains(feedBloc.state.fullCommunityView?.communityView.community.id) ? SubscribedType.subscribed : SubscribedType.notSubscribed;
}

void _onSubscribeIconPressed(BuildContext context) {
  final AuthBloc authBloc = context.read<AuthBloc>();
  final FeedBloc feedBloc = context.read<FeedBloc>();

  if (authBloc.state.isLoggedIn) {
    context.read<CommunityBloc>().add(
          CommunityActionEvent(
            communityId: feedBloc.state.fullCommunityView!.communityView.community.id,
            communityAction: CommunityAction.follow,
            value: (feedBloc.state.fullCommunityView?.communityView.subscribed == SubscribedType.notSubscribed ? true : false),
          ),
        );
    return;
  }

  Community community = feedBloc.state.fullCommunityView!.communityView.community;
  Set<int> currentSubscriptions = context.read<AnonymousSubscriptionsBloc>().state.ids;

  if (currentSubscriptions.contains(community.id)) {
    context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(ids: {community.id}));
    showSnackbar(context, AppLocalizations.of(context)!.unsubscribed);
  } else {
    context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {community}));
    showSnackbar(context, AppLocalizations.of(context)!.subscribed);
  }
}
