import 'dart:math';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/widgets/community_header.dart';
import 'package:thunder/community/widgets/community_sidebar.dart';
import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/widgets/feed_page_app_bar.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
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
  });

  /// The type of feed to display.
  final FeedType feedType;

  /// The type of general feed to display: all, local, subscribed.
  final PostListingType? postListingType;

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

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin<FeedPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// When this is true, we find the feed bloc already present in the widget tree
    /// This is to keep the events on the main page (rather than presenting a new page)
    if (widget.useGlobalFeedBloc) {
      FeedBloc bloc = context.read<FeedBloc>();

      if (bloc.state.status == FeedStatus.initial) {
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

      return BlocProvider.value(
        value: bloc,
        child: const FeedView(),
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
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

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
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7) {
        context.read<FeedBloc>().add(const FeedFetchedEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    bool tabletMode = context.read<ThunderBloc>().state.tabletMode;

    return BlocConsumer<FeedBloc, FeedState>(
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

        if (state.status == FeedStatus.failure && state.message != null) {
          showSnackbar(context, state.message!);
          context.read<FeedBloc>().add(FeedClearMessageEvent()); // Clear the message so that it does not spam
        }
      },
      builder: (context, state) {
        List<PostViewMedia> postViewMedias = state.postViewMedias;

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            triggerRefresh(context);
          },
          edgeOffset: 110.0,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  FeedPageAppBar(showAppBarTitle: showAppBarTitle),
                  SliverToBoxAdapter(
                    child: Visibility(
                      visible: state.feedType == FeedType.general && state.status != FeedStatus.initial,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FeedHeader(),
                            TagLine(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Visibility(
                      visible: state.feedType == FeedType.community,
                      child: GestureDetector(
                        onTap: () => setState(() => showCommunitySidebar = true),
                        child: CommunityHeader(communityInfo: state.fullCommunityView),
                      ),
                    ),
                  ),
                  SliverMasonryGrid.count(
                    crossAxisCount: tabletMode ? 2 : 1,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 0,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimatedSwitcher(
                        switchOutCurve: Curves.ease,
                        duration: const Duration(milliseconds: 0),
                        reverseDuration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(parent: animation, curve: const Interval(0.5, 1.0)),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(1.2, 0), end: const Offset(0, 0)).animate(animation),
                              child: SizeTransition(
                                sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: const Interval(0.0, 0.25),
                                  ),
                                ),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: !queuedForRemoval.contains(postViewMedias[index].postView.post.id)
                            ? PostCard(
                                postViewMedia: postViewMedias[index],
                                communityMode: state.feedType == FeedType.community,
                                onVoteAction: (VoteType voteType) {
                                  context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.vote, value: voteType));
                                },
                                onSaveAction: (bool saved) {
                                  context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.save, value: saved));
                                },
                                onReadAction: (bool read) {
                                  context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.read, value: read));
                                },
                                listingType: state.postListingType,
                                indicateRead: true,
                              )
                            : null,
                      );
                    },
                    childCount: postViewMedias.length,
                  ),
                  SliverToBoxAdapter(
                    child: state.hasReachedEnd
                        ? const FeedReachedEnd()
                        : Container(
                            height: state.status == FeedStatus.initial ? MediaQuery.of(context).size.height / 1.5 : null, // Might have to adjust this to be more robust
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: const CircularProgressIndicator(),
                          ),
                  ),
                ],
              ),
              if (showCommunitySidebar) ModalBarrier(color: context.read<ThemeBloc>().state.themeType == ThemeType.light ? Colors.white.withOpacity(1) : Colors.black.withOpacity(0.5)),
              AnimatedSwitcher(
                switchInCurve: Curves.decelerate,
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
                        fullCommunityView: state.fullCommunityView!,
                        onDismissed: () => setState(() => showCommunitySidebar = false),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
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

    final fullSiteView = context.read<AuthBloc>().state.fullSiteView!;
    if (fullSiteView.taglines.isEmpty) return Container();

    String tagline = taglineToShowCache.getOrSet(() {
      String tagline = fullSiteView.taglines[Random().nextInt(fullSiteView.taglines.length)].content;
      return tagline;
    }, const Duration(seconds: 1));

    final bool taglineIsLong = tagline.length > 200;

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
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
          child: Text(
            'Hmmm. It seems like you\'ve reached the bottom.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
            textScaleFactor: MediaQuery.of(context).textScaleFactor * state.metadataFontSizeScale.textScaleFactor,
          ),
        ),
        const SizedBox(height: 160)
      ],
    );
  }
}
