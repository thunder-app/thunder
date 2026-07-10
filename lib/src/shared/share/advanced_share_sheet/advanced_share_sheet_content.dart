import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_image.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_options.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_preview.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

class AdvancedShareSheetContent extends StatefulWidget {
  const AdvancedShareSheetContent({
    super.key,
    required this.post,
    required this.initialOptions,
  });

  /// The post to share.
  final ThunderPost post;

  /// The initial options for the share sheet.
  final AdvancedShareSheetOptions initialOptions;

  @override
  State<AdvancedShareSheetContent> createState() => _AdvancedShareSheetContentState();
}

class _AdvancedShareSheetContentState extends State<AdvancedShareSheetContent> {
  /// The options for the share sheet.
  late AdvancedShareSheetOptions _options;

  /// The future for the generated image.
  Future<Uint8List>? _generatedImageFuture;

  /// Whether the generated image future has been initialized.
  bool _hasInitializedGeneratedImageFuture = false;

  /// Whether the image is being downloaded.
  bool _isDownloading = false;

  /// The post to share.
  ThunderPost get _post => widget.post;

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions.copy();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitializedGeneratedImageFuture) {
      _hasInitializedGeneratedImageFuture = true;
      _scheduleGeneratedImageUpdate();
    }
  }

  void _updateGeneratedImageFuture() {
    final options = _options.copy();
    _generatedImageFuture = advancedShareIsImageCustomized(options, _post) ? generateShareImage(context, options, _post) : null;
  }

  void _scheduleGeneratedImageUpdate() {
    _generatedImageFuture = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(_updateGeneratedImageFuture);
    });
  }

  void _updateOption(void Function(AdvancedShareSheetOptions options) update, {required bool regeneratesImage}) {
    setState(() {
      update(_options);
      if (regeneratesImage) _scheduleGeneratedImageUpdate();
    });
  }

  Future<void> _share(Uint8List? generatedImage) async {
    await const UserPreferencesStore().setSetting(LocalSettings.advancedShareOptions, jsonEncode(_options.toJson()));

    final text = advancedShareText(_options, _post);

    if (advancedShareCanShareImage(_options, _post)) {
      if (advancedShareIsImageCustomized(_options, _post)) {
        if (generatedImage == null) return;

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(generatedImage, mimeType: 'image/jpeg')],
            text: text,
            sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        );
      } else {
        final thumbnailUrl = advancedShareThumbnailUrl(_post);
        if (thumbnailUrl == null) return;

        setState(() => _isDownloading = true);

        try {
          final file = await DefaultCacheManager().getSingleFile(thumbnailUrl);
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              text: text,
              sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
            ),
          );
        } finally {
          if (mounted) setState(() => _isDownloading = false);
        }
      }
    } else if (text != null) {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _generatedImageFuture,
      builder: (context, snapshot) {
        final isGeneratingImage = advancedShareIsImageCustomized(_options, _post) && snapshot.connectionState != ConnectionState.done;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 30.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AdvancedSharePreview(
                    post: _post,
                    options: _options,
                    generatedImage: snapshot.data,
                    isGeneratingImage: isGeneratingImage,
                  ),
                  const SizedBox(height: 20.0),
                  _AdvancedShareOptionsSection(
                    post: _post,
                    options: _options,
                    onIncludeTitleChanged: (value) => _updateOption((options) => options.includeTitle = value, regeneratesImage: true),
                    onIncludeImageChanged: (value) => _updateOption((options) => options.includeImage = value, regeneratesImage: true),
                    onIncludeTextChanged: (value) => _updateOption((options) => options.includeText = value, regeneratesImage: true),
                    onIncludeCommunityChanged: (value) => _updateOption((options) => options.includeCommnity = value, regeneratesImage: true),
                    onIncludePostLinkChanged: (value) => _updateOption((options) => options.includePostLink = value, regeneratesImage: false),
                    onIncludeExternalLinkChanged: (value) => _updateOption((options) => options.includeExternalLink = value, regeneratesImage: false),
                  ),
                  const SizedBox(height: 12.0),
                  _AdvancedShareActions(
                    canShare: advancedShareCanShare(_options, _post) && !isGeneratingImage,
                    isDownloading: _isDownloading,
                    onShare: () => _share(snapshot.data),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdvancedSharePreview extends StatelessWidget {
  const _AdvancedSharePreview({
    required this.post,
    required this.options,
    required this.generatedImage,
    required this.isGeneratingImage,
  });

  /// The post to share.
  final ThunderPost post;

  /// The options for the share sheet.
  final AdvancedShareSheetOptions options;

  /// The generated image.
  final Uint8List? generatedImage;

  /// Whether the image is being generated.
  final bool isGeneratingImage;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    final thumbnailUrl = advancedShareThumbnailUrl(post);
    final externalLink = advancedShareExternalLink(post);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AdvancedShareSectionTitle(title: l10n.preview),
        if (!advancedShareCanShare(options, post))
          Text(
            l10n.nothingToShare,
            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        if (!advancedShareIsImageCustomized(options, post) && options.includeImage && thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            clipBehavior: Clip.hardEdge,
            child: ShareImagePreview(
              url: thumbnailUrl,
              isExpandable: true,
              isComment: true,
              showFullHeightImages: true,
              altText: advancedSharePrimaryMedia(post)?.altText,
            ),
          ),
        if (advancedShareIsImageCustomized(options, post))
          generatedImage != null && !isGeneratingImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  clipBehavior: Clip.hardEdge,
                  child: ShareImagePreview(
                    bytes: generatedImage!,
                    isExpandable: true,
                    isComment: true,
                    showFullHeightImages: true,
                  ),
                )
              : const CircularProgressIndicator(),
        if (options.includePostLink)
          Text(
            post.apId,
            style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline),
          ),
        if (options.includeExternalLink && externalLink != null)
          Text(
            externalLink,
            style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline),
          ),
      ],
    );
  }
}

class _AdvancedShareOptionsSection extends StatelessWidget {
  const _AdvancedShareOptionsSection({
    required this.post,
    required this.options,
    required this.onIncludeTitleChanged,
    required this.onIncludeImageChanged,
    required this.onIncludeTextChanged,
    required this.onIncludeCommunityChanged,
    required this.onIncludePostLinkChanged,
    required this.onIncludeExternalLinkChanged,
  });

  /// The post to share.
  final ThunderPost post;

  /// The options for the share sheet.
  final AdvancedShareSheetOptions options;

  /// The callback to call when the include title option changes.
  final ValueChanged<bool> onIncludeTitleChanged;

  /// The callback to call when the include image option changes.
  final ValueChanged<bool> onIncludeImageChanged;

  /// The callback to call when the include text option changes.
  final ValueChanged<bool> onIncludeTextChanged;

  /// The callback to call when the include community option changes.
  final ValueChanged<bool> onIncludeCommunityChanged;

  /// The callback to call when the include post link option changes.
  final ValueChanged<bool> onIncludePostLinkChanged;

  /// The callback to call when the include external link option changes.
  final ValueChanged<bool> onIncludeExternalLinkChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AdvancedShareSectionTitle(title: l10n.image),
        ThunderToggleOption(
          title: l10n.includeTitle,
          iconEnabled: Icons.title_rounded,
          iconDisabled: Icons.title_rounded,
          value: options.includeTitle,
          onChanged: onIncludeTitleChanged,
        ),
        if (advancedShareHasImage(post))
          ThunderToggleOption(
            title: l10n.includeImage,
            iconEnabled: Icons.image_rounded,
            iconDisabled: Icons.image_rounded,
            value: options.includeImage,
            onChanged: onIncludeImageChanged,
          ),
        if (advancedShareHasText(post))
          ThunderToggleOption(
            title: l10n.includeText,
            iconEnabled: Icons.comment_rounded,
            iconDisabled: Icons.comment_rounded,
            value: options.includeText,
            onChanged: onIncludeTextChanged,
          ),
        ThunderToggleOption(
          title: l10n.includeCommunity,
          iconEnabled: Icons.people_rounded,
          iconDisabled: Icons.people_rounded,
          value: options.includeCommnity,
          onChanged: onIncludeCommunityChanged,
        ),
        const SizedBox(height: 20.0),
        _AdvancedShareSectionTitle(title: l10n.link(0)),
        ThunderToggleOption(
          title: l10n.includePostLink,
          iconEnabled: Icons.link_rounded,
          iconDisabled: Icons.link_rounded,
          value: options.includePostLink,
          onChanged: onIncludePostLinkChanged,
        ),
        if (advancedShareHasExternalLink(post))
          ThunderToggleOption(
            title: l10n.includeExternalLink,
            iconEnabled: Icons.link_rounded,
            iconDisabled: Icons.link_rounded,
            value: options.includeExternalLink,
            onChanged: onIncludeExternalLinkChanged,
          ),
      ],
    );
  }
}

class _AdvancedShareSectionTitle extends StatelessWidget {
  const _AdvancedShareSectionTitle({required this.title});

  /// The title of the section.
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
      ),
    );
  }
}

class _AdvancedShareActions extends StatelessWidget {
  const _AdvancedShareActions({
    required this.canShare,
    required this.isDownloading,
    required this.onShare,
  });

  /// Whether the post can be shared.
  final bool canShare;

  /// Whether the image is being downloaded.
  final bool isDownloading;

  /// The callback to call when the post is shared.
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: 5.0),
        FilledButton(
          onPressed: canShare ? onShare : null,
          child: Stack(
            children: [
              if (isDownloading)
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              Text(
                l10n.share,
                style: TextStyle(color: isDownloading ? Colors.transparent : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
