// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';

// Project imports
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/shared/input_dialogs.dart';

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
  final Function(ThunderLanguage?) onLanguageSelected;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late int? _languageId;
  late ThunderLanguage? _language;

  @override
  void initState() {
    super.initState();
    _languageId = widget.languageId;

    // Determine the language from the languageId
    final languages = context.read<ProfileBloc>().state.siteResponse?.allLanguages ?? <ThunderLanguage>[];
    _language = languages.firstWhereOrNull((ThunderLanguage language) => language.id == _languageId);
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
          padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
          child: Text.rich(
            softWrap: true,
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: _language != null ? '${l10n.language}: ${_language?.name}' : l10n.selectLanguage),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.chevron_right_rounded),
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
