import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';

import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/gestures/swipe_utils.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Interactive feed card for a post.
class PostCard extends StatefulWidget {
  /// The associated post information to display in the card.
  final ThunderPost post;

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

  /// Optional feed type override for contexts without a FeedBloc.
  final FeedType? feedType;

  /// Optional feed list type override for contexts without a FeedBloc.
  final FeedListType? feedListType;

  /// Optional callback for replacing a post in the current list.
  final void Function(ThunderPost post)? onPostUpdated;

  /// Optional callback for dismissing a hidden post from view.
  final void Function(int postId)? onDismissHiddenPost;

  /// Optional callback for dismissing blocked content from view.
  final void Function({int? userId, int? communityId})? onDismissBlocked;

  const PostCard({
    super.key,
    required this.post,
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
    this.feedType,
    this.feedListType,
    this.onPostUpdated,
    this.onDismissHiddenPost,
    this.onDismissBlocked,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isUserLoggedIn = false;
  double _lastVerticalDy = 0.0;

  @override
  void initState() {
    super.initState();
    isUserLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;
  }

  void triggerPostAction({
    required BuildContext context,
    SwipeAction? swipeAction,
    required Function(int, int) onVoteAction,
    required Function(int, bool) onSaveAction,
    required Function(int, bool) onToggleReadAction,
    required Function(int, bool) onHideAction,
    required int voteType,
    bool? saved,
    bool? read,
    bool? hidden,
    required ThunderPost post,
  }) {
    switch (swipeAction) {
      case SwipeAction.upvote:
        onVoteAction(post.id, voteType == 1 ? 0 : 1);
        return;
      case SwipeAction.downvote:
        bool downvotesEnabled = context.read<ProfileBloc>().state.downvotesEnabled;

        if (downvotesEnabled == false) {
          showThunderSnackbar(AppLocalizations.of(context)!.downvotesDisabled);
          return;
        }

        onVoteAction(post.id, voteType == -1 ? 0 : -1);
        return;
      case SwipeAction.reply:
      case SwipeAction.edit:
        showThunderSnackbar(AppLocalizations.of(context)!.replyNotSupported);
        break;
      case SwipeAction.save:
        onSaveAction(post.id, !(saved ?? false));
        break;
      case SwipeAction.toggleRead:
        onToggleReadAction(post.id, !(read ?? false));
        break;
      case SwipeAction.hide:
        onHideAction(post.id, !(hidden ?? false));
        break;
      default:
        break;
    }
  }

  void _onAction(SwipeAction action) {
    final int myVote = widget.post.context.vote.score;
    final bool saved = widget.post.context.saved ?? false;
    final bool read = widget.post.context.read ?? false;
    final bool hidden = widget.post.context.hidden ?? false;

    triggerPostAction(
      context: context,
      swipeAction: action,
      onSaveAction: (int postId, bool newSaved) => widget.onSaveAction(newSaved),
      onVoteAction: (int postId, int vote) => widget.onVoteAction(vote),
      onToggleReadAction: (int postId, bool newRead) => widget.onReadAction(newRead),
      onHideAction: (int postId, bool hide) => widget.onHideAction(hide),
      voteType: myVote,
      saved: saved,
      read: read,
      hidden: hidden,
      post: widget.post,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Select only the specific properties we need from GesturePreferencesCubit
    final enablePostGestures = context.select<GesturePreferencesCubit, bool>((cubit) => cubit.state.enablePostGestures);
    final leftPrimaryPostGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.leftPrimaryPostGesture);
    final leftSecondaryPostGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.leftSecondaryPostGesture);
    final rightPrimaryPostGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.rightPrimaryPostGesture);
    final rightSecondaryPostGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.rightSecondaryPostGesture);

    // Select only the specific properties we need from FeedPreferencesCubit
    final useCompactView = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.useCompactView);
    final hideThumbnails = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.hideThumbnails);
    final hideNsfwPreviews = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.hideNsfwPreviews);
    final markPostReadOnMediaView = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.markPostReadOnMediaView);
    final showFullHeightImages = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showFullHeightImages);
    final showEdgeToEdgeImages = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showEdgeToEdgeImages);
    final showTitleFirst = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showTitleFirst);
    final showTextContent = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showTextContent);
    final linkPostsUseCompactView = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.linkPostsUseCompactView);
    final pinnedPostsUseCompactView = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.pinnedPostsUseCompactView);

    final currentSwipeDirection = determinePostSwipeDirection(
      isUserLoggedIn: isUserLoggedIn,
      enablePostGestures: enablePostGestures,
      leftPrimaryPostGesture: leftPrimaryPostGesture,
      leftSecondaryPostGesture: leftSecondaryPostGesture,
      rightPrimaryPostGesture: rightPrimaryPostGesture,
      rightSecondaryPostGesture: rightSecondaryPostGesture,
      disableSwiping: widget.disableSwiping,
    );
    final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
    final feedType = widget.feedType ?? (hasFeedBloc ? context.select<FeedBloc, FeedType?>((bloc) => bloc.state.feedType) : null);
    final flairs = feedType == FeedType.community ? widget.post.flairs : const <ThunderFlair>[];
    final postIsCompact = useCompactView ||
        (pinnedPostsUseCompactView && (widget.post.status.featuredLocal || (feedType == FeedType.community && widget.post.status.featuredCommunity))) ||
        (linkPostsUseCompactView && widget.post.media.isNotEmpty && widget.post.media.first.mediaType == MediaType.link);

    // Determine which post card view to use based on the settings
    Widget child = postIsCompact
        ? PostCardViewCompact(
            post: widget.post,
            feedType: feedType,
            feedListType: widget.feedListType,
            flairs: flairs,
            creator: widget.post.creator!,
            community: widget.post.community!,
            indicateRead: widget.indicateRead,
            isLastTapped: widget.isLastTapped,
            showMedia: !hideThumbnails,
            navigateToPost: ({ThunderPost? post}) async {
              widget.onTap();
              await navigateToPost(context, post: widget.post);
            },
          )
        : PostCardViewComfortable(
            post: widget.post,
            feedType: feedType,
            feedListType: widget.feedListType,
            flairs: flairs,
            hideThumbnails: hideThumbnails,
            hideNsfwPreviews: hideNsfwPreviews,
            markPostReadOnMediaView: markPostReadOnMediaView,
            showFullHeightImages: showFullHeightImages,
            edgeToEdgeImages: showEdgeToEdgeImages,
            showTitleFirst: showTitleFirst,
            showTextContent: showTextContent,
            isUserLoggedIn: isUserLoggedIn,
            indicateRead: widget.indicateRead,
            isLastTapped: widget.isLastTapped,
            navigateToPost: ({ThunderPost? post}) async {
              widget.onTap();
              await navigateToPost(context, post: widget.post);
            },
            onVoteAction: widget.onVoteAction,
            onSaveAction: widget.onSaveAction,
            onPostUpdated: widget.onPostUpdated,
            onDismissHiddenPost: widget.onDismissHiddenPost,
            onDismissBlocked: widget.onDismissBlocked,
            onMarkPostRead: () => widget.onReadAction(true),
          );

    // Wrap the post card in an InkWell to handle taps and long presses
    child = RepaintBoundary(
      child: InkWell(
        onTap: () async {
          widget.onTap();
          await navigateToPost(context, post: widget.post);
        },
        onLongPress: () => showPostActionBottomModalSheet(
          context,
          widget.post,
          onAction: ({postAction, userAction, communityAction, post}) {
            if (postAction == null && userAction == null && communityAction == null) {
              return;
            }
            if (post != null) {
              if (widget.onPostUpdated != null) {
                widget.onPostUpdated!(post);
              } else if (hasFeedBloc) {
                context.read<FeedBloc>().add(FeedItemUpdatedEvent(post: post));
              }
            }

            if (postAction == PostAction.hide) {
              final dismissHiddenPost = widget.onDismissHiddenPost ?? FeedActionScope.maybeOf(context)?.dismissHiddenPost;
              dismissHiddenPost?.call(post!.id);
            }

            if (userAction == UserAction.block) {
              if (widget.onDismissBlocked != null) {
                widget.onDismissBlocked!(userId: post!.creator!.id);
              } else {
                FeedActionScope.maybeOf(context)?.dismissBlocked(userId: post!.creator!.id);
              }
            }

            if (communityAction == CommunityAction.block) {
              if (widget.onDismissBlocked != null) {
                widget.onDismissBlocked!(communityId: post!.community!.id);
              } else {
                FeedActionScope.maybeOf(context)?.dismissBlocked(communityId: post!.community!.id);
              }
            }
          },
        ),
        child: child,
      ),
    );

    if (currentSwipeDirection != DismissDirection.none) {
      final read = widget.post.context.read ?? false;
      final hidden = widget.post.context.hidden ?? false;

      final actionThresholds = [0.15, 0.35];
      final leftActions = [leftPrimaryPostGesture, leftSecondaryPostGesture].where((action) => action != SwipeAction.none).toList();
      final rightActions = [rightPrimaryPostGesture, rightSecondaryPostGesture].where((action) => action != SwipeAction.none).toList();

      child = ThunderMultiActionDismissible<SwipeAction>(
        key: ObjectKey(widget.post.id),
        direction: widget.disableSwiping ? DismissDirection.none : currentSwipeDirection,
        leftActions: leftActions.map((action) => ThunderSwipeAction(value: action, icon: action.getIcon(read: read, hidden: hidden), color: (context) => action.getColor(context))).toList(),
        rightActions: rightActions.map((action) => ThunderSwipeAction(value: action, icon: action.getIcon(read: read, hidden: hidden), color: (context) => action.getColor(context))).toList(),
        actionThresholds: actionThresholds,
        onAction: (action) => _onAction(action.value),
        onPointerDown: widget.onDownAction,
        onDragEnd: (dy) => widget.onUpAction(dy),
        backgroundBuilder: (context, dir, progress, action) => PostCardActionBackground(
          swipeAction: action?.value,
          dismissThreshold: progress,
          firstActionThreshold: actionThresholds.first,
          dismissDirection: dir,
          read: read,
          hidden: hidden,
        ),
        child: child,
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [child, const FeedCardDivider()],
      );
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => widget.onDownAction(),
      onPointerMove: (event) => _lastVerticalDy = event.delta.dy,
      onPointerUp: (_) => widget.onUpAction(_lastVerticalDy),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [child, const FeedCardDivider()],
      ),
    );
  }
}
