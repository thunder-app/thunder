import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

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
import 'package:thunder/user/widgets/user_header.dart';
import 'package:thunder/utils/global_context.dart';

class FeedPageAppBar extends StatefulWidget {
  const FeedPageAppBar({
    super.key,
    this.showAppBarTitle = true,
    this.showSidebar = false,
    this.onHeaderTapped,
    this.onSelectViewType,
    this.onShowSaved,
    required this.innerBoxIsScrolled,
  });

  final bool showAppBarTitle;
  final bool showSidebar;
  final bool innerBoxIsScrolled;

  final Function(bool)? onHeaderTapped;
  final Function(FeedViewType)? onSelectViewType;
  final Function(bool)? onShowSaved;

  @override
  State<FeedPageAppBar> createState() => _FeedPageAppBarState();
}

class _FeedPageAppBarState extends State<FeedPageAppBar> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final ThunderBloc thunderBloc = context.read<ThunderBloc>();
    final FeedBloc feedBloc = context.watch<FeedBloc>();
    final FeedState feedState = feedBloc.state;

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
      expandedHeight: getExpandedHeight(feedState.feedType),
      forceElevated: widget.innerBoxIsScrolled,
      leading: feedState.status != FeedStatus.initial
          ? IconButton(
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
            )
          : Container(),
      actions: [
        if (feedState.feedType == FeedType.community)
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
            icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh)),
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
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        collapseMode: CollapseMode.pin,
        background: (feedState.getPersonDetailsResponse != null || feedState.fullCommunityView != null)
            ? Padding(
                padding: EdgeInsets.only(top: 70.0 + MediaQuery.of(context).viewPadding.top, bottom: getFlexibleHeight(feedState.feedType) ?? 0.0),
                child: AnimatedOpacity(
                  opacity: widget.showAppBarTitle ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Visibility(
                    visible: feedState.feedType == FeedType.user || feedState.feedType == FeedType.community,
                    child: feedState.getPersonDetailsResponse != null
                        ? UserHeader(
                            personView: feedState.getPersonDetailsResponse!.personView,
                            showUserSidebar: widget.showSidebar,
                            onToggle: (bool toggled) => widget.onHeaderTapped?.call(toggled),
                          )
                        : CommunityHeader(
                            getCommunityResponse: feedState.fullCommunityView!,
                            showCommunitySidebar: widget.showSidebar,
                            onToggle: (bool toggled) => widget.onHeaderTapped?.call(toggled),
                          ),
                  ),
                ),
              )
            : null,
      ),
      bottom: feedState.feedType == FeedType.user
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

  final FeedState feedState = feedBloc.state;

  if (authBloc.state.isLoggedIn) {
    context.read<CommunityBloc>().add(
          CommunityActionEvent(
            communityId: feedBloc.state.fullCommunityView!.communityView.community.id,
            communityAction: CommunityAction.follow,
            value: (feedState.fullCommunityView?.communityView.subscribed == SubscribedType.notSubscribed ? true : false),
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
