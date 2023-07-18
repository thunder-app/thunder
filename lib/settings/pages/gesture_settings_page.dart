import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

class GestureSettingsPage extends StatefulWidget {
  const GestureSettingsPage({super.key});

  @override
  State<GestureSettingsPage> createState() => _GestureSettingsPageState();
}

class _GestureSettingsPageState extends State<GestureSettingsPage> {
  bool bottomNavBarSwipeGestures = true;
  bool bottomNavBarDoubleTapGestures = false;

  /// Post Gestures
  bool enablePostGestures = true;
  SwipeAction leftPrimaryPostGesture = SwipeAction.upvote;
  SwipeAction leftSecondaryPostGesture = SwipeAction.downvote;
  SwipeAction rightPrimaryPostGesture = SwipeAction.reply;
  SwipeAction rightSecondaryPostGesture = SwipeAction.save;

  /// Comment Gestures
  bool enableCommentGestures = true;
  SwipeAction leftPrimaryCommentGesture = SwipeAction.upvote;
  SwipeAction leftSecondaryCommentGesture = SwipeAction.downvote;
  SwipeAction rightPrimaryCommentGesture = SwipeAction.reply;
  SwipeAction rightSecondaryCommentGesture = SwipeAction.save;

  /// Loading
  bool isLoading = true;

  /// The available gesture options
  List<ListPickerItem> postGestureOptions = [
    ListPickerItem(icon: Icons.north_rounded, label: SwipeAction.upvote.friendlyName, payload: SwipeAction.upvote),
    ListPickerItem(icon: Icons.south_rounded, label: SwipeAction.downvote.friendlyName, payload: SwipeAction.downvote),
    ListPickerItem(icon: Icons.star_outline_rounded, label: SwipeAction.save.friendlyName, payload: SwipeAction.save),
    ListPickerItem(icon: Icons.reply_rounded, label: SwipeAction.reply.friendlyName, payload: SwipeAction.reply),
    ListPickerItem(icon: Icons.markunread_outlined, label: SwipeAction.toggleRead.friendlyName, payload: SwipeAction.toggleRead),
    ListPickerItem(icon: Icons.not_interested_rounded, label: SwipeAction.none.friendlyName, payload: SwipeAction.none),
  ];

  List<ListPickerItem> commentGestureOptions = [
    ListPickerItem(icon: Icons.north_rounded, label: SwipeAction.upvote.friendlyName, payload: SwipeAction.upvote),
    ListPickerItem(icon: Icons.south_rounded, label: SwipeAction.downvote.friendlyName, payload: SwipeAction.downvote),
    ListPickerItem(icon: Icons.star_outline_rounded, label: SwipeAction.save.friendlyName, payload: SwipeAction.save),
    ListPickerItem(icon: Icons.reply_rounded, label: SwipeAction.reply.friendlyName, payload: SwipeAction.reply),
    ListPickerItem(icon: Icons.not_interested_rounded, label: SwipeAction.none.friendlyName, payload: SwipeAction.none),
  ];

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
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
                            'Sidebar',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Navbar Swipe Gestures',
                          subtitle: 'Swipe bottom nav to open sidebar',
                          value: bottomNavBarSwipeGestures,
                          iconEnabled: Icons.swipe_right_rounded,
                          iconDisabled: Icons.swipe_right_outlined,
                          onToggle: (bool value) => setPreferences('setting_general_enable_swipe_gestures', value),
                        ),
                        ToggleOption(
                          description: 'Navbar Double-Tap Gestures',
                          subtitle: 'Double-tap bottom nav to open sidebar',
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
                        ToggleOption(
                          description: 'Post Swipe Actions',
                          value: enablePostGestures,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences('setting_gesture_enable_post_gestures', value),
                        ),
                        const SizedBox(height: 8),
                        ListOption(
                          description: 'Left Short Swipe',
                          value: ListPickerItem(label: leftPrimaryPostGesture.name.capitalize, icon: Icons.feed, payload: leftPrimaryPostGesture),
                          options: postGestureOptions,
                          icon: Icons.keyboard_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_left_primary_gesture', value.payload),
                          disabled: !enablePostGestures,
                        ),
                        ListOption(
                          description: 'Left Long Swipe',
                          value: ListPickerItem(label: leftSecondaryPostGesture.name.capitalize, icon: Icons.feed, payload: leftSecondaryPostGesture),
                          options: postGestureOptions,
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_left_secondary_gesture', value.payload),
                          disabled: !enablePostGestures,
                        ),
                        ListOption(
                          description: 'Right Short Swipe',
                          value: ListPickerItem(label: rightPrimaryPostGesture.name.capitalize, icon: Icons.feed, payload: rightPrimaryPostGesture),
                          options: postGestureOptions,
                          icon: Icons.keyboard_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_right_primary_gesture', value.payload),
                          disabled: !enablePostGestures,
                        ),
                        ListOption(
                          description: 'Right Long Swipe',
                          value: ListPickerItem(label: rightSecondaryPostGesture.name.capitalize, icon: Icons.feed, payload: rightSecondaryPostGesture),
                          options: postGestureOptions,
                          icon: Icons.keyboard_double_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_post_right_secondary_gesture', value.payload),
                          disabled: !enablePostGestures,
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
                        ToggleOption(
                          description: 'Comment Swipe Actions',
                          value: enableCommentGestures,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences('setting_gesture_enable_comment_gestures', value),
                        ),
                        const SizedBox(height: 8),
                        ListOption(
                          description: 'Left Short Swipe',
                          value: ListPickerItem(label: leftPrimaryCommentGesture.name.capitalize, icon: Icons.feed, payload: leftPrimaryCommentGesture),
                          options: commentGestureOptions,
                          icon: Icons.keyboard_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_left_primary_gesture', value.payload),
                          disabled: !enableCommentGestures,
                        ),
                        ListOption(
                          description: 'Left Long Swipe',
                          value: ListPickerItem(label: leftSecondaryCommentGesture.name.capitalize, icon: Icons.feed, payload: leftSecondaryCommentGesture),
                          options: commentGestureOptions,
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_left_secondary_gesture', value.payload),
                          disabled: !enableCommentGestures,
                        ),
                        ListOption(
                          description: 'Right Short Swipe',
                          value: ListPickerItem(label: rightPrimaryCommentGesture.name.capitalize, icon: Icons.feed, payload: rightPrimaryCommentGesture),
                          options: commentGestureOptions,
                          icon: Icons.keyboard_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_right_primary_gesture', value.payload),
                          disabled: !enableCommentGestures,
                        ),
                        ListOption(
                          description: 'Right Long Swipe',
                          value: ListPickerItem(label: rightSecondaryCommentGesture.name.capitalize, icon: Icons.feed, payload: rightSecondaryCommentGesture),
                          options: commentGestureOptions,
                          icon: Icons.keyboard_double_arrow_left_rounded,
                          onChanged: (value) => setPreferences('setting_gesture_comment_right_secondary_gesture', value.payload),
                          disabled: !enableCommentGestures,
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
