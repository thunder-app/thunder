// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

// Project imports
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/input_dialogs.dart';

/// Creates a widget which displays a preview of a pre-selected language, with the ability to change the selected language
///
/// Passing in [languageId] will set the initial state of the widget to display that given language.
/// A callback function [onLanguageSelected] will be triggered whenever a new language is selected from the dropdown.
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    super.key,
    required this.languageId,
    required this.onLanguageSelected,
  });

  /// The initial language id to be passed in
  final int? languageId;

  /// A callback function to trigger whenever a language is selected from the dropdown
  final Function(Language?) onLanguageSelected;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late int? _languageId;
  late Language? _language;

  @override
  void initState() {
    super.initState();
    _languageId = widget.languageId;

    // Determine the language from the languageId
    List<Language> languages = context.read<AuthBloc>().state.getSiteResponse?.allLanguages ?? [];
    _language = languages.firstWhereOrNull((Language language) => language.id == _languageId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        onTap: () {
          showLanguageInputDialog(
            context,
            title: l10n.language,
            onLanguageSelected: (language) {
              if (language.id == -1) {
                setState(() => _languageId = _language = null);
                widget.onLanguageSelected(null);
              } else {
                setState(() {
                  _languageId = language.id;
                  _language = language;
                });
                widget.onLanguageSelected(language);
              }
            },
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: _language != null ? '${l10n.language}: ${_language?.name}' : l10n.selectLanguage),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(Icons.expand_more_rounded),
                  ),
                ),
              ],
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
