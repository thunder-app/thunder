import 'dart:async';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/community_header.dart';
import 'package:thunder/community/widgets/community_sidebar.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_widget.dart';
import 'package:thunder/feed/widgets/feed_fab.dart';
import 'package:thunder/feed/widgets/feed_page_app_bar.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/utils/cache.dart';

enum FeedType { community, user, general }

/// Creates a [FeedPage] which holds a list of posts for a given user, community, or custom feed.
///
/// A [FeedType] must be provided which indicates the type of feed to display.
///
/// If [FeedType.community] is provided, one of [communityId] or [communityName] must be provided. If both are provided, [communityId] will take precedence.
/// If [FeedType.user] is provided, one of [userId] or [username] must be provided. If both are provided, [userId] will take precedence.
/// If [FeedType.general] is provided, [postListingType] must be provided.
///
/// TODO: Add support for user feeds here
class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    this.useGlobalFeedBloc = false,
    required this.feedType,
    this.postListingType,
    required this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.scaffoldStateKey,
    this.scaffoldMessengerKey,
  });

  /// The type of feed to display.
  final FeedType feedType;

  /// The type of general feed to display: all, local, subscribed.
  final ListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  /// This dictates whether we should create a new bloc when the feed is fetched, or use the global feed bloc
  /// The global feed bloc is contains the state of the main feed (without pushing to a new page/route)
  ///
  /// This is useful if we want to keep the user on the "same" page
  final bool useGlobalFeedBloc;

  /// The scaffold key which holds the drawer
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  /// The messenger key back to the main Thunder page
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin<FeedPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    try {
      FeedBloc bloc = context.read<FeedBloc>();

      if (widget.useGlobalFeedBloc && bloc.state.status == FeedStatus.initial) {
        bloc.add(FeedFetchedEvent(
          feedType: widget.feedType,
          postListingType: widget.postListingType,
          sortType: widget.sortType,
          communityId: widget.communityId,
          communityName: widget.communityName,
          userId: widget.userId,
          username: widget.username,
          reset: true,
        ));
      }
    } catch (e) {
      // ignore and continue if we cannot fetch the feed bloc
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// When this is true, we find the feed bloc already present in the widget tree
    /// This is to keep the events on the main page (rather than presenting a new page)
    if (widget.useGlobalFeedBloc) {
      FeedBloc bloc = context.read<FeedBloc>();

      return BlocProvider.value(
        value: bloc,
        child: FeedView(scaffoldStateKey: widget.scaffoldStateKey, scaffoldMessengerKey: widget.scaffoldMessengerKey),
      );
    }

    return BlocProvider<FeedBloc>(
      create: (_) => FeedBloc(lemmyClient: LemmyClient.instance)
        ..add(FeedFetchedEvent(
          feedType: widget.feedType,
          postListingType: widget.postListingType,
          sortType: widget.sortType,
          communityId: widget.communityId,
          communityName: widget.communityName,
          userId: widget.userId,
          username: widget.username,
          reset: true,
        )),
      child: FeedView(scaffoldStateKey: widget.scaffoldStateKey, scaffoldMessengerKey: widget.scaffoldMessengerKey),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key, this.scaffoldStateKey, this.scaffoldMessengerKey});

  /// The scaffold key which holds the drawer
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  /// The messenger key back to the main Thunder page
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();

  /// Boolean which indicates whether the title on the app bar should be shown
  bool showAppBarTitle = false;

  /// Boolean which indicates whether the community sidebar should be shown
  bool showCommunitySidebar = false;

  /// List of post ids to queue for removal. The ids in this list allow us to remove posts in a staggered method
  List<int> queuedForRemoval = [];

  final GlobalKey<ScaffoldMessengerState> _key = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // Updates the [showAppBarTitle] value when the user has scrolled past a given threshold
      if (_scrollController.position.pixels > 100.0 && showAppBarTitle == false) {
        setState(() => showAppBarTitle = true);
      } else if (_scrollController.position.pixels < 100.0 && showAppBarTitle == true) {
        setState(() => showAppBarTitle = false);
      }

      // Fetches new posts when the user has scrolled past 70% list
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7 && context.read<FeedBloc>().state.status != FeedStatus.fetching) {
        context.read<FeedBloc>().add(const FeedFetchedEvent());
      }
    });

    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  /// This function is called whenever the user triggers the dismiss read FAB action
  /// It looks for any posts that have been read, and adds them to the [queuedForRemoval] list
  ///
  /// Once those posts are fully added, an event is triggered which filters those posts from the feed bloc state
  Future<void> dismissRead() async {
    ThunderState state = context.read<ThunderBloc>().state;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<PostViewMedia> postViewMedias = feedBloc.state.postViewMedias;

    if (postViewMedias.isNotEmpty) {
      for (PostViewMedia postViewMedia in postViewMedias) {
        if (postViewMedia.postView.read) {
          setState(() => queuedForRemoval.add(postViewMedia.postView.post.id));
          await Future.delayed(Duration(milliseconds: state.useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    ThunderBloc thunderBloc = context.watch<ThunderBloc>();
    final l10n = AppLocalizations.of(context)!;

    bool tabletMode = thunderBloc.state.tabletMode;
    bool hideTopBarOnScroll = thunderBloc.state.hideTopBarOnScroll;

    return MultiBlocListener(
      listeners: [
        BlocListener<CommunityBloc, CommunityState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackbar(context, state.message!);
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if ((state.status == UserStatus.failure || state.status == UserStatus.failedToBlock) && state.errorMessage != null) {
              showSnackbar(context, state.errorMessage!);
            } else if (state.status == UserStatus.success && state.blockedPerson != null) {
              showSnackbar(context, l10n.successfullyBlocked);
            }
          },
        ),
        BlocListener<InstanceBloc, InstanceState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackbar(context, state.message!);
            }
          },
        ),
      ],
      child: ScaffoldMessenger(
        key: _key,
        child: Scaffold(
          body: SafeArea(
            top: hideTopBarOnScroll, // Don't apply to top of screen to allow for the status bar colour to extend
            child: BlocConsumer<FeedBloc, FeedState>(
              listenWhen: (previous, current) {
                if (current.status == FeedStatus.initial) setState(() => showAppBarTitle = false);
                if (previous.scrollId != current.scrollId) _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                if (previous.dismissReadId != current.dismissReadId) dismissRead();
                return true;
              },
              listener: (context, state) {
                // Continue to fetch more posts as long as the device view is not scrollable.
                // This is to avoid cases where more posts cannot be fetched because the conditions are not met
                if (state.status == FeedStatus.success && state.hasReachedEnd == false) {
                  bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
                  if (!isScrollable) context.read<FeedBloc>().add(const FeedFetchedEvent());
                }

                if ((state.status == FeedStatus.failure || state.status == FeedStatus.failureLoadingCommunity) && state.message != null) {
                  showSnackbar(context, state.message!);
                  context.read<FeedBloc>().add(FeedClearMessageEvent()); // Clear the message so that it does not spam
                }
              },
              builder: (context, state) {
                final theme = Theme.of(context);
                List<PostViewMedia> postViewMedias = state.postViewMedias;

                return RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    triggerRefresh(context);
                  },
                  edgeOffset: 95.0, // This offset is placed to allow the correct positioning of the refresh indicator
                  child: Stack(
                    children: [
                      CustomScrollView(
                        physics: showCommunitySidebar ? const NeverScrollableScrollPhysics() : null, // Disable scrolling on the feed page when the community sidebar is open
                        controller: _scrollController,
                        slivers: <Widget>[
                          FeedPageAppBar(
                            showAppBarTitle: (state.feedType == FeedType.general && state.status != FeedStatus.initial) ? true : showAppBarTitle,
                            scaffoldStateKey: widget.scaffoldStateKey,
                          ),
                          // Display loading indicator until the feed is fetched
                          if (state.status == FeedStatus.initial)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (state.status == FeedStatus.failureLoadingCommunity)
                            SliverToBoxAdapter(
                              child: Container(),
                            ),
                          // Display tagline and list of posts once they are fetched
                          if (state.status != FeedStatus.initial && state.status != FeedStatus.failureLoadingCommunity) ...[
                            SliverToBoxAdapter(
                              child: Visibility(
                                visible: state.feedType == FeedType.general && state.status != FeedStatus.initial,
                                child: const TagLine(),
                              ),
                            ),
                            if (state.fullCommunityView != null)
                              SliverToBoxAdapter(
                                child: Visibility(
                                  visible: state.feedType == FeedType.community,
                                  child: CommunityHeader(
                                    getCommunityResponse: state.fullCommunityView!,
                                    showCommunitySidebar: showCommunitySidebar,
                                    onToggle: (bool toggled) {
                                      // Scroll to top first before showing the sidebar
                                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                      setState(() => showCommunitySidebar = toggled);
                                    },
                                  ),
                                ),
                              ),
                            SliverStack(
                              children: [
                                // Widget representing the list of posts on the feed
                                FeedPostList(
                                  postViewMedias: postViewMedias,
                                  tabletMode: tabletMode,
                                  queuedForRemoval: queuedForRemoval,
                                ),
                                // Widgets to display on the feed when feedType == FeedType.community
                                SliverToBoxAdapter(
                                  child: AnimatedSwitcher(
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeOut,
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                          CurvedAnimation(parent: animation, curve: const Interval(0, 1.0)),
                                        ),
                                        child: child,
                                      );
                                    },
                                    duration: const Duration(milliseconds: 300),
                                    child: showCommunitySidebar
                                        ? GestureDetector(
                                            onTap: () => setState(() => showCommunitySidebar = !showCommunitySidebar),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height,
                                              width: MediaQuery.of(context).size.width,
                                              color: Colors.black.withOpacity(0.5),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                // Contains the widget for the community sidebar
                                SliverToBoxAdapter(
                                  child: AnimatedSwitcher(
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeOut,
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position: Tween<Offset>(begin: const Offset(1.2, 0), end: const Offset(0, 0)).animate(animation),
                                        child: child,
                                      );
                                    },
                                    duration: const Duration(milliseconds: 300),
                                    child: showCommunitySidebar
                                        ? CommunitySidebar(
                                            getCommunityResponse: state.fullCommunityView,
                                            onDismiss: () => setState(() => showCommunitySidebar = false),
                                          )
                                        : Container(),
                                  ),
                                ),
                              ],
                            ),
                            // Widget representing the bottom of the feed (reached end or loading more posts indicators)
                            SliverToBoxAdapter(
                              child: state.hasReachedEnd
                                  ? const FeedReachedEnd()
                                  : Container(
                                      height: state.status == FeedStatus.initial ? MediaQuery.of(context).size.height * 0.5 : null, // Might have to adjust this to be more robust
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: const CircularProgressIndicator(),
                                    ),
                            ),
                          ],
                        ],
                      ),
                      // Widget to host the feed FAB when navigating to new page
                      AnimatedOpacity(
                        opacity: thunderBloc.state.isFabOpen ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: thunderBloc.state.isFabOpen
                            ? ModalBarrier(
                                color: theme.colorScheme.background.withOpacity(0.95),
                                dismissible: true,
                                onDismiss: () => context.read<ThunderBloc>().add(const OnFabToggle(false)),
                              )
                            : null,
                      ),
                      if (Navigator.of(context).canPop() && (state.communityId != null || state.communityName != null) && thunderBloc.state.enableFeedsFab)
                        AnimatedOpacity(
                          opacity: (thunderBloc.state.enableFeedsFab) ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeIn,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            child: FeedFAB(
                              heroTag: state.communityName,
                              scaffoldMessengerKey: widget.scaffoldMessengerKey,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    final bool topOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    // If the sidebar is open, close it
    if (topOfNavigationStack && showCommunitySidebar) {
      setState(() => showCommunitySidebar = false);
      return true;
    }

    FeedBloc feedBloc = context.read<FeedBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();

    // See if we're at the top level of navigation
    final canPop = Navigator.of(context).canPop();

    // Get the desired post listing so we can check against current
    final desiredListingType = thunderBloc.state.defaultListingType;
    final currentListingType = feedBloc.state.postListingType;

    // See if we're in a community
    final communityMode = feedBloc.state.feedType == FeedType.community;

    // If
    // - We're at the top level of navigation AND
    // - We're not on the desired listing type OR
    // - We're on a community
    // THEN navigate to the desired listing type
    if (!canPop && (desiredListingType != currentListingType || communityMode)) {
      feedBloc.add(
        FeedFetchedEvent(
          sortType: thunderBloc.state.defaultSortType,
          reset: true,
          postListingType: desiredListingType,
          feedType: FeedType.general,
          communityId: null,
        ),
      );

      return true;
    }
    return false;
  }
}

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getCommunityName(feedBloc.state),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Icon(getSortIcon(feedBloc.state), size: 17),
            const SizedBox(width: 4),
            Text(
              getSortName(feedBloc.state),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}

class TagLine extends StatelessWidget {
  const TagLine({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taglineToShowCache = Cache<String>();

    final fullSiteView = context.read<AuthBloc>().state.getSiteResponse;
    if (fullSiteView == null || fullSiteView.taglines.isEmpty) return Container();

    String tagline = taglineToShowCache.getOrSet(() {
      String tagline = fullSiteView.taglines[Random().nextInt(fullSiteView.taglines.length)].content;
      return tagline;
    }, const Duration(seconds: 1));

    final bool taglineIsLong = tagline.length > 200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.splashColor,
          borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: !taglineIsLong
              // TODO: Eventually pass in textScalingFactor
              ? CommonMarkdownBody(body: tagline)
              : ExpandableNotifier(
                  child: Column(
                    children: [
                      Expandable(
                        collapsed: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // TODO: Eventually pass in textScalingFactor
                            CommonMarkdownBody(
                              body: '${tagline.substring(0, 150)}...',
                            ),
                            ExpandableButton(
                              theme: const ExpandableThemeData(
                                useInkWell: false,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.showMore,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        expanded: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CommonMarkdownBody(body: tagline),
                            ExpandableButton(
                              theme: const ExpandableThemeData(useInkWell: false),
                              child: Text(
                                AppLocalizations.of(context)!.showLess,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class FeedReachedEnd extends StatelessWidget {
  const FeedReachedEnd({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.dividerColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: ScalableText(
            'Hmmm. It seems like you\'ve reached the bottom.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
            fontScale: state.metadataFontSizeScale,
          ),
        ),
        const SizedBox(height: 160)
      ],
    );
  }
}
