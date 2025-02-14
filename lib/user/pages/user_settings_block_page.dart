import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// A widget that displays the user's blocked users, communities, and instances.
class UserSettingsBlockPage extends StatefulWidget {
  const UserSettingsBlockPage({super.key});

  @override
  State<UserSettingsBlockPage> createState() => _UserSettingsBlockPageState();
}

class _UserSettingsBlockPageState extends State<UserSettingsBlockPage> with SingleTickerProviderStateMixin {
  /// The controller for the tab bar used for switching between blocked users, blocked communities, and blocked instances.
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3);
    context.read<UserSettingsBloc>().add(const GetUserBlocksEvent());
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<Widget> getPersonBlocks(BuildContext context, UserSettingsState state, List<Person> persons) {
    final l10n = AppLocalizations.of(context)!;

    return persons.map((person) {
      return Tooltip(
        message: generateUserFullName(
          context,
          person.name,
          person.displayName,
          fetchInstanceNameFromUrl(person.actorId),
        ),
        preferBelow: false,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
          title: Text(person.displayName ?? person.name, overflow: TextOverflow.ellipsis),
          subtitle: UserFullNameWidget(
            context,
            person.name,
            person.displayName,
            fetchInstanceNameFromUrl(person.actorId) ?? '-',
            // Override because we're showing display name above
            useDisplayName: false,
          ),
          leading: UserAvatar(person: person),
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
                  icon: Icon(Icons.clear, semanticLabel: l10n.remove),
                  onPressed: () => context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: person.id)),
                ),
          onTap: () {
            navigateToFeedPage(context, feedType: FeedType.user, username: "${person.name}@${fetchInstanceNameFromUrl(person.actorId)}");
          },
        ),
      );
    }).toList();
  }

  List<Widget> getCommunityBlocks(BuildContext context, UserSettingsState state, List<Community> communities) {
    final l10n = AppLocalizations.of(context)!;

    return communities.map((community) {
      return Tooltip(
        message: generateCommunityFullName(
          context,
          community.name,
          community.title,
          fetchInstanceNameFromUrl(community.actorId),
        ),
        preferBelow: false,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
          title: Text(community.title, overflow: TextOverflow.ellipsis),
          subtitle: CommunityFullNameWidget(
            context,
            community.title,
            community.title,
            fetchInstanceNameFromUrl(community.actorId) ?? '-',
            // Override because we're showing display name above
            useDisplayName: false,
          ),
          leading: CommunityAvatar(community: community, radius: 16.0),
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
                  icon: Icon(Icons.clear, semanticLabel: l10n.remove),
                  onPressed: () => context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: community.id)),
                ),
          onTap: () {
            navigateToFeedPage(context, feedType: FeedType.community, communityName: "${community.name}@${fetchInstanceNameFromUrl(community.actorId)}");
          },
        ),
      );
    }).toList();
  }

  List<Widget> getInstanceBlocks(BuildContext context, UserSettingsState state, List<Instance> instances) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);

    return instances.map((instance) {
      return Tooltip(
        message: instance.domain,
        preferBelow: false,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
          title: Text(instance.domain, overflow: TextOverflow.ellipsis),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            maxRadius: 16.0,
            child: Text(
              instance.domain[0].toUpperCase(),
              semanticsLabel: "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
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
                  icon: Icon(Icons.clear, semanticLabel: l10n.remove),
                  onPressed: () => context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: instance.id)),
                ),
          onTap: () {
            navigateToInstancePage(context, instanceHost: instance.domain, instanceId: instance.id);
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (tabController.index) {
            case 0:
              showUserInputDialog(
                context,
                title: l10n.blockUser,
                onUserSelected: (personView) {
                  context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: personView.person.id, unblock: false));
                },
              );
              break;
            case 1:
              showCommunityInputDialog(
                context,
                title: l10n.blockCommunity,
                onCommunitySelected: (communityView) {
                  context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: communityView.community.id, unblock: false));
                },
              );
              break;
            case 2:
              showInstanceInputDialog(
                context,
                title: l10n.blockInstance,
                onInstanceSelected: (instanceWithFederationState) {
                  context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: instanceWithFederationState.id, unblock: false));
                },
              );
              break;
            default:
              break;
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<UserSettingsBloc, UserSettingsState>(
        listener: (context, state) {
          bool isBlock = (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0);

          if (state.status == UserSettingsStatus.failure && !isBlock) {
            return showSnackbar(state.errorMessage ?? l10n.unexpectedError);
          }

          if (state.status == UserSettingsStatus.failure) {
            showSnackbar(l10n.failedToUnblock(state.errorMessage ?? l10n.missingErrorMessage));
          } else if (state.status == UserSettingsStatus.failedRevert) {
            showSnackbar(l10n.failedToBlock(state.errorMessage ?? l10n.missingErrorMessage));
          } else if (state.status == UserSettingsStatus.revert) {
            showSnackbar(l10n.successfullyBlocked);
          } else if (state.status == UserSettingsStatus.successBlock) {
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
        },
        builder: (context, state) {
          List<Widget> blockedUsers = getPersonBlocks(context, state, state.personBlocks);
          List<Widget> blockedCommunities = getCommunityBlocks(context, state, state.communityBlocks);
          List<Widget> blockedInstances = getInstanceBlocks(context, state, state.instanceBlocks);

          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  centerTitle: false,
                  toolbarHeight: 70.0,
                  scrolledUnderElevation: 0.0,
                  title: Text(l10n.blockManagement),
                  bottom: TabBar(
                    controller: tabController,
                    tabs: [
                      Tab(text: l10n.users),
                      Tab(text: l10n.communities),
                      Tab(text: l10n.instances),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: [
                UserSettingBlockList(
                  status: state.status,
                  emptyText: l10n.noUserBlocks,
                  items: blockedUsers,
                ),
                UserSettingBlockList(
                  status: state.status,
                  emptyText: l10n.noCommunityBlocks,
                  items: blockedCommunities,
                ),
                UserSettingBlockList(
                  status: state.status,
                  emptyText: l10n.noInstanceBlocks,
                  items: blockedInstances,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// This class creates a widget which displays a list of items. If no items are available, it displays a message.
class UserSettingBlockList extends StatelessWidget {
  /// The status of the bloc
  final UserSettingsStatus status;

  /// The text to display if no items are available
  final String? emptyText;

  /// The widgets to display in the list
  final List<Widget> items;

  const UserSettingBlockList({
    super.key,
    required this.status,
    this.emptyText,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status == UserSettingsStatus.initial) {
      return Container(
        margin: const EdgeInsets.all(10.0),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Center(child: Text(emptyText ?? "", style: TextStyle(color: theme.hintColor)));
    }

    return CustomScrollView(slivers: [SliverList(delegate: SliverChildListDelegate(items))]);
  }
}
