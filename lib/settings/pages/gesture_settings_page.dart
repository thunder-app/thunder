import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

import '../widgets/toggle_option.dart';

class GestureSettingsPage extends StatefulWidget {
  const GestureSettingsPage({super.key});

  @override
  State<GestureSettingsPage> createState() => _GestureSettingsPageState();
}

class _GestureSettingsPageState extends State<GestureSettingsPage> {

  bool disableSwipeActionsOnPost = false;
  bool bottomNavBarSwipeGestures = true;
  bool bottomNavBarDoubleTapGestures = false;

  // Post Gestures
  bool enablePostGestures = true;
  SwipeAction leftPrimaryPostGesture = SwipeAction.upvote;
  SwipeAction leftSecondaryPostGesture = SwipeAction.downvote;
  SwipeAction rightPrimaryPostGesture = SwipeAction.reply;
  SwipeAction rightSecondaryPostGesture = SwipeAction.save;

  // Comment Gestures
  bool enableCommentGestures = true;
  SwipeAction leftPrimaryCommentGesture = SwipeAction.upvote;
  SwipeAction leftSecondaryCommentGesture = SwipeAction.downvote;
  SwipeAction rightPrimaryCommentGesture = SwipeAction.reply;
  SwipeAction rightSecondaryCommentGesture = SwipeAction.save;

  // Loading
  bool isLoading = true;

  List<ListPickerItem> gestureOptions = [
    ListPickerItem(icon: Icons.north_rounded, label: SwipeAction.upvote.name, payload: SwipeAction.upvote),
    ListPickerItem(icon: Icons.south_rounded, label: SwipeAction.downvote.name, payload: SwipeAction.downvote),
    ListPickerItem(icon: Icons.star_outline_rounded, label: SwipeAction.save.name, payload: SwipeAction.save),
    ListPickerItem(icon: Icons.reply_rounded, label: SwipeAction.reply.name, payload: SwipeAction.reply),
    ListPickerItem(icon: Icons.not_interested_rounded, label: SwipeAction.none.name, payload: SwipeAction.none),
  ];

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case 'setting_post_disable_swipe_actions':
        await prefs.setBool('setting_post_disable_swipe_actions', value);
        setState(() => disableSwipeActionsOnPost = value);
        break;
      case 'setting_general_enable_swipe_gestures':
        await prefs.setBool('setting_general_enable_swipe_gestures', value);
        setState(() => bottomNavBarSwipeGestures = value);
        break;
      case 'setting_general_enable_doubletap_gestures':
        await prefs.setBool('setting_general_enable_doubletap_gestures', value);
        setState(() => bottomNavBarDoubleTapGestures = value);
        break;

      // Post Gestures
      case 'setting_gesture_enable_post_gestures':
        await prefs.setBool('setting_gesture_enable_post_gestures', value);
        setState(() => enablePostGestures = value);
        break;
      case 'setting_gesture_post_left_primary_gesture':
        await prefs.setString('setting_gesture_post_left_primary_gesture', (value as SwipeAction).name);
        setState(() => leftPrimaryPostGesture = value);
        break;
      case 'setting_gesture_post_left_secondary_gesture':
        await prefs.setString('setting_gesture_post_left_secondary_gesture', (value as SwipeAction).name);
        setState(() => leftSecondaryPostGesture = value);
        break;
      case 'setting_gesture_post_right_primary_gesture':
        await prefs.setString('setting_gesture_post_right_primary_gesture', (value as SwipeAction).name);
        setState(() => rightPrimaryPostGesture = value);
        break;
      case 'setting_gesture_post_right_secondary_gesture':
        await prefs.setString('setting_gesture_post_right_secondary_gesture', (value as SwipeAction).name);
        setState(() => rightSecondaryPostGesture = value);
        break;

      // Comment Gestures
      case 'setting_gesture_enable_comment_gestures':
        await prefs.setBool('setting_gesture_enable_comment_gestures', value);
        setState(() => enableCommentGestures = value);
        break;
      case 'setting_gesture_comment_left_primary_gesture':
        await prefs.setString('setting_gesture_comment_left_primary_gesture', (value as SwipeAction).name);
        setState(() => leftPrimaryCommentGesture = value);
        break;
      case 'setting_gesture_comment_left_secondary_gesture':
        await prefs.setString('setting_gesture_comment_left_secondary_gesture', (value as SwipeAction).name);
        setState(() => leftSecondaryCommentGesture = value);
        break;
      case 'setting_gesture_comment_right_primary_gesture':
        await prefs.setString('setting_gesture_comment_right_primary_gesture', (value as SwipeAction).name);
        setState(() => rightPrimaryCommentGesture = value);
        break;
      case 'setting_gesture_comment_right_secondary_gesture':
        await prefs.setString('setting_gesture_comment_right_secondary_gesture', (value as SwipeAction).name);
        setState(() => rightSecondaryCommentGesture = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_primary_gesture') ?? SwipeAction.upvote.name);

      // Gestures
      disableSwipeActionsOnPost = prefs.getBool('setting_post_disable_swipe_actions') ?? false;
      bottomNavBarSwipeGestures = prefs.getBool('setting_general_enable_swipe_gestures') ?? true;
      bottomNavBarDoubleTapGestures = prefs.getBool('setting_general_enable_doubletap_gestures') ?? false;

      // Post Gestures
      enablePostGestures = prefs.getBool('setting_gesture_enable_post_gestures') ?? true;
      leftPrimaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_primary_gesture') ?? SwipeAction.upvote.name);
      leftSecondaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_secondary_gesture') ?? SwipeAction.downvote.name);
      rightPrimaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_primary_gesture') ?? SwipeAction.reply.name);
      rightSecondaryPostGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_secondary_gesture') ?? SwipeAction.save.name);

      // Comment Gestures
      enableCommentGestures = prefs.getBool('setting_gesture_enable_comment_gestures') ?? true;
      leftPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_left_primary_gesture') ?? SwipeAction.upvote.name);
      leftSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_left_secondary_gesture') ?? SwipeAction.downvote.name);
      rightPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_right_primary_gesture') ?? SwipeAction.reply.name);
      rightSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString('setting_gesture_comment_right_secondary_gesture') ?? SwipeAction.save.name);

      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestures'), centerTitle: false),
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
                            'Gestures',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Disable Post Swipe Actions',
                          subtitle: 'Comments will still have swipe actions',
                          value: disableSwipeActionsOnPost,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences('setting_post_disable_swipe_actions', value),
                        ),
                        ToggleOption(
                          description: 'Enable Swipe Gestures',
                          subtitle: 'Swipe gestures on bottom nav bar',
                          value: bottomNavBarSwipeGestures,
                          iconEnabled: Icons.swipe_right_rounded,
                          iconDisabled: Icons.swipe_right_outlined,
                          onToggle: (bool value) => setPreferences('setting_general_enable_swipe_gestures', value),
                        ),
                        ToggleOption(
                          description: 'Enable Double-Tap Gestures',
                          subtitle: 'Tap gestures on bottom nav bar',
                          value: bottomNavBarDoubleTapGestures,
                          iconEnabled: Icons.touch_app_rounded,
                          iconDisabled: Icons.touch_app_outlined,
                          onToggle: (bool value) => setPreferences('setting_general_enable_doubletap_gestures', value),
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
                        ListOption(
                          description: 'Left Short Swipe',
                          value: ListPickerItem(label: leftPrimaryPostGesture.name.capitalize, icon: Icons.feed, payload: leftPrimaryPostGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_left_primary_gesture', value.payload),
                        ),
                        ListOption(
                          description: 'Left Long Swipe',
                          value: ListPickerItem(label: leftSecondaryPostGesture.name.capitalize, icon: Icons.feed, payload: leftSecondaryPostGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_left_secondary_gesture', value.payload),
                        ),
                        ListOption(
                          description: 'Right Short Swipe',
                          value: ListPickerItem(label: rightPrimaryPostGesture.name.capitalize, icon: Icons.feed, payload: rightPrimaryPostGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_right_primary_gesture', value.payload),
                        ),
                        ListOption(
                          description: 'Right Long Swipe',
                          value: ListPickerItem(label: rightSecondaryPostGesture.name.capitalize, icon: Icons.feed, payload: rightSecondaryPostGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_double_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_right_secondary_gesture', value.payload),
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
                            'Comments',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ListOption(
                          description: 'Left Short Swipe',
                          value: ListPickerItem(label: leftPrimaryCommentGesture.name.capitalize, icon: Icons.feed, payload: leftPrimaryCommentGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_left_primary_gesture', value.payload),
                        ),
                        ListOption(
                          description: 'Left Long Swipe',
                          value: ListPickerItem(label: leftSecondaryCommentGesture.name.capitalize, icon: Icons.feed, payload: leftSecondaryCommentGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_left_secondary_gesture', value.payload),
                        ),
                        ListOption(
                          description: 'Right Short Swipe',
                          value: ListPickerItem(label: rightPrimaryCommentGesture.name.capitalize, icon: Icons.feed, payload: rightPrimaryCommentGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_right_primary_gesture', value.payload),
                        ),
                        ListOption(
                          description: 'Right Long Swipe',
                          value: ListPickerItem(label: rightSecondaryCommentGesture.name.capitalize, icon: Icons.feed, payload: rightSecondaryCommentGesture),
                          options: gestureOptions,
                          icon: Icons.keyboard_double_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_right_secondary_gesture', value.payload),
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
