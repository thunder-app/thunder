import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:expandable/expandable.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/utils/post.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/utils/constants.dart';

class PostAppearanceSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const PostAppearanceSettingsPage({super.key, this.settingToHighlight});

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

  /// When enabled, the full date will be shown
  bool showFullPostDate = false;

  /// The selected date format. This is only used when `showFullPostDate` is enabled
  DateFormat? selectedDateFormat;

  /// List of available date formats to select from
  List<DateFormat> dateFormats = [
    DateFormat('MMMM dd, yyyy HH:mm:ss'),
    DateFormat('E, dd MMM yyyy HH:mm:ss Z'),
    DateFormat('yyyy-MM-dd HH:mm:ss'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
    DateFormat('MM/dd/yyyy HH:mm:ss'),
    DateFormat('yyyy-MM-ddTHH:mm:ss'),
  ];

  /// When enabled, cross posts will be shown on the post page
  bool showCrossPosts = true;

  /// Controller to manage expandable state for comment preview
  ExpandableController expandableController = ExpandableController();

  /// Determines how post bodies are displayed
  PostBodyViewType postBodyViewType = PostBodyViewType.expanded;

  /// List of compact post card metadata items to show on the post card
  /// The order of the items is important as they will be displayed in that order
  List<PostCardMetadataItem> compactPostCardMetadataItems = [];

  /// List of card post card metadata items to show on the post card
  /// The order of the items is important as they will be displayed in that order
  List<PostCardMetadataItem> cardPostCardMetadataItems = [];

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

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
      showFullPostDate = prefs.getBool(LocalSettings.showFullPostDate.name) ?? false;
      selectedDateFormat = prefs.getString(LocalSettings.dateFormat.name) != null ? DateFormat(prefs.getString(LocalSettings.dateFormat.name)) : DateFormat(DEFAULT_DATE_FORMAT);

      // Compact View Settings
      compactPostCardMetadataItems =
          prefs.getStringList(LocalSettings.compactPostCardMetadataItems.name)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_COMPACT_POST_CARD_METADATA;
      cardPostCardMetadataItems = prefs.getStringList(LocalSettings.cardPostCardMetadataItems.name)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_CARD_POST_CARD_METADATA;
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

      // Post body settings
      showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;
      postBodyViewType = PostBodyViewType.values.byName(prefs.getString(LocalSettings.postBodyViewType.name) ?? PostBodyViewType.expanded.name);
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
      case LocalSettings.showFullPostDate:
        await prefs.setBool(LocalSettings.showFullPostDate.name, value);
        setState(() => showFullPostDate = value);
        break;
      case LocalSettings.dateFormat:
        await prefs.setString(LocalSettings.dateFormat.name, (value as DateFormat).pattern ?? DEFAULT_DATE_FORMAT);
        setState(() => selectedDateFormat = value);
        break;

      case LocalSettings.compactPostCardMetadataItems:
        await prefs.setStringList(LocalSettings.compactPostCardMetadataItems.name, value);
        break;
      case LocalSettings.showThumbnailPreviewOnRight:
        await prefs.setBool(LocalSettings.showThumbnailPreviewOnRight.name, value);
        setState(() => showThumbnailPreviewOnRight = value);
        break;
      case LocalSettings.showTextPostIndicator:
        await prefs.setBool(LocalSettings.showTextPostIndicator.name, value);
        setState(() => showTextPostIndicator = value);
        break;
      case LocalSettings.cardPostCardMetadataItems:
        await prefs.setStringList(LocalSettings.cardPostCardMetadataItems.name, value);
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

      case LocalSettings.showCrossPosts:
        await prefs.setBool(LocalSettings.showCrossPosts.name, value);
        setState(() => showCrossPosts = value);
        break;
      case LocalSettings.postBodyViewType:
        await prefs.setString(LocalSettings.postBodyViewType.name, (value as PostBodyViewType).name);
        setState(() => postBodyViewType = value);
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
    await prefs.remove(LocalSettings.showFullPostDate.name);
    await prefs.remove(LocalSettings.dateFormat.name);
    await prefs.remove(LocalSettings.compactPostCardMetadataItems.name);
    await prefs.remove(LocalSettings.showThumbnailPreviewOnRight.name);
    await prefs.remove(LocalSettings.showTextPostIndicator.name);
    await prefs.remove(LocalSettings.cardPostCardMetadataItems.name);
    await prefs.remove(LocalSettings.showPostTitleFirst.name);
    await prefs.remove(LocalSettings.showPostFullHeightImages.name);
    await prefs.remove(LocalSettings.showPostEdgeToEdgeImages.name);
    await prefs.remove(LocalSettings.showPostTextContentPreview.name);
    await prefs.remove(LocalSettings.showPostVoteActions.name);
    await prefs.remove(LocalSettings.showPostSaveAction.name);
    await prefs.remove(LocalSettings.showPostCommunityIcons.name);
    await prefs.remove(LocalSettings.showCrossPosts.name);
    await prefs.remove(LocalSettings.postBodyViewType.name);

    await initPreferences();

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  /// Generates an example post to show in the post preview
  Future<List<PostViewMedia?>> getExamplePosts() async {
    PostViewMedia? postViewMediaText = await createExamplePost(
      postTitle: 'Example Text Post',
      personName: 'Lightning',
      communityName: 'Thunder',
      postBody: 'Thunder is an open source, cross platform app for interacting, and exploring Lemmy communities.',
      read: dimReadPosts,
      scoreCount: 50,
      commentCount: 4,
    );

    PostViewMedia? postViewMediaImage = await createExamplePost(
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

    PostViewMedia? postViewMediaLink = await createExamplePost(
      postTitle: 'Example Link Post',
      personName: 'Lightning',
      personDisplayName: 'User',
      communityName: 'Thunder',
      postUrl: 'https://github.com/thunder-app/thunder',
      read: false,
      scoreCount: 1210,
      commentCount: 543,
    );

    return [postViewMediaText, postViewMediaLink, postViewMediaImage].whereNotNull().toList();
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
            title: Text(l10n.posts),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.restart_alt_rounded,
                  semanticLabel: l10n.resetPostPreferences,
                ),
                onPressed: () {
                  showThunderDialog(
                    context: context,
                    title: l10n.resetPreferences,
                    contentText: l10n.confirmResetPostPreferences,
                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                    secondaryButtonText: l10n.cancel,
                    onPrimaryButtonPressed: (dialogContext, _) {
                      resetPostPreferences();
                      Navigator.of(dialogContext).pop();
                    },
                    primaryButtonText: l10n.reset,
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
                    expanded: FutureBuilder<List<PostViewMedia?>>(
                      future: getExamplePosts(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) return Container();

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                (useCompactView)
                                    ? IgnorePointer(
                                        child: PostCardViewCompact(
                                          postViewMedia: snapshot.data![index]!,
                                          communityMode: false,
                                          isUserLoggedIn: true,
                                          listingType: ListingType.all,
                                          indicateRead: dimReadPosts,
                                        ),
                                      )
                                    : IgnorePointer(
                                        child: PostCardViewComfortable(
                                          postViewMedia: snapshot.data![index]!,
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
            child: ListOption(
              description: l10n.postViewType,
              value: ListPickerItem(label: useCompactView ? l10n.compactView : l10n.cardView, icon: Icons.crop_16_9_rounded, payload: useCompactView),
              options: [
                ListPickerItem(icon: Icons.crop_16_9_rounded, label: l10n.compactView, payload: true),
                ListPickerItem(icon: Icons.crop_din_rounded, label: l10n.cardView, payload: false),
              ],
              icon: Icons.view_list_rounded,
              onChanged: (value) => setPreferences(LocalSettings.useCompactView, value.payload),
              highlightKey: settingToHighlight == LocalSettings.useCompactView ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.hideNsfwPreviews,
              value: hideNsfwPreviews,
              iconEnabled: Icons.no_adult_content,
              iconDisabled: Icons.no_adult_content,
              onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPreviews, value),
              highlightKey: settingToHighlight == LocalSettings.hideNsfwPreviews ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showPostAuthor,
              value: showPostAuthor,
              iconEnabled: Icons.person_rounded,
              iconDisabled: Icons.person_off_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.showPostAuthor, value),
              highlightKey: settingToHighlight == LocalSettings.showPostAuthor ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showUserDisplayNames,
              value: useDisplayNames,
              iconEnabled: Icons.person_rounded,
              iconDisabled: Icons.person_off_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.useDisplayNamesForUsers, value),
              highlightKey: settingToHighlight == LocalSettings.useDisplayNamesForUsers ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.dimReadPosts,
              subtitle: l10n.dimReadPosts,
              value: dimReadPosts,
              iconEnabled: Icons.chrome_reader_mode,
              iconDisabled: Icons.chrome_reader_mode_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.dimReadPosts, value),
              highlightKey: settingToHighlight == LocalSettings.dimReadPosts ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showFullDate,
              subtitle: l10n.showFullDateDescription,
              value: showFullPostDate,
              iconEnabled: Icons.date_range_rounded,
              iconDisabled: Icons.date_range_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.showFullPostDate, value),
              highlightKey: settingToHighlight == LocalSettings.showFullPostDate ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.dateFormat,
              disabled: !showFullPostDate,
              value: ListPickerItem(
                label: selectedDateFormat!.pattern!,
                icon: Icons.access_time_filled_rounded,
                payload: selectedDateFormat,
                capitalizeLabel: false,
              ),
              options: dateFormats
                  .map((DateFormat dateFormat) => ListPickerItem(icon: Icons.access_time_filled_rounded, label: dateFormat.format(DateTime.now()), payload: dateFormat, subtitle: dateFormat.pattern))
                  .toList(),
              icon: Icons.access_time_filled_rounded,
              onChanged: (value) => setPreferences(LocalSettings.dateFormat, value.payload),
              highlightKey: settingToHighlight == LocalSettings.dateFormat ? settingToHighlightKey : null,
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
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SmoothHighlight(
              key: settingToHighlight == LocalSettings.compactPostCardMetadataItems ? settingToHighlightKey : null,
              useInitialHighLight: settingToHighlight == LocalSettings.compactPostCardMetadataItems,
              enabled: settingToHighlight == LocalSettings.compactPostCardMetadataItems,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: buildCompactViewMetadataPreview(isDisabled: useCompactView == false),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Text(
                l10n.postMetadataInstructions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(8.0)),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(8.0),
              child: PostCardMetadataDraggableTarget(
                isDisabled: useCompactView == false,
                containedPostCardMetadataItems: PostCardMetadataItem.values.where((element) => !compactPostCardMetadataItems.contains(element)).toList(),
                onAcceptedData: (data) {
                  List<PostCardMetadataItem> newCompactPostCardMetadataItems = List.from(compactPostCardMetadataItems)..remove(data);

                  setState(() {
                    compactPostCardMetadataItems = newCompactPostCardMetadataItems;
                    setPreferences(LocalSettings.compactPostCardMetadataItems, compactPostCardMetadataItems.map((e) => e.name).toList());
                  });
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showThumbnailPreviewOnRight,
              value: showThumbnailPreviewOnRight,
              iconEnabled: Icons.switch_left_rounded,
              iconDisabled: Icons.switch_right_rounded,
              onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.showThumbnailPreviewOnRight, value),
              highlightKey: settingToHighlight == LocalSettings.showThumbnailPreviewOnRight ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showTextPostIndicator,
              value: showTextPostIndicator,
              iconEnabled: Icons.article,
              iconDisabled: Icons.article_outlined,
              onToggle: useCompactView == false ? null : (bool value) => setPreferences(LocalSettings.showTextPostIndicator, value),
              highlightKey: settingToHighlight == LocalSettings.showTextPostIndicator ? settingToHighlightKey : null,
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
            child: SmoothHighlight(
              key: settingToHighlight == LocalSettings.cardPostCardMetadataItems ? settingToHighlightKey : null,
              useInitialHighLight: settingToHighlight == LocalSettings.cardPostCardMetadataItems,
              enabled: settingToHighlight == LocalSettings.cardPostCardMetadataItems,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: buildCardViewMetadataPreview(isDisabled: useCompactView == true),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Text(
                l10n.postMetadataInstructions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(8.0)),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(8.0),
              child: PostCardMetadataDraggableTarget(
                isDisabled: useCompactView == true,
                containedPostCardMetadataItems: PostCardMetadataItem.values.where((element) => !cardPostCardMetadataItems.contains(element)).toList(),
                onAcceptedData: (data) {
                  List<PostCardMetadataItem> newCardPostCardMetadataItems = List.from(cardPostCardMetadataItems)..remove(data);

                  setState(() {
                    cardPostCardMetadataItems = newCardPostCardMetadataItems;
                    setPreferences(LocalSettings.cardPostCardMetadataItems, cardPostCardMetadataItems.map((e) => e.name).toList());
                  });
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showPostTitleFirst,
              value: showTitleFirst,
              iconEnabled: Icons.vertical_align_top_rounded,
              iconDisabled: Icons.vertical_align_bottom_rounded,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostTitleFirst, value),
              highlightKey: settingToHighlight == LocalSettings.showPostTitleFirst ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showFullHeightImages,
              value: showFullHeightImages,
              iconEnabled: Icons.image_rounded,
              iconDisabled: Icons.image_outlined,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostFullHeightImages, value),
              highlightKey: settingToHighlight == LocalSettings.showPostFullHeightImages ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showEdgeToEdgeImages,
              value: showEdgeToEdgeImages,
              iconEnabled: Icons.fit_screen_rounded,
              iconDisabled: Icons.fit_screen_outlined,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostEdgeToEdgeImages, value),
              highlightKey: settingToHighlight == LocalSettings.showPostEdgeToEdgeImages ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showPostTextContentPreview,
              value: showTextContent,
              iconEnabled: Icons.notes_rounded,
              iconDisabled: Icons.notes_rounded,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostTextContentPreview, value),
              highlightKey: settingToHighlight == LocalSettings.showPostTextContentPreview ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showPostVoteActions,
              value: showVoteActions,
              iconEnabled: Icons.import_export_rounded,
              iconDisabled: Icons.import_export_rounded,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostVoteActions, value),
              highlightKey: settingToHighlight == LocalSettings.showPostVoteActions ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showPostSaveAction,
              value: showSaveAction,
              iconEnabled: Icons.star_rounded,
              iconDisabled: Icons.star_border_rounded,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostSaveAction, value),
              highlightKey: settingToHighlight == LocalSettings.showPostSaveAction ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showPostCommunityIcons,
              value: showCommunityIcons,
              iconEnabled: Icons.groups,
              iconDisabled: Icons.groups,
              onToggle: useCompactView ? null : (bool value) => setPreferences(LocalSettings.showPostCommunityIcons, value),
              highlightKey: settingToHighlight == LocalSettings.showPostCommunityIcons ? settingToHighlightKey : null,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.postBodySettings, style: theme.textTheme.titleMedium),
                  Text(
                    l10n.postBodySettingsDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showCrossPosts,
              value: showCrossPosts,
              iconEnabled: Icons.repeat_on_rounded,
              iconDisabled: Icons.repeat_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.showCrossPosts, value),
              highlightKey: settingToHighlight == LocalSettings.showCrossPosts ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.postBodyViewType,
              value: ListPickerItem(
                  label: switch (postBodyViewType) {
                    PostBodyViewType.condensed => l10n.condensed,
                    PostBodyViewType.expanded => l10n.expanded,
                  },
                  icon: Icons.crop_16_9_rounded,
                  payload: postBodyViewType,
                  capitalizeLabel: false),
              options: [
                ListPickerItem(icon: Icons.crop_16_9_rounded, label: l10n.condensed, payload: PostBodyViewType.condensed),
                ListPickerItem(icon: Icons.crop_din_rounded, label: l10n.expanded, payload: PostBodyViewType.expanded),
              ],
              icon: Icons.view_list_rounded,
              onChanged: (value) => setPreferences(LocalSettings.postBodyViewType, value.payload),
              highlightKey: settingToHighlight == LocalSettings.postBodyViewType ? settingToHighlightKey : null,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }

  Widget buildCardViewMetadataPreview({bool isDisabled = false}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitleFirst) ...[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 25,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ), // Title
          const SizedBox(height: 4.0),
        ],
        Container(
          height: showFullHeightImages ? 150 : 100,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: BorderRadius.circular((showEdgeToEdgeImages ? 0 : 12)),
          ),
        ),
        if (!showTitleFirst) ...[
          const SizedBox(height: 4.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 25,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ), // Title
          const SizedBox(height: 6.0),
        ],
        if (showTextContent) ...[
          ScalableText(
            l10n.placeholderText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 4.0),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showCommunityIcons)
                        Container(
                          width: 25,
                          height: 25,
                          margin: const EdgeInsets.only(right: 6.0),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 15,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  PostCardMetadataDraggableTarget(
                    isDisabled: useCompactView == true,
                    containerHeight: 25.0,
                    showEmptyTargetMessage: false,
                    containedPostCardMetadataItems: cardPostCardMetadataItems,
                    onAcceptedData: (data) {
                      List<PostCardMetadataItem> newCardPostCardMetadataItems = List.from(cardPostCardMetadataItems)..add(data);

                      setState(() {
                        cardPostCardMetadataItems = newCardPostCardMetadataItems;
                        setPreferences(LocalSettings.cardPostCardMetadataItems, cardPostCardMetadataItems.map((e) => e.name).toList());
                      });
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.more_horiz_rounded),
            ),
            if (showVoteActions) ...[
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.arrow_upward_rounded),
              ),
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.arrow_downward_rounded),
              ),
            ],
            if (showSaveAction)
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.star_outline_rounded),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildCompactViewMetadataPreview({bool isDisabled = false}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(bottom: 8.0, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !showThumbnailPreviewOnRight
              ? Container(
                  width: 75,
                  height: 75,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular((showEdgeToEdgeImages ? 0 : 12)),
                  ),
                )
              : const SizedBox(width: 0),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: showThumbnailPreviewOnRight ? 8.0 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 25,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular((showEdgeToEdgeImages ? 0 : 12)),
                    ),
                  ), // Title
                  const SizedBox(height: 6.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 15,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular((showEdgeToEdgeImages ? 0 : 12)),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  PostCardMetadataDraggableTarget(
                    isDisabled: useCompactView == false,
                    containerHeight: 25.0,
                    showEmptyTargetMessage: false,
                    containedPostCardMetadataItems: compactPostCardMetadataItems,
                    onAcceptedData: (data) {
                      List<PostCardMetadataItem> newCompactPostCardMetadataItems = List.from(compactPostCardMetadataItems)..add(data);

                      setState(() {
                        compactPostCardMetadataItems = newCompactPostCardMetadataItems;
                        setPreferences(LocalSettings.compactPostCardMetadataItems, compactPostCardMetadataItems.map((e) => e.name).toList());
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          showThumbnailPreviewOnRight
              ? Container(
                  width: 75,
                  height: 75,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular((showEdgeToEdgeImages ? 0 : 12)),
                  ),
                )
              : const SizedBox(width: 0),
        ],
      ),
    );
  }
}

/// A draggable target for the post card metadata.
///
/// Held in this draggable target is a list of [PostCardMetadataItem]s. Each of these items can be dragged outside the target.
class PostCardMetadataDraggableTarget extends StatelessWidget {
  /// The items contained in the target
  final List<PostCardMetadataItem> containedPostCardMetadataItems;

  /// Callback when data is accepted
  final void Function(PostCardMetadataItem) onAcceptedData;

  /// The height of the target container, when empty
  final double containerHeight;

  /// Whether to display a message when the target is empty
  final bool showEmptyTargetMessage;

  /// Whether the target is disabled
  final bool isDisabled;

  const PostCardMetadataDraggableTarget({
    super.key,
    required this.containedPostCardMetadataItems,
    required this.onAcceptedData,
    this.containerHeight = 50.0,
    this.showEmptyTargetMessage = true,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AbsorbPointer(
      absorbing: isDisabled,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DragTarget<PostCardMetadataItem>(
          builder: (context, candidateData, rejectedData) => containedPostCardMetadataItems.isEmpty
              ? SizedBox(
                  height: containerHeight,
                  child: Center(
                    child: Text(
                      showEmptyTargetMessage ? l10n.noItems : '',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                    ),
                  ),
                )
              : Container(
                  constraints: BoxConstraints(minHeight: containerHeight),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: containedPostCardMetadataItems
                        .map(
                          (item) => Draggable<PostCardMetadataItem>(
                            key: ValueKey(item),
                            data: item,
                            feedback: buildDraggableItem(context, item: item, isFeedback: true),
                            child: buildDraggableItem(context, item: item, isDisabled: isDisabled),
                          ),
                        )
                        .toList(),
                  ),
                ),
          onLeave: (data) => HapticFeedback.mediumImpact(),
          onWillAccept: (data) {
            if (!containedPostCardMetadataItems.contains(data)) {
              return true;
            }
            return false;
          },
          onAcceptWithDetails: (DragTargetDetails<PostCardMetadataItem> details) {
            onAcceptedData(details.data);
          },
        ),
      ),
    );
  }

  Widget buildDraggableItem(context, {required PostCardMetadataItem item, bool isFeedback = false, bool isDisabled = false}) {
    final theme = Theme.of(context);

    return TooltipVisibility(
      visible: false,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isDisabled ? theme.cardColor : theme.dividerColor,
            border: isDisabled ? Border.all(color: theme.dividerColor.withOpacity(0.4)) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: switch (item) {
            PostCardMetadataItem.score => const ScorePostCardMetaData(score: 1222),
            PostCardMetadataItem.commentCount => const CommentCountPostCardMetaData(commentCount: 4124),
            PostCardMetadataItem.dateTime => DateTimePostCardMetaData(dateTime: DateTime.now().toIso8601String()),
            PostCardMetadataItem.url => const UrlPostCardMetaData(url: 'https://github.com/thunder-app/thunder'),
            PostCardMetadataItem.upvote => const UpvotePostCardMetaData(upvotes: 2412),
            PostCardMetadataItem.downvote => const DownvotePostCardMetaData(downvotes: 532),
          },
        ),
      ),
    );
  }
}
