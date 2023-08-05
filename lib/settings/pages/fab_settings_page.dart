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
  bool enableFeedsFab = true;
  bool enablePostsFab = true;

  bool enableBackToTop = true;
  bool enableSubscriptions = true;
  bool enableChangeSort = true;
  bool enableRefresh = true;
  bool enableDismissRead = true;
  bool enableNewPost = true;

  bool postFabEnableBackToTop = true;
  bool postFabEnableChangeSort = true;
  bool postFabEnableReplyToPost = true;

  String feedFabSinglePressAction = LocalSettings.enableDismissRead.name;
  String feedFabLongPressAction = 'open_fab';
  String postFabSinglePressAction = LocalSettings.postFabEnableReplyToPost.name;
  String postFabLongPressAction = 'open_fab';

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
      case LocalSettings.postFabEnableBackToTop:
        await prefs.setBool(LocalSettings.postFabEnableBackToTop.name, value);
        setState(() => postFabEnableBackToTop = value);
        break;
      case LocalSettings.postFabEnableChangeSort:
        await prefs.setBool(LocalSettings.postFabEnableChangeSort.name, value);
        setState(() => postFabEnableChangeSort = value);
        break;
      case LocalSettings.postFabEnableReplyToPost:
        await prefs.setBool(LocalSettings.postFabEnableReplyToPost.name, value);
        setState(() => postFabEnableReplyToPost = value);
        break;
      case LocalSettings.feedFabSinglePressAction:
        await prefs.setString(LocalSettings.feedFabSinglePressAction.name, value);
        setState(() => feedFabSinglePressAction = value);
        break;
      case LocalSettings.feedFabLongPressAction:
        await prefs.setString(LocalSettings.feedFabLongPressAction.name, value);
        setState(() => feedFabLongPressAction = value);
        break;
      case LocalSettings.postFabSinglePressAction:
        await prefs.setString(LocalSettings.postFabSinglePressAction.name, value);
        setState(() => postFabSinglePressAction = value);
        break;
      case LocalSettings.postFabLongPressAction:
        await prefs.setString(LocalSettings.postFabLongPressAction.name, value);
        setState(() => postFabLongPressAction = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      enableFeedsFab = prefs.getBool(LocalSettings.enableFeedsFab.name) ?? true;
      enablePostsFab = prefs.getBool(LocalSettings.enablePostsFab.name) ?? true;

      enableBackToTop = prefs.getBool(LocalSettings.enableBackToTop.name) ?? true;
      enableSubscriptions = prefs.getBool(LocalSettings.enableSubscriptions.name) ?? true;
      enableChangeSort = prefs.getBool(LocalSettings.enableChangeSort.name) ?? true;
      enableRefresh = prefs.getBool(LocalSettings.enableRefresh.name) ?? true;
      enableDismissRead = prefs.getBool(LocalSettings.enableDismissRead.name) ?? true;
      enableNewPost = prefs.getBool(LocalSettings.enableNewPost.name) ?? true;

      postFabEnableBackToTop = prefs.getBool(LocalSettings.postFabEnableBackToTop.name) ?? true;
      postFabEnableChangeSort = prefs.getBool(LocalSettings.postFabEnableChangeSort.name) ?? true;
      postFabEnableReplyToPost = prefs.getBool(LocalSettings.postFabEnableReplyToPost.name) ?? true;

      feedFabSinglePressAction = prefs.getString(LocalSettings.feedFabSinglePressAction.name) ?? LocalSettings.enableDismissRead.name;
      feedFabLongPressAction = prefs.getString(LocalSettings.feedFabLongPressAction.name) ?? 'open_fab';
      postFabSinglePressAction = prefs.getString(LocalSettings.postFabSinglePressAction.name) ?? LocalSettings.postFabEnableReplyToPost.name;
      postFabLongPressAction = prefs.getString(LocalSettings.postFabLongPressAction.name) ?? 'open_fab';

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
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
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
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Long-press actions to set them as the FAB\'s single-press or long-press action.',
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_outlined,
                                    size: 20,
                                  ),
                                  Text(
                                    'denotes the FAB\'s single-press action.',
                                    style: TextStyle(
                                      color: theme.colorScheme.onBackground.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    size: 20,
                                  ),
                                  Text(
                                    'denotes the FAB\'s long-press action.',
                                    style: TextStyle(
                                      color: theme.colorScheme.onBackground.withOpacity(0.75),
                                    ),
                                  ),
                                ],
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
                                        description: 'Expand options',
                                        value: null,
                                        iconEnabled: Icons.more_horiz_rounded,
                                        iconDisabled: Icons.more_horiz_rounded,
                                        onToggle: (_) {},
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == 'open_fab')
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == 'open_fab')
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker('open_fab'),
                                        onTap: () => showFeedFabActionPicker('open_fab'),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableBackToTop.label,
                                        value: enableBackToTop,
                                        iconEnabled: Icons.arrow_upward,
                                        iconDisabled: Icons.arrow_upward,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableBackToTop, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == LocalSettings.enableBackToTop.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == LocalSettings.enableBackToTop.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(LocalSettings.enableBackToTop.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableSubscriptions.label,
                                        value: enableSubscriptions,
                                        iconEnabled: Icons.people_rounded,
                                        iconDisabled: Icons.people_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableSubscriptions, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == LocalSettings.enableSubscriptions.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == LocalSettings.enableSubscriptions.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(LocalSettings.enableSubscriptions.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableChangeSort.label,
                                        value: enableChangeSort,
                                        iconEnabled: Icons.sort_rounded,
                                        iconDisabled: Icons.sort_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableChangeSort, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == LocalSettings.enableChangeSort.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == LocalSettings.enableChangeSort.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(LocalSettings.enableChangeSort.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableRefresh.label,
                                        value: enableRefresh,
                                        iconEnabled: Icons.refresh_rounded,
                                        iconDisabled: Icons.refresh_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableRefresh, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == LocalSettings.enableRefresh.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == LocalSettings.enableRefresh.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(LocalSettings.enableRefresh.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableDismissRead.label,
                                        value: enableDismissRead,
                                        iconEnabled: Icons.clear_all_rounded,
                                        iconDisabled: Icons.clear_all_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableDismissRead, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == LocalSettings.enableDismissRead.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == LocalSettings.enableDismissRead.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(LocalSettings.enableDismissRead.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableNewPost.label,
                                        value: enableNewPost,
                                        iconEnabled: Icons.add_rounded,
                                        iconDisabled: Icons.add_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableNewPost, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == LocalSettings.enableNewPost.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == LocalSettings.enableNewPost.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(LocalSettings.enableNewPost.name),
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
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            'Posts',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.enablePostsFab.label,
                          value: enablePostsFab,
                          onToggle: (bool value) => setPreferences(LocalSettings.enablePostsFab, value),
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
                          child: enablePostsFab
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    children: [
                                      ToggleOption(
                                        description: 'Expand options',
                                        value: null,
                                        iconEnabled: Icons.more_horiz_rounded,
                                        iconDisabled: Icons.more_horiz_rounded,
                                        onToggle: (_) {},
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == 'open_fab')
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == 'open_fab')
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker('open_fab'),
                                        onTap: () => showPostFabActionPicker('open_fab'),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.postFabEnableBackToTop.label,
                                        value: postFabEnableBackToTop,
                                        iconEnabled: Icons.arrow_upward,
                                        iconDisabled: Icons.arrow_upward,
                                        onToggle: (bool value) => setPreferences(LocalSettings.postFabEnableBackToTop, value),
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == LocalSettings.postFabEnableBackToTop.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == LocalSettings.postFabEnableBackToTop.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(LocalSettings.postFabEnableBackToTop.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.postFabEnableChangeSort.label,
                                        value: postFabEnableChangeSort,
                                        iconEnabled: Icons.sort_rounded,
                                        iconDisabled: Icons.sort_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.postFabEnableChangeSort, value),
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == LocalSettings.postFabEnableChangeSort.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == LocalSettings.postFabEnableChangeSort.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(LocalSettings.postFabEnableChangeSort.name),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.postFabEnableReplyToPost.label,
                                        value: postFabEnableReplyToPost,
                                        iconEnabled: Icons.reply_rounded,
                                        iconDisabled: Icons.reply_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.postFabEnableReplyToPost, value),
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == LocalSettings.postFabEnableReplyToPost.name)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == LocalSettings.postFabEnableReplyToPost.name)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(LocalSettings.postFabEnableReplyToPost.name),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
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

  void showFeedFabActionPicker(String actionName) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => BottomSheetListPicker(
        title: 'Set Press Action',
        items: const [
          ListPickerItem(label: 'Set as short-press action', payload: 'short', icon: Icons.touch_app_outlined),
          ListPickerItem(label: 'Set as long-press action', payload: 'long', icon: Icons.touch_app_rounded)
        ],
        onSelect: (value) {
          if (value.payload == 'short') {
            setPreferences(LocalSettings.feedFabSinglePressAction, actionName);
          }
          if (value.payload == 'long') {
            setPreferences(LocalSettings.feedFabLongPressAction, actionName);
          }
        },
      ),
    );
  }

  void showPostFabActionPicker(String actionName) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => BottomSheetListPicker(
        title: 'Set Press Action',
        items: const [
          ListPickerItem(label: 'Set as short-press action', payload: 'short', icon: Icons.touch_app_outlined),
          ListPickerItem(label: 'Set as long-press action', payload: 'long', icon: Icons.touch_app_rounded)
        ],
        onSelect: (value) {
          if (value.payload == 'short') {
            setPreferences(LocalSettings.postFabSinglePressAction, actionName);
          }
          if (value.payload == 'long') {
            setPreferences(LocalSettings.postFabLongPressAction, actionName);
          }
        },
      ),
    );
  }
}
