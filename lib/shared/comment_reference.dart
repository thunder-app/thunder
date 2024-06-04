import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/comment/utils/comment.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/post/utils/comment_actions.dart';
import 'package:thunder/shared/comment_content.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/utils/numbers.dart';

class CommentReference extends StatefulWidget {
  final CommentView comment;
  final bool isOwnComment;
  final bool disableActions;
  final Function(int, int)? onVoteAction;
  final Function(int, bool)? onSaveAction;
  final Function(int, bool)? onDeleteAction;
  final Function(int)? onReportAction;
  final Function(CommentView, bool)? onReplyEditAction;
  final Widget? child;

  const CommentReference({
    super.key,
    required this.comment,
    this.onVoteAction,
    this.onSaveAction,
    this.onDeleteAction,
    required this.isOwnComment,
    this.onReplyEditAction,
    this.onReportAction,
    this.child,
    this.disableActions = false,
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

  /// Whether to display the comment's raw markdown source
  bool viewSource = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final ThunderState state = context.read<ThunderBloc>().state;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: """${AppLocalizations.of(context)!.inReplyTo(widget.comment.community.name, widget.comment.post.name)}\n
          ${fetchInstanceNameFromUrl(widget.comment.community.actorId)}\n
          ${widget.comment.creator.name}\n
          ${widget.comment.counts.upvotes == 0 ? '' : AppLocalizations.of(context)!.xUpvotes(formatNumberToK(widget.comment.counts.upvotes))}\n
          ${widget.comment.counts.downvotes == 0 ? '' : AppLocalizations.of(context)!.xDownvotes(formatNumberToK(widget.comment.counts.downvotes))}\n
          ${formatTimeToString(dateTime: (widget.comment.comment.updated ?? widget.comment.comment.published).toIso8601String())}\n
          ${cleanCommentContent(widget.comment.comment)}""",
      child: InkWell(
        onTap: widget.comment.post.deleted ? null : () async => await navigateToComment(context, widget.comment),
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
                              if (widget.comment.post.deleted) ...[
                                const Icon(
                                  Icons.delete_rounded,
                                  size: 15,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 5),
                              ],
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
                                child: ScalableText(
                                  l10n.in_,
                                  fontScale: state.contentFontSizeScale,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              ExcludeSemantics(
                                child: CommunityFullNameWidget(
                                  context,
                                  widget.comment.community.name,
                                  fetchInstanceNameFromUrl(widget.comment.community.actorId),
                                  fontScale: state.contentFontSizeScale,
                                  transformColor: (color) => color?.withOpacity(0.75),
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
                          onSaveAction: (int commentId, bool saved) => widget.onSaveAction?.call(commentId, saved),
                          onVoteAction: (int commentId, int vote) => widget.onVoteAction?.call(commentId, vote),
                          voteType: widget.comment.myVote ?? 0,
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
                      direction: (widget.disableActions || isOverridingSwipeGestureAction == true) ? DismissDirection.none : determineCommentSwipeDirection(isUserLoggedIn, state),
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
                              color: swipeAction == null
                                  ? state.leftPrimaryCommentGesture.getColor(context).withOpacity(dismissThreshold / firstActionThreshold)
                                  : (swipeAction ?? SwipeAction.none).getColor(context),
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * dismissThreshold,
                                child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon()),
                              ),
                            )
                          : AnimatedContainer(
                              alignment: Alignment.centerRight,
                              color: swipeAction == null
                                  ? (state.rightPrimaryCommentGesture).getColor(context).withOpacity(dismissThreshold / firstActionThreshold)
                                  : (swipeAction ?? SwipeAction.none).getColor(context),
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * dismissThreshold,
                                child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon()),
                              ),
                            ),
                      child: CommentContent(
                        comment: widget.comment,
                        isUserLoggedIn: isUserLoggedIn,
                        onSaveAction: (int commentId, bool save) => widget.onSaveAction?.call(commentId, save),
                        onVoteAction: (int commentId, int voteType) => widget.onVoteAction?.call(commentId, voteType),
                        onDeleteAction: (int commentId, bool deleted) => widget.onDeleteAction?.call(commentId, deleted),
                        onReplyEditAction: (CommentView commentView, bool isEdit) => widget.onReplyEditAction?.call(commentView, widget.isOwnComment),
                        onReportAction: (int commentId) => widget.onReportAction?.call(commentId),
                        isOwnComment: widget.isOwnComment,
                        isHidden: false,
                        excludeSemantics: true,
                        disableActions: widget.disableActions,
                        viewSource: viewSource,
                        onViewSourceToggled: () => setState(() => viewSource = !viewSource),
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
