import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/settings/api.dart';

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

  const CommentCardBackground({super.key, this.swipeAction, required this.firstActionThreshold, required this.dismissThreshold, required this.dismissDirection});

  @override
  Widget build(BuildContext context) {
    final leftPrimaryCommentGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.leftPrimaryCommentGesture);
    final rightPrimaryCommentGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.rightPrimaryCommentGesture);

    final alignment = dismissDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight;
    final defaultColor = dismissDirection == DismissDirection.startToEnd ? leftPrimaryCommentGesture.getColor(context) : rightPrimaryCommentGesture.getColor(context);

    final backgroundColor = swipeAction != null ? swipeAction!.getColor(context) : defaultColor.withValues(alpha: dismissThreshold / firstActionThreshold);

    return ThunderSwipeActionBackground(alignment: alignment, backgroundColor: backgroundColor, width: MediaQuery.sizeOf(context).width * dismissThreshold, icon: swipeAction?.getIcon());
  }
}
