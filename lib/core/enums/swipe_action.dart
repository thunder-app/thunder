import 'package:flutter/material.dart';

enum SwipeAction {
  upvote(label: 'Upvote'),
  downvote(label: 'Downvote'),
  reply(label: 'Reply/Edit'),
  save(label: 'Save'),
  edit(label: 'Edit'),
  toggleRead(label: 'Mark As Read/Unread'),
  none(label: 'None');

  const SwipeAction({
    required this.label,
  });

  final String label;

  IconData? getIcon({bool? read}) {
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
      default:
        return Icons.not_interested_rounded;
    }
  }

  Color getColor() {
    switch (this) {
      case SwipeAction.upvote:
        return Colors.orange.shade700;
      case SwipeAction.downvote:
        return Colors.blue.shade700;
      case SwipeAction.reply:
        return Colors.green.shade700;
      case SwipeAction.edit:
        return Colors.green.shade700;
      case SwipeAction.save:
        return Colors.purple.shade700;
      case SwipeAction.toggleRead:
        return Colors.teal.shade300;
      default:
        return Colors.transparent;
    }
  }
}
