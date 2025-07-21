import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/widgets/community_header/community_header.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/enums/feed_type_subview.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/widgets/feed_comment_card_list.dart';
import 'package:thunder/feed/widgets/feed_post_card_list.dart';
import 'package:thunder/feed/widgets/feed_fab.dart';
import 'package:thunder/feed/widgets/feed_page_app_bar.dart';
import 'package:thunder/feed/widgets/tagline.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/widgets/user_header/user_header.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/navigation.dart';

enum FeedType { community, user, general, account }

/// Creates a [FeedPage] which holds a list of posts for a given user, community, or custom feed.
///
/// A [FeedType] must be provided which indicates the type of feed to display.
///
/// If [FeedType.community] is provided, one of [communityId] or [communityName] must be provided. If both are provided, [communityId] will take precedence.
/// If [FeedType.user] is provided, one of [userId] or [username] must be provided. If both are provided, [userId] will take precedence.
/// If [FeedType.general] is provided, [feedListType] must be provided.
/// If [FeedType.account] is provided, then it should show the currently logged in user's posts/comments.
class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    this.useGlobalFeedBloc = false,
    required this.feedType,
    this.feedListType,
    required this.postSortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.scaffoldStateKey,
    this.showHidden = false,
  });

  /// The type of feed to display.
  final FeedType feedType;

  /// The type of general feed to display: all, local, subscribed.
  final FeedListType? feedListType;

  /// The sorting to be applied to the feed.
  final PostSortType? postSortType;

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

  /// Whether to show hidden posts in the feed
  final bool showHidden;

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
          feedListType: widget.feedListType,
          postSortType: widget.postSortType,
          communityId: widget.communityId,
          communityName: widget.communityName,
          userId: widget.userId,
          username: widget.username,
          reset: true,
          showHidden: widget.showHidden,
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
        child: FeedView(scaffoldStateKey: widget.scaffoldStateKey, feedType: widget.feedType),
      );
    }

    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return BlocProvider<FeedBloc>(
      create: (_) => FeedBloc(account: account)
        ..add(FeedFetchedEvent(
          feedType: widget.feedType,
          feedListType: widget.feedListType,
          postSortType: widget.postSortType,
          communityId: widget.communityId,
          communityName: widget.communityName,
          userId: widget.userId,
          username: widget.username,
          reset: true,
          showHidden: widget.showHidden,
        )),
      child: FeedView(scaffoldStateKey: widget.scaffoldStateKey, feedType: widget.feedType),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key, this.scaffoldStateKey, this.feedType});

  /// The scaffold key which holds the drawer
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  /// The type of feed to display
  final FeedType? feedType;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();

  /// Indicates which "tab" is selected. This is used for user profiles, where we can switch between posts and comments
  List<bool> selectedUserOption = [true, false];

  /// List of post ids to queue for removal. The ids in this list allow us to remove posts in a staggered method
  List<int> queuedForRemoval = [];

  String? tagline;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // Fetches new posts when the user has scrolled past 70% list
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7 && context.read<FeedBloc>().state.status != FeedStatus.fetching) {
        context.read<FeedBloc>().add(FeedFetchedEvent(feedTypeSubview: selectedUserOption[0] ? FeedTypeSubview.post : FeedTypeSubview.comment));
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
    List<ThunderPost> posts = feedBloc.state.posts;

    if (posts.isNotEmpty) {
      for (ThunderPost post in posts) {
        if (post.read == true) {
          setState(() => queuedForRemoval.add(post.id));
          await Future.delayed(Duration(milliseconds: state.useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  Future<void> dismissBlockedUsersAndCommunities(int? userId, int? communityId) async {
    ThunderState state = context.read<ThunderBloc>().state;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<ThunderPost> posts = feedBloc.state.posts;

    if (posts.isNotEmpty) {
      for (ThunderPost post in posts) {
        if (post.creator?.id == userId || post.community?.id == communityId) {
          setState(() => queuedForRemoval.add(post.id));
          await Future.delayed(Duration(milliseconds: state.useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  Future<void> dismissHiddenPost(int postId) async {
    ThunderState state = context.read<ThunderBloc>().state;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<ThunderPost> posts = feedBloc.state.posts;

    if (posts.isNotEmpty) {
      for (ThunderPost post in posts) {
        if (post.id == postId) {
          setState(() => queuedForRemoval.add(post.id));
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    bool tabletMode = thunderBloc.state.tabletMode;
    bool markPostReadOnScroll = thunderBloc.state.markPostReadOnScroll;
    bool hideTopBarOnScroll = thunderBloc.state.hideTopBarOnScroll;

    return MultiBlocListener(
      listeners: [
        BlocListener<CommunityBloc, CommunityState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackbar(state.message!);
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackbar(state.message!);
            }
          },
        ),
        BlocListener<InstanceBloc, InstanceState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackbar(state.message!);
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: BlocConsumer<FeedBloc, FeedState>(
            listenWhen: (previous, current) {
              if (previous.scrollId != current.scrollId) _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              if (previous.dismissReadId != current.dismissReadId) dismissRead();
              if (current.dismissBlockedUserId != null || current.dismissBlockedCommunityId != null) dismissBlockedUsersAndCommunities(current.dismissBlockedUserId, current.dismissBlockedCommunityId);
              if (current.dismissHiddenPostId != null && !thunderBloc.state.showHiddenPosts) dismissHiddenPost(current.dismissHiddenPostId!);
              if (current.excessiveApiCalls) {
                showSnackbar(
                  l10n.excessiveApiCallsWarning,
                  trailingIcon: Icons.settings_rounded,
                  trailingAction: () => navigateToSettingPage(context, LocalSettings.settingsPageFilters, settingToHighlight: LocalSettings.keywordFilters),
                );
              }
              return true;
            },
            listener: (context, state) {
              // Continue to fetch more items as long as the device view is not scrollable.
              // This is to avoid cases where more items cannot be fetched because the conditions are not met
              if (state.status == FeedStatus.success && ((selectedUserOption[0] && state.hasReachedPostsEnd == false) || (selectedUserOption[1] && state.hasReachedCommentsEnd == false))) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!mounted) return;
                  bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
                  if (!isScrollable) context.read<FeedBloc>().add(const FeedFetchedEvent());
                });
              }

              if ((state.status == FeedStatus.failure || state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser) && state.message != null) {
                showSnackbar(state.message!);
                context.read<FeedBloc>().add(FeedClearMessageEvent()); // Clear the message so that it does not spam
              }
            },
            builder: (context, state) {
              final theme = Theme.of(context);
              List<ThunderPost> posts = state.posts;
              List<ThunderComment> comments = state.comments;

              return RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  triggerRefresh(context);
                },
                edgeOffset: MediaQuery.of(context).padding.top + APP_BAR_HEIGHT, // This offset is placed to allow the correct positioning of the refresh indicator
                child: Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        widget.feedType == FeedType.account
                            ? AccountPageAppBar(scrollController: _scrollController)
                            : FeedPageAppBar(scrollController: _scrollController, scaffoldStateKey: widget.scaffoldStateKey),
                        // Display loading indicator until the feed is fetched
                        if (state.status == FeedStatus.initial)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser)
                          SliverToBoxAdapter(
                            child: Container(),
                          ),
                        // Display tagline and list of posts once they are fetched
                        if (state.status != FeedStatus.initial && (state.status != FeedStatus.failureLoadingCommunity || state.status != FeedStatus.failureLoadingUser)) ...[
                          SliverToBoxAdapter(
                            child: Visibility(
                              visible: state.feedType == FeedType.general && state.status != FeedStatus.initial,
                              child: TagLine(),
                            ),
                          ),
                          if (state.community != null && state.feedType == FeedType.community)
                            SliverToBoxAdapter(
                              child: CommunityHeader(
                                community: state.community!,
                                instance: state.communityInstance,
                                moderators: state.communityModerators,
                                condensed: false,
                              ),
                            ),
                          if (state.user != null && (state.feedType == FeedType.user || state.feedType == FeedType.account))
                            SliverToBoxAdapter(
                              child: UserHeader(
                                user: state.user!,
                                moderates: state.userModerates,
                                feedType: selectedUserOption[0] ? FeedTypeSubview.post : FeedTypeSubview.comment,
                                onChangeFeedType: (feedType) {
                                  setState(() {
                                    selectedUserOption[0] = feedType == FeedTypeSubview.post;
                                    selectedUserOption[1] = feedType == FeedTypeSubview.comment;
                                  });
                                },
                                condensed: false,
                              ),
                            ),
                          selectedUserOption[1]
                              // Widget representing the list of user comments on the feed
                              ? FeedCommentCardList(
                                  comments: comments,
                                  tabletMode: tabletMode,
                                )
                              :
                              // Widget representing the list of posts on the feed
                              FeedPostCardList(
                                  posts: posts,
                                  tabletMode: tabletMode,
                                  markPostReadOnScroll: markPostReadOnScroll,
                                  queuedForRemoval: queuedForRemoval,
                                  dimReadPosts: state.feedType == FeedType.account ? false : null,
                                ),
                          // Widget representing the bottom of the feed (reached end or loading more posts indicators)
                          if (state.status != FeedStatus.failureLoadingCommunity && state.status != FeedStatus.failureLoadingUser)
                            SliverToBoxAdapter(
                              child: ((selectedUserOption[0] && state.hasReachedPostsEnd) || (selectedUserOption[1] && state.hasReachedCommentsEnd))
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
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 250),
                      child: Stack(
                        children: [
                          IgnorePointer(
                              child: Container(
                            color: theme.colorScheme.surface.withValues(alpha: 0.95),
                          )),
                          if (thunderBloc.state.isFabOpen)
                            ModalBarrier(
                              color: null,
                              dismissible: true,
                              onDismiss: () => context.read<ThunderBloc>().add(const OnFabToggle(false)),
                            ),
                        ],
                      ),
                    ),
                    if (Navigator.of(context).canPop() &&
                        (state.communityId != null || state.communityName != null || state.userId != null || state.username != null) &&
                        thunderBloc.state.enableFeedsFab &&
                        state.feedType != FeedType.account)
                      AnimatedOpacity(
                        opacity: (thunderBloc.state.enableFeedsFab) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeIn,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: FeedFAB(heroTag: state.communityName ?? state.username),
                        ),
                      ),
                    if (hideTopBarOnScroll)
                      Positioned(
                        child: Container(
                          height: MediaQuery.of(context).padding.top,
                          color: theme.colorScheme.surface,
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    ProfileBloc authBloc = context.read<ProfileBloc>();
    FeedBloc feedBloc = context.read<FeedBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();

    // See if we're at the top level of navigation
    final canPop = Navigator.of(context).canPop();

    if (widget.feedType == FeedType.account) {
      return false;
    }

    // Get the desired post listing so we can check against current
    final desiredFeedListType = authBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultListingType ?? thunderBloc.state.defaultFeedListType;
    final currentFeedListType = feedBloc.state.feedListType;

    // See if we're in a community
    final communityMode = feedBloc.state.feedType == FeedType.community;

    // If
    // - We're at the top level of navigation AND
    // - We're not on the desired listing type OR
    // - We're on a community
    // THEN navigate to the desired listing type
    if (!canPop && (desiredFeedListType != currentFeedListType || communityMode)) {
      final postSortType = authBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? thunderBloc.state.postSortTypeForInstance;

      feedBloc.add(
        FeedFetchedEvent(
          postSortType: postSortType,
          reset: true,
          feedListType: desiredFeedListType,
          feedType: FeedType.general,
          communityId: null,
          showHidden: thunderBloc.state.showHiddenPosts,
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
          getAppBarTitle(feedBloc.state),
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

class FeedReachedEnd extends StatelessWidget {
  const FeedReachedEnd({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.dividerColor.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: ScalableText(
            l10n.reachedTheBottom,
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
