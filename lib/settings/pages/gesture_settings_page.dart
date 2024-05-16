import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/settings/widgets/swipe_picker.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/constants.dart';

class GestureSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const GestureSettingsPage({super.key, this.settingToHighlight});

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

  bool enableFullScreenSwipeNavigationGesture = true;

  /// Loading
  bool isLoading = true;

  /// The available gesture options
  List<ListPickerItem<SwipeAction>> postGestureOptions = [
    ListPickerItem(icon: SwipeAction.upvote.getIcon(), label: SwipeAction.upvote.label, payload: SwipeAction.upvote),
    ListPickerItem(icon: SwipeAction.downvote.getIcon(), label: SwipeAction.downvote.label, payload: SwipeAction.downvote),
    ListPickerItem(icon: SwipeAction.save.getIcon(), label: SwipeAction.save.label, payload: SwipeAction.save),
    ListPickerItem(icon: SwipeAction.toggleRead.getIcon(), label: SwipeAction.toggleRead.label, payload: SwipeAction.toggleRead),
    ListPickerItem(icon: SwipeAction.none.getIcon(), label: SwipeAction.none.label, payload: SwipeAction.none),
  ];

  List<ListPickerItem<SwipeAction>> commentGestureOptions = [
    ListPickerItem(icon: SwipeAction.upvote.getIcon(), label: SwipeAction.upvote.label, payload: SwipeAction.upvote),
    ListPickerItem(icon: SwipeAction.downvote.getIcon(), label: SwipeAction.downvote.label, payload: SwipeAction.downvote),
    ListPickerItem(icon: SwipeAction.save.getIcon(), label: SwipeAction.save.label, payload: SwipeAction.save),
    ListPickerItem(icon: SwipeAction.reply.getIcon(), label: SwipeAction.reply.label, payload: SwipeAction.reply),
    ListPickerItem(icon: SwipeAction.none.getIcon(), label: SwipeAction.none.label, payload: SwipeAction.none),
  ];

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

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
      case LocalSettings.enableFullScreenSwipeNavigationGesture:
        await prefs.setBool(LocalSettings.enableFullScreenSwipeNavigationGesture.name, value);
        setState(() => enableFullScreenSwipeNavigationGesture = value);
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

      enableFullScreenSwipeNavigationGesture = prefs.getBool(LocalSettings.enableFullScreenSwipeNavigationGesture.name) ?? true;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gestures), centerTitle: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Text(
                            l10n.navigation,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: l10n.fullscreenSwipeGestures,
                          subtitle: l10n.fullScreenNavigationSwipeDescription,
                          value: enableFullScreenSwipeNavigationGesture,
                          iconEnabled: Icons.swipe_left_rounded,
                          iconDisabled: Icons.swipe_left_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.enableFullScreenSwipeNavigationGesture, value),
                          highlightKey: settingToHighlightKey,
                          setting: LocalSettings.enableFullScreenSwipeNavigationGesture,
                          highlightedSetting: settingToHighlight,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Text(
                            l10n.sidebar,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: l10n.navbarSwipeGestures,
                          subtitle: l10n.sidebarBottomNavSwipeDescription,
                          value: bottomNavBarSwipeGestures,
                          iconEnabled: Icons.swipe_right_rounded,
                          iconDisabled: Icons.swipe_right_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.sidebarBottomNavBarSwipeGesture, value),
                          highlightKey: settingToHighlightKey,
                          setting: LocalSettings.sidebarBottomNavBarSwipeGesture,
                          highlightedSetting: settingToHighlight,
                        ),
                        ToggleOption(
                          description: l10n.navbarDoubleTapGestures,
                          subtitle: l10n.sidebarBottomNavDoubleTapDescription,
                          value: bottomNavBarDoubleTapGestures,
                          iconEnabled: Icons.touch_app_rounded,
                          iconDisabled: Icons.touch_app_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.sidebarBottomNavBarDoubleTapGesture, value),
                          highlightKey: settingToHighlightKey,
                          setting: LocalSettings.sidebarBottomNavBarDoubleTapGesture,
                          highlightedSetting: settingToHighlight,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Text(
                            l10n.posts,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18.0, 6.0, 22.0, 6.0),
                          child: Text(
                            l10n.postSwipeGesturesHint,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.75),
                            ),
                          ),
                        ),
                        ToggleOption(
                          description: l10n.postSwipeActions,
                          value: enablePostGestures,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.enablePostGestures, value),
                          highlightKey: settingToHighlightKey,
                          setting: LocalSettings.enablePostGestures,
                          highlightedSetting: settingToHighlight,
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
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 22.0, 6.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.customizeSwipeActions,
                                          style: TextStyle(
                                            color: theme.colorScheme.onBackground.withOpacity(0.75),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
                                      child: SwipePicker(
                                        side: SwipePickerSide.left,
                                        items: [
                                          SwipePickerItem(
                                            label: l10n.leftShortSwipe,
                                            options: postGestureOptions,
                                            value: leftPrimaryPostGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.postGestureLeftPrimary, value.payload),
                                          ),
                                          SwipePickerItem(
                                            label: l10n.leftLongSwipe,
                                            options: postGestureOptions,
                                            value: leftSecondaryPostGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.postGestureLeftSecondary, value.payload),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
                                      child: SwipePicker(
                                        side: SwipePickerSide.right,
                                        items: [
                                          SwipePickerItem(
                                            label: l10n.rightShortSwipe,
                                            options: postGestureOptions,
                                            value: rightPrimaryPostGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.postGestureRightPrimary, value.payload),
                                          ),
                                          SwipePickerItem(
                                            label: l10n.rightLongSwipe,
                                            options: postGestureOptions,
                                            value: rightSecondaryPostGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.postGestureRightSecondary, value.payload),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Text(
                            l10n.comments,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18.0, 6.0, 22.0, 6.0),
                          child: Text(
                            l10n.commentSwipeGesturesHint,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.75),
                            ),
                          ),
                        ),
                        ToggleOption(
                          description: l10n.commentSwipeActions,
                          value: enableCommentGestures,
                          iconEnabled: Icons.swipe_rounded,
                          iconDisabled: Icons.swipe_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.enableCommentGestures, value),
                          highlightKey: settingToHighlightKey,
                          setting: LocalSettings.enableCommentGestures,
                          highlightedSetting: settingToHighlight,
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
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 22.0, 6.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.customizeSwipeActions,
                                          style: TextStyle(
                                            color: theme.colorScheme.onBackground.withOpacity(0.75),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
                                      child: SwipePicker(
                                        side: SwipePickerSide.left,
                                        items: [
                                          SwipePickerItem(
                                            label: l10n.leftShortSwipe,
                                            options: commentGestureOptions,
                                            value: leftPrimaryCommentGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.commentGestureLeftPrimary, value.payload),
                                          ),
                                          SwipePickerItem(
                                            label: l10n.leftLongSwipe,
                                            options: commentGestureOptions,
                                            value: leftSecondaryCommentGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.commentGestureLeftSecondary, value.payload),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
                                      child: SwipePicker(
                                        side: SwipePickerSide.right,
                                        items: [
                                          SwipePickerItem(
                                            label: l10n.rightShortSwipe,
                                            options: commentGestureOptions,
                                            value: rightPrimaryCommentGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.commentGestureRightPrimary, value.payload),
                                          ),
                                          SwipePickerItem(
                                            label: l10n.rightLongSwipe,
                                            options: commentGestureOptions,
                                            value: rightSecondaryCommentGesture,
                                            onChanged: (value) => setPreferences(LocalSettings.commentGestureRightSecondary, value.payload),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        SettingsListTile(
                          icon: Icons.color_lens_rounded,
                          description: l10n.actionColorsRedirect,
                          widget: const SizedBox(
                            height: 42.0,
                            child: Icon(Icons.chevron_right_rounded),
                          ),
                          onTap: () {
                            GoRouter.of(context).push(
                              SETTINGS_APPEARANCE_THEMES_PAGE,
                              extra: [
                                context.read<ThunderBloc>(),
                                LocalSettings.actionColors,
                              ],
                            );
                          },
                          highlightKey: settingToHighlightKey,
                          setting: null,
                          highlightedSetting: settingToHighlight,
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
