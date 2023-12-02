import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/comment.dart';
import 'package:thunder/utils/constants.dart';

class CommentAppearanceSettingsPage extends StatefulWidget {
  const CommentAppearanceSettingsPage({super.key});

  @override
  State<CommentAppearanceSettingsPage> createState() => _CommentAppearanceSettingsPageState();
}

class _CommentAppearanceSettingsPageState extends State<CommentAppearanceSettingsPage> with SingleTickerProviderStateMixin {
  /// When toggled on, comments will show a row of actions to perform
  bool showCommentButtonActions = false;

  /// when toogled on, comments will show intsnace of origin
  bool showOriginInstance = false;

  /// Indicates the style of the nested comment indicator
  NestedCommentIndicatorStyle nestedIndicatorStyle = DEFAULT_NESTED_COMMENT_INDICATOR_STYLE;

  /// Indicates the color of the nested comment indicator
  NestedCommentIndicatorColor nestedIndicatorColor = DEFAULT_NESTED_COMMENT_INDICATOR_COLOR;

  /// Controller to manage expandable state for comment preview
  ExpandableController expandableController = ExpandableController();

  /// An example comment for use with comment preview
  Future<CommentViewTree>? exampleCommentViewTree;

  /// Initialize the settings from the user's shared preferences
  Future<void> initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;
      showOriginInstance = prefs.getBool(LocalSettings.showOriginInstance.name) ?? false;
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
      case LocalSettings.showOriginInstance:
        await prefs.setBool(LocalSettings.showOriginInstance.name, value);
        setState(() => showOriginInstance = value);
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
    await prefs.remove(LocalSettings.nestedCommentIndicatorStyle.name);
    await prefs.remove(LocalSettings.nestedCommentIndicatorColor.name);
    await prefs.remove(LocalSettings.showOriginInstance.name);

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
    WidgetsBinding.instance.addPostFrameCallback((_) => initPreferences());
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
                icon: const Icon(Icons.restart_alt_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.resetPreferences),
                      content: Text(l10n.confirmResetCommentPreferences),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            resetCommentPreferences();
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.reset),
                        ),
                      ],
                    ),
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
                                  now: DateTime.now(),
                                  commentViewTree: snapshot.data!,
                                  onSaveAction: (int commentId, bool save) => {},
                                  onVoteAction: (int commentId, int voteType) => {},
                                  onCollapseCommentChange: (int commentId, bool collapsed) => {},
                                  onDeleteAction: (int commentId, bool deleted) => {},
                                  onReportAction: (int commentId) => {},
                                  onReplyEditAction: (CommentView commentView, bool isEdit) => {},
                                  moderators: const [],
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showCommentActionButtons.label,
                value: showCommentButtonActions,
                iconEnabled: Icons.mode_comment_rounded,
                iconDisabled: Icons.mode_comment_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.showCommentActionButtons, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showOriginInstance.label,
                value: showOriginInstance,
                iconEnabled: Icons.dns_sharp,
                iconDisabled: Icons.dns_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.showOriginInstance, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: LocalSettings.nestedCommentIndicatorStyle.label,
                value: ListPickerItem(label: nestedIndicatorStyle.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorStyle),
                options: [
                  ListPickerItem(icon: Icons.view_list_rounded, label: NestedCommentIndicatorStyle.thick.value, payload: NestedCommentIndicatorStyle.thick),
                  ListPickerItem(icon: Icons.format_list_bulleted_rounded, label: NestedCommentIndicatorStyle.thin.value, payload: NestedCommentIndicatorStyle.thin),
                ],
                icon: Icons.format_list_bulleted_rounded,
                onChanged: (value) => setPreferences(LocalSettings.nestedCommentIndicatorStyle, value.payload.name),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: LocalSettings.nestedCommentIndicatorColor.label,
                value: ListPickerItem(label: nestedIndicatorColor.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorColor),
                options: [
                  ListPickerItem(icon: Icons.invert_colors_on_rounded, label: NestedCommentIndicatorColor.colorful.value, payload: NestedCommentIndicatorColor.colorful),
                  ListPickerItem(icon: Icons.invert_colors_off_rounded, label: NestedCommentIndicatorColor.monochrome.value, payload: NestedCommentIndicatorColor.monochrome),
                ],
                icon: Icons.color_lens_outlined,
                onChanged: (value) => setPreferences(LocalSettings.nestedCommentIndicatorColor, value.payload.name),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
