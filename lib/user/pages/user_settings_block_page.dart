import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/full_name.dart';
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

class UserSettingsBlockPage extends StatefulWidget {
  const UserSettingsBlockPage({super.key});

  @override
  State<UserSettingsBlockPage> createState() => _UserSettingsBlockPageState();
}

class _UserSettingsBlockPageState extends State<UserSettingsBlockPage> with SingleTickerProviderStateMixin {
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
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Tooltip(
          message: generateUserFullName(context, person.name, fetchInstanceNameFromUrl(person.actorId) ?? "-"),
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToFeedPage(context, feedType: FeedType.user, username: "${person.name}@${fetchInstanceNameFromUrl(person.actorId)}");
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
                  fetchInstanceNameFromUrl(person.actorId) ?? "-",
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

  List<Widget> getCommunityBlocks(BuildContext context, UserSettingsState state, List<Community> communities) {
    final l10n = AppLocalizations.of(context)!;

    return communities.map((community) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Tooltip(
          message: generateCommunityFullName(context, community.name, fetchInstanceNameFromUrl(community.actorId) ?? "-"),
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                navigateToFeedPage(context, feedType: FeedType.community, communityName: "${community.name}@${fetchInstanceNameFromUrl(community.actorId)}");
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
                  fetchInstanceNameFromUrl(community.actorId) ?? "-",
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
                    semanticsLabel: "",
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
          if (state.status == UserSettingsStatus.failure || state.status == UserSettingsStatus.failedRevert) {
            showSnackbar(state.errorMessage ?? l10n.unexpectedError);
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
                  title: const Text("Block Management"),
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
  final UserSettingsStatus status;
  final String? emptyText;
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

    return AnimatedCrossFade(
      crossFadeState: status == UserSettingsStatus.initial ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 200),
      firstChild: Container(
        margin: const EdgeInsets.all(10.0),
        child: const Center(child: CircularProgressIndicator()),
      ),
      secondChild: items.isNotEmpty == true
          ? ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return index == items.length ? Container() : items[index];
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  emptyText ?? "",
                  style: TextStyle(color: theme.hintColor),
                ),
              ),
            ),
    );
  }
}


// return PopScope(
//   child: Scaffold(
//     body: BlocProvider(
//       create: (context) => UserSettingsBloc()..add(const GetUserSettingsEvent()),
//       child: BlocListener<AccountBloc, AccountState>(
//         listener: (context, state) {
//           context.read<UserSettingsBloc>().add(const ResetUserSettingsEvent());
//           context.read<UserSettingsBloc>().add(const GetUserSettingsEvent());
//         },
//         child: BlocConsumer<UserSettingsBloc, UserSettingsState>(
//           listener: (context, state) {
//             if (state.status == UserSettingsStatus.success) {
//               context.read<AuthBloc>().add(LemmyAccountSettingUpdated());
//             }

//             if ((state.status == UserSettingsStatus.failure || state.status == UserSettingsStatus.failedRevert) &&
//                 (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
//               showSnackbar(state.status == UserSettingsStatus.failure
//                   ? l10n.failedToUnblock(state.errorMessage ?? l10n.missingErrorMessage)
//                   : l10n.failedToBlock(state.errorMessage ?? l10n.missingErrorMessage));
//             } else if (state.status == UserSettingsStatus.failure) {
//               showSnackbar(l10n.failedToLoadBlocks(state.errorMessage ?? l10n.missingErrorMessage));
//             }

//             if (state.status == UserSettingsStatus.successBlock && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
//               showSnackbar(
//                 l10n.successfullyUnblocked,
//                 trailingIcon: Icons.undo_rounded,
//                 trailingAction: () {
//                   if (state.personBeingBlocked != 0) {
//                     context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: state.personBeingBlocked, unblock: false));
//                   } else if (state.communityBeingBlocked != 0) {
//                     context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: state.communityBeingBlocked, unblock: false));
//                   } else if (state.instanceBeingBlocked != 0) {
//                     context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: state.instanceBeingBlocked, unblock: false));
//                   }
//                 },
//               );
//             }

//             if (state.status == UserSettingsStatus.revert && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0 || state.instanceBeingBlocked != 0)) {
//               showSnackbar(l10n.successfullyBlocked);
//             }
//           },
//           builder: (context, state) {
//             if (state.status == UserSettingsStatus.initial) {
//               context.read<UserSettingsBloc>().add(const GetUserBlocksEvent());
//             }
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//
//                   if (state.status != UserSettingsStatus.notLoggedIn && state.getSiteResponse != null && myUserInfo != null)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         DiscussionLanguageSelector(
//                           initialDiscussionLanguages: DiscussionLanguageSelector.getDiscussionLanguagesFromSiteResponse(state.getSiteResponse),
//                           settingToHighlight: widget.settingToHighlight,
//                         ),
//                         if (LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) ...[
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(l10n.blockedInstances, style: theme.textTheme.titleMedium),
//                                 IconButton(
//                                   visualDensity: VisualDensity.compact,
//                                   icon: Icon(
//                                     Icons.add_rounded,
//                                     semanticLabel: l10n.add,
//                                   ),
//                                   onPressed: () => showInstanceInputDialog(
//                                     context,
//                                     title: l10n.blockInstance,
//                                     onInstanceSelected: (instance) {
//                                       context.read<UserSettingsBloc>().add(UnblockInstanceEvent(instanceId: instance.id, unblock: false));
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           UserSettingBlockList(
//                             status: state.status,
//                             emptyText: l10n.noInstanceBlocks,
//                             items: getInstanceBlocks(context, state, state.instanceBlocks),
//                           ),
//                         ],
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(l10n.blockedUsers, style: theme.textTheme.titleMedium),
//                               IconButton(
//                                 visualDensity: VisualDensity.compact,
//                                 icon: Icon(
//                                   Icons.add_rounded,
//                                   semanticLabel: l10n.add,
//                                 ),
//                                 onPressed: () => showUserInputDialog(
//                                   context,
//                                   title: l10n.blockUser,
//                                   onUserSelected: (personViewSafe) {
//                                     context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: personViewSafe.person.id, unblock: false));
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         UserSettingBlockList(
//                           status: state.status,
//                           emptyText: l10n.noUserBlocks,
//                           items: getPersonBlocks(context, state, state.personBlocks),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(l10n.blockedCommunities, style: theme.textTheme.titleMedium),
//                               IconButton(
//                                 visualDensity: VisualDensity.compact,
//                                 icon: Icon(
//                                   Icons.add_rounded,
//                                   semanticLabel: l10n.add,
//                                 ),
//                                 onPressed: () => showCommunityInputDialog(
//                                   context,
//                                   title: l10n.blockCommunity,
//                                   onCommunitySelected: (communityView) {
//                                     context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: communityView.community.id, unblock: false));
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         UserSettingBlockList(
//                           status: state.status,
//                           emptyText: l10n.noCommunityBlocks,
//                           items: getCommunityBlocks(context, state, state.communityBlocks),
//                         ),
//                         const SizedBox(height: 100.0),
//                       ],
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     ),
//   ),
// );
