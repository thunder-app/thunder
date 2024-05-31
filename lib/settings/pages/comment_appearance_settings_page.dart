import 'dart:async';

import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/utils/constants.dart';

class CommentAppearanceSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const CommentAppearanceSettingsPage({super.key, this.settingToHighlight});

  @override
  State<CommentAppearanceSettingsPage> createState() => _CommentAppearanceSettingsPageState();
}

class _CommentAppearanceSettingsPageState extends State<CommentAppearanceSettingsPage> with SingleTickerProviderStateMixin {
  /// When toggled on, comments will show a row of actions to perform
  bool showCommentButtonActions = false;

  /// When toggled on, user instance is displayed alongside the display name/username
  bool commentShowUserInstance = false;

  /// When toggled on, user avatar is displayed to the left of the display name/username
  bool commentShowUserAvatar = false;

  /// When toggled on, comment scores will be combined instead of having separate upvotes and downvotes
  bool combineCommentScores = false;

  /// Indicates the style of the nested comment indicator
  NestedCommentIndicatorStyle nestedIndicatorStyle = DEFAULT_NESTED_COMMENT_INDICATOR_STYLE;

  /// Indicates the color of the nested comment indicator
  NestedCommentIndicatorColor nestedIndicatorColor = DEFAULT_NESTED_COMMENT_INDICATOR_COLOR;

  /// Controller to manage expandable state for comment preview
  ExpandableController expandableController = ExpandableController();

  /// An example comment for use with comment preview
  Future<CommentViewTree>? exampleCommentViewTree;

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  /// Initialize the settings from the user's shared preferences
  Future<void> initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;
      commentShowUserInstance = prefs.getBool(LocalSettings.commentShowUserInstance.name) ?? false;
      commentShowUserAvatar = prefs.getBool(LocalSettings.commentShowUserAvatar.name) ?? false;
      combineCommentScores = prefs.getBool(LocalSettings.combineCommentScores.name) ?? false;
      nestedIndicatorStyle = NestedCommentIndicatorStyle.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorStyle.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
      nestedIndicatorColor = NestedCommentIndicatorColor.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorColor.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);
    });

    getExampleComment();
  }

  /// Given an attribute and the associated value, update the setting in the shared preferences
  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case LocalSettings.showCommentActionButtons:
        await prefs.setBool(LocalSettings.showCommentActionButtons.name, value);
        setState(() => showCommentButtonActions = value);
        break;
      case LocalSettings.commentShowUserInstance:
        await prefs.setBool(LocalSettings.commentShowUserInstance.name, value);
        setState(() => commentShowUserInstance = value);
      case LocalSettings.commentShowUserAvatar:
        await prefs.setBool(LocalSettings.commentShowUserAvatar.name, value);
        setState(() => commentShowUserAvatar = value);
      case LocalSettings.combineCommentScores:
        await prefs.setBool(LocalSettings.combineCommentScores.name, value);
        setState(() => combineCommentScores = value);
        break;
      case LocalSettings.nestedCommentIndicatorStyle:
        await prefs.setString(LocalSettings.nestedCommentIndicatorStyle.name, value);
        setState(() => nestedIndicatorStyle = NestedCommentIndicatorStyle.values.byName(value ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name));
        break;
      case LocalSettings.nestedCommentIndicatorColor:
        await prefs.setString(LocalSettings.nestedCommentIndicatorColor.name, value);
        setState(() => nestedIndicatorColor = NestedCommentIndicatorColor.values.byName(value ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name));
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  /// Reset the comment preferences to their defaults
  void resetCommentPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    await prefs.remove(LocalSettings.showCommentActionButtons.name);
    await prefs.remove(LocalSettings.combineCommentScores.name);
    await prefs.remove(LocalSettings.nestedCommentIndicatorStyle.name);
    await prefs.remove(LocalSettings.nestedCommentIndicatorColor.name);
    await prefs.remove(LocalSettings.commentShowUserInstance.name);
    await prefs.remove(LocalSettings.commentShowUserAvatar.name);

    await initPreferences();

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  /// Generates an example comment to show in the comment preview
  void getExampleComment() {
    CommentView commentView = createExampleComment(
      id: 1,
      commentCreatorId: 1,
      path: '0.1',
      personName: 'Thunder',
      commentPublished: DateTime.now().subtract(const Duration(minutes: 30)),
      commentUpvotes: 1100,
      commentDownvotes: 0,
      commentScore: 1100,
      commentContent: 'Thunder is an **open source**, cross platform app for exploring Lemmy communities!',
    );

    CommentView replyCommentViewFirst = createExampleComment(
      id: 3,
      commentCreatorId: 3,
      path: '0.1.3',
      personName: 'Cloud',
      commentPublished: DateTime.now().subtract(const Duration(minutes: 15)),
      commentUpvotes: 1,
      commentDownvotes: 0,
      commentScore: 1,
      commentContent: 'Available on Android and iOS platforms.',
      isPersonAdmin: true,
    );

    CommentView replyCommentViewSecond = createExampleComment(
      id: 2,
      commentCreatorId: 2,
      path: '0.1.2',
      personName: 'Lightning',
      commentContent: 'Check out [GitHub](https://github.com/thunder-app/thunder) for more details.',
      commentChildCount: 20,
      isBotAccount: true,
    );

    List<CommentViewTree> commentViewTrees = buildCommentViewTree([commentView, replyCommentViewFirst, replyCommentViewSecond]);

    if (context.mounted) {
      setState(() {
        exampleCommentViewTree = Future.value(commentViewTrees.first);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPreferences();

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
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.comments),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.restart_alt_rounded,
                  semanticLabel: l10n.resetCommentPreferences,
                ),
                onPressed: () {
                  showThunderDialog(
                    context: context,
                    title: l10n.resetPreferences,
                    contentText: l10n.confirmResetCommentPreferences,
                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                    secondaryButtonText: l10n.cancel,
                    onPrimaryButtonPressed: (dialogContext, _) {
                      resetCommentPreferences();
                      Navigator.of(dialogContext).pop();
                    },
                    primaryButtonText: l10n.reset,
                  );
                },
              ),
              const SizedBox(width: 8.0),
            ],
          ),
          // Comment Preview
          SliverToBoxAdapter(
            child: ExpandableNotifier(
              controller: expandableController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.preview,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            expandableController.expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            semanticLabel: expandableController.expanded ? l10n.collapseCommentPreview : l10n.expandCommentPreview,
                          ),
                          onPressed: () {
                            expandableController.toggle();
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      l10n.commentPreview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Expandable(
                    controller: expandableController,
                    collapsed: Container(),
                    expanded: FutureBuilder<CommentViewTree>(
                      future: exampleCommentViewTree,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) return Container();

                        return BlocProvider(
                          create: (context) => PostBloc(),
                          child: IgnorePointer(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                CommentCard(
                                  commentViewTree: snapshot.data!,
                                  onSaveAction: (int commentId, bool save) => {},
                                  onVoteAction: (int commentId, int voteType) => {},
                                  onCollapseCommentChange: (int commentId, bool collapsed) => {},
                                  onDeleteAction: (int commentId, bool deleted) => {},
                                  onReportAction: (int commentId) => {},
                                  onReplyEditAction: (CommentView commentView, bool isEdit) => {},
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.generalSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          // Comment Settings
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showCommentActionButtons,
              value: showCommentButtonActions,
              iconEnabled: Icons.mode_comment_rounded,
              iconDisabled: Icons.mode_comment_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.showCommentActionButtons, value),
              highlightKey: settingToHighlightKey,
              setting: LocalSettings.showCommentActionButtons,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.combineCommentScoresLabel,
              value: combineCommentScores,
              iconEnabled: Icons.onetwothree_rounded,
              iconDisabled: Icons.onetwothree_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.combineCommentScores, value),
              highlightKey: settingToHighlightKey,
              setting: LocalSettings.combineCommentScores,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.commentShowUserInstance,
              value: commentShowUserInstance,
              iconEnabled: Icons.dns_sharp,
              iconDisabled: Icons.dns_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.commentShowUserInstance, value),
              highlightKey: settingToHighlightKey,
              setting: LocalSettings.commentShowUserInstance,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.commentShowUserAvatar,
              value: commentShowUserAvatar,
              iconEnabled: Icons.account_circle,
              iconDisabled: Icons.account_circle_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.commentShowUserAvatar, value),
              highlightKey: settingToHighlightKey,
              setting: LocalSettings.commentShowUserAvatar,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.nestedCommentIndicatorStyle,
              value: ListPickerItem(label: nestedIndicatorStyle.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorStyle),
              options: [
                ListPickerItem(icon: Icons.view_list_rounded, label: NestedCommentIndicatorStyle.thick.value, payload: NestedCommentIndicatorStyle.thick),
                ListPickerItem(icon: Icons.format_list_bulleted_rounded, label: NestedCommentIndicatorStyle.thin.value, payload: NestedCommentIndicatorStyle.thin),
              ],
              icon: Icons.format_list_bulleted_rounded,
              onChanged: (value) async => setPreferences(LocalSettings.nestedCommentIndicatorStyle, value.payload.name),
              highlightKey: settingToHighlightKey,
              setting: LocalSettings.nestedCommentIndicatorStyle,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.nestedCommentIndicatorColor,
              value: ListPickerItem(label: nestedIndicatorColor.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorColor),
              options: [
                ListPickerItem(icon: Icons.invert_colors_on_rounded, label: NestedCommentIndicatorColor.colorful.value, payload: NestedCommentIndicatorColor.colorful),
                ListPickerItem(icon: Icons.invert_colors_off_rounded, label: NestedCommentIndicatorColor.monochrome.value, payload: NestedCommentIndicatorColor.monochrome),
              ],
              icon: Icons.color_lens_outlined,
              onChanged: (value) async => setPreferences(LocalSettings.nestedCommentIndicatorColor, value.payload.name),
              highlightKey: settingToHighlightKey,
              setting: LocalSettings.nestedCommentIndicatorColor,
              highlightedSetting: settingToHighlight,
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsListTile(
              icon: Icons.alternate_email_rounded,
              description: l10n.usernameFormattingRedirect,
              widget: const SizedBox(
                height: 42.0,
                child: Icon(Icons.chevron_right_rounded),
              ),
              onTap: () {
                GoRouter.of(context).push(
                  SETTINGS_APPEARANCE_THEMES_PAGE,
                  extra: [
                    context.read<ThunderBloc>(),
                    LocalSettings.userStyle,
                  ],
                );
              },
              highlightKey: settingToHighlightKey,
              setting: null,
              highlightedSetting: settingToHighlight,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
