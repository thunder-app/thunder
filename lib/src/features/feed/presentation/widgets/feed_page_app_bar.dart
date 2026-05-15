import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';

/// Holds the app bar for the feed page. The app bar actions changes depending on the type of feed (general, community, user)
class FeedPageAppBar extends StatefulWidget {
  const FeedPageAppBar({super.key, required this.scrollController, this.scaffoldStateKey});

  /// The scroll controller used to determine when to show/hide the app bar title
  final ScrollController scrollController;

  /// The scaffold key of the parent scaffold holding the drawer.
  /// This is used to determine if we are in a pushed navigation stack.
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  @override
  State<FeedPageAppBar> createState() => _FeedPageAppBarState();
}

class _FeedPageAppBarState extends State<FeedPageAppBar> {
  /// Boolean which indicates whether the title on the app bar should be shown
  bool showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Updates the [showAppBarTitle] value when the user has scrolled past a given threshold
    if (widget.scrollController.position.pixels > 100.0 && showAppBarTitle == false) {
      setState(() => showAppBarTitle = true);
    } else if (widget.scrollController.position.pixels < 100.0 && showAppBarTitle == true) {
      setState(() => showAppBarTitle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedBloc = context.read<FeedBloc>();
    final hideTopBarOnScroll = context.select<ThunderCubit, bool>((cubit) => cubit.state.hideTopBarOnScroll);
    final useProfilePictureForDrawer = context.select<ThunderCubit, bool>((cubit) => cubit.state.useProfilePictureForDrawer);
    final isLoggedIn = context.select<ProfileBloc, bool>((bloc) => bloc.state.isLoggedIn);
    final feedChrome = context.select<FeedBloc, ({FeedStatus status, FeedType? feedType})>((bloc) => (status: bloc.state.status, feedType: bloc.state.feedType));

    return BlocListener<FeedBloc, FeedState>(
      listenWhen: (previous, current) => previous.status != current.status && current.status == FeedStatus.initial,
      listener: (context, state) => setState(() => showAppBarTitle = false),
      child: SliverAppBar(
        pinned: !hideTopBarOnScroll,
        floating: true,
        centerTitle: false,
        toolbarHeight: APP_BAR_HEIGHT,
        surfaceTintColor: hideTopBarOnScroll ? Colors.transparent : null,
        title: FeedAppBarTitle(visible: (feedChrome.feedType == FeedType.general && feedChrome.status != FeedStatus.initial) ? true : showAppBarTitle),
        leadingWidth: widget.scaffoldStateKey != null && useProfilePictureForDrawer && isLoggedIn ? 50 : null,
        leading: feedChrome.status == FeedStatus.initial
            ? null
            : FeedDrawerButton(
                isRoot: widget.scaffoldStateKey != null,
                showProfilePicture: useProfilePictureForDrawer && isLoggedIn,
                onTap: () => _openDrawerOrGoBack(context, feedBloc),
              ),
        actions: (feedChrome.status != FeedStatus.initial && feedChrome.status != FeedStatus.failureLoadingCommunity && feedChrome.status != FeedStatus.failureLoadingUser)
            ? [
                if (feedChrome.feedType == FeedType.general) const FeedAppBarGeneralActions(),
                if (feedChrome.feedType == FeedType.community) const FeedAppBarCommunityActions(),
                if (feedChrome.feedType == FeedType.user) const FeedAppBarUserActions(),
              ]
            : [],
      ),
    );
  }

  void _openDrawerOrGoBack(BuildContext context, FeedBloc feedBloc) {
    HapticFeedback.mediumImpact();
    (widget.scaffoldStateKey == null && (feedBloc.state.feedType == FeedType.community || feedBloc.state.feedType == FeedType.user))
        ? Navigator.of(context).maybePop()
        : widget.scaffoldStateKey?.currentState?.openDrawer();
  }
}
