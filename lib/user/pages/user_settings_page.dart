import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/settings/widgets/discussion_language_selector.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/account/utils/profiles.dart';

class UserSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const UserSettingsPage({super.key, this.settingToHighlight});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70.0,
          centerTitle: false,
          title: AutoSizeText(l10n.accountSettings),
          scrolledUnderElevation: 0.0,
        ),
        body: BlocProvider(
          create: (context) => UserSettingsBloc()..add(const GetUserSettingsEvent()),
          child: BlocListener<AccountBloc, AccountState>(
            listener: (context, state) {
              context.read<UserSettingsBloc>().add(const ResetUserSettingsEvent());
              context.read<UserSettingsBloc>().add(const GetUserSettingsEvent());
            },
            child: BlocConsumer<UserSettingsBloc, UserSettingsState>(
              listener: (context, state) {
                if (state.status == UserSettingsStatus.success) {
                  context.read<AuthBloc>().add(LemmyAccountSettingUpdated());
                }

                if ((state.status == UserSettingsStatus.failure || state.status == UserSettingsStatus.failedRevert) &&
                    (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
                  showSnackbar(state.status == UserSettingsStatus.failure
                      ? l10n.failedToUnblock(state.errorMessage ?? l10n.missingErrorMessage)
                      : l10n.failedToBlock(state.errorMessage ?? l10n.missingErrorMessage));
                } else if (state.status == UserSettingsStatus.failure) {
                  showSnackbar(l10n.failedToLoadBlocks(state.errorMessage ?? l10n.missingErrorMessage));
                }

                if (state.status == UserSettingsStatus.successBlock && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
                  showSnackbar(
                    l10n.successfullyUnblocked,
                    trailingIcon: Icons.undo_rounded,
                    trailingAction: () {
                      if (state.personBeingBlocked != 0) {
                        context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: state.personBeingBlocked, unblock: false));
                      } else if (state.communityBeingBlocked != 0) {
                        context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: state.communityBeingBlocked, unblock: false));
                      } else if (state.instanceBeingBlocked != 0) {
                        context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: state.instanceBeingBlocked, unblock: false));
                      }
                    },
                  );
                }

                if (state.status == UserSettingsStatus.revert && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
                  showSnackbar(l10n.successfullyBlocked);
                }
              },
              builder: (context, state) {
                if (state.status == UserSettingsStatus.initial) {
                  context.read<UserSettingsBloc>().add(const GetUserBlocksEvent());
                }

                GetSiteResponse? getSiteResponse = state.getSiteResponse;
                MyUserInfo? myUserInfo = getSiteResponse?.myUser;

                LocalUser? localUser = myUserInfo?.localUserView.localUser;
                bool showReadPosts = localUser?.showReadPosts ?? true;
                bool showBotAccounts = localUser?.showBotAccounts ?? true;
                bool showScores = localUser?.showScores ?? true;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SettingsListTile(
                        icon: Icons.people_alt_rounded,
                        description: l10n.manageAccounts,
                        widget: const SizedBox(
                          height: 42.0,
                          child: Icon(Icons.chevron_right_rounded),
                        ),
                        onTap: () => showProfileModalSheet(context),
                        highlightKey: null,
                        setting: null,
                        highlightedSetting: null,
                      ),
                      if (state.status != UserSettingsStatus.notLoggedIn && state.getSiteResponse != null && myUserInfo != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Divider(
                              indent: 32.0,
                              height: 32.0,
                              endIndent: 32.0,
                              thickness: 2.0,
                              color: theme.dividerColor.withOpacity(0.6),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.thisAccount, style: theme.textTheme.titleMedium),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, bottom: 16.0, right: 8),
                              child: UserIndicator(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 8.0, left: 16.0, right: 16.0),
                              child: Text(
                                l10n.userSettingDescription,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.general, style: theme.textTheme.titleMedium),
                            ),
                            SettingsListTile(
                              icon: Icons.logout_rounded,
                              description: l10n.logOut,
                              widget: const SizedBox(
                                height: 42.0,
                                child: Icon(Icons.chevron_right_rounded),
                              ),
                              onTap: () => showProfileModalSheet(context, showLogoutDialog: true),
                              highlightKey: null,
                              setting: null,
                              highlightedSetting: null,
                            ),
                            ToggleOption(
                              description: l10n.showReadPosts,
                              value: showReadPosts,
                              iconEnabled: Icons.fact_check_rounded,
                              iconDisabled: Icons.fact_check_outlined,
                              onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showReadPosts: value))},
                              highlightKey: null,
                              setting: null,
                              highlightedSetting: null,
                            ),
                            ToggleOption(
                              description: l10n.showScores,
                              value: showScores,
                              iconEnabled: Icons.onetwothree_rounded,
                              iconDisabled: Icons.onetwothree_rounded,
                              onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showScores: value))},
                              highlightKey: null,
                              setting: null,
                              highlightedSetting: null,
                            ),
                            ToggleOption(
                              description: l10n.showBotAccounts,
                              value: showBotAccounts,
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
                            DiscussionLanguageSelector(
                              initialDiscussionLanguages: DiscussionLanguageSelector.getDiscussionLanguagesFromSiteResponse(state.getSiteResponse),
                              settingToHighlight: widget.settingToHighlight,
                            ),
                            if (LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.blockedInstances, style: theme.textTheme.titleMedium),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                        Icons.add_rounded,
                                        semanticLabel: l10n.add,
                                      ),
                                      onPressed: () => showInstanceInputDialog(
                                        context,
                                        title: l10n.blockInstance,
                                        onInstanceSelected: (instance) {
                                          context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: instance.id, unblock: false));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              UserSettingBlockList(
                                status: state.status,
                                emptyText: l10n.noInstanceBlocks,
                                items: getInstanceBlocks(context, state, state.instanceBlocks),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(l10n.blockedUsers, style: theme.textTheme.titleMedium),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.add_rounded,
                                      semanticLabel: l10n.add,
                                    ),
                                    onPressed: () => showUserInputDialog(
                                      context,
                                      title: l10n.blockUser,
                                      onUserSelected: (personViewSafe) {
                                        context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: personViewSafe.person.id, unblock: false));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            UserSettingBlockList(
                              status: state.status,
                              emptyText: l10n.noUserBlocks,
                              items: getPersonBlocks(context, state, state.personBlocks),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(l10n.blockedCommunities, style: theme.textTheme.titleMedium),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.add_rounded,
                                      semanticLabel: l10n.add,
                                    ),
                                    onPressed: () => showCommunityInputDialog(
                                      context,
                                      title: l10n.blockCommunity,
                                      onCommunitySelected: (communityView) {
                                        context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: communityView.community.id, unblock: false));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            UserSettingBlockList(
                              status: state.status,
                              emptyText: l10n.noCommunityBlocks,
                              items: getCommunityBlocks(context, state, state.communityBlocks),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(l10n.dangerZone, style: theme.textTheme.titleMedium),
                            ),
                            SettingsListTile(
                              icon: Icons.delete_forever_rounded,
                              description: l10n.deleteAccount,
                              widget: const SizedBox(
                                height: 42.0,
                                child: Icon(Icons.chevron_right_rounded),
                              ),
                              onTap: () async {
                                showThunderDialog<void>(
                                  context: context,
                                  title: l10n.deleteAccount,
                                  contentText: l10n.deleteAccountDescription,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  secondaryButtonText: l10n.cancel,
                                  onPrimaryButtonPressed: (dialogContext, _) async {
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      handleLink(context, url: 'https://${LemmyClient.instance.lemmyApiV3.host}/settings');
                                    }
                                  },
                                  primaryButtonText: l10n.confirm,
                                );
                              },
                              highlightKey: null,
                              setting: null,
                              highlightedSetting: null,
                            ),
                            const SizedBox(height: 100.0),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getInstanceBlocks(BuildContext context, UserSettingsState state, List<Instance> instances) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return instances.map((instance) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Tooltip(
          message: instance.domain,
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToInstancePage(context, instanceHost: instance.domain, instanceId: instance.id);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  maxRadius: 16.0,
                  child: Text(
                    instance.domain[0].toUpperCase(),
                    semanticsLabel: '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(
                  instance.domain,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                trailing: state.status == UserSettingsStatus.blocking && state.instanceBeingBlocked == instance.id
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          semanticLabel: l10n.remove,
                        ),
                        onPressed: () {
                          context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: instance.id));
                        },
                      ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> getCommunityBlocks(BuildContext context, UserSettingsState state, List<Community> communities) {
    final l10n = AppLocalizations.of(context)!;

    return communities.map((community) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Tooltip(
          message: generateCommunityFullName(context, community.name, fetchInstanceNameFromUrl(community.actorId) ?? '-'),
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToFeedPage(context, feedType: FeedType.community, communityName: '${community.name}@${fetchInstanceNameFromUrl(community.actorId)}');
              },
              child: ListTile(
                leading: CommunityAvatar(community: community, radius: 16.0),
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(
                  community.title,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: CommunityFullNameWidget(
                  context,
                  community.name,
                  fetchInstanceNameFromUrl(community.actorId) ?? '-',
                ),
                contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                trailing: state.status == UserSettingsStatus.blocking && state.communityBeingBlocked == community.id
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          semanticLabel: l10n.remove,
                        ),
                        onPressed: () {
                          context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: community.id));
                        },
                      ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> getPersonBlocks(BuildContext context, UserSettingsState state, List<Person> persons) {
    final l10n = AppLocalizations.of(context)!;

    return persons.map((person) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Tooltip(
          message: generateUserFullName(context, person.name, fetchInstanceNameFromUrl(person.actorId) ?? '-'),
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToFeedPage(context, feedType: FeedType.user, username: '${person.name}@${fetchInstanceNameFromUrl(person.actorId)}');
              },
              child: ListTile(
                leading: UserAvatar(person: person),
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(
                  person.displayName ?? person.name,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: UserFullNameWidget(
                  context,
                  person.name,
                  fetchInstanceNameFromUrl(person.actorId) ?? '-',
                ),
                contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                trailing: state.status == UserSettingsStatus.blocking && state.personBeingBlocked == person.id
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          semanticLabel: l10n.remove,
                        ),
                        onPressed: () {
                          context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: person.id));
                        },
                      ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// This class creates a widget which displays a list of items. If no items are available, it displays a message.
class UserSettingBlockList extends StatelessWidget {
  const UserSettingBlockList({
    super.key,
    required this.status,
    this.emptyText,
    this.items = const [],
  });

  final UserSettingsStatus status;
  final String? emptyText;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedCrossFade(
      crossFadeState: status == UserSettingsStatus.initial ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 200),
      firstChild: Container(
        margin: const EdgeInsets.all(10.0),
        child: const Center(child: CircularProgressIndicator()),
      ),
      secondChild: Align(
        alignment: Alignment.centerLeft,
        child: items.isNotEmpty == true
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return index == items.length ? Container() : items[index];
                },
              )
            : Padding(
                padding: const EdgeInsets.only(left: 28, right: 20, bottom: 20),
                child: Text(
                  emptyText ?? '',
                  style: TextStyle(color: theme.hintColor),
                ),
              ),
      ),
    );
  }
}
