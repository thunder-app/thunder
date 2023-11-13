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
  /// -------------------------- Feed Related Settings --------------------------
  bool showCommentButtonActions = false;
  NestedCommentIndicatorStyle nestedIndicatorStyle = DEFAULT_NESTED_COMMENT_INDICATOR_STYLE;
  NestedCommentIndicatorColor nestedIndicatorColor = DEFAULT_NESTED_COMMENT_INDICATOR_COLOR;

  ExpandableController expandableController = ExpandableController();

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      /// -------------------------- Feed Related Settings --------------------------
      case LocalSettings.showCommentActionButtons:
        await prefs.setBool(LocalSettings.showCommentActionButtons.name, value);
        setState(() => showCommentButtonActions = value);
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

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;
      nestedIndicatorStyle = NestedCommentIndicatorStyle.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorStyle.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
      nestedIndicatorColor = NestedCommentIndicatorColor.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorColor.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);
    });
  }

  Future<CommentViewTree> getExampleComment() {
    CommentView commentView = createExampleComment(
      personName: 'Thunder',
      commentPublished: DateTime.now().subtract(const Duration(minutes: 30)),
      commentUpvotes: 1100,
      commentDownvotes: 0,
      commentContent: 'Thunder is an **open source**, cross platform app for exploring Lemmy communities!',
    );

    CommentView replyCommentViewFirst = createExampleComment(
      id: 3,
      path: '0.1.3',
      personName: 'Cloud',
      commentPublished: DateTime.now().subtract(const Duration(minutes: 15)),
      commentCreatorId: 3,
      commentDownvotes: 0,
      commentContent: 'Available on Android and iOS platforms.',
      isPersonAdmin: true,
    );

    CommentView replyCommentViewSecond = createExampleComment(
      id: 2,
      path: '0.1.2',
      personName: 'Lightning',
      commentCreatorId: 2,
      isBotAccount: true,
      commentContent: 'Check out [GitHub](https://github.com/thunder-app/thunder) for more details.',
      commentChildCount: 20,
    );

    List<CommentViewTree> commentViewTrees = buildCommentViewTree([commentView, replyCommentViewFirst, replyCommentViewSecond]);
    return Future.delayed(Duration.zero, () => commentViewTrees.first);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.comments), centerTitle: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpandableNotifier(
                    controller: expandableController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Preview',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: theme.textTheme.titleLarge!.fontSize! - 3.0,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  expandableController.expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                  semanticLabel: expandableController.expanded ? l10n.collapsePostPreview : l10n.expandPostPreview,
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
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            'Show a preview of the comments with the given settings',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Expandable(
                          controller: expandableController,
                          collapsed: Container(),
                          expanded: FutureBuilder<CommentViewTree>(
                            future: getExampleComment(),
                            builder: (context, snapshot) {
                              if (snapshot.data == null) return Container();

                              return BlocProvider(
                                create: (context) => PostBloc(),
                                child: IgnorePointer(
                                  child: ListView(
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
                                        moderators: [],
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
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    child: Text('General Settings', style: theme.textTheme.titleMedium),
                  ),
                  ToggleOption(
                    description: LocalSettings.showCommentActionButtons.label,
                    value: showCommentButtonActions,
                    iconEnabled: Icons.mode_comment_rounded,
                    iconDisabled: Icons.mode_comment_outlined,
                    onToggle: (bool value) => setPreferences(LocalSettings.showCommentActionButtons, value),
                  ),
                  ListOption(
                    description: LocalSettings.nestedCommentIndicatorStyle.label,
                    value: ListPickerItem(label: nestedIndicatorStyle.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorStyle),
                    options: [
                      ListPickerItem(icon: Icons.view_list_rounded, label: NestedCommentIndicatorStyle.thick.value, payload: NestedCommentIndicatorStyle.thick),
                      ListPickerItem(icon: Icons.format_list_bulleted_rounded, label: NestedCommentIndicatorStyle.thin.value, payload: NestedCommentIndicatorStyle.thin),
                    ],
                    icon: Icons.format_list_bulleted_rounded,
                    onChanged: (value) => setPreferences(LocalSettings.nestedCommentIndicatorStyle, value.payload.name),
                  ),
                  ListOption(
                    description: LocalSettings.nestedCommentIndicatorColor.label,
                    value: ListPickerItem(label: nestedIndicatorColor.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorColor),
                    options: [
                      ListPickerItem(icon: Icons.invert_colors_on_rounded, label: NestedCommentIndicatorColor.colorful.value, payload: NestedCommentIndicatorColor.colorful),
                      ListPickerItem(icon: Icons.invert_colors_off_rounded, label: NestedCommentIndicatorColor.monochrome.value, payload: NestedCommentIndicatorColor.monochrome),
                    ],
                    icon: Icons.color_lens_outlined,
                    onChanged: (value) => setPreferences(LocalSettings.nestedCommentIndicatorColor, value.payload.name),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
