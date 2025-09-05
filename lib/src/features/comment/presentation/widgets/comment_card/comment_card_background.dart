import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/core/enums/swipe_action.dart';

/// A widget that displays the proper background when a swipe action is performed on a comment.
class CommentCardBackground extends StatelessWidget {
  /// The [SwipeAction] to be performed
  final SwipeAction? swipeAction;

  /// The threshold at which the first action should be triggered
  final double firstActionThreshold;

  /// The current threshold of the swipe action
  final double dismissThreshold;

  /// The direction of the swipe action
  final DismissDirection dismissDirection;

  const CommentCardBackground({
    super.key,
    this.swipeAction,
    required this.firstActionThreshold,
    required this.dismissThreshold,
    required this.dismissDirection,
  });

  @override
  Widget build(BuildContext context) {
    final leftPrimaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.leftPrimaryCommentGesture);
    final rightPrimaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.rightPrimaryCommentGesture);

    final alignment = dismissDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight;
    final defaultColor = dismissDirection == DismissDirection.startToEnd ? leftPrimaryCommentGesture.getColor(context) : rightPrimaryCommentGesture.getColor(context);

    final backgroundColor = swipeAction != null ? swipeAction!.getColor(context) : defaultColor.withValues(alpha: dismissThreshold / firstActionThreshold);

    return AnimatedContainer(
      alignment: alignment,
      duration: const Duration(milliseconds: 200),
      color: backgroundColor,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * dismissThreshold,
        child: swipeAction != null ? Icon(swipeAction!.getIcon()) : const SizedBox.shrink(),
      ),
    );
  }
}
