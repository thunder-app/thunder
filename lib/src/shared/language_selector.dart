import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/shared/input_dialogs.dart';

/// Creates a widget which displays a preview of a pre-selected language, with the ability to change the selected language.
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    super.key,
    required this.account,
    this.languages,
    this.languageId,
    required this.onLanguageSelected,
  });

  /// Account used to determine available languages.
  final Account account;

  /// List of preloaded languages. If available, will use this instead of fetching languages from the account.
  final Iterable<ThunderLanguage>? languages;

  /// The initial language id to be passed in.
  final int? languageId;

  /// A callback function to trigger whenever a language is selected from the dropdown.
  final Function(ThunderLanguage?) onLanguageSelected;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  List<ThunderLanguage> _languages = const <ThunderLanguage>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LanguageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id || oldWidget.account.instance != widget.account.instance || oldWidget.languages != widget.languages) {
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.languages != null) {
      if (!mounted) return;
      setState(() => _languages = widget.languages!.toList());
      return;
    }

    final site = await ProfileSiteInfoCache.instance.get(widget.account);
    if (!mounted) return;
    setState(() => _languages = site.allLanguages ?? const <ThunderLanguage>[]);
    return;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    final languages = widget.languages?.toList() ?? _languages;
    final language = languages.firstWhereOrNull((candidate) => candidate.id == widget.languageId);

    return Transform.translate(
      offset: const Offset(-8.0, 0.0),
      child: InkWell(
        onTap: () {
          showLanguageInputDialog(
            context,
            title: l10n.language,
            account: widget.account,
            suggestions: languages,
            onLanguageSelected: (language) {
              if (language.id == -1) {
                widget.onLanguageSelected(null);
              } else {
                widget.onLanguageSelected(language);
              }
            },
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0, bottom: 12.0),
          child: Text.rich(
            softWrap: true,
            TextSpan(
              children: [
                TextSpan(text: language != null ? '${l10n.language}: ${language.name}' : l10n.selectLanguage),
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
