import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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
  ThunderUser? user;

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
    final thunderBloc = context.read<ThunderBloc>();
    final ProfileState profileState = context.read<ProfileBloc>().state;

    user = profileState.reload ? profileState.user : user;

    return BlocListener<FeedBloc, FeedState>(
      listenWhen: (previous, current) => current.status == FeedStatus.initial,
      listener: (context, state) {
        if (state.status == FeedStatus.initial) {
          setState(() => showAppBarTitle = false);
        }
      },
      child: SliverAppBar(
        pinned: !thunderBloc.state.hideTopBarOnScroll,
        floating: true,
        centerTitle: false,
        toolbarHeight: APP_BAR_HEIGHT,
        surfaceTintColor: thunderBloc.state.hideTopBarOnScroll ? Colors.transparent : null,
        title: FeedAppBarTitle(visible: (feedBloc.state.feedType == FeedType.general && feedBloc.state.status != FeedStatus.initial) ? true : showAppBarTitle),
        leadingWidth: widget.scaffoldStateKey != null && thunderBloc.state.useProfilePictureForDrawer && profileState.isLoggedIn ? 50 : null,
        leading: feedBloc.state.status == FeedStatus.initial
            ? null
            : widget.scaffoldStateKey != null && thunderBloc.state.useProfilePictureForDrawer && profileState.isLoggedIn
                ? Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Semantics(
                      label: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      child: Stack(
                        children: [
                          if (user != null)
                            Align(
                              alignment: Alignment.center,
                              child: UserAvatar(user: user!),
                            ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _openDrawerOrGoBack(context, feedBloc),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : IconButton(
                    icon: widget.scaffoldStateKey == null
                        ? (!kIsWeb && Platform.isIOS
                            ? Icon(
                                Icons.arrow_back_ios_new_rounded,
                                semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                              )
                            : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip))
                        : Icon(Icons.menu, semanticLabel: MaterialLocalizations.of(context).openAppDrawerTooltip),
                    onPressed: () => _openDrawerOrGoBack(context, feedBloc),
                  ),
        actions: (feedBloc.state.status != FeedStatus.initial && feedBloc.state.status != FeedStatus.failureLoadingCommunity && feedBloc.state.status != FeedStatus.failureLoadingUser)
            ? [
                if (feedBloc.state.feedType == FeedType.general) const FeedAppBarGeneralActions(),
                if (feedBloc.state.feedType == FeedType.community) const FeedAppBarCommunityActions(),
                if (feedBloc.state.feedType == FeedType.user) const FeedAppBarUserActions(),
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

/// The title of the app bar. This shows the title (feed type, community, user) and the sort type
class FeedAppBarTitle extends StatelessWidget {
  const FeedAppBarTitle({super.key, this.visible = true});

  /// Whether to show the title. When the user scrolls down the title will be hidden
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
          getAppBarTitle(feedBloc.state),
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

/// The actions of the app bar for the community feed.
class FeedAppBarCommunityActions extends StatelessWidget {
  const FeedAppBarCommunityActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final postSortType = context.read<FeedBloc>().state.postSortType;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
            onPressed: () {
              HapticFeedback.mediumImpact();
              triggerRefresh(context);
            },
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
                  onSelect: (selected) async => context.read<FeedBloc>().add(FeedChangePostSortTypeEvent(selected.payload)),
                  previouslySelected: postSortType,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The actions of the app bar for the user feed.
class FeedAppBarUserActions extends StatelessWidget {
  const FeedAppBarUserActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
            onPressed: () {
              HapticFeedback.mediumImpact();
              triggerRefresh(context);
            },
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
                  onSelect: (selected) async => feedBloc.add(FeedChangePostSortTypeEvent(selected.payload)),
                  previouslySelected: feedBloc.state.postSortType,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The actions of the app bar for the general feed.
class FeedAppBarGeneralActions extends StatelessWidget {
  const FeedAppBarGeneralActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final feedBloc = context.read<FeedBloc>();

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
                onSelect: (selected) async => feedBloc.add(FeedChangePostSortTypeEvent(selected.payload)),
                previouslySelected: feedBloc.state.postSortType,
              ),
            );
          },
        ),
        Semantics(
          label: l10n.menu,
          child: PopupMenuButton(
            onOpened: () => HapticFeedback.mediumImpact(),
            itemBuilder: (context) => [
              ThunderPopupMenuItem(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await navigateToModlogPage(context, subtitle: 'TODO: Implement modlog subtitle');
                },
                icon: Icons.shield_rounded,
                title: l10n.modlog,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
