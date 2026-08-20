import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' hide Text;
import 'package:path_provider/path_provider.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/navigation/link_navigation_utils.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/settings/presentation/utils/setting_link_utils.dart';
import 'package:thunder/src/features/user/presentation/state/account_settings_cubit.dart';
import 'package:thunder/src/features/user/presentation/widgets/user_settings_page_scaffold.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/networking/error_message_utils.dart';
import 'package:thunder/src/core/domain/enums/enums.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Lemmy account settings page.
class LemmyUserSettingsPage extends StatefulWidget {
  /// The setting to be highlighted when searching.
  final LocalSettings? settingToHighlight;

  const LemmyUserSettingsPage({super.key, this.settingToHighlight});

  @override
  State<LemmyUserSettingsPage> createState() => _LemmyUserSettingsPageState();
}

class _LemmyUserSettingsPageState extends State<LemmyUserSettingsPage> {
  final TextEditingController displayNameTextController = TextEditingController();
  final TextEditingController bioTextController = TextEditingController();

  final GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  @override
  void initState() {
    super.initState();

    if (widget.settingToHighlight != null) {
      setState(() => settingToHighlight = widget.settingToHighlight);

      Timer(const Duration(milliseconds: 500), () {
        if (settingToHighlightKey.currentContext != null) {
          Scrollable.ensureVisible(settingToHighlightKey.currentContext!, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
        }

        Timer(const Duration(seconds: 1), () {
          if (mounted) setState(() => settingToHighlight = null);
        });
      });
    }
  }

  @override
  void dispose() {
    displayNameTextController.dispose();
    bioTextController.dispose();
    super.dispose();
  }

  List<ThunderListPickerItem<FeedListType>> _feedTypeOptions() {
    return const [
      ThunderListPickerItem(icon: Icons.view_list_rounded, label: 'Subscribed', payload: FeedListType.subscribed),
      ThunderListPickerItem(icon: Icons.home_rounded, label: 'All', payload: FeedListType.all),
      ThunderListPickerItem(icon: Icons.grid_view_rounded, label: 'Local', payload: FeedListType.local),
    ];
  }

  ThunderListPickerItem<FeedListType> _currentFeedTypeOption(FeedListType? currentType) {
    return _feedTypeOptions().firstWhereOrNull((item) => item.payload == currentType) ??
        const ThunderListPickerItem(icon: Icons.view_list_rounded, label: 'Subscribed', payload: FeedListType.subscribed);
  }

  ThunderListPickerItem<PostSortType> _currentSortOption(Account account, PostSortType? currentSortType) {
    final options = [...getDefaultPostSortTypeItems(account: account), ...getTopPostSortTypeItems(account: account)];

    if (currentSortType == null) return options.first;

    return options.firstWhereOrNull((item) => item.payload == currentSortType) ??
        allPostSortTypeItems.firstWhere(
          (item) => item.payload == currentSortType,
          orElse: () => ThunderListPickerItem(payload: currentSortType, icon: Icons.sort_rounded, label: currentSortType.value, capitalizeLabel: false),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final account = resolveEffectiveAccount(context);

    return UserSettingsPageScaffold(
      childrenBuilder: (context, state) {
        final theme = Theme.of(context);
        final isUpdating = state.status == AccountSettingsStatus.updating;
        final myUser = state.siteResponse?.myUser;
        final localUser = myUser?.localUserView.localUser;
        final person = myUser?.localUserView.person;
        final currentFeedTypeOption = _currentFeedTypeOption(localUser?.defaultListingType);
        final currentSortOption = _currentSortOption(account, localUser?.defaultSortType);

        return [
          ThunderSectionHeader(title: l10n.general),
          ThunderSettingsTile(
            leading: const Icon(Icons.person_rounded),
            title: l10n.displayName,
            subtitle: person?.displayName?.isNotEmpty == true ? person?.displayName : l10n.noDisplayNameSet,
            trailing: const Padding(padding: EdgeInsets.all(20.0)),
            onTap: isUpdating ? null : () => _editDisplayName(context, person),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountDisplayName),
            highlighted: settingToHighlight == LocalSettings.accountDisplayName,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.note_rounded),
            title: l10n.profileBio,
            subtitle: person?.bio?.isNotEmpty == true ? parse(markdownToHtml(person?.bio ?? '')).documentElement?.text.trim() : l10n.noProfileBioSet,
            subtitleMaxLines: 1,
            trailing: const Padding(padding: EdgeInsets.all(20.0)),
            onTap: isUpdating ? null : () => _editBio(context, person),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountProfileBio),
            highlighted: settingToHighlight == LocalSettings.accountProfileBio,
          ),
          ThunderSectionHeader(title: l10n.feedSettings, description: l10n.settingOverrideLabel),
          ThunderListOption(
            title: l10n.defaultFeedSortType,
            value: currentSortOption,
            options: getDefaultPostSortTypeItems(account: account),
            leading: const Icon(Icons.sort_rounded),
            onChanged: (_) async {},
            disabled: isUpdating,
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
                Icon(currentSortOption.icon, size: 13),
                const SizedBox(width: 4),
                Text(currentSortOption.label, style: theme.textTheme.titleSmall),
              ],
            ),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountDefaultFeedSortType),
            highlighted: settingToHighlight == LocalSettings.accountDefaultFeedSortType,
          ),
          ThunderToggleOption(
            title: l10n.showNsfwContent,
            value: localUser?.showNsfw,
            iconEnabled: Icons.no_adult_content,
            iconDisabled: Icons.no_adult_content,
            onChanged: (value) => context.read<AccountSettingsCubit>().updateSettings(showNsfw: value),
            disabled: isUpdating,
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowNsfwContent),
            highlighted: settingToHighlight == LocalSettings.accountShowNsfwContent,
          ),
          ThunderToggleOption(
            title: l10n.showReadPosts,
            value: localUser?.showReadPosts,
            iconEnabled: Icons.fact_check_rounded,
            iconDisabled: Icons.fact_check_outlined,
            onChanged: (value) => context.read<AccountSettingsCubit>().updateSettings(showReadPosts: value),
            disabled: isUpdating,
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowReadPosts),
            highlighted: settingToHighlight == LocalSettings.accountShowReadPosts,
          ),
          ThunderToggleOption(
            title: l10n.showBotAccounts,
            value: localUser?.showBotAccounts,
            iconEnabled: ThunderIcon.robot,
            iconDisabled: ThunderIcon.robot,
            onChanged: (value) => context.read<AccountSettingsCubit>().updateSettings(showBotAccounts: value),
            disabled: isUpdating,
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountShowBotAccounts),
            highlighted: settingToHighlight == LocalSettings.accountShowBotAccounts,
          ),
          ThunderListOption(
            title: l10n.defaultFeedType,
            value: currentFeedTypeOption,
            options: _feedTypeOptions(),
            leading: const Icon(Icons.filter_alt_rounded),
            disabled: isUpdating,
            onChanged: (value) async => context.read<AccountSettingsCubit>().updateSettings(defaultFeedListType: value.payload),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountDefaultFeedType),
            highlighted: settingToHighlight == LocalSettings.accountDefaultFeedType,
          ),
          ThunderSectionHeader(title: l10n.contentManagement),
          ThunderSettingsTile(
            leading: const Icon(Icons.language_rounded),
            title: l10n.discussionLanguages,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: isUpdating ? null : () => navigateToSettingPage(context, LocalSettings.settingsPageAccountLanguages),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.discussionLanguages),
            highlighted: settingToHighlight == LocalSettings.discussionLanguages,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.block_rounded),
            title: l10n.blockSettingLabel,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccountBlocks),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountBlocks),
            highlighted: settingToHighlight == LocalSettings.accountBlocks,
          ),
          ThunderSectionHeader(title: l10n.importExportSettings, description: l10n.importExportLemmyAccountSettingsSubtitle),
          ThunderSettingsTile(
            leading: const Icon(Icons.file_download_rounded),
            title: l10n.exportLemmyAccountSettingsDescription,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => _exportSettings(context),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountExportSettings),
            highlighted: settingToHighlight == LocalSettings.accountExportSettings,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.file_upload_rounded),
            title: l10n.importLemmyAccountSettingsDescription,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => _importSettings(context),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountImportSettings),
            highlighted: settingToHighlight == LocalSettings.accountImportSettings,
          ),
          ThunderSectionHeader(title: l10n.dangerZone),
          ThunderSettingsTile(
            leading: const Icon(Icons.password),
            title: l10n.changePassword,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => _openInstanceSettings(context, title: l10n.changePassword, contentText: l10n.changePasswordWarning),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountChangePassword),
            highlighted: settingToHighlight == LocalSettings.accountChangePassword,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: l10n.deleteAccount,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => _openInstanceSettings(context, title: l10n.deleteAccount, contentText: l10n.deleteAccountDescription),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountDeleteAccount),
            highlighted: settingToHighlight == LocalSettings.accountDeleteAccount,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.hide_image_rounded),
            title: l10n.manageMedia,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccountMedia),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountManageMedia),
            highlighted: settingToHighlight == LocalSettings.accountManageMedia,
          ),
        ];
      },
    );
  }

  void _editDisplayName(BuildContext context, ThunderUser? person) {
    final l10n = GlobalContext.l10n;
    displayNameTextController.text = person?.displayName ?? '';

    showThunderDialog(
      context: context,
      title: l10n.displayName,
      contentWidgetBuilder: (_) => TextField(
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
  }

  void _editBio(BuildContext context, ThunderUser? person) {
    final l10n = GlobalContext.l10n;
    bioTextController.text = person?.bio ?? '';

    showThunderDialog(
      context: context,
      title: l10n.profileBio,
      contentWidgetBuilder: (_) => TextField(
        controller: bioTextController,
        minLines: 8,
        maxLines: 8,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(border: const OutlineInputBorder(), hintText: l10n.profileBio),
      ),
      primaryButtonText: l10n.save,
      onPrimaryButtonPressed: (dialogContext, _) {
        context.read<AccountSettingsCubit>().updateSettings(bio: bioTextController.text);
        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
    );
  }

  Future<void> _exportSettings(BuildContext context) async {
    final l10n = GlobalContext.l10n;

    dynamic exportSettings;
    try {
      final account = resolveEffectiveAccount(context);
      exportSettings = await createAccountRepository(account).exportSettings();
    } catch (e) {
      showThunderSnackbar(getExceptionErrorMessage(e));
      return;
    }

    try {
      final initialFilePath = (await getApplicationDocumentsDirectory()).path;
      final initialFileName = 'lemmy_user_settings_${DateTime.now().toUtc().toIso8601String().replaceAll(':', '').replaceAll('-', '')}.json';
      final filePath = '$initialFilePath/$initialFileName';

      final file = File(filePath);
      await file.writeAsString(jsonEncode(exportSettings));

      final savedFilePath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(mimeTypesFilter: const ['application/json'], sourceFilePath: filePath, fileName: initialFileName),
      );

      if (savedFilePath?.isNotEmpty == true) {
        showThunderSnackbar(l10n.accountSettingsExportedSuccessfully(savedFilePath!));
      } else {
        showThunderSnackbar(l10n.errorSavingAccountSettings);
      }
    } catch (e) {
      showThunderSnackbar('${l10n.errorSavingAccountSettings} $e');
    }
  }

  Future<void> _importSettings(BuildContext context) async {
    final l10n = GlobalContext.l10n;
    late final String importSettings;

    try {
      final filePath = await FlutterFileDialog.pickFile(params: const OpenFileDialogParams(fileExtensionsFilter: ['json']));

      if (filePath != null) {
        importSettings = await File(filePath).readAsString();
      } else {
        showThunderSnackbar(l10n.errorLoadingAccountSettings);
        return;
      }
    } catch (e) {
      if (e is FormatException) {
        showThunderSnackbar(l10n.errorParsingJson);
      } else if ((e as PlatformException?)?.code == 'invalid_file_extension') {
        showThunderSnackbar(l10n.youMustSelectAJsonFile);
      } else {
        showThunderSnackbar('${l10n.errorLoadingAccountSettings} $e');
      }
      return;
    }

    try {
      final appL10n = AppLocalizations.of(GlobalContext.context)!;
      final account = resolveEffectiveAccount(context);
      final success = await createAccountRepository(account).importSettings(importSettings);

      if (success) {
        showThunderSnackbar(appL10n.accountSettingsImportedSuccessfully);
        context.read<ProfileBloc>().add(FetchProfileSettings());
      } else {
        showThunderSnackbar(appL10n.errorImportingAccountSettings);
      }
    } catch (e) {
      showThunderSnackbar(getExceptionErrorMessage(e));
    }
  }

  Future<void> _openInstanceSettings(BuildContext context, {required String title, required String contentText}) async {
    final l10n = GlobalContext.l10n;

    showThunderDialog<void>(
      context: context,
      title: title,
      contentText: contentText,
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
      primaryButtonText: l10n.confirm,
      onPrimaryButtonPressed: (dialogContext, _) async {
        if (!context.mounted) return;

        Navigator.of(context).pop();
        final account = resolveEffectiveAccount(context);
        handleLink(context, url: 'https://${account.instance}/settings');
      },
    );
  }
}
