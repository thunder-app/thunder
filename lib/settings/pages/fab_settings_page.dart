import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:thunder/core/enums/local_settings.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

class FabSettingsPage extends StatefulWidget {
  const FabSettingsPage({super.key});

  @override
  State<FabSettingsPage> createState() => _FabSettingsPage();
}

class _FabSettingsPage extends State<FabSettingsPage> with TickerProviderStateMixin {
  /// -------------------------- FAB Related Settings --------------------------
  // FAB Settings
  bool enableFeedsFab = false;
  bool enablePostsFab = false;

  bool enableBackToTop = true;
  bool enableSubscriptions = true;
  bool enableChangeSort = true;
  bool enableRefresh = true;
  bool enableDismissRead = true;
  bool enableNewPost = true;

  /// Loading
  bool isLoading = true;

  /// The available gesture options
  List<ListPickerItem> postGestureOptions = [
    ListPickerItem(icon: Icons.north_rounded, label: SwipeAction.upvote.label, payload: SwipeAction.upvote),
    ListPickerItem(icon: Icons.south_rounded, label: SwipeAction.downvote.label, payload: SwipeAction.downvote),
    ListPickerItem(icon: Icons.star_outline_rounded, label: SwipeAction.save.label, payload: SwipeAction.save),
    ListPickerItem(icon: Icons.markunread_outlined, label: SwipeAction.toggleRead.label, payload: SwipeAction.toggleRead),
    ListPickerItem(icon: Icons.not_interested_rounded, label: SwipeAction.none.label, payload: SwipeAction.none),
  ];

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      /// -------------------------- Gesture Related Settings --------------------------
      // Sidebar Gesture Settings
      case LocalSettings.enableFeedsFab:
        await prefs.setBool(LocalSettings.enableFeedsFab.name, value);
        setState(() => enableFeedsFab = value);
        break;
      case LocalSettings.enablePostsFab:
        await prefs.setBool(LocalSettings.enablePostsFab.name, value);
        setState(() => enablePostsFab = value);
        break;
      case LocalSettings.enableBackToTop:
        await prefs.setBool(LocalSettings.enableBackToTop.name, value);
        setState(() => enableBackToTop = value);
        break;
      case LocalSettings.enableSubscriptions:
        await prefs.setBool(LocalSettings.enableSubscriptions.name, value);
        setState(() => enableSubscriptions = value);
        break;
      case LocalSettings.enableChangeSort:
        await prefs.setBool(LocalSettings.enableChangeSort.name, value);
        setState(() => enableChangeSort = value);
        break;
      case LocalSettings.enableRefresh:
        await prefs.setBool(LocalSettings.enableRefresh.name, value);
        setState(() => enableRefresh = value);
        break;
      case LocalSettings.enableDismissRead:
        await prefs.setBool(LocalSettings.enableDismissRead.name, value);
        setState(() => enableDismissRead = value);
        break;
      case LocalSettings.enableNewPost:
        await prefs.setBool(LocalSettings.enableNewPost.name, value);
        setState(() => enableNewPost = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      enableFeedsFab = prefs.getBool(LocalSettings.enableFeedsFab.name) ?? false;
      enablePostsFab = prefs.getBool(LocalSettings.enablePostsFab.name) ?? false;

      enableBackToTop = prefs.getBool(LocalSettings.enableBackToTop.name) ?? false;
      enableSubscriptions = prefs.getBool(LocalSettings.enableSubscriptions.name) ?? false;
      enableChangeSort = prefs.getBool(LocalSettings.enableChangeSort.name) ?? false;
      enableRefresh = prefs.getBool(LocalSettings.enableRefresh.name) ?? false;
      enableDismissRead = prefs.getBool(LocalSettings.enableDismissRead.name) ?? false;
      enableNewPost = prefs.getBool(LocalSettings.enableNewPost.name) ?? false;

      isLoading = false;
    });
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for comment collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Floating Action Button'), centerTitle: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Feeds',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The FAB in Thunder can be used for many things, and supports a couple gestures:',
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                              Text(
                                '- Swipe up to open a menu with additional actions',
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                              Text(
                                '- Swipe down to hide the FAB',
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                              Text(
                                '- Swipe up from lower right corner to bring it back',
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.enableFeedsFab.label,
                          value: enableFeedsFab,
                          onToggle: (bool value) => setPreferences(LocalSettings.enableFeedsFab, value),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: SlideTransition(position: _offsetAnimation, child: child),
                            );
                          },
                          child: enableFeedsFab
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    children: [
                                      ToggleOption(
                                        description: LocalSettings.enableBackToTop.label,
                                        value: enableBackToTop,
                                        iconEnabled: Icons.arrow_upward,
                                        iconDisabled: Icons.arrow_upward,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableBackToTop, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableSubscriptions.label,
                                        value: enableSubscriptions,
                                        iconEnabled: Icons.people_rounded,
                                        iconDisabled: Icons.people_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableSubscriptions, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableChangeSort.label,
                                        value: enableChangeSort,
                                        iconEnabled: Icons.local_fire_department_rounded,
                                        iconDisabled: Icons.local_fire_department_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableChangeSort, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableRefresh.label,
                                        value: enableRefresh,
                                        iconEnabled: Icons.refresh_rounded,
                                        iconDisabled: Icons.refresh_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableRefresh, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableDismissRead.label,
                                        value: enableDismissRead,
                                        iconEnabled: Icons.clear_all_rounded,
                                        iconDisabled: Icons.clear_all_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableDismissRead, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableNewPost.label,
                                        value: enableNewPost,
                                        iconEnabled: Icons.add_rounded,
                                        iconDisabled: Icons.add_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableNewPost, value),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Posts',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        /*Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      'Looking to use buttons instead? Change what buttons appear on post cards in general settings.',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.75),
                      ),
                    ),
                  ),*/
                        ToggleOption(
                          description: LocalSettings.enablePostsFab.label,
                          value: enablePostsFab,
                          onToggle: (bool value) => setPreferences(LocalSettings.enablePostsFab, value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                ],
              ),
            ),
    );
  }
}
