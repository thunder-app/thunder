import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/utils/navigate_community.dart';
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        centerTitle: false,
        title: AutoSizeText(AppLocalizations.of(context)!.accountSettings),
        scrolledUnderElevation: 0.0,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserSettingsBloc(),
          ),
        ],
        child: BlocConsumer<UserSettingsBloc, UserSettingsState>(
          listener: (context, state) {
            if ((state.status == UserSettingsStatus.failure || state.status == UserSettingsStatus.failedRevert) && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0)) {
              showSnackbar(
                  context,
                  state.status == UserSettingsStatus.failure
                      ? AppLocalizations.of(context)!.failedToUnblock(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage)
                      : AppLocalizations.of(context)!.failedToBlock(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage));
            } else if (state.status == UserSettingsStatus.failure) {
              showSnackbar(context, AppLocalizations.of(context)!.failedToLoadBlocks(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage));
            }

            if (state.status == UserSettingsStatus.success && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0)) {
              showSnackbar(
                context,
                AppLocalizations.of(context)!.successfullyUnblocked,
                trailingIcon: Icons.undo_rounded,
                trailingAction: () {
                  if (state.personBeingBlocked != 0) {
                    context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: state.personBeingBlocked, unblock: false));
                  } else if (state.communityBeingBlocked != 0) {
                    context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: state.communityBeingBlocked, unblock: false));
                  }
                },
              );
            }

            if (state.status == UserSettingsStatus.revert && (state.personBeingBlocked != 0 || state.communityBeingBlocked != 0)) {
              showSnackbar(context, AppLocalizations.of(context)!.successfullyBlocked);
            }
          },
          builder: (context, state) {
            if (state.status == UserSettingsStatus.initial) {
              context.read<UserSettingsBloc>().add(GetUserBlocksEvent(userId: widget.userId));
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.blockedUsers,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.add_rounded,
                          semanticLabel: AppLocalizations.of(context)!.add,
                        ),
                        onPressed: () => showUserInputDialog(
                          context,
                          title: AppLocalizations.of(context)!.blockUser,
                          onUserSelected: (personViewSafe) {
                            context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: personViewSafe.person.id, unblock: false));
                          },
                        ),
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    crossFadeState: state.status == UserSettingsStatus.initial ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                    firstChild: Container(
                      margin: const EdgeInsets.all(10.0),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    secondChild: Align(
                      alignment: Alignment.centerLeft,
                      child: state.personBlocks.isNotEmpty == true
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.personBlocks.length,
                              itemBuilder: (context, index) {
                                return index == state.personBlocks.length
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                        child: Tooltip(
                                          message: '${state.personBlocks[index].name}@${fetchInstanceNameFromUrl(state.personBlocks[index].actorId) ?? '-'}',
                                          preferBelow: false,
                                          child: Material(
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(50),
                                              onTap: () {
                                                navigateToUserPage(context, username: '${state.personBlocks[index].name}@${fetchInstanceNameFromUrl(state.personBlocks[index].actorId)}');
                                              },
                                              child: ListTile(
                                                leading: UserAvatar(person: state.personBlocks[index]),
                                                visualDensity: const VisualDensity(vertical: -2),
                                                title: Text(
                                                  state.personBlocks[index].displayName ?? state.personBlocks[index].name,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  '${state.personBlocks[index].name}@${fetchInstanceNameFromUrl(state.personBlocks[index].actorId) ?? '-'}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                                                trailing: state.status == UserSettingsStatus.blocking && state.personBeingBlocked == state.personBlocks[index].id
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
                                                          semanticLabel: AppLocalizations.of(context)!.remove,
                                                        ),
                                                        onPressed: () {
                                                          context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: state.personBlocks[index].id));
                                                        },
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 70, right: 20),
                              child: Text(
                                AppLocalizations.of(context)!.noUserBlocks,
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.people_rounded),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.blockedCommunities,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.add_rounded,
                          semanticLabel: AppLocalizations.of(context)!.add,
                        ),
                        onPressed: () => showCommunityInputDialog(
                          context,
                          title: AppLocalizations.of(context)!.blockCommunity,
                          onCommunitySelected: (communityView) {
                            context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: communityView.community.id, unblock: false));
                          },
                        ),
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    crossFadeState: state.status == UserSettingsStatus.initial ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                    firstChild: Container(
                      margin: const EdgeInsets.all(10.0),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    secondChild: Align(
                      alignment: Alignment.centerLeft,
                      child: state.communityBlocks.isNotEmpty == true
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 50),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.communityBlocks.length,
                              itemBuilder: (context, index) {
                                return index == state.communityBlocks.length
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                        child: Tooltip(
                                          message: '${state.communityBlocks[index].name}@${fetchInstanceNameFromUrl(state.communityBlocks[index].actorId) ?? '-'}',
                                          preferBelow: false,
                                          child: Material(
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(50),
                                              onTap: () {
                                                navigateToCommunityPage(context,
                                                    communityName: '${state.communityBlocks[index].name}@${fetchInstanceNameFromUrl(state.communityBlocks[index].actorId)}');
                                              },
                                              child: ListTile(
                                                leading: CommunityIcon(community: state.communityBlocks[index], radius: 16.0),
                                                visualDensity: const VisualDensity(vertical: -2),
                                                title: Text(
                                                  state.communityBlocks[index].title,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  '${state.communityBlocks[index].name}@${fetchInstanceNameFromUrl(state.communityBlocks[index].actorId) ?? '-'}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                                                trailing: state.status == UserSettingsStatus.blocking && state.communityBeingBlocked == state.communityBlocks[index].id
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
                                                          semanticLabel: AppLocalizations.of(context)!.remove,
                                                        ),
                                                        onPressed: () {
                                                          context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: state.communityBlocks[index].id));
                                                        },
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 70, right: 20),
                              child: Text(
                                AppLocalizations.of(context)!.noCommunityBlocks,
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
