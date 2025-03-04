import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/global_context.dart';

enum PostStatus {
  hidden(icon: Icons.visibility_off_rounded, size: 16.0),
  locked(icon: Icons.lock_rounded, size: 15.0),
  saved(icon: Icons.star_rounded, size: 17.0),
  pinned(icon: Icons.push_pin_rounded, size: 15.0, color: Colors.green),
  deleted(icon: Icons.delete_rounded, size: 16.0, color: Colors.red),
  removed(icon: Icons.delete_forever_rounded, size: 16.0, color: Colors.red);

  final IconData icon;

  final double size;

  final Color? color;

  double getScaledSize(double textScaleFactor) => size * textScaleFactor;

  Color getColor(BuildContext context) {
    switch (this) {
      case PostStatus.hidden:
        return context.read<ThunderBloc>().state.hideColor.color;
      case PostStatus.locked:
        return context.read<ThunderBloc>().state.upvoteColor.color;
      case PostStatus.saved:
        return context.read<ThunderBloc>().state.saveColor.color;
      case PostStatus.pinned:
        return color!;
      case PostStatus.deleted:
        return color!;
      case PostStatus.removed:
        return color!;
    }
  }

  String getLabel() {
    final l10n = GlobalContext.l10n;

    switch (this) {
      case PostStatus.hidden:
        return l10n.hidden;
      case PostStatus.locked:
        return l10n.locked;
      case PostStatus.saved:
        return l10n.saved;
      case PostStatus.pinned:
        return l10n.pinned;
      case PostStatus.deleted:
        return l10n.deleted;
      case PostStatus.removed:
        return l10n.removed;
    }
  }

  const PostStatus({
    required this.icon,
    required this.size,
    this.color,
  });
}
