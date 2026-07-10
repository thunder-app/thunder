import 'dart:async';

import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/settings/presentation/utils/setting_link_utils.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

class FabSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const FabSettingsPage({super.key, this.settingToHighlight});

  @override
  State<FabSettingsPage> createState() => _FabSettingsPage();
}

class _FabSettingsPage extends State<FabSettingsPage> with TickerProviderStateMixin {
  /// When enabled, the FAB for the feed/community will be shown
  bool enableFeedsFab = true;

  /// When enabled, the FAB for the post will be shown
  bool enablePostsFab = true;

  /// FAB action which scrolls the user to the top of the page
  bool enableBackToTop = true;

  /// FAB action which opens the main sidebar
  bool enableSubscriptions = true;

  /// FAB action to open the sort bottom sheet
  bool enableChangeSort = true;

  /// FAB action which refreshes the current feed
  bool enableRefresh = true;

  /// FAB action which dismisses currently read posts from the feed
  bool enableDismissRead = true;

  /// FAB action which navigates to the create post page screen
  bool enableNewPost = true;

  /// Post FAB action which scrolls the user to the top of the page
  bool postFabEnableBackToTop = true;

  /// Post FAB action to open the sort bottom sheet
  bool postFabEnableChangeSort = true;

  /// Post FAB action which opens the create comment page
  bool postFabEnableReplyToPost = true;

  /// Post FAB action which refreshes the current post
  bool postFabEnableRefresh = true;

  /// Post FAB action which opens the search dialog
  bool postFabEnableSearch = true;

  /// The main single press action for the feed FAB
  FeedFabAction feedFabSinglePressAction = FeedFabAction.newPost;

  /// The secondary long press action for the feed FAB
  FeedFabAction feedFabLongPressAction = FeedFabAction.openFab;

  /// The main single press action for the post FAB
  PostFabAction postFabSinglePressAction = PostFabAction.replyToPost;

  /// The secondary long press action for the post FAB
  PostFabAction postFabLongPressAction = PostFabAction.openFab;

  /// Controller to manage expandable state for FAB information
  ExpandableController expandableController = ExpandableController(initialExpanded: true);

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  void setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = const UserPreferencesStore();

    switch (attribute) {
      case LocalSettings.enableFeedsFab:
        await prefs.setSetting(LocalSettings.enableFeedsFab, value);
        setState(() => enableFeedsFab = value);
        break;
      case LocalSettings.enablePostsFab:
        await prefs.setSetting(LocalSettings.enablePostsFab, value);
        setState(() => enablePostsFab = value);
        break;

      case LocalSettings.enableBackToTop:
        await prefs.setSetting(LocalSettings.enableBackToTop, value);
        setState(() => enableBackToTop = value);
        break;
      case LocalSettings.enableSubscriptions:
        await prefs.setSetting(LocalSettings.enableSubscriptions, value);
        setState(() => enableSubscriptions = value);
        break;
      case LocalSettings.enableChangeSort:
        await prefs.setSetting(LocalSettings.enableChangeSort, value);
        setState(() => enableChangeSort = value);
        break;
      case LocalSettings.enableRefresh:
        await prefs.setSetting(LocalSettings.enableRefresh, value);
        setState(() => enableRefresh = value);
        break;
      case LocalSettings.enableDismissRead:
        await prefs.setSetting(LocalSettings.enableDismissRead, value);
        setState(() => enableDismissRead = value);
        break;
      case LocalSettings.enableNewPost:
        await prefs.setSetting(LocalSettings.enableNewPost, value);
        setState(() => enableNewPost = value);
        break;

      case LocalSettings.postFabEnableBackToTop:
        await prefs.setSetting(LocalSettings.postFabEnableBackToTop, value);
        setState(() => postFabEnableBackToTop = value);
        break;
      case LocalSettings.postFabEnableChangeSort:
        await prefs.setSetting(LocalSettings.postFabEnableChangeSort, value);
        setState(() => postFabEnableChangeSort = value);
        break;
      case LocalSettings.postFabEnableReplyToPost:
        await prefs.setSetting(LocalSettings.postFabEnableReplyToPost, value);
        setState(() => postFabEnableReplyToPost = value);
        break;
      case LocalSettings.postFabEnableRefresh:
        await prefs.setSetting(LocalSettings.postFabEnableRefresh, value);
        setState(() => postFabEnableRefresh = value);
        break;
      case LocalSettings.postFabEnableSearch:
        await prefs.setSetting(LocalSettings.postFabEnableSearch, value);
        setState(() => postFabEnableSearch = value);
        break;

      case LocalSettings.feedFabSinglePressAction:
        await prefs.setSetting(LocalSettings.feedFabSinglePressAction, (value as FeedFabAction).name);
        setState(() => feedFabSinglePressAction = value);
        break;
      case LocalSettings.feedFabLongPressAction:
        await prefs.setSetting(LocalSettings.feedFabLongPressAction, (value as FeedFabAction).name);
        setState(() => feedFabLongPressAction = value);
        break;
      case LocalSettings.postFabSinglePressAction:
        await prefs.setSetting(LocalSettings.postFabSinglePressAction, (value as PostFabAction).name);
        setState(() => postFabSinglePressAction = value);
        break;
      case LocalSettings.postFabLongPressAction:
        await prefs.setSetting(LocalSettings.postFabLongPressAction, (value as PostFabAction).name);
        setState(() => postFabLongPressAction = value);
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<ThunderCubit>().reload();
      context.read<FabPreferencesCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = const UserPreferencesStore();

    setState(() {
      enableFeedsFab = prefs.getLocalSetting<bool>(LocalSettings.enableFeedsFab) ?? true;
      enablePostsFab = prefs.getLocalSetting<bool>(LocalSettings.enablePostsFab) ?? true;

      enableBackToTop = prefs.getLocalSetting<bool>(LocalSettings.enableBackToTop) ?? true;
      enableSubscriptions = prefs.getLocalSetting<bool>(LocalSettings.enableSubscriptions) ?? true;
      enableChangeSort = prefs.getLocalSetting<bool>(LocalSettings.enableChangeSort) ?? true;
      enableRefresh = prefs.getLocalSetting<bool>(LocalSettings.enableRefresh) ?? true;
      enableDismissRead = prefs.getLocalSetting<bool>(LocalSettings.enableDismissRead) ?? true;
      enableNewPost = prefs.getLocalSetting<bool>(LocalSettings.enableNewPost) ?? true;

      postFabEnableBackToTop = prefs.getLocalSetting<bool>(LocalSettings.postFabEnableBackToTop) ?? true;
      postFabEnableChangeSort = prefs.getLocalSetting<bool>(LocalSettings.postFabEnableChangeSort) ?? true;
      postFabEnableReplyToPost = prefs.getLocalSetting<bool>(LocalSettings.postFabEnableReplyToPost) ?? true;
      postFabEnableRefresh = prefs.getLocalSetting<bool>(LocalSettings.postFabEnableRefresh) ?? true;
      postFabEnableSearch = prefs.getLocalSetting<bool>(LocalSettings.postFabEnableSearch) ?? true;

      feedFabSinglePressAction = FeedFabAction.values.byName(prefs.getLocalSetting<String>(LocalSettings.feedFabSinglePressAction) ?? FeedFabAction.newPost.name);
      feedFabLongPressAction = FeedFabAction.values.byName(prefs.getLocalSetting<String>(LocalSettings.feedFabLongPressAction) ?? FeedFabAction.openFab.name);
      postFabSinglePressAction = PostFabAction.values.byName(prefs.getLocalSetting<String>(LocalSettings.postFabSinglePressAction) ?? PostFabAction.replyToPost.name);
      postFabLongPressAction = PostFabAction.values.byName(prefs.getLocalSetting<String>(LocalSettings.postFabLongPressAction) ?? PostFabAction.openFab.name);
    });
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  /// Animation for collapsing content
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.floatingActionButton), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              ExpandableNotifier(
                controller: expandableController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(l10n.information, style: theme.textTheme.titleMedium)),
                          IconButton(
                            icon: Icon(
                              expandableController.expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              semanticLabel: expandableController.expanded ? l10n.collapseInformation : l10n.expandInformation,
                            ),
                            onPressed: () {
                              expandableController.toggle();
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                    Expandable(
                      controller: expandableController,
                      collapsed: Container(),
                      expanded: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonMarkdownBody(body: l10n.floatingActionButtonInformation),
                            const SizedBox(height: 8.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                                  child: Icon(Icons.touch_app_outlined, size: 20),
                                ),
                                CommonMarkdownBody(body: l10n.floatingActionButtonSinglePressDescription),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Icon(Icons.touch_app_rounded, size: 20),
                                ),
                                CommonMarkdownBody(body: l10n.floatingActionButtonLongPressDescription),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Text(l10n.feed, style: theme.textTheme.titleMedium),
              ),
              ThunderToggleOption(
                  title: l10n.enableFeedFab,
                  value: enableFeedsFab,
                  onChanged: (bool value) => setPreferences(LocalSettings.enableFeedsFab, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.enableFeedsFab),
                  highlighted: settingToHighlight == LocalSettings.enableFeedsFab),
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
                    ? Column(
                        children: [
                          ThunderToggleOption(
                              title: l10n.expandOptions,
                              value: null,
                              semanticLabel: """${l10n.expandOptions}
                                          ${feedFabSinglePressAction == FeedFabAction.openFab ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.openFab ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.more_horiz_rounded,
                              iconDisabled: Icons.more_horiz_rounded,
                              onChanged: (_) {},
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.openFab) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.openFab) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.openFab),
                              onTap: () => showFeedFabActionPicker(FeedFabAction.openFab),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: false),
                          ThunderToggleOption(
                              title: l10n.backToTop,
                              value: enableBackToTop,
                              semanticLabel: """${l10n.backToTop}
                                          ${feedFabSinglePressAction == FeedFabAction.backToTop ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.backToTop ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.arrow_upward,
                              iconDisabled: Icons.arrow_upward,
                              onChanged: (bool value) => setPreferences(LocalSettings.enableBackToTop, value),
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.backToTop) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.backToTop) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.backToTop),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.enableBackToTop),
                          ThunderToggleOption(
                              title: l10n.subscriptions,
                              value: enableSubscriptions,
                              semanticLabel: """${l10n.subscriptions}
                                          ${feedFabSinglePressAction == FeedFabAction.subscriptions ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.subscriptions ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.people_rounded,
                              iconDisabled: Icons.people_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.enableSubscriptions, value),
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.subscriptions) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.subscriptions) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.subscriptions),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.enableSubscriptions),
                          ThunderToggleOption(
                              title: l10n.changeSort,
                              value: enableChangeSort,
                              semanticLabel: """${l10n.changeSort}
                                          ${feedFabSinglePressAction == FeedFabAction.changeSort ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.changeSort ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.sort_rounded,
                              iconDisabled: Icons.sort_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.enableChangeSort, value),
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.changeSort) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.changeSort) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.changeSort),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.enableChangeSort),
                          ThunderToggleOption(
                              title: l10n.refresh,
                              value: enableRefresh,
                              semanticLabel: """${l10n.refresh}
                                          ${feedFabSinglePressAction == FeedFabAction.refresh ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.refresh ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.refresh_rounded,
                              iconDisabled: Icons.refresh_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.enableRefresh, value),
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.refresh) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.refresh) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.refresh),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.enableRefresh),
                          ThunderToggleOption(
                              title: l10n.dismissRead,
                              value: enableDismissRead,
                              semanticLabel: """${l10n.dismissRead}
                                          ${feedFabSinglePressAction == FeedFabAction.dismissRead ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.dismissRead ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.clear_all_rounded,
                              iconDisabled: Icons.clear_all_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.enableDismissRead, value),
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.dismissRead) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.dismissRead) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.dismissRead),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.enableDismissRead),
                          ThunderToggleOption(
                              title: l10n.createPost,
                              value: enableNewPost,
                              semanticLabel: """${l10n.createPost}
                                          ${feedFabSinglePressAction == FeedFabAction.newPost ? l10n.currentSinglePress : ''}
                                          ${feedFabLongPressAction == FeedFabAction.newPost ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.add_rounded,
                              iconDisabled: Icons.add_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.enableNewPost, value),
                              additionalTrailing: [
                                if (feedFabSinglePressAction == FeedFabAction.newPost) const Icon(Icons.touch_app_outlined),
                                if (feedFabLongPressAction == FeedFabAction.newPost) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showFeedFabActionPicker(FeedFabAction.newPost),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.enableNewPost),
                        ],
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Text(l10n.posts, style: theme.textTheme.titleMedium),
              ),
              ThunderToggleOption(
                  title: l10n.enablePostFab,
                  value: enablePostsFab,
                  onChanged: (bool value) => setPreferences(LocalSettings.enablePostsFab, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.enablePostsFab),
                  highlighted: settingToHighlight == LocalSettings.enablePostsFab),
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
                    ? Column(
                        children: [
                          ThunderToggleOption(
                              title: l10n.expandOptions,
                              value: null,
                              semanticLabel: """${l10n.expandOptions}
                                          ${postFabSinglePressAction == PostFabAction.openFab ? l10n.currentSinglePress : ''}
                                          ${postFabLongPressAction == PostFabAction.openFab ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.more_horiz_rounded,
                              iconDisabled: Icons.more_horiz_rounded,
                              onChanged: (_) {},
                              additionalTrailing: [
                                if (postFabSinglePressAction == PostFabAction.openFab) const Icon(Icons.touch_app_outlined),
                                if (postFabLongPressAction == PostFabAction.openFab) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showPostFabActionPicker(PostFabAction.openFab),
                              onTap: () => showPostFabActionPicker(PostFabAction.openFab),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: false),
                          ThunderToggleOption(
                              title: l10n.search,
                              value: postFabEnableSearch,
                              semanticLabel: """${l10n.search}
                                          ${postFabSinglePressAction == PostFabAction.search ? l10n.currentSinglePress : ''}
                                          ${postFabLongPressAction == PostFabAction.search ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.search_rounded,
                              iconDisabled: Icons.search_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.postFabEnableSearch, value),
                              additionalTrailing: [
                                if (postFabSinglePressAction == PostFabAction.search) const Icon(Icons.touch_app_outlined),
                                if (postFabLongPressAction == PostFabAction.search) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showPostFabActionPicker(PostFabAction.search),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.postFabEnableSearch),
                          ThunderToggleOption(
                              title: l10n.backToTop,
                              value: postFabEnableBackToTop,
                              semanticLabel: """${l10n.backToTop}
                                          ${postFabSinglePressAction == PostFabAction.backToTop ? l10n.currentSinglePress : ''}
                                          ${postFabLongPressAction == PostFabAction.backToTop ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.arrow_upward,
                              iconDisabled: Icons.arrow_upward,
                              onChanged: (bool value) => setPreferences(LocalSettings.postFabEnableBackToTop, value),
                              additionalTrailing: [
                                if (postFabSinglePressAction == PostFabAction.backToTop) const Icon(Icons.touch_app_outlined),
                                if (postFabLongPressAction == PostFabAction.backToTop) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showPostFabActionPicker(PostFabAction.backToTop),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.postFabEnableBackToTop),
                          ThunderToggleOption(
                              title: l10n.changeSort,
                              value: postFabEnableChangeSort,
                              semanticLabel: """${l10n.changeSort}
                                          ${postFabSinglePressAction == PostFabAction.changeSort ? l10n.currentSinglePress : ''}
                                          ${postFabLongPressAction == PostFabAction.changeSort ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.sort_rounded,
                              iconDisabled: Icons.sort_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.postFabEnableChangeSort, value),
                              additionalTrailing: [
                                if (postFabSinglePressAction == PostFabAction.changeSort) const Icon(Icons.touch_app_outlined),
                                if (postFabLongPressAction == PostFabAction.changeSort) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showPostFabActionPicker(PostFabAction.changeSort),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.postFabEnableChangeSort),
                          ThunderToggleOption(
                              title: l10n.replyToPost,
                              value: postFabEnableReplyToPost,
                              semanticLabel: """${l10n.replyToPost}
                                          ${postFabSinglePressAction == PostFabAction.replyToPost ? l10n.currentSinglePress : ''}
                                          ${postFabLongPressAction == PostFabAction.replyToPost ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.reply_rounded,
                              iconDisabled: Icons.reply_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.postFabEnableReplyToPost, value),
                              additionalTrailing: [
                                if (postFabSinglePressAction == PostFabAction.replyToPost) const Icon(Icons.touch_app_outlined),
                                if (postFabLongPressAction == PostFabAction.replyToPost) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showPostFabActionPicker(PostFabAction.replyToPost),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.postFabEnableReplyToPost),
                          ThunderToggleOption(
                              title: l10n.refresh,
                              value: postFabEnableRefresh,
                              semanticLabel: """${l10n.refresh}
                                          ${postFabSinglePressAction == PostFabAction.refresh ? l10n.currentSinglePress : ''}
                                          ${postFabLongPressAction == PostFabAction.refresh ? l10n.currentLongPress : ''}""",
                              iconEnabled: Icons.refresh_rounded,
                              iconDisabled: Icons.refresh_rounded,
                              onChanged: (bool value) => setPreferences(LocalSettings.postFabEnableRefresh, value),
                              additionalTrailing: [
                                if (postFabSinglePressAction == PostFabAction.refresh) const Icon(Icons.touch_app_outlined),
                                if (postFabLongPressAction == PostFabAction.refresh) const Icon(Icons.touch_app_rounded),
                              ],
                              onLongPress: () => showPostFabActionPicker(PostFabAction.refresh),
                              padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                              highlightKey: settingToHighlightKey,
                              highlighted: settingToHighlight == LocalSettings.postFabEnableRefresh),
                        ],
                      )
                    : null,
              ),
              SizedBox(height: 80)
            ],
          ),
        ],
      ),
    );
  }

  void showFeedFabActionPicker(FeedFabAction action) {
    final l10n = GlobalContext.l10n;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ThunderBottomSheetListPicker(
        title: l10n.setAction,
        items: [
          ThunderListPickerItem(label: l10n.setShortPress, payload: 'short', icon: Icons.touch_app_outlined),
          ThunderListPickerItem(label: l10n.setLongPress, payload: 'long', icon: Icons.touch_app_rounded),
        ],
        onSelect: (value) async {
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
    final l10n = GlobalContext.l10n;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ThunderBottomSheetListPicker(
        title: l10n.setAction,
        items: [
          ThunderListPickerItem(label: l10n.setShortPress, payload: 'short', icon: Icons.touch_app_outlined),
          ThunderListPickerItem(label: l10n.setLongPress, payload: 'long', icon: Icons.touch_app_rounded),
        ],
        onSelect: (value) async {
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
