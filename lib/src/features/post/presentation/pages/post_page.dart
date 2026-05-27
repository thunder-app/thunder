import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';

import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_fab_overlay.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_page_floating_action_button.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_page_scroll_body.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_top_bar_scrim.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

/// A page that displays the post details and comments associated with a post.
class PostPage extends StatefulWidget {
  /// The initial [ThunderPost] that should be displayed in the page.
  /// When a post action is performed, the post bloc's [post] is updated.
  /// Additionally, the [onPostUpdated] function is called to update the post in the feed.
  final ThunderPost initialPost;

  /// Called whenever the post is updated. Used to update the post in the feed.
  final Function(ThunderPost post)? onPostUpdated;

  /// The ID of the comment that should be initially highlighted.
  final int? highlightedCommentId;

  /// The path of the comment that should be initially highlighted.
  final String? commentPath;

  const PostPage({
    super.key,
    required this.initialPost,
    this.onPostUpdated,
    this.highlightedCommentId,
    this.commentPath,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  /// Creates a [ScrollController] that can be used to control the scroll position of the page.
  final ScrollController scrollController = ScrollController();

  /// Creates a [ListController] that can be used to control the list of items in the page.
  final ListController listController = ListController();

  /// The key for the app bar
  final GlobalKey appBarKey = GlobalKey();

  /// Whether the post source should be displayed.
  bool viewSource = false;

  /// Whether we have set the initial scroll offset.
  /// This needs to be done after building so the controller is attached
  bool hasSetInitialScroll = false;

  /// The ID of the comment that should be highlighted
  int? highlightedCommentId;

  /// The timer for detecting when scrolling has stopped
  Timer? _updateScrollPositionTimer;
  Set<int> _blockedCommunityIds = const <int>{};
  final Set<int> _notifiedBlockedPostIds = <int>{};
  ThunderPost? _lastNotifiedPost;
  int? _lastAutoScrolledCommentId;

  @override
  void initState() {
    super.initState();
    _loadBlockedCommunities();
    _loadInitialPost();

    highlightedCommentId = widget.highlightedCommentId;

    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasSetInitialScroll) {
        hasSetInitialScroll = true;
        final scrollPosition = context.read<PostNavigationCubit>().state.scrollPosition;
        if (scrollController.hasClients && scrollPosition != null) {
          scrollController.jumpTo(scrollPosition);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    listController.dispose();
    _updateScrollPositionTimer?.cancel();
    super.dispose();
  }

  /// Starts the initial post fetch once the bloc is available.
  void _loadInitialPost() {
    final bloc = context.read<PostBloc>();
    if (bloc.state.status != PostPageStatus.initial) return;

    bloc.add(
      GetPostEvent(
        post: widget.initialPost,
        selectedCommentPath: widget.commentPath,
      ),
    );
  }

  /// Handles pagination and scroll-position persistence for the post page.
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final state = context.read<PostBloc>().state;
    final isPastThreshold = scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.7;

    if (isPastThreshold && state.status == PostPageStatus.success && !state.hasReachedCommentEnd) {
      context.read<PostBloc>().add(const GetPostCommentsPageEvent());
    }

    _updateScrollPosition();
  }

  /// Updates the scroll position in the cubit after scrolling has stopped
  void _updateScrollPosition() {
    _updateScrollPositionTimer?.cancel();

    _updateScrollPositionTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted || !scrollController.hasClients) return;
      context.read<PostNavigationCubit>().updateScrollPosition(scrollController.position.pixels);
    });
  }

  Future<void> _loadBlockedCommunities() async {
    final account = context.read<PostBloc>().account;
    if (account.anonymous) return;

    final siteInfo = await ProfileSiteInfoCache.instance.get(account);
    if (!mounted) return;

    final blockedCommunityIds = siteInfo.myUser?.communityBlocks.map((community) => community.id).toSet() ?? <int>{};
    setState(() => _blockedCommunityIds = blockedCommunityIds);

    final state = context.read<PostBloc>().state;
    if (state.status == PostPageStatus.success && state.post != null && state.hasReachedCommentEnd) {
      _maybeShowBlockedCommunityMessage(state.post!);
    }
  }

  void _maybeShowBlockedCommunityMessage(ThunderPost post) {
    final communityId = post.community?.id;
    if (communityId == null || !_blockedCommunityIds.contains(communityId) || !_notifiedBlockedPostIds.add(post.id)) {
      return;
    }

    showSnackbar(GlobalContext.l10n.noVisibleComments);
  }

  bool _listenWhen(PostState previous, PostState current) {
    return previous.status != current.status ||
        previous.post != current.post ||
        previous.comments != current.comments ||
        previous.errorMessage != current.errorMessage ||
        previous.hasReachedCommentEnd != current.hasReachedCommentEnd;
  }

  void _listener(BuildContext context, PostState state) {
    final l10n = GlobalContext.l10n;
    final navigationState = context.read<PostNavigationCubit>().state;

    if (navigationState.didScrollPositionChange) {
      context.read<PostNavigationCubit>().clearScrollPositionChange();
      return;
    }

    if (state.status == PostPageStatus.success && state.post != null && _lastNotifiedPost != state.post) {
      widget.onPostUpdated?.call(state.post!);
      _lastNotifiedPost = state.post;
    }

    if (state.status == PostPageStatus.success && state.post != null && state.hasReachedCommentEnd) {
      _maybeShowBlockedCommunityMessage(state.post!);
    }

    if (state.status == PostPageStatus.failure) {
      showSnackbar(state.errorMessage ?? l10n.missingErrorMessage);
    }

    _maybeScrollToHighlightedComment(state);
  }

  /// Scrolls the initially highlighted comment into view after comments load.
  void _maybeScrollToHighlightedComment(PostState state) {
    final highlightedCommentId = context.read<PostNavigationCubit>().state.highlightedCommentId;
    if (widget.highlightedCommentId == null || highlightedCommentId == null || _lastAutoScrolledCommentId == highlightedCommentId) {
      return;
    }

    final highlightedCommentIndex = state.comments.indexWhere((element) => element.comment?.id == highlightedCommentId);
    if (highlightedCommentIndex == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !listController.isAttached) return;

      final visibleRange = listController.visibleRange;
      if (visibleRange == null) return;

      // Add 1 to account for the placeholder item at the start of the sliver list.
      final adjustedIndex = highlightedCommentIndex + 1;
      if (adjustedIndex < (visibleRange.$1 + 3) || adjustedIndex > (visibleRange.$2 - 3)) {
        listController.animateToItem(
          index: adjustedIndex,
          scrollController: scrollController,
          alignment: 0,
          duration: (_) => const Duration(milliseconds: 250),
          curve: (_) => Curves.easeInOutCubicEmphasized,
        );
      }

      _lastAutoScrolledCommentId = highlightedCommentId;
    });
  }

  Future<void> _resetScroll() async {
    if (!scrollController.hasClients) return;
    await scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOutCubicEmphasized);
  }

  void _refreshPost() {
    final navigationState = context.read<PostNavigationCubit>().state;
    if (navigationState.highlightedCommentId != null) {
      context.read<PostBloc>().add(GetPostEvent(postId: widget.initialPost.id, selectedCommentPath: widget.commentPath));
    } else {
      context.read<PostBloc>().add(GetPostEvent(postId: widget.initialPost.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listenWhen: _listenWhen,
      listener: _listener,
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          _refreshPost();
        },
        edgeOffset: MediaQuery.of(context).padding.top + APP_BAR_HEIGHT,
        child: Scaffold(
          floatingActionButton: PostPageFloatingActionButton(
            initialPost: widget.initialPost,
            scrollController: scrollController,
            listController: listController,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                PostPageScrollBody(
                  scrollController: scrollController,
                  listController: listController,
                  appBarKey: appBarKey,
                  initialPost: widget.initialPost,
                  viewSource: viewSource,
                  onViewSource: (value) => setState(() => viewSource = value),
                  onReset: _resetScroll,
                  onRetry: _refreshPost,
                  highlightedCommentId: highlightedCommentId,
                  commentPath: widget.commentPath,
                ),
                const PostTopBarScrim(),
                const PostFabOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
