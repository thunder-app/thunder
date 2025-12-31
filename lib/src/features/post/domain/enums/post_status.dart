import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/app/utils/global_context.dart';

enum PostStatusType {
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
    final themeState = context.read<ThemePreferencesCubit>().state;
    switch (this) {
      case PostStatusType.hidden:
        return themeState.hideColor.color;
      case PostStatusType.locked:
        return themeState.upvoteColor.color;
      case PostStatusType.saved:
        return themeState.saveColor.color;
      case PostStatusType.pinned:
        return color!;
      case PostStatusType.deleted:
        return color!;
      case PostStatusType.removed:
        return color!;
    }
  }

  String getLabel() {
    final l10n = GlobalContext.l10n;

    switch (this) {
      case PostStatusType.hidden:
        return l10n.hidden;
      case PostStatusType.locked:
        return l10n.locked;
      case PostStatusType.saved:
        return l10n.saved;
      case PostStatusType.pinned:
        return l10n.pinned;
      case PostStatusType.deleted:
        return l10n.deleted;
      case PostStatusType.removed:
        return l10n.removed;
    }
  }

  const PostStatusType({
    required this.icon,
    required this.size,
    this.color,
  });
}
