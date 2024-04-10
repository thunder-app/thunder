import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';

class DiscussionLanguageSelector extends StatefulWidget {
  final List<Language>? initialDiscussionLanguages;

  const DiscussionLanguageSelector({super.key, this.initialDiscussionLanguages});

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

  Future<void> _setDiscussionLanguages(List<Language> discussionLanguages) async {
    setState(() => this.discussionLanguages = discussionLanguages);
  }

  @override
  void initState() {
    super.initState();

    discussionLanguages = widget.initialDiscussionLanguages ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8.0),
                    Text(l10n.discussionLanguages),
                  ],
                ),
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
        Align(
          alignment: Alignment.centerLeft,
          child: discussionLanguages.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                  child: Text(
                    l10n.noDiscussionLanguages,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: discussionLanguages.length,
                  itemBuilder: (context, index) {
                    return SettingsListTile(
                      description: discussionLanguages[index].name,
                      widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                      onTap: () async {
                        showThunderDialog(
                          context: context,
                          title: l10n.removeDiscussionLanguage,
                          contentText: discussionLanguages[index].id == 0 ? l10n.deselectUndeterminedWarning : l10n.removeLanguage(discussionLanguages[index].name),
                          primaryButtonText: l10n.remove,
                          onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
                            _setDiscussionLanguages(discussionLanguages = discussionLanguages.where((element) => element != discussionLanguages[index]).toList());
                            context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: discussionLanguages.map((e) => e.id).toList()));
                            Navigator.of(dialogContext).pop();
                          },
                          secondaryButtonText: l10n.cancel,
                          onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
