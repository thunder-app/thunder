import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

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
import 'package:thunder/post/utils/comment_actions.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

import '../../user/bloc/user_bloc.dart';

class PostCard extends StatefulWidget {
  final PostViewMedia postViewMedia;
  final bool showInstanceName;

  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;

  const PostCard({
    super.key,
    required this.postViewMedia,
    this.showInstanceName = true,
    required this.onVoteAction,
    required this.onSaveAction,
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

  @override
  void initState() {
    super.initState();

    isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
  }

  final GlobalKey<ScaffoldState> _feedScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    VoteType? myVote = widget.postViewMedia.postView.myVote;
    bool saved = widget.postViewMedia.postView.saved;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _feedScaffoldKey.currentState?.openDrawer();
        }
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) => {},
        onPointerUp: (event) => {
          if (swipeAction != null && swipeAction != SwipeAction.none)
            {
              triggerPostAction(
                context: context,
                swipeAction: swipeAction,
                onSaveAction: (int postId, bool saved) => widget.onSaveAction(saved),
                onVoteAction: (int postId, VoteType vote) => widget.onVoteAction(vote),
                voteType: myVote ?? VoteType.none,
                saved: saved,
                postViewMedia: widget.postViewMedia,
              ),
            }
        },
        onPointerCancel: (event) => {},
        child: Dismissible(
          direction: state.enablePostGestures == false ? DismissDirection.none : determinePostSwipeDirection(isUserLoggedIn, state),
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
                  color: swipeAction == null
                      ? getSwipeActionColor(state.leftPrimaryPostGesture ?? SwipeAction.none).withOpacity(dismissThreshold / firstActionThreshold)
                      : getSwipeActionColor(swipeAction ?? SwipeAction.none),
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * dismissThreshold,
                    child: swipeAction == null ? Container() : Icon(getSwipeActionIcon(swipeAction ?? SwipeAction.none)),
                  ),
                )
              : AnimatedContainer(
                  alignment: Alignment.centerRight,
                  color: swipeAction == null
                      ? getSwipeActionColor(state.rightPrimaryPostGesture ?? SwipeAction.none).withOpacity(dismissThreshold / firstActionThreshold)
                      : getSwipeActionColor(swipeAction ?? SwipeAction.none),
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * dismissThreshold,
                    child: swipeAction == null ? Container() : Icon(getSwipeActionIcon(swipeAction ?? SwipeAction.none)),
                  ),
                ),
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
              InkWell(
                child: state.useCompactView
                    ? PostCardViewCompact(
                        postViewMedia: widget.postViewMedia,
                        showThumbnailPreviewOnRight: state.showThumbnailPreviewOnRight,
                        hideNsfwPreviews: state.hideNsfwPreviews,
                        markPostReadOnMediaView: state.markPostReadOnMediaView,
                        showInstanceName: widget.showInstanceName,
                        isUserLoggedIn: isUserLoggedIn,
                      )
                    : PostCardViewComfortable(
                        postViewMedia: widget.postViewMedia,
                        showThumbnailPreviewOnRight: state.showThumbnailPreviewOnRight,
                        hideNsfwPreviews: state.hideNsfwPreviews,
                        markPostReadOnMediaView: state.markPostReadOnMediaView,
                        showInstanceName: widget.showInstanceName,
                        showFullHeightImages: state.showFullHeightImages,
                        edgeToEdgeImages: state.showEdgeToEdgeImages,
                        showTitleFirst: state.showTitleFirst,
                        showVoteActions: state.showVoteActions,
                        showSaveAction: state.showSaveAction,
                        showTextContent: state.showTextContent,
                        isUserLoggedIn: isUserLoggedIn,
                        onVoteAction: widget.onVoteAction,
                        onSaveAction: widget.onSaveAction,
                      ),
                onLongPress: () => showPostActionBottomModalSheet(context, widget.postViewMedia),
                onTap: () async {
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
                    MaterialPageRoute(
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
