import 'dart:async';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/core/domain/domain.dart';

import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

class UserLabelSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const UserLabelSettingsPage({super.key, this.settingToHighlight});

  @override
  State<UserLabelSettingsPage> createState() => _UserLabelSettingsPageState();
}

class _UserLabelSettingsPageState extends State<UserLabelSettingsPage> with SingleTickerProviderStateMixin {
  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  List<UserLabel> userLabels = [];

  void _updateChangedUserLabel(({UserLabel? userLabel, bool deleted}) result) {
    if (result.userLabel == null) return;

    UserLabel? existingLabel = userLabels.firstWhereOrNull((userLabel) => userLabel.username == result.userLabel!.username);
    if (existingLabel == null && !result.deleted) {
      // It doesn't exist in our list yet, add it!
      setState(() => userLabels.add(result.userLabel!));
    } else if (existingLabel != null) {
      if (result.deleted) {
        // It exists in our list and was deleted, so remove it.
        setState(() => userLabels.removeWhere((userLabel) => userLabel.username == result.userLabel!.username));
      } else {
        // It exists in our list but was changed, so update it.
        setState(() => userLabels[userLabels.indexOf(existingLabel)] = result.userLabel!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.settingToHighlight != null) {
        setState(() => settingToHighlight = widget.settingToHighlight);

        // Need some delay to finish building, even though we're in a post-frame callback.
        Timer(const Duration(milliseconds: 500), () {
          if (settingToHighlightKey.currentContext != null) {
            // Ensure that the selected setting is visible on the screen
            Scrollable.ensureVisible(settingToHighlightKey.currentContext!, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
          }

          // Give time for the highlighting to appear, then turn it off
          Timer(const Duration(seconds: 1), () {
            setState(() => settingToHighlight = null);
          });
        });
      }

      // Load the user labels
      userLabels = await createUserLabelRepository().fetchAllUserLabels();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // First, show the user dialog so we can pick who to label
          showUserInputDialog(
            context,
            title: l10n.username,
            account: context.read<ProfileBloc>().state.account,
            onUserSelected: (user) async {
              // Then show the label editor
              ({UserLabel? userLabel, bool deleted}) result = await showUserLabelEditorDialog(context, UserLabel.usernameFromParts(user.name, user.actorId));
              _updateChangedUserLabel(result);
            },
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.userLabels), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text(l10n.userLabelsSettingsPageDescription, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8))),
              ),
              SmoothHighlight(
                key: settingToHighlight == LocalSettings.userLabels ? settingToHighlightKey : null,
                useInitialHighLight: settingToHighlight == LocalSettings.userLabels,
                enabled: settingToHighlight == LocalSettings.userLabels,
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(l10n.userLabels, style: theme.textTheme.titleMedium)],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: userLabels.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Text(l10n.noUserLabels, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8))),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: userLabels.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                            title: UserFullNameWidget(
                              name: UserLabel.partsFromUsername(userLabels[index].username).username,
                              displayName: null,
                              instance: UserLabel.partsFromUsername(userLabels[index].username).instance,
                              textStyle: theme.textTheme.bodyLarge,
                            ),
                            subtitle: Text(userLabels[index].label),
                            trailing: IconButton(
                              icon: Icon(Icons.clear, semanticLabel: l10n.remove),
                              onPressed: () async {
                                bool result = false;

                                await showThunderDialog<void>(
                                  context: context,
                                  title: l10n.confirm,
                                  contentText: l10n.deleteUserLabelConfirmation,
                                  onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                                  secondaryButtonText: l10n.cancel,
                                  onPrimaryButtonPressed: (dialogContext, _) async {
                                    Navigator.of(dialogContext).pop();
                                    result = true;
                                  },
                                  primaryButtonText: l10n.delete,
                                );

                                if (result) {
                                  createUserLabelRepository().deleteUserLabel(userLabels[index].username);
                                  _updateChangedUserLabel((userLabel: userLabels[index], deleted: true));
                                }
                              },
                            ),
                            onTap: () async {
                              ({bool deleted, UserLabel? userLabel}) result = await showUserLabelEditorDialog(context, userLabels[index].username);
                              _updateChangedUserLabel(result);
                            },
                          );
                        },
                      ),
              ),
              SizedBox(height: 128.0),
            ],
          ),
        ],
      ),
    );
  }
}
