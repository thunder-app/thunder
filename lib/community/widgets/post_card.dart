import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/utils/post_actions.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/widgets/post_action_bottom_sheet.dart';
import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/widgets/widgets.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/user/enums/user_action.dart';

class PostCard extends StatefulWidget {
  /// The associated post information to display in the card.
  final PostViewMedia postViewMedia;

  /// Determines whether the post should be dimmed or not. This is usually to indicate when a post has been read.
  final bool indicateRead;

  /// Determines whether the post is the last tapped post. This is used to highlight the post.
  final bool isLastTapped;

  /// Determines whether the swipe gestures should be disabled or not.
  final bool disableSwiping;

  /// The callback function when the user votes on a post.
  final Function(int) onVoteAction;

  /// The callback function when the user saves a post.
  final Function(bool) onSaveAction;

  /// The callback function when the user reads a post.
  final Function(bool) onReadAction;

  /// The callback function when the user hides a post.
  final Function(bool) onHideAction;

  /// The callback function when the user's finger is lifted off the screen.
  final Function(double) onUpAction;

  /// The callback function when the user's finger is placed on the screen.
  final Function() onDownAction;

  /// The callback function when the user taps on a post.
  final Function() onTap;

  const PostCard({
    super.key,
    required this.postViewMedia,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onReadAction,
    required this.onHideAction,
    required this.onUpAction,
    required this.onDownAction,
    required this.onTap,
    required this.indicateRead,
    required this.isLastTapped,
    this.disableSwiping = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  /// The current point at which the user drags the comment
  double dismissThreshold = 0;

  /// The current swipe action that would be performed if the user let go off the screen
  SwipeAction? swipeAction;

  /// Determines the direction that the user is allowed to drag (to enable/disable swipe gestures)
  DismissDirection? dismissDirection;

  /// The first action threshold to trigger the left or right actions (upvote/reply)
  static const double firstActionThreshold = 0.15;

  /// The second action threshold to trigger the left or right actions (downvote/save)
  static const double secondActionThreshold = 0.35;

  /// User Settings
  bool isUserLoggedIn = false;

  /// This is used to temporarily disable the swipe action to allow for detection of full screen swipe to go back
  bool isOverridingSwipeGestureAction = false;

  /// The vertical drag distance between moves
  double verticalDragDistance = 0;

  /// The last timestamp of the pointer move event. This is used to debounce the pointer move event
  int _lastPointerMoveTimestamp = 0;

  @override
  void initState() {
    super.initState();
    isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  }

  void _updateOverridingSwipe(bool override) {
    if (isOverridingSwipeGestureAction == override) return;
    setState(() => isOverridingSwipeGestureAction = override);
  }

  void _onPointerUp() {
    final int? myVote = widget.postViewMedia.postView.myVote;
    final bool saved = widget.postViewMedia.postView.saved;
    final bool read = widget.postViewMedia.postView.read;
    final bool? hidden = widget.postViewMedia.postView.hidden;

    _updateOverridingSwipe(false);

    if (swipeAction != null && swipeAction != SwipeAction.none) {
      triggerPostAction(
        context: context,
        swipeAction: swipeAction,
        onSaveAction: (int postId, bool saved) => widget.onSaveAction(saved),
        onVoteAction: (int postId, int vote) => widget.onVoteAction(vote),
        onToggleReadAction: (int postId, bool read) => widget.onReadAction(read),
        onHideAction: (int postId, bool hide) => widget.onHideAction(hide),
        voteType: myVote ?? 0,
        saved: saved,
        read: read,
        hidden: hidden,
        postViewMedia: widget.postViewMedia,
      );
    }

    widget.onUpAction(verticalDragDistance);
  }

  void _onPointerMove(PointerMoveEvent event, DismissDirection currentSwipeDirection) {
    // Only process every 16ms (roughly 60fps)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPointerMoveTimestamp < 16) return;
    _lastPointerMoveTimestamp = now;

    verticalDragDistance = event.delta.dy;

    if (currentSwipeDirection != DismissDirection.endToStart) return;

    final horizontalDragDistance = event.delta.dx;
    final isSwipingRight = horizontalDragDistance > 0;

    if (isSwipingRight && !isOverridingSwipeGestureAction && dismissThreshold == 0.0) {
      _updateOverridingSwipe(true);
    } else if (!isSwipingRight && isOverridingSwipeGestureAction) {
      _updateOverridingSwipe(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ThunderBloc>().state;
    final currentSwipeDirection = determinePostSwipeDirection(isUserLoggedIn, state, disableSwiping: widget.disableSwiping);
    final feedType = context.read<FeedBloc>().state.feedType;

    // Determine which post card view to use based on the settings
    Widget child = state.useCompactView || widget.postViewMedia.postView.post.featuredLocal || (feedType == FeedType.community && widget.postViewMedia.postView.post.featuredCommunity)
        ? PostCardViewCompact(
            postViewMedia: widget.postViewMedia,
            isUserLoggedIn: isUserLoggedIn,
            indicateRead: widget.indicateRead,
            isLastTapped: widget.isLastTapped,
            showMedia: !state.hideThumbnails,
            navigateToPost: ({PostViewMedia? postViewMedia}) async {
              widget.onTap();
              await navigateToPost(context, postViewMedia: widget.postViewMedia);
            },
          )
        : PostCardViewComfortable(
            postViewMedia: widget.postViewMedia,
            hideThumbnails: state.hideThumbnails,
            hideNsfwPreviews: state.hideNsfwPreviews,
            markPostReadOnMediaView: state.markPostReadOnMediaView,
            showPostAuthor: state.showPostAuthor,
            showFullHeightImages: state.showFullHeightImages,
            edgeToEdgeImages: state.showEdgeToEdgeImages,
            showTitleFirst: state.showTitleFirst,
            showVoteActions: state.showVoteActions,
            showSaveAction: state.showSaveAction,
            showTextContent: state.showTextContent,
            isUserLoggedIn: isUserLoggedIn,
            indicateRead: widget.indicateRead,
            isLastTapped: widget.isLastTapped,
            navigateToPost: ({PostViewMedia? postViewMedia}) async {
              widget.onTap();
              await navigateToPost(context, postViewMedia: widget.postViewMedia);
            },
            onVoteAction: widget.onVoteAction,
            onSaveAction: widget.onSaveAction,
          );

    // Wrap the post card in an InkWell to handle taps and long presses
    child = RepaintBoundary(
      child: InkWell(
        onTap: () async {
          widget.onTap();
          await navigateToPost(context, postViewMedia: widget.postViewMedia);
        },
        onLongPress: () => showPostActionBottomModalSheet(
          context,
          widget.postViewMedia,
          onAction: ({postAction, userAction, communityAction, required postViewMedia}) async {
            if (postAction == null && userAction == null && communityAction == null) return;

            final post = postViewMedia.postView.post;
            final creator = postViewMedia.postView.creator;
            final community = postViewMedia.postView.community;

            if (postAction == PostAction.hide) {
              context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: post.id));
            }

            if (userAction == UserAction.block) {
              context.read<FeedBloc>().add(FeedDismissBlockedEvent(userId: creator.id));
            }

            if (communityAction == CommunityAction.block) {
              context.read<FeedBloc>().add(FeedDismissBlockedEvent(communityId: community.id));
            }
          },
        ),
        child: child,
      ),
    );

    // Wrap the post card in a Dismissible to handle swipe actions if swipe gestures are enabled
    if (currentSwipeDirection != DismissDirection.none) {
      final read = widget.postViewMedia.postView.read;
      final hidden = widget.postViewMedia.postView.hidden;

      final leftPrimary = state.leftPrimaryPostGesture;
      final leftSecondary = state.leftSecondaryPostGesture;
      final rightPrimary = state.rightPrimaryPostGesture;
      final rightSecondary = state.rightSecondaryPostGesture;

      bool shouldTriggerHaptic = false;

      child = Dismissible(
        key: ObjectKey(widget.postViewMedia.postView.post.id),
        direction: isOverridingSwipeGestureAction ? DismissDirection.none : currentSwipeDirection,
        resizeDuration: Duration.zero,
        dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
        confirmDismiss: (_) async => false,
        onUpdate: (details) {
          if ((dismissThreshold - details.progress).abs() < 0.01) return;

          SwipeAction? updatedAction;
          final bool isStartToEnd = details.direction == DismissDirection.startToEnd;

          if (details.progress > firstActionThreshold) {
            if (isStartToEnd) {
              updatedAction = details.progress < secondActionThreshold ? leftPrimary : (leftSecondary != SwipeAction.none ? leftSecondary : leftPrimary);
            } else {
              updatedAction = details.progress < secondActionThreshold ? rightPrimary : (rightSecondary != SwipeAction.none ? rightSecondary : rightPrimary);
            }
          }

          if (updatedAction == SwipeAction.hide && !LemmyClient.instance.supportsFeature(LemmyFeature.hidePosts)) {
            updatedAction = SwipeAction.none;
          }

          shouldTriggerHaptic = updatedAction != swipeAction && updatedAction != null;

          setState(() {
            dismissThreshold = details.progress;
            dismissDirection = details.direction;
            swipeAction = updatedAction;
          });

          if (shouldTriggerHaptic) HapticFeedback.mediumImpact();
        },
        background: PostCardActionBackground(
          swipeAction: swipeAction,
          dismissThreshold: dismissThreshold,
          firstActionThreshold: firstActionThreshold,
          dismissDirection: dismissDirection ?? DismissDirection.startToEnd,
          read: read,
          hidden: hidden ?? false,
        ),
        child: child,
      );
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => widget.onDownAction(),
      onPointerUp: (_) => _onPointerUp(),
      onPointerMove: (event) => _onPointerMove(event, currentSwipeDirection),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [child, const FeedCardDivider()],
      ),
    );
  }
}

/// Determines the appropriate color and icon for the post background swipe action
class PostCardActionBackground extends StatelessWidget {
  const PostCardActionBackground({
    super.key,
    this.swipeAction,
    required this.firstActionThreshold,
    required this.dismissThreshold,
    required this.read,
    required this.hidden,
    required this.dismissDirection,
  });

  /// The [SwipeAction] to be performed
  final SwipeAction? swipeAction;

  /// The threshold at which the first action should be triggered
  final double firstActionThreshold;

  /// The current threshold of the swipe action
  final double dismissThreshold;

  /// Whether the post is read
  final bool read;

  /// Whether the post is hidden
  final bool hidden;

  /// The direction of the swipe action
  final DismissDirection dismissDirection;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tabletMode = context.select<ThunderBloc, bool>((bloc) => bloc.state.tabletMode);
    final leftPrimaryPostGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.leftPrimaryPostGesture);
    final rightPrimaryPostGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.rightPrimaryPostGesture);

    final alignment = dismissDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight;
    final defaultColor = dismissDirection == DismissDirection.startToEnd ? leftPrimaryPostGesture.getColor(context) : rightPrimaryPostGesture.getColor(context);

    final backgroundColor = swipeAction != null ? swipeAction!.getColor(context) : defaultColor.withValues(alpha: dismissThreshold / firstActionThreshold);
    final computedWidth = width * (tabletMode ? 0.5 : 1) * dismissThreshold;

    return AnimatedContainer(
      alignment: alignment,
      duration: const Duration(milliseconds: 200),
      color: backgroundColor,
      child: SizedBox(
        width: computedWidth,
        child: swipeAction != null ? Icon(swipeAction!.getIcon(read: read, hidden: hidden)) : const SizedBox.shrink(),
      ),
    );
  }
}
