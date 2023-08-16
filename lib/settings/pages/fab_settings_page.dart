import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/local_settings.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  FeedFabAction feedFabSinglePressAction = FeedFabAction.dismissRead;
  FeedFabAction feedFabLongPressAction = FeedFabAction.openFab;
  PostFabAction postFabSinglePressAction = PostFabAction.replyToPost;
  PostFabAction postFabLongPressAction = PostFabAction.openFab;

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
        await prefs.setString(LocalSettings.feedFabSinglePressAction.name, (value as FeedFabAction).name);
        setState(() => feedFabSinglePressAction = value);
        break;
      case LocalSettings.feedFabLongPressAction:
        await prefs.setString(LocalSettings.feedFabLongPressAction.name, (value as FeedFabAction).name);
        setState(() => feedFabLongPressAction = value);
        break;
      case LocalSettings.postFabSinglePressAction:
        await prefs.setString(LocalSettings.postFabSinglePressAction.name, (value as PostFabAction).name);
        setState(() => postFabSinglePressAction = value);
        break;
      case LocalSettings.postFabLongPressAction:
        await prefs.setString(LocalSettings.postFabLongPressAction.name, (value as PostFabAction).name);
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

      feedFabSinglePressAction = FeedFabAction.values.byName(prefs.getString(LocalSettings.feedFabSinglePressAction.name) ?? FeedFabAction.dismissRead.name);
      feedFabLongPressAction = FeedFabAction.values.byName(prefs.getString(LocalSettings.feedFabLongPressAction.name) ?? FeedFabAction.openFab.name);
      postFabSinglePressAction = PostFabAction.values.byName(prefs.getString(LocalSettings.postFabSinglePressAction.name) ?? PostFabAction.replyToPost.name);
      postFabLongPressAction = PostFabAction.values.byName(prefs.getString(LocalSettings.postFabLongPressAction.name) ?? PostFabAction.openFab.name);

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
                                        description: AppLocalizations.of(context)!.expandOptions,
                                        value: null,
                                        semanticLabel: """${AppLocalizations.of(context)!.expandOptions}
                                            ${feedFabSinglePressAction == FeedFabAction.openFab ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.openFab ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.more_horiz_rounded,
                                        iconDisabled: Icons.more_horiz_rounded,
                                        onToggle: (_) {},
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.openFab)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.openFab)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.openFab),
                                        onTap: () => showFeedFabActionPicker(FeedFabAction.openFab),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableBackToTop.label,
                                        value: enableBackToTop,
                                        semanticLabel: """${LocalSettings.enableBackToTop.label}
                                            ${feedFabSinglePressAction == FeedFabAction.backToTop ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.backToTop ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.arrow_upward,
                                        iconDisabled: Icons.arrow_upward,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableBackToTop, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.backToTop)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.backToTop)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.backToTop),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableSubscriptions.label,
                                        value: enableSubscriptions,
                                        semanticLabel: """${LocalSettings.enableSubscriptions.label}
                                            ${feedFabSinglePressAction == FeedFabAction.subscriptions ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.subscriptions ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.people_rounded,
                                        iconDisabled: Icons.people_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableSubscriptions, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.subscriptions)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.subscriptions)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.subscriptions),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableChangeSort.label,
                                        value: enableChangeSort,
                                        semanticLabel: """${LocalSettings.enableChangeSort.label}
                                            ${feedFabSinglePressAction == FeedFabAction.changeSort ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.changeSort ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.sort_rounded,
                                        iconDisabled: Icons.sort_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableChangeSort, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.changeSort)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.changeSort)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.changeSort),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableRefresh.label,
                                        value: enableRefresh,
                                        semanticLabel: """${LocalSettings.enableRefresh.label}
                                            ${feedFabSinglePressAction == FeedFabAction.refresh ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.refresh ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.refresh_rounded,
                                        iconDisabled: Icons.refresh_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableRefresh, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.refresh)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.refresh)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.refresh),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableDismissRead.label,
                                        value: enableDismissRead,
                                        semanticLabel: """${LocalSettings.enableDismissRead.label}
                                            ${feedFabSinglePressAction == FeedFabAction.dismissRead ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.dismissRead ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.clear_all_rounded,
                                        iconDisabled: Icons.clear_all_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableDismissRead, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.dismissRead)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.dismissRead)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.dismissRead),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.enableNewPost.label,
                                        value: enableNewPost,
                                        semanticLabel: """${LocalSettings.enableNewPost.label}
                                            ${feedFabSinglePressAction == FeedFabAction.newPost ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${feedFabLongPressAction == FeedFabAction.newPost ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.add_rounded,
                                        iconDisabled: Icons.add_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.enableNewPost, value),
                                        additionalWidgets: [
                                          if (feedFabSinglePressAction == FeedFabAction.newPost)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (feedFabLongPressAction == FeedFabAction.newPost)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showFeedFabActionPicker(FeedFabAction.newPost),
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
                                        description: AppLocalizations.of(context)!.expandOptions,
                                        value: null,
                                        semanticLabel: """${AppLocalizations.of(context)!.expandOptions}
                                            ${postFabSinglePressAction == PostFabAction.openFab ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${postFabLongPressAction == PostFabAction.openFab ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.more_horiz_rounded,
                                        iconDisabled: Icons.more_horiz_rounded,
                                        onToggle: (_) {},
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == PostFabAction.openFab)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == PostFabAction.openFab)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(PostFabAction.openFab),
                                        onTap: () => showPostFabActionPicker(PostFabAction.openFab),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.postFabEnableBackToTop.label,
                                        value: postFabEnableBackToTop,
                                        semanticLabel: """${LocalSettings.postFabEnableBackToTop.label}
                                            ${postFabSinglePressAction == PostFabAction.backToTop ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${postFabLongPressAction == PostFabAction.backToTop ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.arrow_upward,
                                        iconDisabled: Icons.arrow_upward,
                                        onToggle: (bool value) => setPreferences(LocalSettings.postFabEnableBackToTop, value),
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == PostFabAction.backToTop)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == PostFabAction.backToTop)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(PostFabAction.backToTop),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.postFabEnableChangeSort.label,
                                        value: postFabEnableChangeSort,
                                        semanticLabel: """${LocalSettings.postFabEnableChangeSort.label}
                                            ${postFabSinglePressAction == PostFabAction.changeSort ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${postFabLongPressAction == PostFabAction.changeSort ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.sort_rounded,
                                        iconDisabled: Icons.sort_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.postFabEnableChangeSort, value),
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == PostFabAction.changeSort)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == PostFabAction.changeSort)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(PostFabAction.changeSort),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.postFabEnableReplyToPost.label,
                                        value: postFabEnableReplyToPost,
                                        semanticLabel: """${LocalSettings.postFabEnableReplyToPost.label}
                                            ${postFabSinglePressAction == PostFabAction.replyToPost ? AppLocalizations.of(context)!.currentSinglePress : ''}
                                            ${postFabLongPressAction == PostFabAction.replyToPost ? AppLocalizations.of(context)!.currentLongPress : ''}""",
                                        iconEnabled: Icons.reply_rounded,
                                        iconDisabled: Icons.reply_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.postFabEnableReplyToPost, value),
                                        additionalWidgets: [
                                          if (postFabSinglePressAction == PostFabAction.replyToPost)
                                            const Icon(
                                              Icons.touch_app_outlined,
                                            ),
                                          if (postFabLongPressAction == PostFabAction.replyToPost)
                                            const Icon(
                                              Icons.touch_app_rounded,
                                            ),
                                        ],
                                        onLongPress: () => showPostFabActionPicker(PostFabAction.replyToPost),
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

  void showFeedFabActionPicker(FeedFabAction action) {
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
            setPreferences(LocalSettings.feedFabSinglePressAction, action);
          }
          if (value.payload == 'long') {
            setPreferences(LocalSettings.feedFabLongPressAction, action);
          }
        },
      ),
    );
  }

  void showPostFabActionPicker(PostFabAction action) {
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
            setPreferences(LocalSettings.postFabSinglePressAction, action);
          }
          if (value.payload == 'long') {
            setPreferences(LocalSettings.postFabLongPressAction, action);
          }
        },
      ),
    );
  }
}
