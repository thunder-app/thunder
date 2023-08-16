import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/utils/post_actions.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc; // renamed to prevent clash with VotePostEvent, etc from community_bloc
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

import '../../user/bloc/user_bloc.dart';

class PostCard extends StatefulWidget {
  final PostViewMedia postViewMedia;
  final bool showInstanceName;

  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;
  final Function(bool) onToggleReadAction;

  final PostListingType? listingType;

  const PostCard({
    super.key,
    required this.postViewMedia,
    this.showInstanceName = true,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onToggleReadAction,
    required this.listingType,
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

  @override
  void initState() {
    super.initState();

    isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;

    VoteType? myVote = widget.postViewMedia.postView.myVote;
    bool saved = widget.postViewMedia.postView.saved;
    bool read = widget.postViewMedia.postView.read;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => {},
      onPointerUp: (event) {
        setState(() => isOverridingSwipeGestureAction = false);

        if (swipeAction != null && swipeAction != SwipeAction.none) {
          triggerPostAction(
            context: context,
            swipeAction: swipeAction,
            onSaveAction: (int postId, bool saved) => widget.onSaveAction(saved),
            onVoteAction: (int postId, VoteType vote) => widget.onVoteAction(vote),
            onToggleReadAction: (int postId, bool read) => widget.onToggleReadAction(read),
            voteType: myVote ?? VoteType.none,
            saved: saved,
            read: read,
            postViewMedia: widget.postViewMedia,
          );
        }
      },
      onPointerCancel: (event) => {},
      onPointerMove: (PointerMoveEvent event) {
        // Get the horizontal drag distance
        double horizontalDragDistance = event.delta.dx;

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
          Divider(
            height: 1.0,
            thickness: 4.0,
            color: ElevationOverlay.applySurfaceTint(
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceTint,
              10,
            ),
          ),
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
                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                if (state.leftSecondaryPostGesture != SwipeAction.none) {
                  updatedSwipeAction = state.leftSecondaryPostGesture;
                } else {
                  updatedSwipeAction = state.leftPrimaryPostGesture;
                }
                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.endToStart) {
                updatedSwipeAction = state.rightPrimaryPostGesture;
                if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
              } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.endToStart) {
                if (state.rightSecondaryPostGesture != SwipeAction.none) {
                  updatedSwipeAction = state.rightSecondaryPostGesture;
                } else {
                  updatedSwipeAction = state.rightPrimaryPostGesture;
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
                    color: swipeAction == null ? state.leftPrimaryPostGesture.getColor().withOpacity(dismissThreshold / firstActionThreshold) : (swipeAction ?? SwipeAction.none).getColor(),
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * (state.tabletMode ? 0.5 : 1) * dismissThreshold,
                      child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon(read: read)),
                    ),
                  )
                : AnimatedContainer(
                    alignment: Alignment.centerRight,
                    color: swipeAction == null ? state.rightPrimaryPostGesture.getColor().withOpacity(dismissThreshold / firstActionThreshold) : (swipeAction ?? SwipeAction.none).getColor(),
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width * (state.tabletMode ? 0.5 : 1)) * dismissThreshold,
                      child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon(read: read)),
                    ),
                  ),
            child: InkWell(
              child: state.useCompactView
                  ? PostCardViewCompact(
                      postViewMedia: widget.postViewMedia,
                      showThumbnailPreviewOnRight: state.showThumbnailPreviewOnRight,
                      showTextPostIndicator: state.showTextPostIndicator,
                      showPostAuthor: state.showPostAuthor,
                      hideNsfwPreviews: state.hideNsfwPreviews,
                      markPostReadOnMediaView: state.markPostReadOnMediaView,
                      showInstanceName: widget.showInstanceName,
                      isUserLoggedIn: isUserLoggedIn,
                      listingType: widget.listingType,
                      navigateToPost: () async => await navigateToPost(context),
                    )
                  : PostCardViewComfortable(
                      postViewMedia: widget.postViewMedia,
                      showThumbnailPreviewOnRight: state.showThumbnailPreviewOnRight,
                      hideNsfwPreviews: state.hideNsfwPreviews,
                      markPostReadOnMediaView: state.markPostReadOnMediaView,
                      showInstanceName: widget.showInstanceName,
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
                      navigateToPost: () async => await navigateToPost(context),
                    ),
              onLongPress: () => showPostActionBottomModalSheet(
                context,
                widget.postViewMedia,
                actionsToInclude: [
                  PostCardAction.visitProfile,
                  PostCardAction.visitCommunity,
                  PostCardAction.blockCommunity,
                  PostCardAction.sharePost,
                  PostCardAction.shareMedia,
                  PostCardAction.shareLink,
                ],
              ),
              onTap: () async => await navigateToPost(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToPost(BuildContext context) async {
    AccountBloc accountBloc = context.read<AccountBloc>();
    AuthBloc authBloc = context.read<AuthBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();
    CommunityBloc communityBloc = context.read<CommunityBloc>();

    // Mark post as read when tapped
    if (isUserLoggedIn) {
      int postId = widget.postViewMedia.postView.post.id;
      try {
        UserBloc userBloc = BlocProvider.of<UserBloc>(context);
        userBloc.add(MarkUserPostAsReadEvent(postId: postId, read: true));
      } catch (e) {
        CommunityBloc communityBloc = BlocProvider.of<CommunityBloc>(context);
        communityBloc.add(MarkPostAsReadEvent(postId: postId, read: true));
      }
    }

    await Navigator.of(context).push(
      SwipeablePageRoute(
        backGestureDetectionStartOffset: 45,
        canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true),
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: accountBloc),
              BlocProvider.value(value: authBloc),
              BlocProvider.value(value: thunderBloc),
              BlocProvider.value(value: communityBloc),
              BlocProvider(create: (context) => post_bloc.PostBloc()),
            ],
            child: PostPage(
              postView: widget.postViewMedia,
              onPostUpdated: () {},
            ),
          );
        },
      ),
    );
    if (context.mounted) context.read<CommunityBloc>().add(ForceRefreshEvent());
  }
}
