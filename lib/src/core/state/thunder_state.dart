part of 'thunder_bloc.dart';

const _thunderStateUnset = Object();

class ThunderState extends Equatable {
  const ThunderState({
    // Tablet Settings
    this.tabletMode = false,

    // General Settings
    this.browserMode = BrowserMode.customTabs,
    this.openInReaderMode = false,
    this.useProfilePictureForDrawer = false,
    this.showInAppUpdateNotification = false,
    this.showUpdateChangelogs = true,
    this.inboxNotificationType = NotificationType.none,
    this.scoreCounters = false,
    this.enableExperimentalFeatures = false,
    this.showNavigationLabels = true,
    this.hideTopBarOnScroll = false,
    this.hideBottomBarOnScroll = false,
    this.appLanguageCode = 'en',
  });

  // Tablet Settings
  final bool tabletMode;

  // General Settings
  final BrowserMode browserMode;
  final bool openInReaderMode;
  final bool useProfilePictureForDrawer;
  final bool showInAppUpdateNotification;
  final bool showUpdateChangelogs;
  final NotificationType inboxNotificationType;
  final bool scoreCounters;
  final bool enableExperimentalFeatures;
  final bool showNavigationLabels;
  final bool hideTopBarOnScroll;
  final bool hideBottomBarOnScroll;
  final String? appLanguageCode;

  ThunderState copyWith({
    bool? tabletMode,
    BrowserMode? browserMode,
    bool? openInReaderMode,
    bool? useProfilePictureForDrawer,
    bool? showInAppUpdateNotification,
    bool? showUpdateChangelogs,
    NotificationType? inboxNotificationType,
    bool? scoreCounters,
    bool? enableExperimentalFeatures,
    bool? showNavigationLabels,
    bool? hideTopBarOnScroll,
    bool? hideBottomBarOnScroll,
    Object? appLanguageCode = _thunderStateUnset,
  }) {
    return ThunderState(
      tabletMode: tabletMode ?? this.tabletMode,
      browserMode: browserMode ?? this.browserMode,
      openInReaderMode: openInReaderMode ?? this.openInReaderMode,
      useProfilePictureForDrawer: useProfilePictureForDrawer ?? this.useProfilePictureForDrawer,
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
      showUpdateChangelogs: showUpdateChangelogs ?? this.showUpdateChangelogs,
      inboxNotificationType: inboxNotificationType ?? this.inboxNotificationType,
      scoreCounters: scoreCounters ?? this.scoreCounters,
      enableExperimentalFeatures: enableExperimentalFeatures ?? this.enableExperimentalFeatures,
      showNavigationLabels: showNavigationLabels ?? this.showNavigationLabels,
      hideTopBarOnScroll: hideTopBarOnScroll ?? this.hideTopBarOnScroll,
      hideBottomBarOnScroll: hideBottomBarOnScroll ?? this.hideBottomBarOnScroll,
      appLanguageCode: identical(appLanguageCode, _thunderStateUnset) ? this.appLanguageCode : appLanguageCode as String?,
    );
  }

  @override
  List<Object?> get props => [
        tabletMode,
        browserMode,
        openInReaderMode,
        useProfilePictureForDrawer,
        showInAppUpdateNotification,
        showUpdateChangelogs,
        inboxNotificationType,
        scoreCounters,
        enableExperimentalFeatures,
        showNavigationLabels,
        hideTopBarOnScroll,
        hideBottomBarOnScroll,
        appLanguageCode,
      ];
}
