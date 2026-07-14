import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/settings/presentation/utils/setting_link_utils.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

class DebugSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const DebugSettingsPage({super.key, this.settingToHighlight});

  @override
  State<DebugSettingsPage> createState() => _DebugSettingsPageState();
}

class _DebugSettingsPageState extends State<DebugSettingsPage> {
  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  NotificationType? inboxNotificationType = NotificationType.none;
  bool areNotificationsAllowed = false;
  String? unifiedPushDistributorApp;
  int unifiedPushDistributorAppCount = 0;
  String? pushNotificationServer;
  String? unifiedPushServer;
  String? thunderNotificationServer;

  /// Enable experimental features in the app.
  bool enableExperimentalFeatures = false;

  /// The maximum amount of time in seconds to fetch the image dimensions.
  int imageDimensionTimeout = 2;

  /// The available timeout values for image dimensions in seconds.
  List<int> imageDimensionTimeouts = List.generate(10, (index) => index + 1);

  Future<void> setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = const UserPreferencesStore();

    switch (attribute) {
      case LocalSettings.enableExperimentalFeatures:
        await prefs.setSetting(LocalSettings.enableExperimentalFeatures, value);
        setState(() => enableExperimentalFeatures = value);
        break;
      case LocalSettings.imageDimensionTimeout:
        await prefs.setSetting(LocalSettings.imageDimensionTimeout, value);
        setState(() => imageDimensionTimeout = value);
        break;
      default:
        break;
    }

    if (mounted) {
      BlocProvider.of<ThunderCubit>(super.context).reload();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = const UserPreferencesStore();
      inboxNotificationType = NotificationType.values.byName(prefs.getLocalSetting<String>(LocalSettings.inboxNotificationType) ?? NotificationType.none.name);

      if (!kIsWeb && Platform.isAndroid) {
        AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        // Check if notifications are allowed
        areNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.areNotificationsEnabled() ?? false;

        // Find the current and available UnifiedPush distributor apps
        unifiedPushDistributorApp = await UnifiedPush.getDistributor();
        unifiedPushDistributorAppCount = (await UnifiedPush.getDistributors()).length;

        // Find the UnifiedPush server endpoint
        Uri? unifiedPushEnpoint = Uri.tryParse(prefs.getString('unified_push_endpoint') ?? '');
        if (unifiedPushEnpoint != null) {
          unifiedPushServer = '${unifiedPushEnpoint.scheme}://${unifiedPushEnpoint.host}';
        }

        // Find the Thunder notification server
        thunderNotificationServer = prefs.getLocalSetting<String>(LocalSettings.pushNotificationServer);
      } else if (!kIsWeb && Platform.isIOS) {
        IOSFlutterLocalNotificationsPlugin? iosFlutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

        areNotificationsAllowed = (await iosFlutterLocalNotificationsPlugin?.checkPermissions())?.isEnabled ?? false;
      }

      pushNotificationServer = prefs.getLocalSetting<String>(LocalSettings.pushNotificationServer) ?? THUNDER_SERVER_URL;

      setState(() {
        enableExperimentalFeatures = prefs.getLocalSetting<bool>(LocalSettings.enableExperimentalFeatures) ?? false;
        imageDimensionTimeout = prefs.getLocalSetting<int>(LocalSettings.imageDimensionTimeout) ?? 2;
      });

      if (widget.settingToHighlight != null) {
        setState(() => settingToHighlight = widget.settingToHighlight);

        // Need some delay to finish building, even though we're in a post-frame callback.
        Timer(const Duration(milliseconds: 500), () {
          if (settingToHighlightKey.currentContext != null) {
            // Ensure that the selected setting is visible on the screen
            Scrollable.ensureVisible(
              settingToHighlightKey.currentContext!,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }

          // Give time for the highlighting to appear, then turn it off
          Timer(const Duration(seconds: 1), () {
            setState(() => settingToHighlight = null);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.debug), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.resetPreferencesAndData, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Text(
                      l10n.debugDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              ThunderSettingsTile(
                  leading: Icon(Icons.co_present_rounded),
                  title: l10n.deleteLocalPreferences,
                  trailing: const ThunderSettingsChevronTrailing(),
                  onTap: () async {
                    showThunderDialog<void>(
                      context: context,
                      title: l10n.deleteLocalPreferences,
                      contentText: l10n.deleteLocalPreferencesDescription,
                      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                      secondaryButtonText: l10n.cancel,
                      onPrimaryButtonPressed: (dialogContext, _) async {
                        final cleared = await const UserPreferencesStore().clear();

                        if (cleared) {
                          context.read<ThunderCubit>().reload();
                          showThunderSnackbar(AppLocalizations.of(context)!.clearedUserPreferences);
                        } else {
                          showThunderSnackbar(AppLocalizations.of(context)!.failedToPerformAction);
                        }

                        Navigator.of(dialogContext).pop();
                      },
                      primaryButtonText: l10n.clearPreferences,
                    );
                  },
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.debugDeleteLocalPreferences),
                  highlighted: settingToHighlight == LocalSettings.debugDeleteLocalPreferences),
              SizedBox(height: 8.0),
              ThunderSettingsTile(
                  leading: Icon(Icons.data_array_rounded),
                  title: l10n.deleteLocalDatabase,
                  trailing: const ThunderSettingsChevronTrailing(),
                  onTap: () async {
                    showThunderDialog<void>(
                      context: context,
                      title: l10n.deleteLocalDatabase,
                      contentText: l10n.deleteLocalDatabaseDescription,
                      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                      secondaryButtonText: l10n.cancel,
                      onPrimaryButtonPressed: (dialogContext, _) async {
                        final dbFolder = await getApplicationDocumentsDirectory();
                        final file = File(join(dbFolder.path, 'thunder.sqlite'));

                        await databaseFactory.deleteDatabase(file.path);

                        if (context.mounted) {
                          showThunderSnackbar(AppLocalizations.of(context)!.clearedDatabase);
                          Navigator.of(context).pop();
                        }
                      },
                      primaryButtonText: l10n.clearDatabase,
                    );
                  },
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.debugDeleteLocalDatabase),
                  highlighted: settingToHighlight == LocalSettings.debugDeleteLocalDatabase),
              const ThunderDivider(sliver: false),
              FutureBuilder<int>(
                future: getImageCacheSize(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ThunderSettingsTile(
                        leading: Icon(Icons.data_saver_off_rounded),
                        title: l10n.clearCache('${(snapshot.data! / (1024 * 1024)).toStringAsFixed(2)} MB'),
                        trailing: const ThunderSettingsChevronTrailing(),
                        onTap: () async {
                          await clearImageCache(expiration: null);
                          if (context.mounted) showThunderSnackbar(l10n.clearedCache);
                          setState(() {}); // Trigger a rebuild to refresh the cache size
                        },
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.debugClearCache),
                        highlighted: settingToHighlight == LocalSettings.debugClearCache);
                  }
                  return Container();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.notifications(2), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Text(
                      l10n.debugNotificationsDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0, bottom: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(l10n.status, style: theme.textTheme.titleSmall)],
                ),
              ),
              ThunderSettingsTile(
                  leading: Icon(Icons.info_rounded),
                  title: l10n.currentNotificationsMode(inboxNotificationType.toString()),
                  trailing: Container(),
                  onTap: null,
                  highlightKey: settingToHighlightKey,
                  highlighted: false),
              SizedBox(height: 8.0),
              ThunderSettingsTile(
                  leading: Icon(Icons.info_rounded),
                  title: l10n.areNotificationsAllowedBySystem(areNotificationsAllowed ? l10n.yes : l10n.no),
                  trailing: Container(),
                  onTap: null,
                  highlightKey: settingToHighlightKey,
                  highlighted: false),
              if (!kIsWeb && Platform.isAndroid && enableExperimentalFeatures) ...[
                SizedBox(height: 8.0),
                ThunderSettingsTile(
                    leading: Icon(Icons.info_rounded),
                    title: l10n.unifiedPushDistributorApp(unifiedPushDistributorApp ?? l10n.none, unifiedPushDistributorAppCount),
                    trailing: Container(),
                    onTap: null,
                    highlightKey: settingToHighlightKey,
                    highlighted: false),
                SizedBox(height: 8.0),
                ThunderSettingsTile(
                    leading: Icon(Icons.info_rounded),
                    title: l10n.thunderNotificationServer(thunderNotificationServer ?? l10n.none),
                    trailing: Container(),
                    onTap: null,
                    highlightKey: settingToHighlightKey,
                    highlighted: false),
                SizedBox(height: 8.0),
                ThunderSettingsTile(
                    leading: Icon(Icons.info_rounded),
                    title: l10n.unifiedPushServer(unifiedPushServer ?? l10n.none),
                    trailing: Container(),
                    onTap: null,
                    highlightKey: settingToHighlightKey,
                    highlighted: false),
              ],
              if (!kIsWeb && Platform.isAndroid) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0, bottom: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(l10n.localNotifications, style: theme.textTheme.titleSmall)],
                  ),
                ),
                ThunderSettingsTile(
                    leading: Icon(Icons.notifications_rounded),
                    title: l10n.sendTestLocalNotification,
                    trailing: const ThunderSettingsChevronTrailing(),
                    onTap: inboxNotificationType == NotificationType.local
                        ? () {
                            showTestAndroidNotification();
                          }
                        : null,
                    highlightKey: settingToHighlightKey,
                    onLongPress: () => shareLocalSetting(context, LocalSettings.debugSendTestLocalNotification),
                    highlighted: settingToHighlight == LocalSettings.debugSendTestLocalNotification),
                SizedBox(height: 8.0),
                ThunderSettingsTile(
                    leading: Icon(Icons.circle_notifications_rounded),
                    title: l10n.sendBackgroundTestLocalNotification,
                    trailing: const ThunderSettingsChevronTrailing(),
                    onTap: inboxNotificationType == NotificationType.local
                        ? () async {
                            bool result = false;

                            await showThunderDialog(
                              context: context,
                              title: l10n.confirm,
                              contentWidgetBuilder: (setPrimaryButtonEnabled) => Text(l10n.testBackgroundNotificationDescription),
                              primaryButtonText: l10n.confirm,
                              primaryButtonInitialEnabled: true,
                              onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
                                Navigator.of(dialogContext).pop();
                                result = true;
                              },
                              secondaryButtonText: l10n.cancel,
                              onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                            );

                            if (result) {
                              // Hook up a callback to generate a background notification.
                              // The next time Thunder starts, this will get reset
                              await disableBackgroundFetch();
                              await initTestBackgroundFetch();
                              initTestHeadlessBackgroundFetch();

                              SystemNavigator.pop();
                            }
                          }
                        : null,
                    highlightKey: settingToHighlightKey,
                    onLongPress: () => shareLocalSetting(context, LocalSettings.debugSendBackgroundTestLocalNotification),
                    highlighted: settingToHighlight == LocalSettings.debugSendBackgroundTestLocalNotification),
                if (enableExperimentalFeatures) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0, bottom: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(l10n.unifiedpush, style: theme.textTheme.titleSmall)],
                    ),
                  ),
                  ThunderSettingsTile(
                      leading: Icon(Icons.notifications_rounded),
                      title: l10n.sendTestUnifiedPushNotification,
                      trailing: const ThunderSettingsChevronTrailing(),
                      onTap: inboxNotificationType == NotificationType.unifiedPush
                          ? () async {
                              final error = await requestTestNotification(resolveActiveAccount(context));

                              if (error == null) {
                                showThunderSnackbar(l10n.sentRequestForTestNotification);
                              } else {
                                showThunderSnackbar(l10n.failedToCommunicateWithThunderNotificationServer('$pushNotificationServer\n\n$error'));
                              }
                            }
                          : null,
                      highlightKey: settingToHighlightKey,
                      onLongPress: () => shareLocalSetting(context, LocalSettings.debugSendTestUnifiedPushNotification),
                      highlighted: settingToHighlight == LocalSettings.debugSendTestUnifiedPushNotification),
                  SizedBox(height: 8.0),
                  ThunderSettingsTile(
                      leading: Icon(Icons.circle_notifications_rounded),
                      title: l10n.sendBackgroundTestUnifiedPushNotification,
                      trailing: const ThunderSettingsChevronTrailing(),
                      onTap: inboxNotificationType == NotificationType.unifiedPush
                          ? () async {
                              bool result = false;

                              await showThunderDialog(
                                context: context,
                                title: l10n.confirm,
                                contentWidgetBuilder: (setPrimaryButtonEnabled) => Text(l10n.testBackgroundUnifiedPushNotificationDescription),
                                primaryButtonText: l10n.confirm,
                                primaryButtonInitialEnabled: true,
                                onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
                                  Navigator.of(dialogContext).pop();
                                  result = true;
                                },
                                secondaryButtonText: l10n.cancel,
                                onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                              );

                              if (result) {
                                final error = await requestTestNotification(resolveActiveAccount(context));

                                if (error == null) {
                                  showThunderSnackbar(l10n.sentRequestForTestNotification);
                                } else {
                                  showThunderSnackbar(l10n.failedToCommunicateWithThunderNotificationServer('$pushNotificationServer\n\n$error'));
                                }

                                SystemNavigator.pop();
                              }
                            }
                          : null,
                      highlightKey: settingToHighlightKey,
                      onLongPress: () => shareLocalSetting(context, LocalSettings.debugSendBackgroundTestUnifiedPushNotification),
                      highlighted: settingToHighlight == LocalSettings.debugSendBackgroundTestUnifiedPushNotification),
                ],
              ],
              const ThunderDivider(sliver: false),
              ThunderSettingsTile(
                  leading: Icon(Icons.edit_notifications_rounded),
                  title: l10n.changeNotificationSettings,
                  trailing: const ThunderSettingsChevronTrailing(),
                  onTap: () => navigateToSettingPage(context, LocalSettings.inboxNotificationType),
                  highlightKey: settingToHighlightKey,
                  highlighted: false),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.experimentalFeatures, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Text(
                      l10n.experimentalFeaturesDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              ThunderToggleOption(
                  title: l10n.enableExperimentalFeatures,
                  value: enableExperimentalFeatures,
                  iconEnabled: Icons.construction_rounded,
                  iconDisabled: Icons.construction_outlined,
                  onChanged: (value) => setPreferences(LocalSettings.enableExperimentalFeatures, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.enableExperimentalFeatures),
                  highlighted: settingToHighlight == LocalSettings.enableExperimentalFeatures),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Text(l10n.feed, style: theme.textTheme.titleMedium),
              ),
              SizedBox(height: 8.0),
              ThunderListOption(
                  title: l10n.imageDimensionTimeout,
                  value: ThunderListPickerItem(label: '${imageDimensionTimeout}s', icon: Icons.timelapse, payload: imageDimensionTimeout),
                  options: imageDimensionTimeouts.map((value) => ThunderListPickerItem(icon: Icons.timelapse, label: '${value}s', payload: value)).toList(),
                  leading: Icon(Icons.timelapse),
                  onChanged: (value) async => setPreferences(LocalSettings.imageDimensionTimeout, value.payload),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.imageDimensionTimeout),
                  highlighted: settingToHighlight == LocalSettings.imageDimensionTimeout),
              SizedBox(height: 48),
            ],
          ),
        ],
      ),
    );
  }
}
