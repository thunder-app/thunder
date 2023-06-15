import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/enums/theme_type.dart';

part 'thunder_event.dart';
part 'thunder_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class ThunderBloc extends Bloc<ThunderEvent, ThunderState> {
  ThunderBloc() : super(const ThunderState()) {
    on<ThemeChangeEvent>(
      _themeChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _themeChangeEvent(ThemeChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.loading));

      // @todo keep user preferences for theming
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String themeName = 'assets/themes/black.json';

      switch (event.themeType) {
        case ThemeType.black:
          themeName = 'assets/themes/black.json';
        case ThemeType.white:
          themeName = 'assets/themes/white.json';
      }

      final themeString = await rootBundle.loadString(themeName);
      final themeJson = jsonDecode(themeString);
      final theme = ThemeDecoder.decodeThemeData(themeJson)!;

      return emit(state.copyWith(status: ThunderStatus.success, theme: theme));
    } catch (e) {
      print(e);
      emit(state.copyWith(status: ThunderStatus.failure));
    }
  }
}
