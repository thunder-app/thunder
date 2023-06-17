import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:path/path.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
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
    on<InitializeAppEvent>(
      _initializeAppEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UserPreferencesChangeEvent>(
      _userPreferencesChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ThemeChangeEvent>(
      _themeChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _initializeAppEvent(InitializeAppEvent event, Emitter<ThunderState> emit) async {
    try {
      // Load up database
      final database = await openDatabase(
        join(await getDatabasesPath(), 'thunder.db'),
        onCreate: (db, version) {
          return db.execute('CREATE TABLE accounts(id INTEGER PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT)');
        },
        version: 1,
      );

      emit(state.copyWith(status: ThunderStatus.success, database: database));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
    }
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

      return emit(state.copyWith(status: ThunderStatus.success, theme: theme, preferences: prefs));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      emit(state.copyWith(status: ThunderStatus.failure));
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.loading));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      return emit(state.copyWith(status: ThunderStatus.success, preferences: prefs));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      emit(state.copyWith(status: ThunderStatus.failure));
    }
  }
}
