import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

enum SwipeAction {
  upvote(label: 'Upvote'),
  downvote(label: 'Downvote'),
  reply(label: 'Reply/Edit'),
  save(label: 'Save'),
  edit(label: 'Edit'),
  toggleRead(label: 'Mark As Read/Unread'),
  hide(label: 'Hide'),
  none(label: 'None');

  const SwipeAction({
    required this.label,
  });

  final String label;

  IconData? getIcon({bool? read, bool? hidden}) {
    switch (this) {
      case SwipeAction.upvote:
        return Icons.north_rounded;
      case SwipeAction.downvote:
        return Icons.south_rounded;
      case SwipeAction.reply:
        return Icons.reply_rounded;
      case SwipeAction.edit:
        return Icons.edit;
      case SwipeAction.save:
        return Icons.star_rounded;
      case SwipeAction.toggleRead:
        return read == null
            ? Icons.markunread_outlined
            : read
                ? Icons.mark_email_unread_rounded
                : Icons.mark_email_read_outlined;
      case SwipeAction.hide:
        return hidden == null
            ? Icons.close_rounded
            : hidden
                ? Icons.refresh_rounded
                : Icons.close_rounded;
      default:
        return Icons.not_interested_rounded;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case SwipeAction.upvote:
        return context.read<ThunderBloc>().state.upvoteColor.color;
      case SwipeAction.downvote:
        return context.read<ThunderBloc>().state.downvoteColor.color;
      case SwipeAction.reply:
        return context.read<ThunderBloc>().state.replyColor.color;
      case SwipeAction.edit:
        return context.read<ThunderBloc>().state.replyColor.color;
      case SwipeAction.save:
        return context.read<ThunderBloc>().state.saveColor.color;
      case SwipeAction.toggleRead:
        return context.read<ThunderBloc>().state.markReadColor.color;
      case SwipeAction.hide:
        return context.read<ThunderBloc>().state.hideColor.color;
      default:
        return Colors.transparent;
    }
  }
}
