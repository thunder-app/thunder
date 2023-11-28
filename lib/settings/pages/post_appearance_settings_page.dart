import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

class PostAppearanceSettingsPage extends StatefulWidget {
  const PostAppearanceSettingsPage({super.key});

  @override
  State<PostAppearanceSettingsPage> createState() => _PostAppearanceSettingsPageState();
}

class _PostAppearanceSettingsPageState extends State<PostAppearanceSettingsPage> with SingleTickerProviderStateMixin {
  /// Blurs any posts that are marked as NSFW
  bool hideNsfwPreviews = true;

  /// When enabled, displays the user's display name instead of the username
  bool useDisplayNames = true;

  /// When enabled, posts on the feed will be compacted
  bool useCompactView = false;

  /// When enabled, the thumbnail previews will be shown on the right. By default, they are shown on the left
  bool showThumbnailPreviewOnRight = false;

  /// When enabled, the text post indicator will be shown for text posts
  bool showTextPostIndicator = false;

  /// Shows the title of the post first, instead of the media or link
  bool showTitleFirst = false;

  /// When enabled, vote actions are shown when the user is logged in
  bool showVoteActions = true;

  /// When enabled, save actions are shown when the user is logged in
  bool showSaveAction = true;

  /// When enabled, community icons are shown
  bool showCommunityIcons = false;

  /// When enabled, images and media will display full height. By default, they are displayed with a max height
  bool showFullHeightImages = false;

  /// When enabled, images and media will extend to the edge of the screen. By default, they are shown as a card
  bool showEdgeToEdgeImages = false;

  /// When enabled, a preview of the post content will be shown
  bool showTextContent = false;

  /// When enabled, the author of the post will be shown on the post
  bool showPostAuthor = false;

  /// When enabled, posts that have been marked as read will be dimmed
  bool dimReadPosts = true;

  /// When enabled, cross posts will be shown on the post page
  bool showCrossPosts = true;

  /// Controller to manage expandable state for comment preview
  ExpandableController expandableController = ExpandableController();

  /// Initialize the settings from the user's shared preferences
  Future<void> initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      // General Settings
      useCompactView = prefs.getBool(LocalSettings.useCompactView.name) ?? false;
      hideNsfwPreviews = prefs.getBool(LocalSettings.hideNsfwPreviews.name) ?? true;
      showPostAuthor = prefs.getBool(LocalSettings.showPostAuthor.name) ?? false;
      useDisplayNames = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? true;
      dimReadPosts = prefs.getBool(LocalSettings.dimReadPosts.name) ?? true;
      showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;

      // Compact View Settings
      showThumbnailPreviewOnRight = prefs.getBool(LocalSettings.showThumbnailPreviewOnRight.name) ?? false;
      showTextPostIndicator = prefs.getBool(LocalSettings.showTextPostIndicator.name) ?? false;

      // Card View Settings
      showTitleFirst = prefs.getBool(LocalSettings.showPostTitleFirst.name) ?? false;
      showFullHeightImages = prefs.getBool(LocalSettings.showPostFullHeightImages.name) ?? false;
      showEdgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
      showTextContent = prefs.getBool(LocalSettings.showPostTextContentPreview.name) ?? false;
      showVoteActions = prefs.getBool(LocalSettings.showPostVoteActions.name) ?? true;
      showSaveAction = prefs.getBool(LocalSettings.showPostSaveAction.name) ?? true;
      showCommunityIcons = prefs.getBool(LocalSettings.showPostCommunityIcons.name) ?? false;
    });
  }

  /// Given an attribute and the associated value, update the setting in the shared preferences
  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case LocalSettings.useCompactView:
        await prefs.setBool(LocalSettings.useCompactView.name, value);
        setState(() => useCompactView = value);
        break;
      case LocalSettings.hideNsfwPreviews:
        await prefs.setBool(LocalSettings.hideNsfwPreviews.name, value);
        setState(() => hideNsfwPreviews = value);
        break;
      case LocalSettings.showPostAuthor:
        await prefs.setBool(LocalSettings.showPostAuthor.name, value);
        setState(() => showPostAuthor = value);
        break;
      case LocalSettings.useDisplayNamesForUsers:
        await prefs.setBool(LocalSettings.useDisplayNamesForUsers.name, value);
        setState(() => useDisplayNames = value);
        break;
      case LocalSettings.dimReadPosts:
        await prefs.setBool(LocalSettings.dimReadPosts.name, value);
        setState(() => dimReadPosts = value);
        break;
      case LocalSettings.showCrossPosts:
        await prefs.setBool(LocalSettings.showCrossPosts.name, value);
        setState(() => showCrossPosts = value);
        break;

      case LocalSettings.showThumbnailPreviewOnRight:
        await prefs.setBool(LocalSettings.showThumbnailPreviewOnRight.name, value);
        setState(() => showThumbnailPreviewOnRight = value);
        break;
      case LocalSettings.showTextPostIndicator:
        await prefs.setBool(LocalSettings.showTextPostIndicator.name, value);
        setState(() => showTextPostIndicator = value);
        break;
      case LocalSettings.showPostTitleFirst:
        await prefs.setBool(LocalSettings.showPostTitleFirst.name, value);
        setState(() => showTitleFirst = value);
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
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  /// Reset the posts preferences to their defaults
  void resetPostPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    await prefs.remove(LocalSettings.useCompactView.name);
    await prefs.remove(LocalSettings.hideNsfwPreviews.name);
    await prefs.remove(LocalSettings.showPostAuthor.name);
    await prefs.remove(LocalSettings.useDisplayNamesForUsers.name);
    await prefs.remove(LocalSettings.dimReadPosts.name);
    await prefs.remove(LocalSettings.showCrossPosts.name);
    await prefs.remove(LocalSettings.showThumbnailPreviewOnRight.name);
    await prefs.remove(LocalSettings.showTextPostIndicator.name);
    await prefs.remove(LocalSettings.showPostTitleFirst.name);
    await prefs.remove(LocalSettings.showPostFullHeightImages.name);
    await prefs.remove(LocalSettings.showPostEdgeToEdgeImages.name);
    await prefs.remove(LocalSettings.showPostTextContentPreview.name);
    await prefs.remove(LocalSettings.showPostVoteActions.name);
    await prefs.remove(LocalSettings.showPostSaveAction.name);
    await prefs.remove(LocalSettings.showPostCommunityIcons.name);

    await initPreferences();

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  /// Generates an example post to show in the post preview
  Future<List<PostViewMedia>> getExamplePosts() async {
    PostViewMedia postViewMediaText = await createExamplePost(
      postTitle: 'Example Text Post',
      personName: 'Lightning',
      communityName: 'Thunder',
      postBody: 'Thunder is an open source, cross platform app for interacting, and exploring Lemmy communities.',
      read: dimReadPosts,
      scoreCount: 50,
      commentCount: 4,
    );

    PostViewMedia postViewMediaImage = await createExamplePost(
      postTitle: 'Example Image Post',
      personName: 'Lightning',
      personDisplayName: 'User',
      communityName: 'Thunder',
      postUrl: 'https://lemmy.ml/pictrs/image/4ff0a2f3-970c-4493-b143-a6d46d378c95.jpeg',
      nsfw: true,
      read: false,
      scoreCount: 102,
      commentCount: 4230,
    );

    PostViewMedia postViewMediaLink = await createExamplePost(
      postTitle: 'Example Link Post',
      personName: 'Lightning',
      personDisplayName: 'User',
      communityName: 'Thunder',
      postUrl: 'https://github.com/thunder-app/thunder',
      read: false,
      scoreCount: 1210,
      commentCount: 543,
    );

    return [postViewMediaText, postViewMediaLink, postViewMediaImage];
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
            title: Text(l10n.posts),
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
                      content: Text(l10n.confirmResetPostPreferences),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            resetPostPreferences();
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
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      l10n.postPreview,
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.generalSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: l10n.postViewType,
                value: ListPickerItem(label: useCompactView ? l10n.compactView : l10n.cardView, icon: Icons.crop_16_9_rounded, payload: useCompactView),
                options: [
                  ListPickerItem(icon: Icons.crop_16_9_rounded, label: l10n.compactView, payload: true),
                  ListPickerItem(icon: Icons.crop_din_rounded, label: l10n.cardView, payload: false),
                ],
                icon: Icons.view_list_rounded,
                onChanged: (value) => setPreferences(LocalSettings.useCompactView, value.payload),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.hideNsfwPreviews.label,
                value: hideNsfwPreviews,
                iconEnabled: Icons.no_adult_content,
                iconDisabled: Icons.no_adult_content,
                onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPreviews, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostAuthor.label,
                value: showPostAuthor,
                iconEnabled: Icons.person_rounded,
                iconDisabled: Icons.person_off_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.showPostAuthor, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.useDisplayNamesForUsers.label,
                value: useDisplayNames,
                iconEnabled: Icons.person_rounded,
                iconDisabled: Icons.person_off_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.useDisplayNamesForUsers, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.dimReadPosts.label,
                subtitle: l10n.dimReadPosts,
                value: dimReadPosts,
                iconEnabled: Icons.chrome_reader_mode,
                iconDisabled: Icons.chrome_reader_mode_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.dimReadPosts, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showCrossPosts.label,
                value: showCrossPosts,
                iconEnabled: Icons.repeat_on_rounded,
                iconDisabled: Icons.repeat_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.showCrossPosts, value),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.compactViewSettings, style: theme.textTheme.titleMedium),
                  Text(
                    l10n.compactViewDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showThumbnailPreviewOnRight.label,
                value: showThumbnailPreviewOnRight,
                iconEnabled: Icons.switch_left_rounded,
                iconDisabled: Icons.switch_right_rounded,
                onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.showThumbnailPreviewOnRight, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showTextPostIndicator.label,
                value: showTextPostIndicator,
                iconEnabled: Icons.article,
                iconDisabled: Icons.article_outlined,
                onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.showTextPostIndicator, value),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cardViewSettings, style: theme.textTheme.titleMedium),
                  Text(
                    l10n.cardViewDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostTitleFirst.label,
                value: showTitleFirst,
                iconEnabled: Icons.vertical_align_top_rounded,
                iconDisabled: Icons.vertical_align_bottom_rounded,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostTitleFirst, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostFullHeightImages.label,
                value: showFullHeightImages,
                iconEnabled: Icons.image_rounded,
                iconDisabled: Icons.image_outlined,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostFullHeightImages, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostEdgeToEdgeImages.label,
                value: showEdgeToEdgeImages,
                iconEnabled: Icons.fit_screen_rounded,
                iconDisabled: Icons.fit_screen_outlined,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostEdgeToEdgeImages, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostTextContentPreview.label,
                value: showTextContent,
                iconEnabled: Icons.notes_rounded,
                iconDisabled: Icons.notes_rounded,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostTextContentPreview, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostVoteActions.label,
                value: showVoteActions,
                iconEnabled: Icons.import_export_rounded,
                iconDisabled: Icons.import_export_rounded,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostVoteActions, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostSaveAction.label,
                value: showSaveAction,
                iconEnabled: Icons.star_rounded,
                iconDisabled: Icons.star_border_rounded,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostSaveAction, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showPostCommunityIcons.label,
                value: showCommunityIcons,
                iconEnabled: Icons.groups,
                iconDisabled: Icons.groups,
                onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostCommunityIcons, value),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
