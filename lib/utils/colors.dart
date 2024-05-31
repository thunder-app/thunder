import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';

/// Gets a tinted background color that looks good in light and dark mode
Color getBackgroundColor(BuildContext context) {
  final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;
  final ThemeData theme = Theme.of(context);
  return darkTheme ? theme.dividerColor.darken(5) : theme.dividerColor.lighten(20);
}

/// Retrieves the color based on the depth of the comment in the comment tree
Color getCommentLevelColor(BuildContext context, int level) {
  // TODO: make this themeable
  List<Color> colors = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];

  final theme = Theme.of(context);

  return Color.alphaBlend(theme.colorScheme.primary.withOpacity(0.4), colors[level]);
}
