import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/settings/api.dart';

/// Background shown behind a post card while a swipe action is in progress.
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

  /// The active swipe action, when the swipe has crossed an action threshold.
  final SwipeAction? swipeAction;

  /// Swipe progress where the first configured action becomes active.
  final double firstActionThreshold;

  /// Current swipe progress as a fraction of the card width.
  final double dismissThreshold;

  /// Whether the post is currently read.
  final bool read;

  /// Whether the post is currently hidden.
  final bool hidden;

  /// Direction of the active swipe gesture.
  final DismissDirection dismissDirection;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final tabletMode = context.select<ThunderCubit, bool>((bloc) => bloc.state.tabletMode);
    final leftPrimaryPostGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.leftPrimaryPostGesture);
    final rightPrimaryPostGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.rightPrimaryPostGesture);

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
