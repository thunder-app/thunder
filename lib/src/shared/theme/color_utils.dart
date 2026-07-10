import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/config/config.dart';

/// Gets a tinted background color that looks good in light and dark mode
Color getBackgroundColor(BuildContext context) {
  final useDarkTheme = context.read<ThemePreferencesCubit>().state.useDarkTheme;
  return useDarkTheme ? DARK_THEME_BACKGROUND_COLOR : LIGHT_THEME_BACKGROUND_COLOR;
}
