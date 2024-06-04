import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:smooth_highlight/smooth_highlight.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';

class DiscussionLanguageSelector extends StatefulWidget {
  final List<Language>? initialDiscussionLanguages;
  final LocalSettings? settingToHighlight;

  const DiscussionLanguageSelector({super.key, this.initialDiscussionLanguages, this.settingToHighlight});

  static List<Language> getDiscussionLanguagesFromSiteResponse(GetSiteResponse? getSiteResponse) {
    List<Language> languages = getSiteResponse?.allLanguages ?? [];
    List<int> discussionLanguageIds = getSiteResponse?.myUser?.discussionLanguages ?? [];
    return discussionLanguageIds.map((id) => languages.firstWhere((language) => language.id == id)).toList();
  }

  @override
  State<DiscussionLanguageSelector> createState() => _DiscussionLanguageSelector();
}

class _DiscussionLanguageSelector extends State<DiscussionLanguageSelector> {
  late List<Language> discussionLanguages;
  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  Future<void> _setDiscussionLanguages(List<Language> discussionLanguages) async {
    setState(() => this.discussionLanguages = discussionLanguages);
  }

  @override
  void initState() {
    super.initState();

    discussionLanguages = widget.initialDiscussionLanguages ?? [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SmoothHighlight(
          key: settingToHighlight == LocalSettings.discussionLanguages ? settingToHighlightKey : null,
          useInitialHighLight: settingToHighlight == LocalSettings.discussionLanguages,
          enabled: settingToHighlight == LocalSettings.discussionLanguages,
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: l10n.discussionLanguagesTooltip,
                  preferBelow: false,
                  child: Text(l10n.discussionLanguages, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.add_rounded,
                    semanticLabel: l10n.add,
                  ),
                  onPressed: () => showLanguageInputDialog(
                    context,
                    title: l10n.addDiscussionLanguage,
                    excludedLanguageIds: [-1],
                    onLanguageSelected: (language) {
                      _setDiscussionLanguages(discussionLanguages = [
                        ...{...discussionLanguages, language}
                      ]);
                      context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: discussionLanguages.map((e) => e.id).toList()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: discussionLanguages.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 20.0, bottom: 20.0),
                  child: Text(
                    l10n.noDiscussionLanguages,
                    style: TextStyle(color: theme.hintColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 12, right: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: discussionLanguages.length,
                  itemBuilder: (context, index) => ListTile(
                    visualDensity: const VisualDensity(vertical: -2),
                    title: Text(
                      discussionLanguages[index].name,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.clear,
                        semanticLabel: l10n.remove,
                      ),
                      onPressed: () {
                        // Warn user against removing 'Undetermined' language when other discussion languages are selected.
                        // This filters out most content. If no discussion languages are selected, all content is displayed.
                        if (discussionLanguages[index].id == 0 && discussionLanguages.length > 1) {
                          showThunderDialog(
                            context: context,
                            title: l10n.warning,
                            contentText: l10n.deselectUndeterminedWarning,
                            primaryButtonText: l10n.remove,
                            onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
                              _setDiscussionLanguages(discussionLanguages = discussionLanguages.where((element) => element != discussionLanguages[index]).toList());
                              context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: discussionLanguages.map((e) => e.id).toList()));
                              Navigator.of(dialogContext).pop();
                            },
                            secondaryButtonText: l10n.cancel,
                            onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                          );
                        } else {
                          _setDiscussionLanguages(discussionLanguages = discussionLanguages.where((element) => element != discussionLanguages[index]).toList());
                          context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: discussionLanguages.map((e) => e.id).toList()));
                        }
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
