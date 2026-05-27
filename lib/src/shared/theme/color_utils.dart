import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/config.dart';

/// Gets a tinted background color that looks good in light and dark mode
Color getBackgroundColor(BuildContext context) {
  final useDarkTheme = context.read<ThemePreferencesCubit>().state.useDarkTheme;
  return useDarkTheme ? DARK_THEME_BACKGROUND_COLOR : LIGHT_THEME_BACKGROUND_COLOR;
}

/// Retrieves the color based on the depth of the comment in the comment tree
Color getCommentLevelColor(BuildContext context, int level) {
  List<Color> colors = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];

  final theme = Theme.of(context);

  return Color.alphaBlend(theme.colorScheme.primary.withValues(alpha: 0.4), colors[level]);
}
