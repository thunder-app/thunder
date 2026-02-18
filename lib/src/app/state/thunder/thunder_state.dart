part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, refreshing, success, failure }

const _thunderStateUnset = Object();

class ThunderState extends Equatable {
  const ThunderState({
    this.status = ThunderStatus.initial,

    // General
    this.version,
    this.errorMessage,
    this.errorReason,

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
    this.imageCachingMode = ImageCachingMode.relaxed,
    this.showNavigationLabels = true,
    this.hideTopBarOnScroll = false,
    this.hideBottomBarOnScroll = false,
    this.appLanguageCode = 'en',
    this.currentAnonymousInstance = DEFAULT_INSTANCE,
  });

  final ThunderStatus status;
  final Version? version;
  final String? errorMessage;
  final AppErrorReason? errorReason;

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
  final ImageCachingMode imageCachingMode;
  final bool showNavigationLabels;
  final bool hideTopBarOnScroll;
  final bool hideBottomBarOnScroll;
  final String? appLanguageCode;
  final String? currentAnonymousInstance;

  ThunderState copyWith({
    ThunderStatus? status,
    Object? version = _thunderStateUnset,
    Object? errorMessage = _thunderStateUnset,
    Object? errorReason = _thunderStateUnset,
    bool? tabletMode,
    BrowserMode? browserMode,
    bool? openInReaderMode,
    bool? useProfilePictureForDrawer,
    bool? showInAppUpdateNotification,
    bool? showUpdateChangelogs,
    NotificationType? inboxNotificationType,
    bool? scoreCounters,
    ImageCachingMode? imageCachingMode,
    bool? showNavigationLabels,
    bool? hideTopBarOnScroll,
    bool? hideBottomBarOnScroll,
    Object? appLanguageCode = _thunderStateUnset,
    Object? currentAnonymousInstance = _thunderStateUnset,
  }) {
    return ThunderState(
      status: status ?? this.status,
      version: identical(version, _thunderStateUnset) ? this.version : version as Version?,
      errorMessage: identical(errorMessage, _thunderStateUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _thunderStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
      tabletMode: tabletMode ?? this.tabletMode,
      browserMode: browserMode ?? this.browserMode,
      openInReaderMode: openInReaderMode ?? this.openInReaderMode,
      useProfilePictureForDrawer: useProfilePictureForDrawer ?? this.useProfilePictureForDrawer,
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
      showUpdateChangelogs: showUpdateChangelogs ?? this.showUpdateChangelogs,
      inboxNotificationType: inboxNotificationType ?? this.inboxNotificationType,
      scoreCounters: scoreCounters ?? this.scoreCounters,
      imageCachingMode: imageCachingMode ?? this.imageCachingMode,
      showNavigationLabels: showNavigationLabels ?? this.showNavigationLabels,
      hideTopBarOnScroll: hideTopBarOnScroll ?? this.hideTopBarOnScroll,
      hideBottomBarOnScroll: hideBottomBarOnScroll ?? this.hideBottomBarOnScroll,
      appLanguageCode: identical(appLanguageCode, _thunderStateUnset) ? this.appLanguageCode : appLanguageCode as String?,
      currentAnonymousInstance: identical(currentAnonymousInstance, _thunderStateUnset) ? this.currentAnonymousInstance : currentAnonymousInstance as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        version,
        errorMessage,
        errorReason,
        tabletMode,
        browserMode,
        openInReaderMode,
        useProfilePictureForDrawer,
        showInAppUpdateNotification,
        showUpdateChangelogs,
        inboxNotificationType,
        scoreCounters,
        imageCachingMode,
        showNavigationLabels,
        hideTopBarOnScroll,
        hideBottomBarOnScroll,
        appLanguageCode,
        currentAnonymousInstance,
      ];
}
