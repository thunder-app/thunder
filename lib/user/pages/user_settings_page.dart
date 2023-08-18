import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: const AutoSizeText('Account Settings'),
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
              if (state.status == UserSettingsStatus.failure) {
                showSnackbar(
                    context,
                    state.status == UserSettingsStatus.failure
                        ? AppLocalizations.of(context)!.failedToUnblock(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage)
                        : AppLocalizations.of(context)!.failedToBlock(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage));
              }
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
                children: [
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Blocked Users'),
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
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.personBlocks.length,
                              itemBuilder: (context, index) {
                                return index == state.personBlocks.length
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 42),
                                        child: ListTile(
                                          visualDensity: const VisualDensity(vertical: -2),
                                          title: Tooltip(
                                            message: '${state.personBlocks[index].name}@${fetchInstanceNameFromUrl(state.personBlocks[index].actorId) ?? '-'}',
                                            preferBelow: false,
                                            child: Text(
                                              '${state.personBlocks[index].name}@${fetchInstanceNameFromUrl(state.personBlocks[index].actorId) ?? '-'}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
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
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    context.read<UserSettingsBloc>().add(UnblockPersonEvent(personId: state.personBlocks[index].id));
                                                  },
                                                ),
                                        ),
                                      );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 57, right: 20),
                              child: Text(
                                'It looks like you have not blocked anybody.',
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const ListTile(
                    leading: Icon(Icons.people_rounded),
                    title: Text('Blocked Communities'),
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
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.communityBlocks.length,
                              itemBuilder: (context, index) {
                                return index == state.communityBlocks.length
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 42),
                                        child: ListTile(
                                          visualDensity: const VisualDensity(vertical: -2),
                                          title: Tooltip(
                                            message: '${state.communityBlocks[index].name}@${fetchInstanceNameFromUrl(state.communityBlocks[index].actorId) ?? '-'}',
                                            preferBelow: false,
                                            child: Text(
                                              '${state.communityBlocks[index].name}@${fetchInstanceNameFromUrl(state.communityBlocks[index].actorId) ?? '-'}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
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
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    context.read<UserSettingsBloc>().add(UnblockCommunityEvent(communityId: state.communityBlocks[index].id));
                                                  },
                                                ),
                                        ),
                                      );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 57, right: 20),
                              child: Text(
                                'It looks like you have not blocked any communities.',
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
