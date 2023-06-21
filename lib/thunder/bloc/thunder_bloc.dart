<<<<<<< HEAD
<<<<<<< HEAD
import 'dart:convert';
=======
import 'package:flutter/material.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
import 'package:flutter/material.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/enums/theme_type.dart';
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:path/path.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/models/version.dart';
import 'package:thunder/core/update/check_github_update.dart';
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

part 'thunder_event.dart';
part 'thunder_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class ThunderBloc extends Bloc<ThunderEvent, ThunderState> {
  ThunderBloc() : super(const ThunderState()) {
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    on<InitializeAppEvent>(
      _initializeAppEvent,
      transformer: throttleDroppable(throttleDuration),
    );
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    on<UserPreferencesChangeEvent>(
      _userPreferencesChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
<<<<<<< HEAD
<<<<<<< HEAD
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

      return emit(state.copyWith(status: ThunderStatus.success, theme: theme, preferences: prefs));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      emit(state.copyWith(status: ThunderStatus.failure));
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }

  Future<void> _initializeAppEvent(InitializeAppEvent event, Emitter<ThunderState> emit) async {
    try {
      // Load up database
      final database = await openDatabase(
        join(await getDatabasesPath(), 'thunder.db'),
        version: 1,
      );

      // Check for any updates from GitHub
      Version version = await fetchVersion();

      // Get theme preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String themeType = prefs.getString('setting_theme_type') ?? 'dark';

      bool useDarkTheme = themeType == 'dark';

      emit(state.copyWith(status: ThunderStatus.success, database: database, version: version, useDarkTheme: useDarkTheme));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.loading));

      SharedPreferences prefs = await SharedPreferences.getInstance();

<<<<<<< HEAD
<<<<<<< HEAD
      return emit(state.copyWith(status: ThunderStatus.success, preferences: prefs));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      emit(state.copyWith(status: ThunderStatus.failure));
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      await Future.delayed(const Duration(seconds: 1), () {
        return emit(state.copyWith(status: ThunderStatus.success, preferences: prefs));
      });
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    }
  }
}
