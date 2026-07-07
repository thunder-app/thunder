import 'dart:async';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/settings/presentation/utils/setting_link_utils.dart';
import 'package:thunder/src/features/user/presentation/state/account_settings_cubit.dart';
import 'package:thunder/src/features/user/presentation/widgets/user_settings_page_scaffold.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/enums/enums.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_language.dart';
import 'package:thunder/src/shared/sort_picker.dart';

/// PieFed account settings page.
class PiefedUserSettingsPage extends StatefulWidget {
  /// The setting to be highlighted when searching.
  final LocalSettings? settingToHighlight;

  const PiefedUserSettingsPage({super.key, this.settingToHighlight});

  @override
  State<PiefedUserSettingsPage> createState() => _PiefedUserSettingsPageState();
}

class _PiefedUserSettingsPageState extends State<PiefedUserSettingsPage> {
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
          Scrollable.ensureVisible(
            settingToHighlightKey.currentContext!,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }

        Timer(const Duration(seconds: 1), () {
          if (mounted) setState(() => settingToHighlight = null);
        });
      });
    }
  }

  @override
  void dispose() {
    bioTextController.dispose();
    super.dispose();
  }

  List<ThunderListPickerItem<PostSortType>> _defaultSortOptions(Account account) {
    const allowedSortTypes = {
      PostSortType.hot,
      PostSortType.new_,
      PostSortType.active,
      PostSortType.old,
      PostSortType.scaled,
    };

    return [
      ...getDefaultPostSortTypeItems(account: account),
      ...getTopPostSortTypeItems(account: account),
    ].where((item) => allowedSortTypes.contains(item.payload)).toList();
  }

  List<ThunderListPickerItem<FeedListType>> _feedTypeOptions(Account account) {
    return FeedListType.values
        .where(
          (type) => type.platform == null || type.platform == account.platform,
        )
        .map(
          (type) => ThunderListPickerItem<FeedListType>(
            payload: type,
            icon: switch (type) {
              FeedListType.all => Icons.home_rounded,
              FeedListType.local => Icons.grid_view_rounded,
              FeedListType.subscribed => Icons.view_list_rounded,
              FeedListType.popular => Icons.local_fire_department_rounded,
              FeedListType.moderating || FeedListType.moderatorView => Icons.gavel_rounded,
            },
            label: type.value,
            capitalizeLabel: false,
          ),
        )
        .toList();
  }

  ThunderListPickerItem<FeedListType> _currentFeedTypeOption(
    Account account,
    FeedListType? currentType,
  ) {
    return _feedTypeOptions(account).firstWhereOrNull(
          (item) => item.payload == currentType,
        ) ??
        ThunderListPickerItem<FeedListType>(
          payload: currentType ?? FeedListType.subscribed,
          icon: Icons.feed_rounded,
          label: currentType?.value ?? FeedListType.subscribed.value,
          capitalizeLabel: false,
        );
  }

  ThunderListPickerItem<PostSortType> _currentSortOption({
    required Account account,
    required PostSortType? currentSortType,
  }) {
    final options = _defaultSortOptions(account);

    if (currentSortType == null) return options.first;

    return options.firstWhereOrNull((item) => item.payload == currentSortType) ??
        allPostSortTypeItems.firstWhere(
          (item) => item.payload == currentSortType,
          orElse: () => ThunderListPickerItem<PostSortType>(
            payload: currentSortType,
            icon: Icons.sort_rounded,
            label: currentSortType.value,
            capitalizeLabel: false,
          ),
        );
  }

  String _discussionLanguagesSubtitle(
    List<ThunderLanguage> allLanguages,
    List<int> selectedLanguageIds,
  ) {
    final l10n = GlobalContext.l10n;

    if (selectedLanguageIds.isEmpty) return l10n.noDiscussionLanguages;

    final names = selectedLanguageIds.map((id) {
      return allLanguages.firstWhereOrNull((language) => language.id == id)?.name ?? id.toString();
    }).toList();

    return names.join(', ');
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
        final currentFeedTypeOption = _currentFeedTypeOption(account, localUser?.defaultListingType);
        final currentSortOption = _currentSortOption(
          account: account,
          currentSortType: localUser?.defaultSortType,
        );
        final languages = state.siteResponse?.allLanguages ?? const <ThunderLanguage>[];
        final selectedLanguageIds = myUser?.discussionLanguages ?? const <int>[];

        return [
          ThunderSectionHeader(title: l10n.general),
          ThunderSettingsTile(
            leading: const Icon(Icons.note_rounded),
            title: l10n.profileBio,
            subtitle: person?.bio?.isNotEmpty == true ? parse(markdownToHtml(person?.bio ?? '')).documentElement?.text.trim() : l10n.noProfileBioSet,
            subtitleMaxLines: 1,
            trailing: const Padding(padding: EdgeInsets.all(20.0)),
            onTap: isUpdating ? null : () => _editBio(context, person?.bio),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountProfileBio),
            highlighted: settingToHighlight == LocalSettings.accountProfileBio,
          ),
          ThunderSectionHeader(
            title: l10n.feedSettings,
            description: l10n.settingOverrideLabel,
          ),
          ThunderListOption(
            title: l10n.defaultFeedSortType,
            value: currentSortOption,
            options: _defaultSortOptions(account),
            leading: const Icon(Icons.sort_rounded),
            onChanged: (_) async {},
            disabled: isUpdating,
            isBottomModalScrollControlled: true,
            customListPicker: ThunderBottomSheetListPicker<PostSortType>(
              title: l10n.defaultFeedSortType,
              items: _defaultSortOptions(account),
              previouslySelected: localUser?.defaultSortType,
              onSelect: (value) async {
                context.read<AccountSettingsCubit>().updateSettings(
                      defaultPostSortType: value.payload,
                    );
              },
            ),
            valueDisplay: Row(
              children: [
                Icon(currentSortOption.icon, size: 13),
                const SizedBox(width: 4),
                Text(
                  currentSortOption.label,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountDefaultFeedSortType,
            ),
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
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountShowNsfwContent,
            ),
            highlighted: settingToHighlight == LocalSettings.accountShowNsfwContent,
          ),
          ThunderToggleOption(
            title: 'Show NSFL',
            value: localUser?.showNsfl,
            iconEnabled: Icons.warning_amber_rounded,
            iconDisabled: Icons.warning_amber_outlined,
            onChanged: (value) => context.read<AccountSettingsCubit>().updateSettings(showNsfl: value),
            disabled: isUpdating,
            highlighted: false,
          ),
          ThunderToggleOption(
            title: l10n.showReadPosts,
            value: localUser?.showReadPosts,
            iconEnabled: Icons.fact_check_rounded,
            iconDisabled: Icons.fact_check_outlined,
            onChanged: (value) => context.read<AccountSettingsCubit>().updateSettings(showReadPosts: value),
            disabled: isUpdating,
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountShowReadPosts,
            ),
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
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountShowBotAccounts,
            ),
            highlighted: settingToHighlight == LocalSettings.accountShowBotAccounts,
          ),
          ThunderListOption(
            title: l10n.defaultFeedType,
            value: currentFeedTypeOption,
            options: _feedTypeOptions(account),
            leading: const Icon(Icons.filter_alt_rounded),
            disabled: true,
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountDefaultFeedType,
            ),
            highlighted: settingToHighlight == LocalSettings.accountDefaultFeedType,
          ),
          ThunderSectionHeader(title: l10n.contentManagement),
          ThunderSettingsTile(
            leading: const Icon(Icons.language_rounded),
            title: l10n.discussionLanguages,
            subtitle: _discussionLanguagesSubtitle(
              languages,
              selectedLanguageIds,
            ),
            subtitleMaxLines: 2,
            enabled: false,
            highlightKey: settingToHighlightKey,
            highlighted: settingToHighlight == LocalSettings.discussionLanguages,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.block_rounded),
            title: l10n.blockSettingLabel,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => navigateToSettingPage(
              context,
              LocalSettings.settingsPageAccountBlocks,
            ),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(context, LocalSettings.accountBlocks),
            highlighted: settingToHighlight == LocalSettings.accountBlocks,
          ),
          ThunderSectionHeader(title: l10n.dangerZone),
          ThunderSettingsTile(
            leading: const Icon(Icons.password),
            title: l10n.changePassword,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => _openInstanceSettings(
              context,
              title: l10n.changePassword,
              contentText: l10n.changePasswordWarning,
            ),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountChangePassword,
            ),
            highlighted: settingToHighlight == LocalSettings.accountChangePassword,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: l10n.deleteAccount,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => _openInstanceSettings(
              context,
              title: l10n.deleteAccount,
              contentText: l10n.deleteAccountDescription,
            ),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountDeleteAccount,
            ),
            highlighted: settingToHighlight == LocalSettings.accountDeleteAccount,
          ),
          ThunderSettingsTile(
            leading: const Icon(Icons.hide_image_rounded),
            title: l10n.manageMedia,
            trailing: const ThunderSettingsChevronTrailing(),
            onTap: () => navigateToSettingPage(
              context,
              LocalSettings.settingsPageAccountMedia,
            ),
            highlightKey: settingToHighlightKey,
            onLongPress: () => shareLocalSetting(
              context,
              LocalSettings.accountManageMedia,
            ),
            highlighted: settingToHighlight == LocalSettings.accountManageMedia,
          ),
        ];
      },
    );
  }

  void _editBio(BuildContext context, String? bio) {
    final l10n = GlobalContext.l10n;
    bioTextController.text = bio ?? '';

    showThunderDialog(
      context: context,
      title: l10n.profileBio,
      contentWidgetBuilder: (_) => TextField(
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
        context.read<AccountSettingsCubit>().updateSettings(
              bio: bioTextController.text,
            );
        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
    );
  }

  Future<void> _openInstanceSettings(
    BuildContext context, {
    required String title,
    required String contentText,
  }) async {
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
        handleLink(context, url: 'https://${account.instance}/user/settings');
      },
    );
  }
}
