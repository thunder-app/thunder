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
