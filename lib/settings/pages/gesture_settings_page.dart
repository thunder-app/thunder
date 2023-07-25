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

class GestureSettingsPage extends StatefulWidget {
  const GestureSettingsPage({super.key});

  @override
  State<GestureSettingsPage> createState() => _GestureSettingsPageState();
}

class _GestureSettingsPageState extends State<GestureSettingsPage> with TickerProviderStateMixin {
  /// -------------------------- Gesture Related Settings --------------------------
  // Sidebar Gesture Settings
  bool bottomNavBarSwipeGestures = true;
  bool bottomNavBarDoubleTapGestures = false;

  // Post Gesture Settings
  bool enablePostGestures = true;
  SwipeAction leftPrimaryPostGesture = SwipeAction.upvote;
  SwipeAction leftSecondaryPostGesture = SwipeAction.downvote;
  SwipeAction rightPrimaryPostGesture = SwipeAction.save;
  SwipeAction rightSecondaryPostGesture = SwipeAction.toggleRead;

  // Comment Gesture Settings
  bool enableCommentGestures = true;
  SwipeAction leftPrimaryCommentGesture = SwipeAction.upvote;
  SwipeAction leftSecondaryCommentGesture = SwipeAction.downvote;
  SwipeAction rightPrimaryCommentGesture = SwipeAction.reply;
  SwipeAction rightSecondaryCommentGesture = SwipeAction.save;

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

  List<ListPickerItem> commentGestureOptions = [
    ListPickerItem(icon: Icons.north_rounded, label: SwipeAction.upvote.label, payload: SwipeAction.upvote),
    ListPickerItem(icon: Icons.south_rounded, label: SwipeAction.downvote.label, payload: SwipeAction.downvote),
    ListPickerItem(icon: Icons.star_outline_rounded, label: SwipeAction.save.label, payload: SwipeAction.save),
    ListPickerItem(icon: Icons.reply_rounded, label: SwipeAction.reply.label, payload: SwipeAction.reply),
    ListPickerItem(icon: Icons.not_interested_rounded, label: SwipeAction.none.label, payload: SwipeAction.none),
  ];

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      /// -------------------------- Gesture Related Settings --------------------------
      // Sidebar Gesture Settings
      case LocalSettings.sidebarBottomNavBarSwipeGesture:
        await prefs.setBool(LocalSettings.sidebarBottomNavBarSwipeGesture.name, value);
        setState(() => bottomNavBarSwipeGestures = value);
        break;
      case LocalSettings.sidebarBottomNavBarDoubleTapGesture:
        await prefs.setBool(LocalSettings.sidebarBottomNavBarDoubleTapGesture.name, value);
        setState(() => bottomNavBarDoubleTapGestures = value);
        break;

      // Post Gesture Settings
      case LocalSettings.enablePostGestures:
        await prefs.setBool(LocalSettings.enablePostGestures.name, value);
        setState(() => enablePostGestures = value);
        break;
      case LocalSettings.postGestureLeftPrimary:
        await prefs.setString(LocalSettings.postGestureLeftPrimary.name, (value as SwipeAction).name);
        setState(() => leftPrimaryPostGesture = value);
        break;
      case LocalSettings.postGestureLeftSecondary:
        await prefs.setString(LocalSettings.postGestureLeftSecondary.name, (value as SwipeAction).name);
        setState(() => leftSecondaryPostGesture = value);
        break;
      case LocalSettings.postGestureRightPrimary:
        await prefs.setString(LocalSettings.postGestureRightPrimary.name, (value as SwipeAction).name);
        setState(() => rightPrimaryPostGesture = value);
        break;
      case LocalSettings.postGestureRightSecondary:
        await prefs.setString(LocalSettings.postGestureRightSecondary.name, (value as SwipeAction).name);
        setState(() => rightSecondaryPostGesture = value);
        break;

      // Comment Gesture Settings
      case LocalSettings.enableCommentGestures:
        await prefs.setBool(LocalSettings.enableCommentGestures.name, value);
        setState(() => enableCommentGestures = value);
        break;
      case LocalSettings.commentGestureLeftPrimary:
        await prefs.setString(LocalSettings.commentGestureLeftPrimary.name, (value as SwipeAction).name);
        setState(() => leftPrimaryCommentGesture = value);
        break;
      case LocalSettings.commentGestureLeftSecondary:
        await prefs.setString(LocalSettings.commentGestureLeftSecondary.name, (value as SwipeAction).name);
        setState(() => leftSecondaryCommentGesture = value);
        break;
      case LocalSettings.commentGestureRightPrimary:
        await prefs.setString(LocalSettings.commentGestureRightPrimary.name, (value as SwipeAction).name);
        setState(() => rightPrimaryCommentGesture = value);
        break;
      case LocalSettings.commentGestureRightSecondary:
        await prefs.setString(LocalSettings.commentGestureRightSecondary.name, (value as SwipeAction).name);
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
      /// -------------------------- Gesture Related Settings --------------------------
      // Sidebar Gesture Settings
      bottomNavBarSwipeGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarSwipeGesture.name) ?? true;
      bottomNavBarDoubleTapGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarDoubleTapGesture.name) ?? false;

      // Post Gesture Settings
      enablePostGestures = prefs.getBool(LocalSettings.enablePostGestures.name) ?? true;
      leftPrimaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureLeftPrimary.name) ?? SwipeAction.upvote.name);
      leftSecondaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureLeftSecondary.name) ?? SwipeAction.downvote.name);
      rightPrimaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureRightPrimary.name) ?? SwipeAction.save.name);
      rightSecondaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureRightSecondary.name) ?? SwipeAction.toggleRead.name);

      // Comment Gesture Settings
      enableCommentGestures = prefs.getBool(LocalSettings.enableCommentGestures.name) ?? true;
      leftPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureLeftPrimary.name) ?? SwipeAction.upvote.name);
      leftSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureLeftSecondary.name) ?? SwipeAction.downvote.name);
      rightPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureRightPrimary.name) ?? SwipeAction.reply.name);
      rightSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureRightSecondary.name) ?? SwipeAction.save.name);

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
                          description: LocalSettings.sidebarBottomNavBarSwipeGesture.label,
                          subtitle: 'Swipe bottom nav to open sidebar',
                          value: bottomNavBarSwipeGestures,
                          iconEnabled: Icons.swipe_right_rounded,
                          iconDisabled: Icons.swipe_right_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.sidebarBottomNavBarSwipeGesture, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.sidebarBottomNavBarDoubleTapGesture.label,
                          subtitle: 'Double-tap bottom nav to open sidebar',
                          value: bottomNavBarDoubleTapGestures,
                          iconEnabled: Icons.touch_app_rounded,
                          iconDisabled: Icons.touch_app_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.sidebarBottomNavBarDoubleTapGesture, value),
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
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            'Looking to use buttons instead? Change what buttons appear on post cards in general settings.',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.75),
                            ),
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.enablePostGestures.label,
                          value: enablePostGestures,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.enablePostGestures, value),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: SlideTransition(position: _offsetAnimation, child: child),
                            );
                          },
                          child: enablePostGestures
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    children: [
                                      ListOption(
                                        description: LocalSettings.postGestureLeftPrimary.label,
                                        value: ListPickerItem(label: leftPrimaryPostGesture.name.capitalize, icon: Icons.feed, payload: leftPrimaryPostGesture),
                                        options: postGestureOptions,
                                        icon: Icons.keyboard_arrow_right_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.postGestureLeftPrimary, value.payload),
                                        disabled: !enablePostGestures,
                                      ),
                                      ListOption(
                                        description: LocalSettings.postGestureLeftSecondary.label,
                                        value: ListPickerItem(label: leftSecondaryPostGesture.name.capitalize, icon: Icons.feed, payload: leftSecondaryPostGesture),
                                        options: postGestureOptions,
                                        icon: Icons.keyboard_double_arrow_right_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.postGestureLeftSecondary, value.payload),
                                        disabled: !enablePostGestures,
                                      ),
                                      ListOption(
                                        description: LocalSettings.postGestureRightPrimary.label,
                                        value: ListPickerItem(label: rightPrimaryPostGesture.name.capitalize, icon: Icons.feed, payload: rightPrimaryPostGesture),
                                        options: postGestureOptions,
                                        icon: Icons.keyboard_arrow_left_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.postGestureRightPrimary, value.payload),
                                        disabled: !enablePostGestures,
                                      ),
                                      ListOption(
                                        description: LocalSettings.postGestureRightSecondary.label,
                                        value: ListPickerItem(label: rightSecondaryPostGesture.name.capitalize, icon: Icons.feed, payload: rightSecondaryPostGesture),
                                        options: postGestureOptions,
                                        icon: Icons.keyboard_double_arrow_left_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.postGestureRightSecondary, value.payload),
                                        disabled: !enablePostGestures,
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
                            'Comments',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            'Looking to use buttons instead? Enable them in the comments section in general settings.',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.75),
                            ),
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.enableCommentGestures.label,
                          value: enableCommentGestures,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.enableCommentGestures, value),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: SlideTransition(position: _offsetAnimation, child: child),
                            );
                          },
                          child: enableCommentGestures
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    children: [
                                      ListOption(
                                        description: LocalSettings.commentGestureLeftPrimary.label,
                                        value: ListPickerItem(label: leftPrimaryCommentGesture.name.capitalize, icon: Icons.feed, payload: leftPrimaryCommentGesture),
                                        options: commentGestureOptions,
                                        icon: Icons.keyboard_arrow_right_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.commentGestureLeftPrimary, value.payload),
                                        disabled: !enableCommentGestures,
                                      ),
                                      ListOption(
                                        description: LocalSettings.commentGestureLeftSecondary.label,
                                        value: ListPickerItem(label: leftSecondaryCommentGesture.name.capitalize, icon: Icons.feed, payload: leftSecondaryCommentGesture),
                                        options: commentGestureOptions,
                                        icon: Icons.keyboard_double_arrow_right_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.commentGestureLeftSecondary, value.payload),
                                        disabled: !enableCommentGestures,
                                      ),
                                      ListOption(
                                        description: LocalSettings.commentGestureRightPrimary.label,
                                        value: ListPickerItem(label: rightPrimaryCommentGesture.name.capitalize, icon: Icons.feed, payload: rightPrimaryCommentGesture),
                                        options: commentGestureOptions,
                                        icon: Icons.keyboard_arrow_left_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.commentGestureRightPrimary, value.payload),
                                        disabled: !enableCommentGestures,
                                      ),
                                      ListOption(
                                        description: LocalSettings.commentGestureRightSecondary.label,
                                        value: ListPickerItem(label: rightSecondaryCommentGesture.name.capitalize, icon: Icons.feed, payload: rightSecondaryCommentGesture),
                                        options: commentGestureOptions,
                                        icon: Icons.keyboard_double_arrow_left_rounded,
                                        onChanged: (value) => setPreferences(LocalSettings.commentGestureRightSecondary, value.payload),
                                        disabled: !enableCommentGestures,
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
}
