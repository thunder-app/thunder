import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/models/thunder_language.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/shared/dialogs.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/constants.dart';

class DiscussionLanguageSelector extends StatefulWidget {
  const DiscussionLanguageSelector({super.key});

  @override
  State<DiscussionLanguageSelector> createState() => _DiscussionLanguageSelector();
}

class _DiscussionLanguageSelector extends State<DiscussionLanguageSelector> {
  List<ThunderLanguage> _languages = [];

  @override
  void initState() {
    super.initState();

    final state = context.read<UserSettingsBloc>().state;
    setState(() => _languages = state.siteResponse?.allLanguages ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        final selectedLanguages = state.siteResponse?.myUser?.discussionLanguages ?? [];
        final discussionLanguages = selectedLanguages.map((id) => _languages.firstWhere((language) => language.id == id)).toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => showLanguageInputDialog(
              context,
              title: l10n.addDiscussionLanguage,
              excludedLanguageIds: [-1],
              onLanguageSelected: (language) {
                List<ThunderLanguage> updatedDiscussionLanguages = List.from(discussionLanguages)..add(language);
                context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: updatedDiscussionLanguages.map((e) => e.id).toList()));
              },
            ),
            child: const Icon(Icons.add_rounded),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                centerTitle: false,
                toolbarHeight: APP_BAR_HEIGHT,
                scrolledUnderElevation: 0.0,
                title: Text(l10n.discussionLanguages),
              ),
              if (discussionLanguages.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 20.0, bottom: 20.0),
                    child: Text(
                      l10n.noDiscussionLanguages,
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                ),
              SliverList.builder(
                itemCount: discussionLanguages.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: 20.0, end: 12.0),
                  title: Text(discussionLanguages[index].name, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: Icon(Icons.clear, semanticLabel: l10n.remove),
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
                            final updatedDiscussionLanguages = discussionLanguages.where((element) => element != discussionLanguages[index]).toList();
                            context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: updatedDiscussionLanguages.map((e) => e.id).toList()));
                            Navigator.of(dialogContext).pop();
                          },
                          secondaryButtonText: l10n.cancel,
                          onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                        );
                      } else {
                        final updatedDiscussionLanguages = discussionLanguages.where((element) => element != discussionLanguages[index]).toList();
                        context.read<UserSettingsBloc>().add(UpdateUserSettingsEvent(discussionLanguages: updatedDiscussionLanguages.map((e) => e.id).toList()));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
