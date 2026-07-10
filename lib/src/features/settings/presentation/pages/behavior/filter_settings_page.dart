import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/domain/domain.dart';

import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

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

  void setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = const UserPreferencesStore();

    switch (attribute) {
      case LocalSettings.keywordFilters:
        await prefs.setSetting(LocalSettings.keywordFilters, value);
        setState(() => keywordFilters = value);
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<ThunderCubit>().reload();
      context.read<FeedPreferencesCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = const UserPreferencesStore();

    setState(() {
      keywordFilters = prefs.getLocalSetting<List<String>>(LocalSettings.keywordFilters) ?? [];
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
    final l10n = GlobalContext.l10n;
    final profileState = context.read<ProfileBloc>().state;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.filters), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text(
                  l10n.keywordFilterDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ),
              SmoothHighlight(
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
              Align(
                alignment: Alignment.centerLeft,
                child: keywordFilters.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Text(
                          l10n.noKeywordFilters,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: keywordFilters.length,
                        itemBuilder: (context, index) {
                          return ThunderSettingsTile(
                              title: keywordFilters[index],
                              trailing: const ThunderSettingsChevronTrailing(),
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
                              highlighted: false);
                        },
                      ),
              ),
              SizedBox(height: 16.0),
              ThunderSettingsTile(
                  leading: Icon(Icons.language),
                  title: l10n.languageFilters,
                  trailing: const ThunderSettingsChevronTrailing(),
                  onTap: () {
                    // Can only set discussion language if user is logged in
                    if (profileState.isLoggedIn && profileState.status == ProfileStatus.success && profileState.user != null) {
                      navigateToSettingPage(context, LocalSettings.settingsPageAccountLanguages);
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
                  highlighted: false),
              SizedBox(height: 128.0),
            ],
          ),
        ],
      ),
    );
  }
}
