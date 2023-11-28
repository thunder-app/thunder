import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_instance.dart';
import 'package:thunder/utils/navigate_user.dart';

class UserSettingsPage extends StatefulWidget {
  final int? userId;

  const UserSettingsPage(this.userId, {super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        centerTitle: false,
        title: AutoSizeText(l10n.accountSettings),
        scrolledUnderElevation: 0.0,
      ),
      body: BlocProvider(
        create: (context) => UserSettingsBloc()..add(const GetUserSettingsEvent()),
        child: BlocConsumer<UserSettingsBloc, UserSettingsState>(
          listener: (context, state) {
            if ((state.status == UserSettingsStatus.failure || state.status == UserSettingsStatus.failedRevert) &&
                (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
              showSnackbar(
                context,
                state.status == UserSettingsStatus.failure ? l10n.failedToUnblock(state.errorMessage ?? l10n.missingErrorMessage) : l10n.failedToBlock(state.errorMessage ?? l10n.missingErrorMessage),
              );
            } else if (state.status == UserSettingsStatus.failure) {
              showSnackbar(context, l10n.failedToLoadBlocks(state.errorMessage ?? l10n.missingErrorMessage));
            }

            if (state.status == UserSettingsStatus.successBlock && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
              showSnackbar(
                context,
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
              showSnackbar(context, l10n.successfullyBlocked);
            }
          },
          builder: (context, state) {
            if (state.status == UserSettingsStatus.initial) {
              context.read<UserSettingsBloc>().add(GetUserBlocksEvent(userId: widget.userId));
            }

            GetSiteResponse? getSiteResponse = state.getSiteResponse;
            MyUserInfo? myUserInfo = getSiteResponse?.myUser;

            LocalUser? localUser = myUserInfo?.localUserView.localUser;
            bool showReadPosts = localUser?.showReadPosts ?? true;

            if (state.getSiteResponse == null || myUserInfo == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ToggleOption(
                      description: l10n.showReadPosts,
                      value: showReadPosts,
                      iconEnabled: Icons.fact_check_rounded,
                      iconDisabled: Icons.fact_check_outlined,
                      onToggle: (bool value) => {context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(showReadPosts: value))},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(l10n.filters, style: theme.textTheme.titleMedium),
                  ),
                  if (LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) ...[
                    UserSettingTopic(
                      title: l10n.blockedInstances,
                      trailing: IconButton(
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
                    ),
                    UserSettingBlockList(
                      status: state.status,
                      emptyText: l10n.noInstanceBlocks,
                      items: getInstanceBlocks(context, state, state.instanceBlocks),
                    ),
                  ],
                  UserSettingTopic(
                    title: l10n.blockedUsers,
                    trailing: IconButton(
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
                  ),
                  UserSettingBlockList(
                    status: state.status,
                    emptyText: l10n.noUserBlocks,
                    items: getPersonBlocks(context, state, state.personBlocks),
                  ),
                  UserSettingTopic(
                    title: l10n.blockedCommunities,
                    trailing: IconButton(
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
                  ),
                  UserSettingBlockList(
                    status: state.status,
                    emptyText: l10n.noCommunityBlocks,
                    items: getCommunityBlocks(context, state, state.communityBlocks),
                  ),
                ],
              ),
            );
          },
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
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToInstancePage(context, instanceHost: instance.domain);
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
          message: '${community.name}@${fetchInstanceNameFromUrl(community.actorId) ?? '-'}',
          preferBelow: false,
          child: Material(
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToFeedPage(context, feedType: FeedType.community, communityName: '${community.name}@${fetchInstanceNameFromUrl(community.actorId)}');
              },
              child: ListTile(
                leading: CommunityIcon(community: community, radius: 16.0),
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(
                  community.title,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${community.name}@${fetchInstanceNameFromUrl(community.actorId) ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          message: '${person.name}@${fetchInstanceNameFromUrl(person.actorId) ?? '-'}',
          preferBelow: false,
          child: Material(
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToUserPage(context, username: '${person.name}@${fetchInstanceNameFromUrl(person.actorId)}');
              },
              child: ListTile(
                leading: UserAvatar(person: person),
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(
                  person.displayName ?? person.name,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${person.name}@${fetchInstanceNameFromUrl(person.actorId) ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

/// This class creates a widget for the title of a given [UserSettingTopic] (e.g., blocked users, communities, instances).
///
/// It takes in an icon, a title, and an optional [trailing] widget.
class UserSettingTopic extends StatelessWidget {
  const UserSettingTopic({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
  });

  final IconData? icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListTile(
        leading: icon != null
            ? CircleAvatar(
                radius: 16.0,
                backgroundColor: Colors.transparent,
                child: Icon(icon),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
        trailing: trailing,
      ),
    );
  }
}
