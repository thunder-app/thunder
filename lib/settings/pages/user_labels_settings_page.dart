import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_highlight/smooth_highlight.dart';
import 'package:thunder/account/models/user_label.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/post/utils/user_label_utils.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/input_dialogs.dart';

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

      // Load the user labels
      userLabels = await UserLabel.fetchAllUserLabels();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // First, show the user dialog so we can pick who to label
          showUserInputDialog(
            context,
            title: l10n.username,
            onUserSelected: (personView) async {
              // Then show the label editor
              ({UserLabel? userLabel, bool deleted}) result = await showUserLabelEditorDialog(context, UserLabel.usernameFromParts(personView.person.name, personView.person.actorId));
              _updateChangedUserLabel(result);
            },
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.userLabels),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                l10n.userLabelsSettingsPageDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SmoothHighlight(
              key: settingToHighlight == LocalSettings.userLabels ? settingToHighlightKey : null,
              useInitialHighLight: settingToHighlight == LocalSettings.userLabels,
              enabled: settingToHighlight == LocalSettings.userLabels,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.userLabels, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: userLabels.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        l10n.noUserLabels,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
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
                            context,
                            UserLabel.partsFromUsername(userLabels[index].username).username,
                            null,
                            UserLabel.partsFromUsername(userLabels[index].username).instance,
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
                                UserLabel.deleteUserLabel(userLabels[index].username);
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
