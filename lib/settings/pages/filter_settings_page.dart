import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_highlight/smooth_highlight.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';

class FilterSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const FilterSettingsPage({super.key, this.settingToHighlight});

  @override
  State<FilterSettingsPage> createState() => _FilterSettingsPageState();
}

class _FilterSettingsPageState extends State<FilterSettingsPage> with SingleTickerProviderStateMixin {
  /// The list of keyword filters to apply for posts
  List<String> keywordFilters = [];

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case LocalSettings.keywordFilters:
        await prefs.setStringList(LocalSettings.keywordFilters.name, value);
        setState(() => keywordFilters = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      keywordFilters = prefs.getStringList(LocalSettings.keywordFilters.name) ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPreferences();

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
    AuthState authState = context.read<AuthBloc>().state;
    AccountState accountState = context.read<AccountBloc>().state;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.filters),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                l10n.keywordFilterDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SmoothHighlight(
              key: settingToHighlight == LocalSettings.keywordFilters ? settingToHighlightKey : null,
              useInitialHighLight: settingToHighlight == LocalSettings.keywordFilters,
              enabled: settingToHighlight == LocalSettings.keywordFilters,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.keywordFilters, style: theme.textTheme.titleMedium),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.add_rounded,
                        semanticLabel: l10n.add,
                      ),
                      onPressed: () => showKeywordInputDialog(
                        context,
                        title: l10n.addKeywordFilter,
                        onKeywordSelected: (keyword) {
                          setPreferences(LocalSettings.keywordFilters, [...keywordFilters, keyword]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: keywordFilters.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Text(
                        l10n.noKeywordFilters,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: keywordFilters.length,
                      itemBuilder: (context, index) {
                        return SettingsListTile(
                          description: keywordFilters[index],
                          widget: const SizedBox(height: 42.0, child: Icon(Icons.chevron_right_rounded)),
                          onTap: () async {
                            showThunderDialog(
                              context: context,
                              title: l10n.removeKeywordFilter,
                              contentText: l10n.removeKeyword(keywordFilters[index]),
                              primaryButtonText: l10n.remove,
                              onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) {
                                setPreferences(LocalSettings.keywordFilters, keywordFilters.where((element) => element != keywordFilters[index]).toList());
                                Navigator.of(dialogContext).pop();
                              },
                              secondaryButtonText: l10n.cancel,
                              onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                            );
                          },
                          highlightKey: settingToHighlightKey,
                          setting: null,
                          highlightedSetting: settingToHighlight,
                        );
                      },
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: SettingsListTile(
              icon: Icons.language,
              description: l10n.languageFilters,
              widget: const SizedBox(
                height: 42.0,
                child: Icon(Icons.chevron_right_rounded),
              ),
              onTap: () {
                // Can only set discussion language if user is logged in
                if (authState.isLoggedIn && accountState.status == AccountStatus.success && accountState.personView != null) {
                  GoRouter.of(context).push(SETTINGS_ACCOUNT_PAGE, extra: [
                    context.read<ThunderBloc>(),
                    LocalSettings.discussionLanguages,
                  ]);
                } else {
                  showThunderDialog(
                    context: context,
                    title: l10n.userNotLoggedIn,
                    contentText: l10n.mustBeLoggedIn,
                    primaryButtonText: l10n.ok,
                    onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) => Navigator.of(dialogContext).pop(),
                  );
                }
              },
              highlightKey: settingToHighlightKey,
              setting: null,
              highlightedSetting: settingToHighlight,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
