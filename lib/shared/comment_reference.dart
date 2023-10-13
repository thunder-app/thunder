import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/numbers.dart';

import '../core/enums/swipe_action.dart';
import '../post/utils/comment_actions.dart';
import '../utils/swipe.dart';
import 'comment_content.dart';

class CommentReference extends StatefulWidget {
  final CommentView comment;
  final DateTime now;
  final bool isOwnComment;
  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onDeleteAction;
  final Function(CommentView, bool) onReplyEditAction;
  final Widget? child;

  const CommentReference({
    super.key,
    required this.comment,
    required this.now,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.isOwnComment,
    required this.onReplyEditAction,
    this.child,
  });

  @override
  State<CommentReference> createState() => _CommentReferenceState();
}

class _CommentReferenceState extends State<CommentReference> {
  // @todo - make this themeable
  List<Color> colors = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];

  bool isHidden = true;
  GlobalKey childKey = GlobalKey();

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

  /// This is used to temporarily disable the swipe action to allow for detection of full screen swipe to go back
  bool isOverridingSwipeGestureAction = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final ThunderState state = context.read<ThunderBloc>().state;

    return Semantics(
      label: """${AppLocalizations.of(context)!.inReplyTo(widget.comment.community.name, widget.comment.post.name)}\n
          ${fetchInstanceNameFromUrl(widget.comment.community.actorId)}\n
          ${widget.comment.creator.name}\n
          ${widget.comment.counts.upvotes == 0 ? '' : AppLocalizations.of(context)!.xUpvotes(formatNumberToK(widget.comment.counts.upvotes))}\n
          ${widget.comment.counts.downvotes == 0 ? '' : AppLocalizations.of(context)!.xDownvotes(formatNumberToK(widget.comment.counts.downvotes))}\n
          ${formatTimeToString(dateTime: (widget.comment.comment.updated ?? widget.comment.comment.published).toIso8601String())}\n
          ${widget.comment.comment.content}""",
      child: InkWell(
        onTap: () async {
          AccountBloc accountBloc = context.read<AccountBloc>();
          AuthBloc authBloc = context.read<AuthBloc>();
          ThunderBloc thunderBloc = context.read<ThunderBloc>();

          final ThunderState state = context.read<ThunderBloc>().state;
          final bool reduceAnimations = state.reduceAnimations;

          // To to specific post for now, in the future, will be best to scroll to the position of the comment
          await Navigator.of(context).push(
            SwipeablePageRoute(
              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
              backGestureDetectionWidth: 45,
              canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: authBloc.state.isLoggedIn, state: thunderBloc.state, isPostPage: true) || !state.enableFullScreenSwipeNavigationGesture,
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: accountBloc),
                  BlocProvider.value(value: authBloc),
                  BlocProvider.value(value: thunderBloc),
                  BlocProvider(create: (context) => PostBloc()),
                ],
                child: PostPage(
                  selectedCommentId: widget.comment.comment.id,
                  selectedCommentPath: widget.comment.comment.path,
                  postId: widget.comment.post.id,
                  onPostUpdated: (PostViewMedia postViewMedia) => {},
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: ExcludeSemantics(
                                  child: Text(
                                    widget.comment.post.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ExcludeSemantics(
                                child: Text(
                                  'in ',
                                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              ExcludeSemantics(
                                child: Text(
                                  '${widget.comment.community.name}${' · ${fetchInstanceNameFromUrl(widget.comment.community.actorId)}'}',
                                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.child != null) widget.child!,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) => {},
                    onPointerUp: (event) {
                      setState(() => isOverridingSwipeGestureAction = false);

                      if (swipeAction != null && swipeAction != SwipeAction.none) {
                        triggerCommentAction(
                          context: context,
                          swipeAction: swipeAction,
                          onSaveAction: (int commentId, bool saved) => widget.onSaveAction(commentId, saved),
                          onVoteAction: (int commentId, VoteType vote) => widget.onVoteAction(commentId, vote),
                          voteType: widget.comment.myVote ?? VoteType.none,
                          saved: widget.comment.saved,
                          commentView: widget.comment,
                          selectedCommentId: widget.comment.comment.id,
                          selectedCommentPath: widget.comment.comment.path,
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
                        if (determineCommentSwipeDirection(isUserLoggedIn, state) == DismissDirection.endToStart && isOverridingSwipeGestureAction == false && dismissThreshold == 0.0) {
                          setState(() => isOverridingSwipeGestureAction = true);
                        }
                      } else {
                        if (determineCommentSwipeDirection(isUserLoggedIn, state) == DismissDirection.endToStart && isOverridingSwipeGestureAction == true) {
                          setState(() => isOverridingSwipeGestureAction = false);
                        }
                      }
                    },
                    child: Dismissible(
                      direction: isOverridingSwipeGestureAction == true ? DismissDirection.none : determineCommentSwipeDirection(isUserLoggedIn, state),
                      key: ObjectKey(widget.comment.comment.id),
                      resizeDuration: Duration.zero,
                      dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
                      confirmDismiss: (DismissDirection direction) async {
                        return false;
                      },
                      onUpdate: (DismissUpdateDetails details) {
                        SwipeAction? updatedSwipeAction;

                        if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                          updatedSwipeAction = state.leftPrimaryCommentGesture;

                          // Change the swipe action to edit for comments
                          if (updatedSwipeAction == SwipeAction.reply && widget.isOwnComment) {
                            updatedSwipeAction = SwipeAction.edit;
                          }

                          if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                        } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                          if (state.leftSecondaryCommentGesture != SwipeAction.none) {
                            updatedSwipeAction = state.leftSecondaryCommentGesture;
                          } else {
                            updatedSwipeAction = state.leftPrimaryCommentGesture;
                          }

                          // Change the swipe action to edit for comments
                          if (updatedSwipeAction == SwipeAction.reply && widget.isOwnComment) {
                            updatedSwipeAction = SwipeAction.edit;
                          }

                          if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                        } else if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.endToStart) {
                          updatedSwipeAction = state.rightPrimaryCommentGesture;

                          // Change the swipe action to edit for comments
                          if (updatedSwipeAction == SwipeAction.reply && widget.isOwnComment) {
                            updatedSwipeAction = SwipeAction.edit;
                          }

                          if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                        } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.endToStart) {
                          if (state.rightSecondaryCommentGesture != SwipeAction.none) {
                            updatedSwipeAction = state.rightSecondaryCommentGesture;
                          } else {
                            updatedSwipeAction = state.rightPrimaryCommentGesture;
                          }

                          // Change the swipe action to edit for comments
                          if (updatedSwipeAction == SwipeAction.reply && widget.isOwnComment) {
                            updatedSwipeAction = SwipeAction.edit;
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
                                  swipeAction == null ? state.leftPrimaryCommentGesture.getColor().withOpacity(dismissThreshold / firstActionThreshold) : (swipeAction ?? SwipeAction.none).getColor(),
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * dismissThreshold,
                                child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon()),
                              ),
                            )
                          : AnimatedContainer(
                              alignment: Alignment.centerRight,
                              color: swipeAction == null
                                  ? (state.rightPrimaryCommentGesture).getColor().withOpacity(dismissThreshold / firstActionThreshold)
                                  : (swipeAction ?? SwipeAction.none).getColor(),
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * dismissThreshold,
                                child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon()),
                              ),
                            ),
                      child: CommentContent(
                        comment: widget.comment,
                        isUserLoggedIn: isUserLoggedIn,
                        now: widget.now,
                        onSaveAction: (int commentId, bool save) => widget.onSaveAction(commentId, save),
                        onVoteAction: (int commentId, VoteType voteType) => widget.onVoteAction(commentId, voteType),
                        onDeleteAction: (int commentId, bool deleted) => widget.onDeleteAction(commentId, deleted),
                        onReplyEditAction: (CommentView commentView, bool isEdit) => widget.onReplyEditAction(commentView, widget.isOwnComment),
                        isOwnComment: widget.isOwnComment,
                        isHidden: false,
                        excludeSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
