import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/utils/post_actions.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/feed/widgets/widgets.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/post/utils/navigate_post.dart';

class PostCard extends StatefulWidget {
  final PostViewMedia postViewMedia;
  final FeedType? feedType;
  final bool indicateRead;
  final bool isLastTapped;

  final Function(int) onVoteAction;
  final Function(bool) onSaveAction;
  final Function(bool) onReadAction;
  final Function(bool) onHideAction;
  final Function(double) onUpAction;
  final Function() onDownAction;
  final Function() onTap;

  final ListingType? listingType;

  const PostCard({
    super.key,
    required this.postViewMedia,
    required this.feedType,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onReadAction,
    required this.onHideAction,
    required this.onUpAction,
    required this.onDownAction,
    required this.onTap,
    required this.listingType,
    required this.indicateRead,
    required this.isLastTapped,
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
  double firstActionThreshold = 0.15;

  /// The second action threshold to trigger the left or right actions (downvote/save)
  double secondActionThreshold = 0.35;

  /// User Settings
  bool isUserLoggedIn = false;

  /// This is used to temporarily disable the swipe action to allow for detection of full screen swipe to go back
  bool isOverridingSwipeGestureAction = false;

  /// The vertical drag distance between moves
  double verticalDragDistance = 0;

  @override
  void initState() {
    super.initState();

    isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;

    int? myVote = widget.postViewMedia.postView.myVote;
    bool saved = widget.postViewMedia.postView.saved;
    bool read = widget.postViewMedia.postView.read;
    bool? hidden = widget.postViewMedia.postView.hidden;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (PointerDownEvent event) {
        widget.onDownAction();
      },
      onPointerUp: (event) {
        setState(() => isOverridingSwipeGestureAction = false);

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
      },
      onPointerCancel: (event) => {},
      onPointerMove: (PointerMoveEvent event) {
        // Get the horizontal drag distance
        double horizontalDragDistance = event.delta.dx;

        // Set the vertical drag distance
        verticalDragDistance = event.delta.dy;

        // We are checking to see if there is a left to right swipe here. If there is a left to right swipe, and LTR swipe actions are disabled, then we disable the DismissDirection temporarily
        // to allow for the full screen swipe to go back. Otherwise, we retain the default behaviour
        if (horizontalDragDistance > 0) {
          if (determinePostSwipeDirection(isUserLoggedIn, state) == DismissDirection.endToStart && isOverridingSwipeGestureAction == false && dismissThreshold == 0.0) {
            setState(() => isOverridingSwipeGestureAction = true);
          }
        } else {
          if (determinePostSwipeDirection(isUserLoggedIn, state) == DismissDirection.endToStart && isOverridingSwipeGestureAction == true) {
            setState(() => isOverridingSwipeGestureAction = false);
          }
        }
      },
      child: Column(
        children: [
          Dismissible(
            direction: isOverridingSwipeGestureAction == true ? DismissDirection.none : determinePostSwipeDirection(isUserLoggedIn, state),
            key: ObjectKey(widget.postViewMedia.postView.post.id),
            resizeDuration: Duration.zero,
            dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
            confirmDismiss: (DismissDirection direction) async {
              return false;
            },
            onUpdate: (DismissUpdateDetails details) {
              SwipeAction? updatedSwipeAction;

              if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                updatedSwipeAction = state.leftPrimaryPostGesture;

                // Change the hide action to none of not supported by instance
                if (updatedSwipeAction == SwipeAction.hide && !LemmyClient.instance.supportsFeature(LemmyFeature.hidePosts)) {
                  updatedSwipeAction = SwipeAction.none;
                }

                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                if (state.leftSecondaryPostGesture != SwipeAction.none) {
                  updatedSwipeAction = state.leftSecondaryPostGesture;
                } else {
                  updatedSwipeAction = state.leftPrimaryPostGesture;
                }

                // Change the hide action to none of not supported by instance
                if (updatedSwipeAction == SwipeAction.hide && !LemmyClient.instance.supportsFeature(LemmyFeature.hidePosts)) {
                  updatedSwipeAction = SwipeAction.none;
                }

                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.endToStart) {
                updatedSwipeAction = state.rightPrimaryPostGesture;

                // Change the hide action to none of not supported by instance
                if (updatedSwipeAction == SwipeAction.hide && !LemmyClient.instance.supportsFeature(LemmyFeature.hidePosts)) {
                  updatedSwipeAction = SwipeAction.none;
                }

                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.endToStart) {
                if (state.rightSecondaryPostGesture != SwipeAction.none) {
                  updatedSwipeAction = state.rightSecondaryPostGesture;
                } else {
                  updatedSwipeAction = state.rightPrimaryPostGesture;
                }

                // Change the hide action to none of not supported by instance
                if (updatedSwipeAction == SwipeAction.hide && !LemmyClient.instance.supportsFeature(LemmyFeature.hidePosts)) {
                  updatedSwipeAction = SwipeAction.none;
                }

                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else {
                updatedSwipeAction = null;
              }

              setState(() {
                dismissThreshold = details.progress;
                dismissDirection = details.direction;
                swipeAction = updatedSwipeAction;
              });
            },
            background: dismissDirection == DismissDirection.startToEnd
                ? AnimatedContainer(
                    alignment: Alignment.centerLeft,
                    color:
                        swipeAction == null ? state.leftPrimaryPostGesture.getColor(context).withOpacity(dismissThreshold / firstActionThreshold) : (swipeAction ?? SwipeAction.none).getColor(context),
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * (state.tabletMode ? 0.5 : 1) * dismissThreshold,
                      child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon(read: read, hidden: hidden)),
                    ),
                  )
                : AnimatedContainer(
                    alignment: Alignment.centerRight,
                    color: swipeAction == null
                        ? state.rightPrimaryPostGesture.getColor(context).withOpacity(dismissThreshold / firstActionThreshold)
                        : (swipeAction ?? SwipeAction.none).getColor(context),
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width * (state.tabletMode ? 0.5 : 1)) * dismissThreshold,
                      child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon(read: read, hidden: hidden)),
                    ),
                  ),
            child: InkWell(
              child: state.useCompactView
                  ? PostCardViewCompact(
                      postViewMedia: widget.postViewMedia,
                      feedType: widget.feedType,
                      isUserLoggedIn: isUserLoggedIn,
                      listingType: widget.listingType,
                      navigateToPost: ({PostViewMedia? postViewMedia}) async => await navigateToPost(context, postViewMedia: widget.postViewMedia),
                      indicateRead: widget.indicateRead,
                      showMedia: !state.hideThumbnails,
                      isLastTapped: widget.isLastTapped,
                    )
                  : PostCardViewComfortable(
                      postViewMedia: widget.postViewMedia,
                      hideThumbnails: state.hideThumbnails,
                      showThumbnailPreviewOnRight: state.showThumbnailPreviewOnRight,
                      hideNsfwPreviews: state.hideNsfwPreviews,
                      markPostReadOnMediaView: state.markPostReadOnMediaView,
                      feedType: widget.feedType,
                      showPostAuthor: state.showPostAuthor,
                      showFullHeightImages: state.showFullHeightImages,
                      edgeToEdgeImages: state.showEdgeToEdgeImages,
                      showTitleFirst: state.showTitleFirst,
                      showVoteActions: state.showVoteActions,
                      showSaveAction: state.showSaveAction,
                      showCommunityIcons: state.showCommunityIcons,
                      showTextContent: state.showTextContent,
                      isUserLoggedIn: isUserLoggedIn,
                      onVoteAction: widget.onVoteAction,
                      onSaveAction: widget.onSaveAction,
                      listingType: widget.listingType,
                      navigateToPost: ({PostViewMedia? postViewMedia}) async => await navigateToPost(context, postViewMedia: widget.postViewMedia),
                      indicateRead: widget.indicateRead,
                      isLastTapped: widget.isLastTapped,
                    ),
              onLongPress: () => showPostActionBottomModalSheet(
                context,
                widget.postViewMedia,
                onBlockedUser: (userId) => context.read<FeedBloc>().add(FeedDismissBlockedEvent(userId: userId)),
                onBlockedCommunity: (communityId) => context.read<FeedBloc>().add(FeedDismissBlockedEvent(communityId: communityId)),
                onPostHidden: (postId) => context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: postId)),
              ),
              onTap: () async {
                widget.onTap.call();
                PostView postView = widget.postViewMedia.postView;
                if (postView.read == false && isUserLoggedIn) context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postView.post.id, postAction: PostAction.read, value: true));
                return await navigateToPost(context, postViewMedia: widget.postViewMedia);
              },
            ),
          ),
          const FeedCardDivider(),
        ],
      ),
    );
  }
}
