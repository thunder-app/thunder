import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

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

      SharedPreferences prefs = await SharedPreferences.getInstance();

      bool useSystemTheme = prefs.getBool('setting_theme_use_system_theme') ?? false;

      String themeType = prefs.getString('setting_theme_type') ?? 'dark';
      bool useBlackTheme = prefs.getBool('setting_theme_use_black_theme') ?? false;

      bool useMaterialYouTheme = prefs.getBool('setting_theme_use_material_you') ?? false;

      if (themeType == 'dark') {
        return emit(state.copyWith(
          status: ThemeStatus.success,
          useSystemTheme: useSystemTheme,
          useMaterialYouTheme: useMaterialYouTheme,
          useDarkTheme: true,
          useBlackTheme: useBlackTheme,
        ));
      } else {
        return emit(state.copyWith(
          status: ThemeStatus.success,
          useSystemTheme: useSystemTheme,
          useMaterialYouTheme: useMaterialYouTheme,
          useDarkTheme: false,
          useBlackTheme: useBlackTheme,
        ));
      }
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: ThemeStatus.failure));
    }
  }
}
