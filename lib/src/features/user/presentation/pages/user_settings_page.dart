import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_file_dialog/flutter_file_dialog.dart";
import "package:html/parser.dart";
import "package:path_provider/path_provider.dart";
import 'package:markdown/markdown.dart' hide Text;

import "package:thunder/src/foundation/primitives/models/thunder_local_user.dart";
import "package:thunder/src/foundation/primitives/models/thunder_site_response.dart";
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import "package:thunder/src/foundation/primitives/enums/enums.dart";
import "package:thunder/src/shared/sort_picker.dart";
import "package:thunder/src/features/user/user.dart";
import "package:thunder/src/foundation/config/app_constants.dart";
import "package:thunder/src/foundation/networking/error_message_utils.dart";
import "package:thunder/src/foundation/config/global_context.dart";
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/features/settings/presentation/utils/setting_link_utils.dart';
import "package:thunder/src/app/shell/navigation/navigation_utils.dart";
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays the user's account settings. These settings are synchronized with the instance and should be preferred over the app settings.
class UserSettingsPage extends StatefulWidget {
  /// The setting to be highlighted when searching
  final LocalSettings? settingToHighlight;

  const UserSettingsPage({super.key, this.settingToHighlight});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  /// Text controller for the user's display name
  TextEditingController displayNameTextController = TextEditingController();

  /// Text controller for the profile bio
  TextEditingController bioTextController = TextEditingController();

  /// Text controller for the user's email
  TextEditingController emailTextController = TextEditingController();

  /// Text controller for the user's matrix id
  TextEditingController matrixUserTextController = TextEditingController();

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final account = context.read<ProfileBloc>().state.account;

    // TODO: Add support for Piefed account settings
    if (account.platform == ThreadiversePlatform.piefed) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.accountSettings)),
        body: const Center(child: Text("This feature is not yet available.")),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) context.read<ProfileBloc>().add(FetchProfileSettings());
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (_, state) => state.status == ProfileStatus.success && state.siteResponse != null,
            listener: (context, state) {
              if (!context.mounted) return;
              context.read<AccountSettingsCubit>().hydrateFromProfile(state.siteResponse);
            },
            child: BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
              listener: (context, state) {
                if (state.status == AccountSettingsStatus.failure) {
                  showSnackbar(state.errorMessage ?? l10n.unexpectedError);
                } else if (state.status == AccountSettingsStatus.success) {
                  context.read<ProfileBloc>().add(FetchProfileSettings());
                }
              },
              builder: (context, state) {
                ThunderSiteResponse? siteResponse = state.siteResponse;

                ThunderMyUser? myUser = siteResponse?.myUser;
                ThunderLocalUser? localUser = myUser?.localUserView.localUser;
                ThunderUser? person = myUser?.localUserView.person;

                return CustomScrollView(
                  physics: state.status == AccountSettingsStatus.notLoggedIn ? const NeverScrollableScrollPhysics() : null,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      centerTitle: false,
                      toolbarHeight: APP_BAR_HEIGHT,
                      title: Text(l10n.accountSettings),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.people_alt_rounded),
                          onPressed: () => showProfileModalSheet(context),
                        ),
                      ],
                    ),
                    switch (state.status) {
                      AccountSettingsStatus.notLoggedIn => const SliverFillRemaining(hasScrollBody: false, child: AccountPlaceholder()),
                      AccountSettingsStatus.initial => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      _ => SliverList.list(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const UserIndicator(),
                                  IconButton(
                                    icon: const Icon(Icons.logout_rounded),
                                    onPressed: () => showProfileModalSheet(context, showLogoutDialog: true),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16.0, right: 16.0),
                              child: Text(
                                l10n.userSettingDescription,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.general, style: theme.textTheme.titleMedium),
                            ),
                            ThunderSettingsTile(
                                leading: Icon(Icons.person_rounded),
                                title: l10n.displayName,
                                subtitle: person?.displayName?.isNotEmpty == true ? person?.displayName : l10n.noDisplayNameSet,
                                trailing: const Padding(padding: EdgeInsets.all(20.0)),
                                onTap: () {
                                  displayNameTextController.text = person?.displayName ?? "";
                                  showThunderDialog(
                                    context: context,
                                    title: l10n.displayName,
                                    contentWidgetBuilder: (setPrimaryButtonEnabled) => TextField(
                                      controller: displayNameTextController,
                                      decoration: InputDecoration(hintText: l10n.displayName),
                                    ),
                                    primaryButtonText: l10n.save,
                                    onPrimaryButtonPressed: (dialogContext, _) {
                                      context.read<AccountSettingsCubit>().updateSettings(displayName: displayNameTextController.text);
                                      Navigator.of(dialogContext).pop();
                                    },
                                    secondaryButtonText: l10n.cancel,
                                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  );
                                },
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountDisplayName),
                                highlighted: settingToHighlight == LocalSettings.accountDisplayName),
                            ThunderSettingsTile(
                                leading: Icon(Icons.note_rounded),
                                title: l10n.profileBio,
                                subtitle: person?.bio?.isNotEmpty == true ? parse(markdownToHtml(person?.bio ?? "")).documentElement?.text.trim() : l10n.noProfileBioSet,
                                subtitleMaxLines: 1,
                                trailing: const Padding(padding: EdgeInsets.all(20.0)),
                                onTap: () {
                                  bioTextController.text = person?.bio ?? "";
                                  showThunderDialog(
                                    context: context,
                                    title: l10n.profileBio,
                                    contentWidgetBuilder: (setPrimaryButtonEnabled) => TextField(
                                      controller: bioTextController,
                                      minLines: 8,
                                      maxLines: 8,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: l10n.profileBio,
                                      ),
                                    ),
                                    primaryButtonText: l10n.save,
                                    onPrimaryButtonPressed: (dialogContext, _) {
                                      context.read<AccountSettingsCubit>().updateSettings(bio: bioTextController.text);
                                      Navigator.of(dialogContext).pop();
                                    },
                                    secondaryButtonText: l10n.cancel,
                                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  );
                                },
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountProfileBio),
                                highlighted: settingToHighlight == LocalSettings.accountProfileBio),
                            ThunderSettingsTile(
                                leading: Icon(Icons.email_rounded),
                                title: l10n.email,
                                subtitle: localUser?.email?.isNotEmpty == true ? localUser?.email : l10n.noEmailSet,
                                trailing: const Padding(padding: EdgeInsets.all(20.0)),
                                onTap: () {
                                  emailTextController.text = localUser?.email ?? "";
                                  showThunderDialog(
                                    context: context,
                                    title: l10n.email,
                                    contentWidgetBuilder: (setPrimaryButtonEnabled) => TextField(
                                      controller: emailTextController,
                                      decoration: InputDecoration(hintText: l10n.email),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    primaryButtonText: l10n.save,
                                    onPrimaryButtonPressed: (dialogContext, _) {
                                      context.read<AccountSettingsCubit>().updateSettings(email: emailTextController.text);
                                      Navigator.of(dialogContext).pop();
                                    },
                                    secondaryButtonText: l10n.cancel,
                                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  );
                                },
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountEmail),
                                highlighted: settingToHighlight == LocalSettings.accountEmail),
                            ThunderSettingsTile(
                                leading: Icon(Icons.person_rounded),
                                title: l10n.matrixUser,
                                subtitle: person?.matrixUserId?.isNotEmpty == true ? person?.matrixUserId : l10n.noMatrixUserSet,
                                trailing: const Padding(padding: EdgeInsets.all(20.0)),
                                onTap: () {
                                  matrixUserTextController.text = person?.matrixUserId ?? "";
                                  showThunderDialog(
                                    context: context,
                                    title: l10n.matrixUser,
                                    contentWidgetBuilder: (setPrimaryButtonEnabled) => TextField(
                                      controller: matrixUserTextController,
                                      decoration: const InputDecoration(hintText: "@user:instance"),
                                    ),
                                    primaryButtonText: l10n.save,
                                    onPrimaryButtonPressed: (dialogContext, _) {
                                      context.read<AccountSettingsCubit>().updateSettings(matrixUserId: matrixUserTextController.text);
                                      Navigator.of(dialogContext).pop();
                                    },
                                    secondaryButtonText: l10n.cancel,
                                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  );
                                },
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountMatrixUser),
                                highlighted: settingToHighlight == LocalSettings.accountMatrixUser),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.feedSettings, style: theme.textTheme.titleMedium),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16.0, right: 16.0),
                              child: Text(
                                l10n.settingOverrideLabel,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                            ThunderListOption(
                                title: l10n.defaultFeedType,
                                value: ListPickerItem(label: localUser?.defaultListingType?.value ?? "", icon: Icons.feed, payload: localUser?.defaultListingType),
                                options: [
                                  ListPickerItem(icon: Icons.view_list_rounded, label: FeedListType.subscribed.value, payload: FeedListType.subscribed),
                                  ListPickerItem(icon: Icons.home_rounded, label: FeedListType.all.value, payload: FeedListType.all),
                                  ListPickerItem(icon: Icons.grid_view_rounded, label: FeedListType.local.value, payload: FeedListType.local),
                                ],
                                leading: Icon(Icons.filter_alt_rounded),
                                onChanged: (value) async => context.read<AccountSettingsCubit>().updateSettings(defaultFeedListType: value.payload),
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountDefaultFeedType),
                                highlighted: settingToHighlight == LocalSettings.accountDefaultFeedType),
                            ThunderListOption(
                                title: l10n.defaultFeedSortType,
                                value: ListPickerItem(
                                  label: localUser?.defaultSortType?.name ?? "",
                                  icon: Icons.local_fire_department_rounded,
                                  payload: localUser?.defaultSortType,
                                ),
                                options: [...getDefaultPostSortTypeItems(account: account), ...getTopPostSortTypeItems(account: account)],
                                leading: Icon(Icons.sort_rounded),
                                onChanged: (_) async {},
                                isBottomModalScrollControlled: true,
                                customListPicker: SortPicker<PostSortType>(
                                  account: account,
                                  title: l10n.defaultFeedSortType,
                                  onSelect: (value) async {
                                    context.read<AccountSettingsCubit>().updateSettings(defaultPostSortType: value.payload);
                                  },
                                  previouslySelected: localUser?.defaultSortType,
                                ),
                                valueDisplay: Row(
                                  children: [
                                    Icon(allPostSortTypeItems.firstWhere((item) => item.payload == localUser?.defaultSortType).icon, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      allPostSortTypeItems.firstWhere((item) => item.payload == localUser?.defaultSortType).label,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountDefaultFeedSortType),
                                highlighted: settingToHighlight == LocalSettings.accountDefaultFeedSortType),
                            ThunderToggleOption(
                                title: l10n.showNsfwContent,
                                value: localUser?.showNsfw,
                                iconEnabled: Icons.no_adult_content,
                                iconDisabled: Icons.no_adult_content,
                                onChanged: (bool value) => context.read<AccountSettingsCubit>().updateSettings(showNsfw: value),
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowNsfwContent),
                                highlighted: settingToHighlight == LocalSettings.accountShowNsfwContent),
                            ThunderToggleOption(
                                title: l10n.showScores,
                                value: localUser?.showScores,
                                iconEnabled: Icons.onetwothree_rounded,
                                iconDisabled: Icons.onetwothree_rounded,
                                onChanged: (bool value) => {context.read<AccountSettingsCubit>().updateSettings(showScores: value)},
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowScores),
                                highlighted: settingToHighlight == LocalSettings.accountShowScores),
                            ThunderToggleOption(
                                title: l10n.showReadPosts,
                                value: localUser?.showReadPosts,
                                iconEnabled: Icons.fact_check_rounded,
                                iconDisabled: Icons.fact_check_outlined,
                                onChanged: (bool value) => {context.read<AccountSettingsCubit>().updateSettings(showReadPosts: value)},
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowReadPosts),
                                highlighted: settingToHighlight == LocalSettings.accountShowReadPosts),
                            ThunderToggleOption(
                                title: l10n.bot,
                                value: person?.botAccount,
                                iconEnabled: Thunder.robot,
                                iconDisabled: Thunder.robot,
                                iconSpacing: 14.0,
                                onChanged: (bool value) => {context.read<AccountSettingsCubit>().updateSettings(botAccount: value)},
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountIsBot),
                                highlighted: settingToHighlight == LocalSettings.accountIsBot),
                            ThunderToggleOption(
                                title: l10n.showBotAccounts,
                                value: localUser?.showBotAccounts,
                                iconEnabled: Thunder.robot,
                                iconDisabled: Thunder.robot,
                                iconSpacing: 14.0,
                                onChanged: (bool value) => {context.read<AccountSettingsCubit>().updateSettings(showBotAccounts: value)},
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowBotAccounts),
                                highlighted: settingToHighlight == LocalSettings.accountShowBotAccounts),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.contentManagement, style: theme.textTheme.titleMedium),
                            ),
                            ThunderSettingsTile(
                                leading: Icon(Icons.language_rounded),
                                title: l10n.discussionLanguages,
                                trailing: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                                onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccountLanguages),
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.discussionLanguages),
                                highlighted: settingToHighlight == LocalSettings.discussionLanguages),
                            ThunderSettingsTile(
                                leading: Icon(Icons.block_rounded),
                                title: l10n.blockSettingLabel,
                                trailing: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                                onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccountBlocks),
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountBlocks),
                                highlighted: settingToHighlight == LocalSettings.accountBlocks),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.importExportSettings, style: theme.textTheme.titleMedium),
                                  Text(l10n.importExportLemmyAccountSettingsSubtitle),
                                ],
                              ),
                            ),
                            ThunderSettingsTile(
                                leading: Icon(Icons.file_download_rounded),
                                title: l10n.exportLemmyAccountSettingsDescription,
                                trailing: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                                onTap: () async {
                                  dynamic exportSettings;
                                  try {
                                    final account = context.read<ProfileBloc>().state.account;
                                    exportSettings = await AccountRepositoryImpl(account: account).exportSettings();
                                  } catch (e) {
                                    // Catch rate-limit errors
                                    showSnackbar(getExceptionErrorMessage(e));
                                    return;
                                  }

                                  try {
                                    final String initialFilePath = (await getApplicationDocumentsDirectory()).path;
                                    // Use the same naming convention as the web UI
                                    String initialFileName = 'lemmy_user_settings_${DateTime.now().toUtc().toIso8601String().replaceAll(":", "").replaceAll("-", "")}.json';
                                    final filePath = '$initialFilePath/$initialFileName';

                                    final File file = File(filePath);
                                    await file.writeAsString(jsonEncode(exportSettings));

                                    final String? savedFilePath = await FlutterFileDialog.saveFile(
                                      params: SaveFileDialogParams(
                                        mimeTypesFilter: ['application/json'],
                                        sourceFilePath: filePath,
                                        fileName: initialFileName,
                                      ),
                                    );

                                    if (savedFilePath?.isNotEmpty == true) {
                                      showSnackbar(l10n.accountSettingsExportedSuccessfully(savedFilePath!));
                                    } else {
                                      showSnackbar(l10n.errorSavingAccountSettings);
                                    }
                                  } catch (e) {
                                    showSnackbar('${l10n.errorSavingAccountSettings} $e');
                                  }
                                },
                                highlightKey: settingToHighlightKey,
                                onLongPress: () => shareLocalSetting(context, LocalSettings.accountExportSettings),
                                highlighted: settingToHighlight == LocalSettings.accountExportSettings),
                            ThunderSettingsTile(
                              leading: Icon(Icons.file_upload_rounded),
                              title: l10n.importLemmyAccountSettingsDescription,
                              trailing: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                              onTap: () async {
                                String importSettings;

                                try {
                                  final filePath = await FlutterFileDialog.pickFile(
                                    params: const OpenFileDialogParams(
                                      fileExtensionsFilter: ['json'],
                                    ),
                                  );

                                  if (filePath != null) {
                                    importSettings = await File(filePath).readAsString();
                                  } else {
                                    showSnackbar(l10n.errorLoadingAccountSettings);
                                    return;
                                  }
                                } catch (e) {
                                  if (e is FormatException) {
                                    showSnackbar(l10n.errorParsingJson);
                                  } else if ((e as PlatformException?)?.code == "invalid_file_extension") {
                                    showSnackbar(l10n.youMustSelectAJsonFile);
                                  } else {
                                    showSnackbar('${l10n.errorLoadingAccountSettings} $e');
                                  }
                                  return;
                                }

                                try {
                                  final l10n = AppLocalizations.of(GlobalContext.context)!;
                                  final account = context.read<ProfileBloc>().state.account;
                                  final success = await AccountRepositoryImpl(account: account).importSettings(importSettings);

                                  if (success) {
                                    showSnackbar(l10n.accountSettingsImportedSuccessfully);
                                    context.read<ProfileBloc>().add(FetchProfileSettings());
                                  } else {
                                    showSnackbar(l10n.errorImportingAccountSettings);
                                  }
                                } catch (e) {
                                  showSnackbar(getExceptionErrorMessage(e));
                                }
                              },
                              highlightKey: settingToHighlightKey,
                              onLongPress: () => shareLocalSetting(context, LocalSettings.accountImportSettings),
                              highlighted: settingToHighlight == LocalSettings.accountImportSettings,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.dangerZone, style: theme.textTheme.titleMedium),
                            ),
                            ThunderSettingsTile(
                              leading: Icon(Icons.password),
                              title: l10n.changePassword,
                              trailing: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                              onTap: () async {
                                showThunderDialog<void>(
                                  context: context,
                                  title: l10n.changePassword,
                                  contentText: l10n.changePasswordWarning,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  secondaryButtonText: l10n.cancel,
                                  onPrimaryButtonPressed: (dialogContext, _) async {
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      final account = context.read<ProfileBloc>().state.account;

                                      handleLink(context, url: "https://${account.instance}/settings");
                                    }
                                  },
                                  primaryButtonText: l10n.confirm,
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              onLongPress: () => shareLocalSetting(context, LocalSettings.accountChangePassword),
                              highlighted: settingToHighlight == LocalSettings.accountChangePassword,
                            ),
                            ThunderSettingsTile(
                              leading: Icon(Icons.delete_forever_rounded),
                              title: l10n.deleteAccount,
                              trailing: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                              onTap: () async {
                                showThunderDialog<void>(
                                  context: context,
                                  title: l10n.deleteAccount,
                                  contentText: l10n.deleteAccountDescription,
                                  secondaryButtonText: l10n.cancel,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  primaryButtonText: l10n.confirm,
                                  onPrimaryButtonPressed: (dialogContext, _) async {
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      final account = context.read<ProfileBloc>().state.account;

                                      handleLink(context, url: "https://${account.instance}/settings");
                                    }
                                  },
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              onLongPress: () => shareLocalSetting(context, LocalSettings.accountDeleteAccount),
                              highlighted: settingToHighlight == LocalSettings.accountDeleteAccount,
                            ),
                            ThunderSettingsTile(
                              leading: Icon(Icons.hide_image_rounded),
                              title: l10n.manageMedia,
                              trailing: const SizedBox(
                                height: 42.0,
                                child: Icon(Icons.chevron_right_rounded),
                              ),
                              onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccountMedia),
                              highlightKey: settingToHighlightKey,
                              onLongPress: () => shareLocalSetting(context, LocalSettings.accountManageMedia),
                              highlighted: settingToHighlight == LocalSettings.accountManageMedia,
                            ),
                            const SizedBox(height: 100.0),
                          ],
                        ),
                    }
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
