import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/config/config.dart';

part 'thunder_event.dart';
part 'thunder_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class ThunderBloc extends Bloc<ThunderEvent, ThunderState> {
  ThunderBloc({
    required PreferencesStore preferencesStore,
    required VersionChecker versionChecker,
  })  : _preferencesStore = preferencesStore,
        _versionChecker = versionChecker,
        super(const ThunderState()) {
    on<InitializeAppEvent>(_initializeAppEvent, transformer: throttleDroppable(throttleDuration));
    on<UserPreferencesChangeEvent>(_userPreferencesChangeEvent, transformer: throttleDroppable(throttleDuration));
    on<OnSetCurrentAnonymousInstance>(_onSetCurrentAnonymousInstance);
  }

  final PreferencesStore _preferencesStore;
  final VersionChecker _versionChecker;

  /// This event should be triggered at the start of the app.
  ///
  /// It initializes the local database, checks for updates from GitHub, and loads the user's preferences.
  Future<void> _initializeAppEvent(InitializeAppEvent event, Emitter<ThunderState> emit) async {
    try {
      // Check for any updates from GitHub
      final version = await _versionChecker.fetchLatestVersion();

      add(UserPreferencesChangeEvent());
      emit(state.copyWith(status: ThunderStatus.success, version: version));
    } catch (e) {
      final message = e.toString();

      return emit(
        state.copyWith(
          status: ThunderStatus.failure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: message),
        ),
      );
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.refreshing));

      // Tablet Settings
      bool tabletMode = _preferencesStore.getLocalSetting(LocalSettings.useTabletMode) ?? false;

      // General Settings
      BrowserMode browserMode = BrowserMode.values.byName(_preferencesStore.getLocalSetting(LocalSettings.browserMode) ?? BrowserMode.customTabs.name);
      bool openInReaderMode = _preferencesStore.getLocalSetting(LocalSettings.openLinksInReaderMode) ?? false;
      bool showInAppUpdateNotification = _preferencesStore.getLocalSetting(LocalSettings.showInAppUpdateNotification) ?? false;
      bool showUpdateChangelogs = _preferencesStore.getLocalSetting(LocalSettings.showUpdateChangelogs) ?? true;
      NotificationType inboxNotificationType = NotificationType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.inboxNotificationType) ?? NotificationType.none.name);
      String? appLanguageCode = _preferencesStore.getLocalSetting(LocalSettings.appLanguageCode) ?? 'en';
      bool useProfilePictureForDrawer = _preferencesStore.getLocalSetting(LocalSettings.useProfilePictureForDrawer) ?? false;
      ImageCachingMode imageCachingMode = ImageCachingMode.values.byName(_preferencesStore.getLocalSetting(LocalSettings.imageCachingMode) ?? ImageCachingMode.relaxed.name);
      bool showNavigationLabels = _preferencesStore.getLocalSetting(LocalSettings.showNavigationLabels) ?? true;
      bool hideTopBarOnScroll = _preferencesStore.getLocalSetting(LocalSettings.hideTopBarOnScroll) ?? false;
      bool hideBottomBarOnScroll = _preferencesStore.getLocalSetting(LocalSettings.hideBottomBarOnScroll) ?? false;
      bool scoreCounters = _preferencesStore.getLocalSetting(LocalSettings.scoreCounters) ?? false;

      String currentAnonymousInstance = _preferencesStore.getLocalSetting(LocalSettings.currentAnonymousInstance) ?? DEFAULT_INSTANCE;

      return emit(state.copyWith(
        status: ThunderStatus.success,
        tabletMode: tabletMode,
        browserMode: browserMode,
        openInReaderMode: openInReaderMode,
        showInAppUpdateNotification: showInAppUpdateNotification,
        showUpdateChangelogs: showUpdateChangelogs,
        inboxNotificationType: inboxNotificationType,
        appLanguageCode: appLanguageCode,
        useProfilePictureForDrawer: useProfilePictureForDrawer,
        imageCachingMode: imageCachingMode,
        showNavigationLabels: showNavigationLabels,
        hideTopBarOnScroll: hideTopBarOnScroll,
        hideBottomBarOnScroll: hideBottomBarOnScroll,
        scoreCounters: scoreCounters,
        currentAnonymousInstance: currentAnonymousInstance,
        errorReason: null,
      ));
    } catch (e) {
      final message = e.toString();
      return emit(state.copyWith(
        status: ThunderStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _onSetCurrentAnonymousInstance(OnSetCurrentAnonymousInstance event, Emitter<ThunderState> emit) async {
    if (event.instance != null) {
      _preferencesStore.setSetting(LocalSettings.currentAnonymousInstance, event.instance!);
    } else {
      _preferencesStore.removeSetting(LocalSettings.currentAnonymousInstance);
    }

    return emit(state.copyWith(currentAnonymousInstance: event.instance));
  }
}
