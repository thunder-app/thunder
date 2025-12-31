import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/core/enums/browser_mode.dart';
import 'package:thunder/src/core/enums/image_caching_mode.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/core/models/version.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/core/update/check_github_update.dart';
import 'package:thunder/src/shared/utils/constants.dart';

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
    on<OnSetCurrentAnonymousInstance>(
      _onSetCurrentAnonymousInstance,
    );
  }

  /// This event should be triggered at the start of the app.
  ///
  /// It initializes the local database, checks for updates from GitHub, and loads the user's preferences.
  Future<void> _initializeAppEvent(InitializeAppEvent event, Emitter<ThunderState> emit) async {
    try {
      // Check for any updates from GitHub
      Version version = await fetchVersion();

      add(UserPreferencesChangeEvent());
      emit(state.copyWith(status: ThunderStatus.success, version: version));
    } catch (e) {
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.refreshing));

      // Tablet Settings
      bool tabletMode = UserPreferences.getLocalSetting(LocalSettings.useTabletMode) ?? false;

      // General Settings
      BrowserMode browserMode = BrowserMode.values.byName(UserPreferences.getLocalSetting(LocalSettings.browserMode) ?? BrowserMode.customTabs.name);
      bool openInReaderMode = UserPreferences.getLocalSetting(LocalSettings.openLinksInReaderMode) ?? false;
      bool showInAppUpdateNotification = UserPreferences.getLocalSetting(LocalSettings.showInAppUpdateNotification) ?? false;
      bool showUpdateChangelogs = UserPreferences.getLocalSetting(LocalSettings.showUpdateChangelogs) ?? true;
      NotificationType inboxNotificationType = NotificationType.values.byName(UserPreferences.getLocalSetting(LocalSettings.inboxNotificationType) ?? NotificationType.none.name);
      String? appLanguageCode = UserPreferences.getLocalSetting(LocalSettings.appLanguageCode) ?? 'en';
      bool useProfilePictureForDrawer = UserPreferences.getLocalSetting(LocalSettings.useProfilePictureForDrawer) ?? false;
      ImageCachingMode imageCachingMode = ImageCachingMode.values.byName(UserPreferences.getLocalSetting(LocalSettings.imageCachingMode) ?? ImageCachingMode.relaxed.name);
      bool showNavigationLabels = UserPreferences.getLocalSetting(LocalSettings.showNavigationLabels) ?? true;
      bool hideTopBarOnScroll = UserPreferences.getLocalSetting(LocalSettings.hideTopBarOnScroll) ?? false;
      bool hideBottomBarOnScroll = UserPreferences.getLocalSetting(LocalSettings.hideBottomBarOnScroll) ?? false;
      bool scoreCounters = UserPreferences.getLocalSetting(LocalSettings.scoreCounters) ?? false;

      String currentAnonymousInstance = UserPreferences.getLocalSetting(LocalSettings.currentAnonymousInstance) ?? DEFAULT_INSTANCE;

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
      ));
    } catch (e) {
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onSetCurrentAnonymousInstance(OnSetCurrentAnonymousInstance event, Emitter<ThunderState> emit) async {
    if (event.instance != null) {
      UserPreferences.setSetting(LocalSettings.currentAnonymousInstance, event.instance!);
    } else {
      UserPreferences.removeSetting(LocalSettings.currentAnonymousInstance);
    }

    emit(state.copyWith(currentAnonymousInstance: event.instance));
  }
}
