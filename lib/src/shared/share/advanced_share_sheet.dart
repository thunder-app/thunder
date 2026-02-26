import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/shared/share/share_image_preview.dart';
import 'package:thunder/packages/ui/ui.dart';

class AdvancedShareSheetOptions {
  AdvancedShareSheetOptions({
    this.includePostLink = true,
    this.includeExternalLink = false,
    this.includeImage = true,
    this.includeText = false,
    this.includeTitle = false,
    this.includeCommnity = false,
  });

  bool includePostLink;
  bool includeExternalLink;
  bool includeImage;
  bool includeText;
  bool includeTitle;
  bool includeCommnity;

  Map<String, dynamic> toJson() => {
        'includePostLink': includePostLink,
        'includeExternalLink': includeExternalLink,
        'includeImage': includeImage,
        'includeText': includeText,
        'includeTitle': includeTitle,
        'includeCommnity': includeCommnity,
      };

  static AdvancedShareSheetOptions fromJson(Map<String, dynamic> json) => AdvancedShareSheetOptions(
        includePostLink: json['includePostLink'],
        includeExternalLink: json['includeExternalLink'],
        includeImage: json['includeImage'],
        includeText: json['includeText'],
        includeTitle: json['includeTitle'],
        includeCommnity: json['includeCommnity'],
      );
}

bool _hasImage(ThunderPost post) => post.media.isNotEmpty && post.media.first.thumbnailUrl != null;

bool _hasText(ThunderPost post) => post.body?.isNotEmpty == true;

bool _hasExternalLink(ThunderPost post) => post.media.first.mediaType != MediaType.text;

bool _canShare(AdvancedShareSheetOptions options, ThunderPost post) {
  return options.includePostLink || (options.includeExternalLink && _hasExternalLink(post)) || _canShareImage(options, post);
}

bool _canShareImage(AdvancedShareSheetOptions options, ThunderPost post) {
  return (options.includeImage && _hasImage(post)) || _isImageCustomized(options, post);
}

bool _isImageCustomized(AdvancedShareSheetOptions options, ThunderPost post) {
  return options.includeTitle || options.includeCommnity || (options.includeText && _hasText(post)) || (options.includeImage && _hasImage(post) && (options.includeTitle || options.includeCommnity));
}

Future<Uint8List> generateShareImage(BuildContext context, AdvancedShareSheetOptions options, ThunderPost post) async {
  Uint8List result = Uint8List(0);
  ScreenshotController screenshotController = ScreenshotController();

  // This little trick allows the images we generate to be taller than the viewport
  // (which is otherwise the default size in the screenshot package) without having a render overflow.
  final FlutterView? view = View.maybeOf(context);
  final Size? viewSize = view == null ? null : view.physicalSize / view.devicePixelRatio;
  final Size? targetSize = viewSize == null ? null : Size(viewSize.width, 999);

  result = await screenshotController.captureFromWidget(
    targetSize: targetSize,
    pixelRatio: 4,
    Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (options.includeTitle) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  post.name,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (options.includeImage && _hasImage(post))
              Image.network(
                post.media.first.thumbnailUrl!,
              ),
            if (options.includeText && post.body?.isNotEmpty == true) ...[
              if (_hasImage(post)) const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    post.body!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
            if (options.includeCommnity) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  post.community!.actorId,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  return result;
}

void showAdvancedShareSheet(BuildContext context, ThunderPost post) async {
  final ThemeData theme = Theme.of(context);

  String? optionsJson = UserPreferences.getLocalSetting(LocalSettings.advancedShareOptions);
  AdvancedShareSheetOptions options = optionsJson != null ? AdvancedShareSheetOptions.fromJson(jsonDecode(optionsJson)) : AdvancedShareSheetOptions();

  bool isDownloading = false;
  bool isGeneratingImage = true;

  if (context.mounted) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder(
              future: generateShareImage(context, options, post),
              builder: (context, snapshot) {
                if (!_isImageCustomized(options, post) || snapshot.connectionState == ConnectionState.done) {
                  isGeneratingImage = false;
                }

                return AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14, bottom: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                AppLocalizations.of(context)!.preview,
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                          ),
                          if (!_canShare(options, post))
                            Text(
                              AppLocalizations.of(context)!.nothingToShare,
                              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          if (!_isImageCustomized(options, post) && options.includeImage && _hasImage(post))
                            ShareImagePreview(
                              url: post.media.first.thumbnailUrl.toString(),
                              isExpandable: true,
                              isComment: true,
                              showFullHeightImages: true,
                              altText: post.media.first.altText,
                            ),
                          if (_isImageCustomized(options, post))
                            snapshot.hasData && !isGeneratingImage
                                ? ShareImagePreview(
                                    bytes: snapshot.data!,
                                    isExpandable: true,
                                    isComment: true,
                                    showFullHeightImages: true,
                                  )
                                : const CircularProgressIndicator(),
                          if (options.includePostLink)
                            Text(
                              post.apId,
                              style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline),
                            ),
                          if (options.includeExternalLink && _hasExternalLink(post))
                            Text(
                              post.media.first.originalUrl!,
                              style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline),
                            ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                AppLocalizations.of(context)!.image,
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                          ),
                          ThunderToggleOption(
                              title: AppLocalizations.of(context)!.includeTitle,
                              iconEnabled: Icons.title_rounded,
                              iconDisabled: Icons.title_rounded,
                              value: options.includeTitle,
                              onChanged: (_) => setState(() {
                                    isGeneratingImage = true;
                                    options.includeTitle = !options.includeTitle;
                                  }),
                              highlightKey: null,
                              highlighted: null == null),
                          if (_hasImage(post))
                            ThunderToggleOption(
                                title: AppLocalizations.of(context)!.includeImage,
                                iconEnabled: Icons.image_rounded,
                                iconDisabled: Icons.image_rounded,
                                value: options.includeImage,
                                onChanged: (_) => setState(() {
                                      isGeneratingImage = true;
                                      options.includeImage = !options.includeImage;
                                    }),
                                highlightKey: null,
                                highlighted: null == null),
                          if (_hasText(post))
                            ThunderToggleOption(
                                title: AppLocalizations.of(context)!.includeText,
                                iconEnabled: Icons.comment_rounded,
                                iconDisabled: Icons.comment_rounded,
                                value: options.includeText,
                                onChanged: (_) => setState(() {
                                      isGeneratingImage = true;
                                      options.includeText = !options.includeText;
                                    }),
                                highlightKey: null,
                                highlighted: null == null),
                          ThunderToggleOption(
                              title: AppLocalizations.of(context)!.includeCommunity,
                              iconEnabled: Icons.people_rounded,
                              iconDisabled: Icons.people_rounded,
                              value: options.includeCommnity,
                              onChanged: (_) => setState(() {
                                    isGeneratingImage = true;
                                    options.includeCommnity = !options.includeCommnity;
                                  }),
                              highlightKey: null,
                              highlighted: null == null),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                AppLocalizations.of(context)!.link(0),
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                          ),
                          ThunderToggleOption(
                              title: AppLocalizations.of(context)!.includePostLink,
                              iconEnabled: Icons.link_rounded,
                              iconDisabled: Icons.link_rounded,
                              value: options.includePostLink,
                              onChanged: (_) => setState(() => options.includePostLink = !options.includePostLink),
                              highlightKey: null,
                              highlighted: null == null),
                          if (_hasExternalLink(post))
                            ThunderToggleOption(
                                title: AppLocalizations.of(context)!.includeExternalLink,
                                iconEnabled: Icons.link_rounded,
                                iconDisabled: Icons.link_rounded,
                                value: options.includeExternalLink,
                                onChanged: (_) => setState(() => options.includeExternalLink = !options.includeExternalLink),
                                highlightKey: null,
                                highlighted: null == null),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              const SizedBox(width: 5),
                              FilledButton(
                                onPressed: _canShare(options, post) && !isGeneratingImage
                                    ? () async {
                                        // Save the share settings
                                        UserPreferences.setSetting(LocalSettings.advancedShareOptions, jsonEncode(options.toJson()));

                                        // Generate the text to share
                                        String? text;
                                        if (options.includePostLink) {
                                          text = post.apId;
                                        }
                                        if (options.includeExternalLink && _hasExternalLink(post)) {
                                          text == null ? text = post.media.first.originalUrl! : text = '$text\n${post.media.first.originalUrl!}';
                                        }

                                        // Do the actual sharing
                                        if (_canShareImage(options, post)) {
                                          if (_isImageCustomized(options, post)) {
                                            SharePlus.instance.share(ShareParams(
                                              files: [XFile.fromData(snapshot.data!, mimeType: 'image/jpeg')],
                                              text: text,
                                              sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                                            ));
                                          } else {
                                            setState(() => isDownloading = true);
                                            final File file = await DefaultCacheManager().getSingleFile(post.media.first.thumbnailUrl!);
                                            setState(() => isDownloading = false);
                                            SharePlus.instance.share(ShareParams(
                                              files: [XFile(file.path)],
                                              text: text,
                                              sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                                            ));
                                          }
                                        } else if (text != null) {
                                          SharePlus.instance.share(ShareParams(
                                            text: text,
                                            sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                                          ));
                                        }

                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    : null,
                                child: Stack(
                                  children: [
                                    if (isDownloading)
                                      const Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Text(
                                      AppLocalizations.of(context)!.share,
                                      style: TextStyle(color: isDownloading ? Colors.transparent : null),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
