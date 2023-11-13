import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostAppearanceSettingsPage extends StatefulWidget {
  const PostAppearanceSettingsPage({super.key});

  @override
  State<PostAppearanceSettingsPage> createState() => _PostAppearanceSettingsPageState();
}

class _PostAppearanceSettingsPageState extends State<PostAppearanceSettingsPage> with SingleTickerProviderStateMixin {
  /// -------------------------- Feed Related Settings --------------------------
  // NSFW Settings
  bool hideNsfwPreviews = true;

  // General Settings
  bool useDisplayNames = true;

  /// -------------------------- Feed Post Related Settings --------------------------
  // Compact Related Settings
  bool useCompactView = false;
  bool showTitleFirst = false;
  bool showThumbnailPreviewOnRight = false;
  bool showTextPostIndicator = false;
  bool tappableAuthorCommunity = false;

  // General Settings
  bool showVoteActions = true;
  bool showSaveAction = true;
  bool showCommunityIcons = false;
  bool showFullHeightImages = false;
  bool showEdgeToEdgeImages = false;
  bool showTextContent = false;
  bool showPostAuthor = false;
  bool scoreCounters = false;

  bool dimReadPosts = true;
  bool showCrossPosts = true;

  // Page State
  bool compactEnabled = true;
  ExpandableController expandableController = ExpandableController();

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      /// -------------------------- Feed Related Settings --------------------------
      // Default Listing/Sort Settings

      case LocalSettings.hideNsfwPreviews:
        await prefs.setBool(LocalSettings.hideNsfwPreviews.name, value);
        setState(() => hideNsfwPreviews = value);
        break;

      case LocalSettings.useDisplayNamesForUsers:
        await prefs.setBool(LocalSettings.useDisplayNamesForUsers.name, value);
        setState(() => useDisplayNames = value);
        break;

      case LocalSettings.scoreCounters:
        await prefs.setBool(LocalSettings.scoreCounters.name, value);
        setState(() => scoreCounters = value);
        break;

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      case LocalSettings.useCompactView:
        await prefs.setBool(LocalSettings.useCompactView.name, value);
        setState(() => useCompactView = value);
        break;
      case LocalSettings.showPostTitleFirst:
        await prefs.setBool(LocalSettings.showPostTitleFirst.name, value);
        setState(() => showTitleFirst = value);
        break;
      case LocalSettings.showThumbnailPreviewOnRight:
        await prefs.setBool(LocalSettings.showThumbnailPreviewOnRight.name, value);
        setState(() => showThumbnailPreviewOnRight = value);
        break;
      case LocalSettings.showTextPostIndicator:
        await prefs.setBool(LocalSettings.showTextPostIndicator.name, value);
        setState(() => showTextPostIndicator = value);
        break;
      case LocalSettings.tappableAuthorCommunity:
        await prefs.setBool(LocalSettings.tappableAuthorCommunity.name, value);
        setState(() => tappableAuthorCommunity = value);
        break;

      // General Settings
      case LocalSettings.showPostVoteActions:
        await prefs.setBool(LocalSettings.showPostVoteActions.name, value);
        setState(() => showVoteActions = value);
        break;
      case LocalSettings.showPostSaveAction:
        await prefs.setBool(LocalSettings.showPostSaveAction.name, value);
        setState(() => showSaveAction = value);
        break;
      case LocalSettings.showPostCommunityIcons:
        await prefs.setBool(LocalSettings.showPostCommunityIcons.name, value);
        setState(() => showCommunityIcons = value);
        break;
      case LocalSettings.showPostFullHeightImages:
        await prefs.setBool(LocalSettings.showPostFullHeightImages.name, value);
        setState(() => showFullHeightImages = value);
        break;
      case LocalSettings.showPostEdgeToEdgeImages:
        await prefs.setBool(LocalSettings.showPostEdgeToEdgeImages.name, value);
        setState(() => showEdgeToEdgeImages = value);
        break;
      case LocalSettings.showPostTextContentPreview:
        await prefs.setBool(LocalSettings.showPostTextContentPreview.name, value);
        setState(() => showTextContent = value);
        break;
      case LocalSettings.showPostAuthor:
        await prefs.setBool(LocalSettings.showPostAuthor.name, value);
        setState(() => showPostAuthor = value);
        break;
      case LocalSettings.dimReadPosts:
        await prefs.setBool(LocalSettings.dimReadPosts.name, value);
        setState(() => dimReadPosts = value);
        break;

      case LocalSettings.showCrossPosts:
        await prefs.setBool(LocalSettings.showCrossPosts.name, value);
        setState(() => showCrossPosts = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      // Feed Settings
      hideNsfwPreviews = prefs.getBool(LocalSettings.hideNsfwPreviews.name) ?? true;
      useDisplayNames = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? true;
      scoreCounters = prefs.getBool(LocalSettings.scoreCounters.name) ?? false;

      // Post Settings
      useCompactView = prefs.getBool(LocalSettings.useCompactView.name) ?? false;
      showTitleFirst = prefs.getBool(LocalSettings.showPostTitleFirst.name) ?? false;
      showThumbnailPreviewOnRight = prefs.getBool(LocalSettings.showThumbnailPreviewOnRight.name) ?? false;
      showTextPostIndicator = prefs.getBool(LocalSettings.showTextPostIndicator.name) ?? false;
      tappableAuthorCommunity = prefs.getBool(LocalSettings.tappableAuthorCommunity.name) ?? false;
      showVoteActions = prefs.getBool(LocalSettings.showPostVoteActions.name) ?? true;
      showSaveAction = prefs.getBool(LocalSettings.showPostSaveAction.name) ?? true;
      showCommunityIcons = prefs.getBool(LocalSettings.showPostCommunityIcons.name) ?? false;
      showFullHeightImages = prefs.getBool(LocalSettings.showPostFullHeightImages.name) ?? false;
      showEdgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
      showTextContent = prefs.getBool(LocalSettings.showPostTextContentPreview.name) ?? false;
      showPostAuthor = prefs.getBool(LocalSettings.showPostAuthor.name) ?? false;
      dimReadPosts = prefs.getBool(LocalSettings.dimReadPosts.name) ?? true;
      showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;
    });
  }

  Future<List<PostViewMedia>> getExamplePosts() async {
    PostViewMedia postViewMediaText = await createExamplePost(
      postTitle: 'Example Text Post',
      personName: 'Lightning',
      communityName: 'Thunder',
      postBody: 'Thunder is an open source, cross platform app for interacting, and exploring Lemmy communities.',
      read: dimReadPosts,
    );

    PostViewMedia postViewMediaImage = await createExamplePost(
      postTitle: 'Example Image Post',
      personName: 'Lightning',
      personDisplayName: 'User',
      communityName: 'Thunder',
      postUrl: 'https://lemmy.ml/pictrs/image/4ff0a2f3-970c-4493-b143-a6d46d378c95.jpeg',
      nsfw: true,
      read: dimReadPosts,
    );

    PostViewMedia postViewMediaLink = await createExamplePost(
      postTitle: 'Example Link Post',
      personName: 'Lightning',
      personDisplayName: 'User',
      communityName: 'Thunder',
      postUrl: 'https://github.com/thunder-app/thunder',
      read: dimReadPosts,
    );

    return [postViewMediaText, postViewMediaLink, postViewMediaImage];
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
      appBar: AppBar(title: Text(l10n.posts), centerTitle: false),
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
                              // const Expanded(child: Divider(indent: 8.0)),
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
                            'Show a preview of the post with the given settings',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Expandable(
                          controller: expandableController,
                          collapsed: Container(),
                          expanded: FutureBuilder<List<PostViewMedia>>(
                            future: getExamplePosts(),
                            builder: (context, snapshot) {
                              if (snapshot.data == null) return Container();

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      (useCompactView)
                                          ? IgnorePointer(
                                              child: PostCardViewCompact(
                                              postViewMedia: snapshot.data![index],
                                              showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
                                              showTextPostIndicator: showTextPostIndicator,
                                              showPostAuthor: showPostAuthor,
                                              hideNsfwPreviews: hideNsfwPreviews,
                                              communityMode: false,
                                              markPostReadOnMediaView: false,
                                              isUserLoggedIn: true,
                                              listingType: ListingType.all,
                                              indicateRead: dimReadPosts,
                                            ))
                                          : IgnorePointer(
                                              child: PostCardViewComfortable(
                                                postViewMedia: snapshot.data![index],
                                                showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
                                                showPostAuthor: showPostAuthor,
                                                hideNsfwPreviews: hideNsfwPreviews,
                                                communityMode: false,
                                                markPostReadOnMediaView: false,
                                                isUserLoggedIn: true,
                                                listingType: ListingType.all,
                                                indicateRead: dimReadPosts,
                                                edgeToEdgeImages: showEdgeToEdgeImages,
                                                showTitleFirst: showTitleFirst,
                                                showFullHeightImages: showFullHeightImages,
                                                showVoteActions: showVoteActions,
                                                showSaveAction: showSaveAction,
                                                showCommunityIcons: showCommunityIcons,
                                                showTextContent: showTextContent,
                                                onVoteAction: (voteType) {},
                                                onSaveAction: (saved) {},
                                              ),
                                            ),
                                      const Divider(),
                                    ],
                                  );
                                },
                                itemCount: snapshot.data!.length,
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
                  ListOption(
                    description: 'Post View Type',
                    value: ListPickerItem(label: useCompactView ? 'Compact View' : 'Card View', icon: Icons.crop_16_9_rounded, payload: useCompactView),
                    options: const [
                      ListPickerItem(icon: Icons.crop_16_9_rounded, label: 'Compact View', payload: true),
                      ListPickerItem(icon: Icons.crop_din_rounded, label: 'Card View', payload: false),
                    ],
                    icon: Icons.view_list_rounded,
                    onChanged: (value) => setPreferences(LocalSettings.useCompactView, value.payload),
                  ),
                  ToggleOption(
                    description: LocalSettings.hideNsfwPreviews.label,
                    value: hideNsfwPreviews,
                    iconEnabled: Icons.no_adult_content,
                    iconDisabled: Icons.no_adult_content,
                    onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPreviews, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostAuthor.label,
                    value: showPostAuthor,
                    iconEnabled: Icons.person_rounded,
                    iconDisabled: Icons.person_off_rounded,
                    onToggle: (bool value) => setPreferences(LocalSettings.showPostAuthor, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.useDisplayNamesForUsers.label,
                    value: useDisplayNames,
                    iconEnabled: Icons.person_rounded,
                    iconDisabled: Icons.person_off_rounded,
                    onToggle: (bool value) => setPreferences(LocalSettings.useDisplayNamesForUsers, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.dimReadPosts.label,
                    subtitle: l10n.dimReadPosts,
                    value: dimReadPosts,
                    iconEnabled: Icons.chrome_reader_mode,
                    iconDisabled: Icons.chrome_reader_mode_outlined,
                    onToggle: (bool value) => setPreferences(LocalSettings.dimReadPosts, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showCrossPosts.label,
                    value: showCrossPosts,
                    iconEnabled: Icons.repeat_on_rounded,
                    iconDisabled: Icons.repeat_rounded,
                    onToggle: (bool value) => setPreferences(LocalSettings.showCrossPosts, value),
                  ),
                  const SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compact View Settings', style: theme.textTheme.titleMedium),
                        Text(
                          'Enable compact view to adjust settings',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ToggleOption(
                    description: LocalSettings.showThumbnailPreviewOnRight.label,
                    value: showThumbnailPreviewOnRight,
                    iconEnabled: Icons.switch_left_rounded,
                    iconDisabled: Icons.switch_right_rounded,
                    onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.showThumbnailPreviewOnRight, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showTextPostIndicator.label,
                    value: showTextPostIndicator,
                    iconEnabled: Icons.article,
                    iconDisabled: Icons.article_outlined,
                    onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.showTextPostIndicator, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.tappableAuthorCommunity.label,
                    value: tappableAuthorCommunity,
                    iconEnabled: Icons.touch_app_rounded,
                    iconDisabled: Icons.touch_app_outlined,
                    onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.tappableAuthorCommunity, value),
                  ),
                  const SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Card View Settings', style: theme.textTheme.titleMedium),
                        Text(
                          'Enable card view to adjust settings',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostTitleFirst.label,
                    value: showTitleFirst,
                    iconEnabled: Icons.vertical_align_top_rounded,
                    iconDisabled: Icons.vertical_align_bottom_rounded,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostTitleFirst, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostFullHeightImages.label,
                    value: showFullHeightImages,
                    iconEnabled: Icons.image_rounded,
                    iconDisabled: Icons.image_outlined,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostFullHeightImages, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostEdgeToEdgeImages.label,
                    value: showEdgeToEdgeImages,
                    iconEnabled: Icons.fit_screen_rounded,
                    iconDisabled: Icons.fit_screen_outlined,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostEdgeToEdgeImages, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostTextContentPreview.label,
                    value: showTextContent,
                    iconEnabled: Icons.notes_rounded,
                    iconDisabled: Icons.notes_rounded,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostTextContentPreview, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostVoteActions.label,
                    value: showVoteActions,
                    iconEnabled: Icons.import_export_rounded,
                    iconDisabled: Icons.import_export_rounded,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostVoteActions, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostSaveAction.label,
                    value: showSaveAction,
                    iconEnabled: Icons.star_rounded,
                    iconDisabled: Icons.star_border_rounded,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostSaveAction, value),
                  ),
                  ToggleOption(
                    description: LocalSettings.showPostCommunityIcons.label,
                    value: showCommunityIcons,
                    iconEnabled: Icons.groups,
                    iconDisabled: Icons.groups,
                    onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostCommunityIcons, value),
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
