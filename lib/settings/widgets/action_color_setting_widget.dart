import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/enums/action_color.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

class ActionColorSettingWidget extends StatelessWidget {
  final LocalSettings? settingToHighlight;
  final GlobalKey settingToHighlightKey;
  final Future<void> Function(LocalSettings attribute, String? value) setPreferences;
  final ActionColor upvoteColor;
  final ActionColor downvoteColor;
  final ActionColor saveColor;
  final ActionColor markReadColor;
  final ActionColor replyColor;

  const ActionColorSettingWidget({
    super.key,
    required this.settingToHighlight,
    required this.settingToHighlightKey,
    required this.setPreferences,
    required this.upvoteColor,
    required this.downvoteColor,
    required this.saveColor,
    required this.markReadColor,
    required this.replyColor,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    ActionColor upvoteColor = this.upvoteColor;
    ActionColor downvoteColor = this.downvoteColor;
    ActionColor saveColor = this.saveColor;
    ActionColor markReadColor = this.markReadColor;
    ActionColor replyColor = this.replyColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(l10n.colors, style: theme.textTheme.titleLarge),
          ),
          ListOption(
            isBottomModalScrollControlled: true,
            value: const ListPickerItem(payload: -1),
            description: l10n.actionColors,
            icon: Icons.color_lens_rounded,
            highlightKey: settingToHighlightKey,
            setting: LocalSettings.actionColors,
            highlightedSetting: settingToHighlight,
            customListPicker: StatefulBuilder(
              builder: (context, setState) {
                return BottomSheetListPicker(
                  title: l10n.actionColors,
                  items: [
                    ListPickerItem(
                      payload: -1,
                      customWidget: ListTile(
                        title: Text(
                          l10n.upvoteColor,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: DropdownButton<ActionColor>(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            isExpanded: true,
                            underline: Container(),
                            value: upvoteColor,
                            items: ActionColor.getPossibleValues(upvoteColor)
                                .map(
                                  (actionColor) => DropdownMenuItem<ActionColor>(
                                    alignment: Alignment.center,
                                    value: actionColor,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10.0,
                                          backgroundColor: actionColor.color,
                                        ),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          actionColor.label(context),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              await setPreferences(LocalSettings.upvoteColor, value?.colorRaw);
                              setState(() => upvoteColor = value ?? upvoteColor);
                            },
                          ),
                        ),
                      ),
                    ),
                    ListPickerItem(
                      payload: -1,
                      customWidget: ListTile(
                        title: Text(
                          l10n.downvoteColor,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: DropdownButton<ActionColor>(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            isExpanded: true,
                            underline: Container(),
                            value: downvoteColor,
                            items: ActionColor.getPossibleValues(downvoteColor)
                                .map(
                                  (actionColor) => DropdownMenuItem<ActionColor>(
                                    alignment: Alignment.center,
                                    value: actionColor,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10.0,
                                          backgroundColor: actionColor.color,
                                        ),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          actionColor.label(context),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              await setPreferences(LocalSettings.downvoteColor, value?.colorRaw);
                              setState(() => downvoteColor = value ?? downvoteColor);
                            },
                          ),
                        ),
                      ),
                    ),
                    ListPickerItem(
                      payload: -1,
                      customWidget: ListTile(
                        title: Text(
                          l10n.saveColor,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: DropdownButton<ActionColor>(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            isExpanded: true,
                            underline: Container(),
                            value: saveColor,
                            items: ActionColor.getPossibleValues(saveColor)
                                .map(
                                  (actionColor) => DropdownMenuItem<ActionColor>(
                                    alignment: Alignment.center,
                                    value: actionColor,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10.0,
                                          backgroundColor: actionColor.color,
                                        ),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          actionColor.label(context),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              await setPreferences(LocalSettings.saveColor, value?.colorRaw);
                              setState(() => saveColor = value ?? saveColor);
                            },
                          ),
                        ),
                      ),
                    ),
                    ListPickerItem(
                      payload: -1,
                      customWidget: ListTile(
                        title: Text(
                          l10n.markReadColor,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: DropdownButton<ActionColor>(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            isExpanded: true,
                            underline: Container(),
                            value: markReadColor,
                            items: ActionColor.getPossibleValues(markReadColor)
                                .map(
                                  (actionColor) => DropdownMenuItem<ActionColor>(
                                    alignment: Alignment.center,
                                    value: actionColor,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10.0,
                                          backgroundColor: actionColor.color,
                                        ),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          actionColor.label(context),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              await setPreferences(LocalSettings.markReadColor, value?.colorRaw);
                              setState(() => markReadColor = value ?? markReadColor);
                            },
                          ),
                        ),
                      ),
                    ),
                    ListPickerItem(
                      payload: -1,
                      customWidget: ListTile(
                        title: Text(
                          l10n.replyColor,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: DropdownButton<ActionColor>(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            isExpanded: true,
                            underline: Container(),
                            value: replyColor,
                            items: ActionColor.getPossibleValues(replyColor)
                                .map(
                                  (actionColor) => DropdownMenuItem<ActionColor>(
                                    alignment: Alignment.center,
                                    value: actionColor,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10.0,
                                          backgroundColor: actionColor.color,
                                        ),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          actionColor.label(context),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) async {
                              await setPreferences(LocalSettings.replyColor, value?.colorRaw);
                              setState(() => replyColor = value ?? replyColor);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
