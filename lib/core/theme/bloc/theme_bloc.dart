import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/core/enums/custom_theme_type.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/singletons/preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeChangeEvent>(
      _themeChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _themeChangeEvent(ThemeChangeEvent event, Emitter<ThemeState> emit) async {
    try {
      emit(state.copyWith(status: ThemeStatus.loading));

      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

      ThemeType themeType = ThemeType.values[prefs.getInt(LocalSettings.appTheme.name) ?? ThemeType.system.index];
      CustomThemeType selectedTheme = CustomThemeType.values.byName(prefs.getString(LocalSettings.appThemeAccentColor.name) ?? CustomThemeType.deepBlue.name);

      bool useMaterialYouTheme = prefs.getBool(LocalSettings.useMaterialYouTheme.name) ?? false;

      // Fetch reduce animations preferences to remove overscrolling effects
      bool reduceAnimations = prefs.getBool(LocalSettings.reduceAnimations.name) ?? false;

      // Check what the system theme is (light/dark)
      Brightness brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool useDarkTheme = themeType != ThemeType.light;
      if (themeType == ThemeType.system) {
        useDarkTheme = brightness == Brightness.dark;
      }

      return emit(
        state.copyWith(
          status: ThemeStatus.success,
          themeType: themeType,
          selectedTheme: selectedTheme,
          useMaterialYouTheme: useMaterialYouTheme,
          useDarkTheme: useDarkTheme,
          reduceAnimations: reduceAnimations,
        ),
      );
    } catch (e) {
      return emit(state.copyWith(status: ThemeStatus.failure));
    }
  }
}
