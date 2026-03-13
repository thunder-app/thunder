import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';

part 'thunder_state.dart';

class ThunderCubit extends Cubit<ThunderState> {
  ThunderCubit({
    required PreferencesStore preferencesStore,
  })  : _preferencesStore = preferencesStore,
        super(const ThunderState());

  final PreferencesStore _preferencesStore;

  Future<void> reload() async {
    try {
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
      bool enableExperimentalFeatures = _preferencesStore.getLocalSetting(LocalSettings.enableExperimentalFeatures) ?? false;
      bool showNavigationLabels = _preferencesStore.getLocalSetting(LocalSettings.showNavigationLabels) ?? true;
      bool hideTopBarOnScroll = _preferencesStore.getLocalSetting(LocalSettings.hideTopBarOnScroll) ?? false;
      bool hideBottomBarOnScroll = _preferencesStore.getLocalSetting(LocalSettings.hideBottomBarOnScroll) ?? false;
      bool scoreCounters = _preferencesStore.getLocalSetting(LocalSettings.scoreCounters) ?? false;

      emit(state.copyWith(
        tabletMode: tabletMode,
        browserMode: browserMode,
        openInReaderMode: openInReaderMode,
        showInAppUpdateNotification: showInAppUpdateNotification,
        showUpdateChangelogs: showUpdateChangelogs,
        inboxNotificationType: inboxNotificationType,
        appLanguageCode: appLanguageCode,
        useProfilePictureForDrawer: useProfilePictureForDrawer,
        imageCachingMode: imageCachingMode,
        enableExperimentalFeatures: enableExperimentalFeatures,
        showNavigationLabels: showNavigationLabels,
        hideTopBarOnScroll: hideTopBarOnScroll,
        hideBottomBarOnScroll: hideBottomBarOnScroll,
        scoreCounters: scoreCounters,
      ));
    } catch (_) {
      rethrow;
    }
  }
}
