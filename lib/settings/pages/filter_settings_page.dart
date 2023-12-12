import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class FilterSettingsPage extends StatefulWidget {
  const FilterSettingsPage({super.key});

  @override
  State<FilterSettingsPage> createState() => _FilterSettingsPageState();
}

class _FilterSettingsPageState extends State<FilterSettingsPage> with SingleTickerProviderStateMixin {
  TextEditingController keywordFilterController = TextEditingController();
  List<String> keywordFilters = [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: keywordFilters.length,
                  itemBuilder: (context, index) {
                    return SettingsListTile(
                      description: keywordFilters[index],
                      widget: const SizedBox(
                        height: 42.0,
                        child: Icon(Icons.chevron_right_rounded),
                      ),
                      onTap: () async {
                        setPreferences(LocalSettings.keywordFilters, keywordFilters.where((element) => element != keywordFilters[index]).toList());
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
