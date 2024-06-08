import "package:flutter/material.dart";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:lemmy_api_client/v3.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:swipeable_page_route/swipeable_page_route.dart";

import "package:thunder/account/bloc/account_bloc.dart";
import "package:thunder/core/enums/local_settings.dart";
import "package:thunder/core/singletons/lemmy_client.dart";
import "package:thunder/settings/widgets/settings_list_tile.dart";
import "package:thunder/settings/widgets/toggle_option.dart";
import "package:thunder/shared/dialogs.dart";
import "package:thunder/thunder/bloc/thunder_bloc.dart";
import "package:thunder/thunder/thunder_icons.dart";
import "package:thunder/user/bloc/user_settings_bloc.dart";
import "package:thunder/user/pages/user_settings_block_page.dart";
import "package:thunder/user/widgets/user_indicator.dart";
import "package:thunder/utils/links.dart";
import "package:thunder/account/utils/profiles.dart";

/// A widget that displays the user settings page. This page contains user settings that are synced with the instance.
class UserSettingsPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    context.read<UserSettingsBloc>().add(const GetUserSettingsEvent());
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
            listener: (context, state) {},
            builder: (context, state) {
              GetSiteResponse? getSiteResponse = state.getSiteResponse;

              MyUserInfo? myUserInfo = getSiteResponse?.myUser;
              LocalUser? localUser = myUserInfo?.localUserView.localUser;
              Person? person = myUserInfo?.localUserView.person;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    centerTitle: false,
                    toolbarHeight: 70.0,
                    title: Text(l10n.accountSettings),
                    actions: [
                      IconButton(icon: const Icon(Icons.people_alt_rounded), onPressed: () => showProfileModalSheet(context)),
                    ],
                  ),
                  state.status == UserSettingsStatus.notLoggedIn
                      ? SliverToBoxAdapter(child: Container())
                      : SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0, right: 8.0),
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              SettingsListTile(
                                icon: Icons.note_rounded,
                                description: l10n.profileBio,
                                subtitle: person?.bio?.isNotEmpty == true ? person?.bio : l10n.noProfileBioSet,
                                widget: const Padding(padding: EdgeInsets.all(20.0)),
                                onTap: () {
                                  bioTextController.text = person?.bio ?? "";
                                  showThunderDialog(
                                    context: context,
                                    title: l10n.profileBio,
                                    contentWidgetBuilder: (setPrimaryButtonEnabled) => TextField(
                                      controller: bioTextController,
                                      decoration: InputDecoration(hintText: l10n.profileBio),
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              SettingsListTile(
                                icon: Icons.person_2,
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
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
                              ToggleOption(
                                description: l10n.showNsfwContent,
                                value: localUser?.showNsfw,
                                iconEnabled: Icons.no_adult_content,
                                iconDisabled: Icons.no_adult_content,
                                onToggle: (bool value) => context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showNsfw: value)),
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              ToggleOption(
                                description: l10n.blurNsfwContent,
                                value: localUser?.blurNsfw,
                                iconEnabled: Icons.no_adult_content,
                                iconDisabled: Icons.no_adult_content,
                                onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(blurNsfw: value))},
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              ToggleOption(
                                description: l10n.showScores,
                                value: localUser?.showScores,
                                iconEnabled: Icons.onetwothree_rounded,
                                iconDisabled: Icons.onetwothree_rounded,
                                onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showScores: value))},
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              ToggleOption(
                                description: l10n.showReadPosts,
                                value: localUser?.showReadPosts,
                                iconEnabled: Icons.fact_check_rounded,
                                iconDisabled: Icons.fact_check_outlined,
                                onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showReadPosts: value))},
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              ToggleOption(
                                description: l10n.showBotAccounts,
                                value: localUser?.showBotAccounts,
                                iconEnabled: Thunder.robot,
                                iconEnabledSize: 18.0,
                                iconDisabled: Thunder.robot,
                                iconDisabledSize: 18.0,
                                iconSpacing: 14.0,
                                onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showBotAccounts: value))},
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Text(l10n.contentManagement, style: theme.textTheme.titleMedium),
                              ),
                              SettingsListTile(
                                icon: Icons.language_rounded,
                                description: l10n.discussionLanguages,
                                widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                                onTap: () {},
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
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
                                highlightKey: null,
                                setting: null,
                                highlightedSetting: null,
                              ),
                              const SizedBox(height: 100.0),
                            ],
                          ),
                        )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
