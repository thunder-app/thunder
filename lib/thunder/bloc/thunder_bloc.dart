import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:path/path.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/models/version.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/update/check_github_update.dart';

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

      // Get Preferences
      SharedPreferences prefs = UserPreferences.instance.sharedPreferences;

      emit(state.copyWith(status: ThunderStatus.success, database: database, version: version, preferences: prefs));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.refreshing));

      SharedPreferences prefs = UserPreferences.instance.sharedPreferences;

      return emit(state.copyWith(status: ThunderStatus.success, preferences: prefs));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }
}
