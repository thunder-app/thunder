import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:html/parser.dart";
import "package:lemmy_api_client/v3.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:swipeable_page_route/swipeable_page_route.dart";
import 'package:markdown/markdown.dart' hide Text;

import "package:thunder/account/bloc/account_bloc.dart";
import "package:thunder/account/widgets/account_placeholder.dart";
import "package:thunder/core/auth/bloc/auth_bloc.dart";
import "package:thunder/core/enums/local_settings.dart";
import "package:thunder/core/singletons/lemmy_client.dart";
import "package:thunder/settings/widgets/discussion_language_selector.dart";
import "package:thunder/settings/widgets/list_option.dart";
import "package:thunder/settings/widgets/settings_list_tile.dart";
import "package:thunder/settings/widgets/toggle_option.dart";
import "package:thunder/shared/dialogs.dart";
import "package:thunder/shared/snackbar.dart";
import "package:thunder/shared/sort_picker.dart";
import "package:thunder/thunder/bloc/thunder_bloc.dart";
import "package:thunder/thunder/thunder_icons.dart";
import "package:thunder/user/bloc/user_settings_bloc.dart";
import "package:thunder/user/pages/user_settings_block_page.dart";
import "package:thunder/user/widgets/user_indicator.dart";
import "package:thunder/utils/bottom_sheet_list_picker.dart";
import "package:thunder/utils/links.dart";
import "package:thunder/account/utils/profiles.dart";
import "package:version/version.dart";

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
    context.read<UserSettingsBloc>().add(const GetUserSettingsEvent());

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (!context.mounted) return;
            context.read<UserSettingsBloc>().add(const ResetUserSettingsEvent());
            context.read<UserSettingsBloc>().add(const GetUserSettingsEvent());
          },
          child: BlocConsumer<UserSettingsBloc, UserSettingsState>(
            listener: (context, state) {
              if (state.status == UserSettingsStatus.failure) {
                showSnackbar(state.errorMessage ?? l10n.unexpectedError);
              }

              if (state.status == UserSettingsStatus.success) {
                context.read<AuthBloc>().add(LemmyAccountSettingUpdated());
              }
            },
            builder: (context, state) {
              GetSiteResponse? getSiteResponse = state.getSiteResponse;

              MyUserInfo? myUserInfo = getSiteResponse?.myUser;
              LocalUser? localUser = myUserInfo?.localUserView.localUser;
              Person? person = myUserInfo?.localUserView.person;

              return CustomScrollView(
                physics: state.status == UserSettingsStatus.notLoggedIn ? const NeverScrollableScrollPhysics() : null,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    centerTitle: false,
                    toolbarHeight: 70.0,
                    title: Text(l10n.accountSettings),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.people_alt_rounded),
                        onPressed: () => showProfileModalSheet(context),
                      ),
                    ],
                  ),
                  switch (state.status) {
                    UserSettingsStatus.notLoggedIn => const SliverFillRemaining(hasScrollBody: false, child: AccountPlaceholder()),
                    UserSettingsStatus.initial => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: SizedBox(
                            width: 64.0,
                            height: 64.0,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    _ => SliverList(
                        delegate: SliverChildListDelegate(
                          [
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
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.general, style: theme.textTheme.titleMedium),
                            ),
                            SettingsListTile(
                              icon: Icons.person_rounded,
                              description: l10n.displayName,
                              subtitle: person?.displayName?.isNotEmpty == true ? person?.displayName : l10n.noDisplayNameSet,
                              widget: const Padding(padding: EdgeInsets.all(20.0)),
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
                                    context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(displayName: displayNameTextController.text));
                                    Navigator.of(dialogContext).pop();
                                  },
                                  secondaryButtonText: l10n.cancel,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountDisplayName,
                              highlightedSetting: settingToHighlight,
                            ),
                            SettingsListTile(
                              icon: Icons.note_rounded,
                              description: l10n.profileBio,
                              subtitle: person?.bio?.isNotEmpty == true ? parse(markdownToHtml(person?.bio ?? "")).documentElement?.text.trim() : l10n.noProfileBioSet,
                              subtitleMaxLines: 1,
                              widget: const Padding(padding: EdgeInsets.all(20.0)),
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
                                    context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(bio: bioTextController.text));
                                    Navigator.of(dialogContext).pop();
                                  },
                                  secondaryButtonText: l10n.cancel,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountProfileBio,
                              highlightedSetting: settingToHighlight,
                            ),
                            SettingsListTile(
                              icon: Icons.email_rounded,
                              description: l10n.email,
                              subtitle: localUser?.email?.isNotEmpty == true ? localUser?.email : l10n.noEmailSet,
                              widget: const Padding(padding: EdgeInsets.all(20.0)),
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
                                    context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(email: emailTextController.text));
                                    Navigator.of(dialogContext).pop();
                                  },
                                  secondaryButtonText: l10n.cancel,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountEmail,
                              highlightedSetting: settingToHighlight,
                            ),
                            SettingsListTile(
                              icon: Icons.person_rounded,
                              description: l10n.matrixUser,
                              subtitle: person?.matrixUserId?.isNotEmpty == true ? person?.matrixUserId : l10n.noMatrixUserSet,
                              widget: const Padding(padding: EdgeInsets.all(20.0)),
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
                                    context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(matrixUserId: matrixUserTextController.text));
                                    Navigator.of(dialogContext).pop();
                                  },
                                  secondaryButtonText: l10n.cancel,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountMatrixUser,
                              highlightedSetting: settingToHighlight,
                            ),
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
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                            ),
                            ListOption(
                              description: l10n.defaultFeedType,
                              value: ListPickerItem(label: localUser!.defaultListingType.value, icon: Icons.feed, payload: localUser.defaultListingType),
                              options: [
                                ListPickerItem(icon: Icons.view_list_rounded, label: ListingType.subscribed.value, payload: ListingType.subscribed),
                                ListPickerItem(icon: Icons.home_rounded, label: ListingType.all.value, payload: ListingType.all),
                                ListPickerItem(icon: Icons.grid_view_rounded, label: ListingType.local.value, payload: ListingType.local),
                              ],
                              icon: Icons.filter_alt_rounded,
                              onChanged: (value) async => context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(defaultListingType: value.payload)),
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountDefaultFeedType,
                              highlightedSetting: settingToHighlight,
                            ),
                            ListOption(
                              description: l10n.defaultFeedSortType,
                              value: ListPickerItem(label: localUser.defaultSortType.value, icon: Icons.local_fire_department_rounded, payload: localUser.defaultSortType),
                              options: [
                                ...SortPicker.getDefaultSortTypeItems(minimumVersion: Version(0, 19, 0, preRelease: ["rc", "1"])),
                                ...topSortTypeItems
                              ],
                              icon: Icons.sort_rounded,
                              onChanged: (_) async {},
                              isBottomModalScrollControlled: true,
                              customListPicker: SortPicker(
                                minimumVersion: Version(0, 19, 0, preRelease: ["rc", "1"]),
                                title: l10n.defaultFeedSortType,
                                onSelect: (value) async {
                                  context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(defaultSortType: value.payload));
                                },
                                previouslySelected: localUser.defaultSortType,
                              ),
                              valueDisplay: Row(
                                children: [
                                  Icon(allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == localUser.defaultSortType).icon, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == localUser.defaultSortType).label,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ],
                              ),
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountDefaultFeedSortType,
                              highlightedSetting: settingToHighlight,
                            ),
                            ToggleOption(
                              description: l10n.showNsfwContent,
                              value: localUser.showNsfw,
                              iconEnabled: Icons.no_adult_content,
                              iconDisabled: Icons.no_adult_content,
                              onToggle: (bool value) => context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showNsfw: value)),
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountShowNsfwContent,
                              highlightedSetting: settingToHighlight,
                            ),
                            ToggleOption(
                              description: l10n.showScores,
                              value: localUser.showScores,
                              iconEnabled: Icons.onetwothree_rounded,
                              iconDisabled: Icons.onetwothree_rounded,
                              onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showScores: value))},
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountShowScores,
                              highlightedSetting: settingToHighlight,
                            ),
                            ToggleOption(
                              description: l10n.showReadPosts,
                              value: localUser.showReadPosts,
                              iconEnabled: Icons.fact_check_rounded,
                              iconDisabled: Icons.fact_check_outlined,
                              onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showReadPosts: value))},
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountShowReadPosts,
                              highlightedSetting: settingToHighlight,
                            ),
                            ToggleOption(
                              description: l10n.bot,
                              value: person?.botAccount,
                              iconEnabled: Thunder.robot,
                              iconDisabled: Thunder.robot,
                              iconSpacing: 14.0,
                              onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(botAccount: value))},
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountIsBot,
                              highlightedSetting: settingToHighlight,
                            ),
                            ToggleOption(
                              description: l10n.showBotAccounts,
                              value: localUser.showBotAccounts,
                              iconEnabled: Thunder.robot,
                              iconDisabled: Thunder.robot,
                              iconSpacing: 14.0,
                              onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showBotAccounts: value))},
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountShowBotAccounts,
                              highlightedSetting: settingToHighlight,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.contentManagement, style: theme.textTheme.titleMedium),
                            ),
                            SettingsListTile(
                              icon: Icons.language_rounded,
                              description: l10n.discussionLanguages,
                              widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                              onTap: () async {
                                final state = context.read<ThunderBloc>().state;
                                await Navigator.of(context).push(
                                  SwipeablePageRoute(
                                    transitionDuration: state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                                    canOnlySwipeFromEdge: true,
                                    backGestureDetectionWidth: 45,
                                    builder: (navigatorContext) {
                                      return MultiBlocProvider(
                                        providers: [BlocProvider<UserSettingsBloc>.value(value: context.read<UserSettingsBloc>())],
                                        child: const DiscussionLanguageSelector(),
                                      );
                                    },
                                  ),
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.discussionLanguages,
                              highlightedSetting: settingToHighlight,
                            ),
                            SettingsListTile(
                              icon: Icons.block_rounded,
                              description: l10n.blockSettingLabel,
                              widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                              onTap: () async {
                                final state = context.read<ThunderBloc>().state;
                                await Navigator.of(context).push(
                                  SwipeablePageRoute(
                                    transitionDuration: state.reduceAnimations ? const Duration(milliseconds: 100) : null,
                                    canOnlySwipeFromEdge: true,
                                    backGestureDetectionWidth: 45,
                                    builder: (navigatorContext) {
                                      return MultiBlocProvider(
                                        providers: [BlocProvider<UserSettingsBloc>.value(value: context.read<UserSettingsBloc>())],
                                        child: const UserSettingsBlockPage(),
                                      );
                                    },
                                  ),
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountBlocks,
                              highlightedSetting: settingToHighlight,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.dangerZone, style: theme.textTheme.titleMedium),
                            ),
                            SettingsListTile(
                              icon: Icons.password,
                              description: l10n.changePassword,
                              widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
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
                                      handleLink(context, url: "https://${LemmyClient.instance.lemmyApiV3.host}/settings");
                                    }
                                  },
                                  primaryButtonText: l10n.confirm,
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountChangePassword,
                              highlightedSetting: settingToHighlight,
                            ),
                            SettingsListTile(
                              icon: Icons.delete_forever_rounded,
                              description: l10n.deleteAccount,
                              widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
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
                                      handleLink(context, url: "https://${LemmyClient.instance.lemmyApiV3.host}/settings");
                                    }
                                  },
                                );
                              },
                              highlightKey: settingToHighlightKey,
                              setting: LocalSettings.accountDeleteAccount,
                              highlightedSetting: settingToHighlight,
                            ),
                            const SizedBox(height: 100.0),
                          ],
                        ),
                      )
                  }
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
