import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/identity/presentation/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderPopupMenuItem;

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
    final thunderBloc = context.read<ThunderBloc>();
    final ProfileState profileState = context.read<ProfileBloc>().state;

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
            : _FeedDrawerButton(
                isRoot: widget.scaffoldStateKey != null,
                showProfilePicture: thunderBloc.state.useProfilePictureForDrawer && profileState.isLoggedIn,
                onTap: () => _openDrawerOrGoBack(context, feedBloc),
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
    final feedBloc = context.read<FeedBloc>();
    final postSortType = feedBloc.state.postSortType;

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
                builder: (builderContext) => SortPicker<PostSortType>(
                  account: feedBloc.account,
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
                builder: (builderContext) => SortPicker<PostSortType>(
                  account: feedBloc.account,
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
              builder: (builderContext) => SortPicker<PostSortType>(
                account: feedBloc.account,
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
                  await navigateToModlogPage(context, subtitle: context.read<ProfileBloc>().state.account.instance);
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

/// The drawer button for the feed page app bar.
///
/// If [showProfilePicture] is true, then the profile picture will be shown. Otherwise, it falls back to the default back button.
class _FeedDrawerButton extends StatelessWidget {
  const _FeedDrawerButton({
    required this.showProfilePicture,
    required this.onTap,
    required this.isRoot,
  });

  /// Whether the feed is the main feed. This is defined by a non-null [scaffoldStateKey].
  final bool isRoot;

  /// Whether to display the profile picture in place of the drawer icon.
  final bool showProfilePicture;

  /// The function to call when the drawer is tapped.
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    // Show profile picture only if it's the root feed and profile picture is enabled
    if (isRoot && showProfilePicture) {
      return _buildProfilePictureButton(context);
    }
    return _buildIconButton(context);
  }

  Widget _buildProfilePictureButton(BuildContext context) {
    final state = context.read<ProfileBloc>().state;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Semantics(
        label: MaterialLocalizations.of(context).openAppDrawerTooltip,
        child: Stack(
          children: [
            if (state.user != null)
              Align(
                alignment: Alignment.center,
                child: UserAvatar(user: state.user!),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context) {
    final IconData icon;
    final String semanticLabel;

    if (isRoot) {
      icon = Icons.menu;
      semanticLabel = MaterialLocalizations.of(context).openAppDrawerTooltip;
    } else {
      icon = (!kIsWeb && Platform.isIOS) ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded;
      semanticLabel = MaterialLocalizations.of(context).backButtonTooltip;
    }

    return IconButton(
      icon: Icon(icon, semanticLabel: semanticLabel),
      onPressed: onTap,
    );
  }
}
