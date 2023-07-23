import 'dart:async';
import 'dart:math' as math;

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/community/widgets/community_drawer.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';

class CommunityPage extends StatefulWidget {
  final int? communityId;
  final String? communityName;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CommunityPage({super.key, this.communityId, this.communityName, this.scaffoldKey});

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

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return BlocProvider<CommunityBloc>(
      create: (context) => currentCommunityBloc = CommunityBloc(),
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
            SnackBar snackBar = SnackBar(
              content: Text(state.errorMessage ?? 'No error message available'),
              behavior: SnackBarBehavior.floating,
            );
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
          }

          if (state.status == CommunityStatus.success && state.blockedCommunity != null) {
            SnackBar snackBar = SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Successfully ${state.blockedCommunity?.blocked == true ? 'blocked' : 'unblocked'} ${state.blockedCommunity?.communityView.community.title}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (state.blockedCommunity?.blocked == true)
                    SizedBox(
                      height: 20,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          context.read<CommunityBloc>().add(BlockCommunityEvent(communityId: state.blockedCommunity!.communityView.community.id, block: false));
                        },
                        icon: Icon(
                          Icons.undo_rounded,
                          color: theme.colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
            );
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
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
            child: Scaffold(
              key: widget.scaffoldKey,
              appBar: AppBar(
                title: Text(getCommunityName(state)),
                centerTitle: false,
                toolbarHeight: 70.0,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if ((state.communityId != null || state.communityName != null) && isUserLoggedIn)
                        IconButton(
                          icon: Icon(
                            switch (state.subscribedType) {
                              SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                              SubscribedType.pending => Icons.pending_outlined,
                              SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                              _ => Icons.add_circle_outline_rounded,
                            },
                            semanticLabel: (state.subscribedType == SubscribedType.notSubscribed || state.subscribedType == null) ? 'Subscribe' : 'Unsubscribe',
                          ),
                          tooltip: switch (state.subscribedType) {
                            SubscribedType.notSubscribed => 'Subscribe',
                            SubscribedType.pending => 'Unsubscribe (subscription pending)',
                            SubscribedType.subscribed => 'Unsubscribe',
                            _ => null,
                          },
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.read<CommunityBloc>().add(
                                  ChangeCommunitySubsciptionStatusEvent(
                                    communityId: state.communityId!,
                                    follow: (state.subscribedType == null) ? true : (state.subscribedType == SubscribedType.notSubscribed ? true : false),
                                  ),
                                );
                          },
                        ),
                      IconButton(
                          icon: const Icon(Icons.refresh_rounded, semanticLabel: 'Refresh'),
                          onPressed: () {
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
                          icon: Icon(sortTypeIcon, semanticLabel: 'Sort By'),
                          tooltip: sortTypeLabel,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            showSortBottomSheet(context, state);
                          }),
                      const SizedBox(width: 8.0),
                    ],
                  )
                ],
              ),
              drawer: (widget.communityId != null || widget.communityName != null) ? null : const CommunityDrawer(),
              floatingActionButton: GestureFab(
                distance: 60,
                icon: const Icon(Icons.menu_rounded),
                children: [
                  const ActionButton(
                    onPressed: null/*() {dismissRead();}*/,
                    title: "Dismiss Read",
                    icon: Icon(Icons.clear_all_rounded),
                  ),
                  ActionButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.read<AccountBloc>().add(GetAccountInformation());
                      return context.read<CommunityBloc>().add(GetCommunityPostsEvent(
                        reset: true,
                        sortType: sortType,
                        communityId: state.communityId,
                        listingType: state.listingType,
                        communityName: state.communityName,
                      ));
                    },
                    title: "Refresh",
                    icon: Icon(Icons.refresh),
                  ),
                  const ActionButton(
                    onPressed: null,
                    title: /*compactMode ? "Large View" :*/ "Compact View",
                    icon: /*compactMode ? const Icon(Icons.crop_din_rounded) :*/ Icon(Icons.crop_16_9_rounded),
                  ),
                  ActionButton(
                    onPressed: () => widget.scaffoldKey!.currentState!.openEndDrawer(),
                    title: "Subscriptions",
                    icon: Icon(Icons.people_rounded),
                  ),
                  const ActionButton(
                    onPressed: null/*() {scrollToTop();}*/,
                    title: "Back to Top",
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  SafeArea(child: _getBody(context, state)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Listener(
                      onPointerUp: null,
                      child: Container(
                        color: theme.colorScheme.background.withOpacity(0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
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
          postViews: state.postViews,
          listingType: state.communityId != null ? null : state.listingType,
          communityId: widget.communityId ?? state.communityId,
          communityName: widget.communityName ?? state.communityName,
          hasReachedEnd: state.hasReachedEnd,
          communityInfo: state.communityInfo,
          sortType: state.sortType,
          onScrollEndReached: () => context.read<CommunityBloc>().add(GetCommunityPostsEvent(communityId: widget.communityId)),
          onSaveAction: (int postId, bool save) => context.read<CommunityBloc>().add(SavePostEvent(postId: postId, save: save)),
          onVoteAction: (int postId, VoteType voteType) => context.read<CommunityBloc>().add(VotePostEvent(postId: postId, score: voteType)),
          onToggleReadAction: (int postId, bool read) => context.read<CommunityBloc>().add(MarkPostAsReadEvent(postId: postId, read: read)),
        );
      case CommunityStatus.empty:
        return const Center(child: Text('No posts found'));
    }
  }

  void showSortBottomSheet(BuildContext context, CommunityState state) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (builderContext) => SortPicker(
        title: 'Sort Options',
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
      // return state.postViews?.firstOrNull?.community.name ?? '';
      return '';
    }

    return (state.listingType != null) ? (destinations.firstWhere((destination) => destination.listingType == state.listingType).label) : '';
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    if (currentCommunityBloc != null) {
      // This restricts back button handling to when we're already at the top level of navigation
      final canPop = Navigator.of(context).canPop();

      final prefs = (await UserPreferences.instance).sharedPreferences;
      final desiredPostListingType = PostListingType.values.byName(prefs.getString("setting_general_default_listing_type") ?? DEFAULT_LISTING_TYPE.name);
      final currentPostListingType = currentCommunityBloc!.state.listingType;
      final currentCommunityId = currentCommunityBloc!.state.communityId;

      if (!canPop && (desiredPostListingType != currentPostListingType || currentCommunityId != null)) {
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


@immutable
class GestureFab extends StatefulWidget {
  const GestureFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
    required this.icon,
    this.onSlideUp,
    this.onSlideLeft,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final Icon icon;
  final Function? onSlideUp;
  final Function? onSlideLeft;

  @override
  State<GestureFab> createState() => _GestureFabState();
}

class _GestureFabState extends State<GestureFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    for (var i = 0, distance = widget.distance;
    i < count;
    i++, distance += widget.distance) {
      children.add(
        _ExpandingActionButton(
          maxDistance: distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 200),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onVerticalDragStart: null,
            onHorizontalDragStart: null,
            child: FloatingActionButton(
              onPressed: _toggle,
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    this.title,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        title != null ? Text(title!) : Container(),
        const SizedBox(width: 16),
        SizedBox(
          height: 40,
          width: 40,
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.primaryContainer,
            elevation: 4,
            child: InkWell(
              onTap: onPressed,
              child: icon,
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({

    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          90 * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 8.0 + offset.dx,
          bottom: 10.0 + offset.dy,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}
