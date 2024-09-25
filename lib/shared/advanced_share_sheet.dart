import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/image_preview.dart';

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

  static fromJson(Map<String, dynamic> json) => AdvancedShareSheetOptions(
        includePostLink: json['includePostLink'],
        includeExternalLink: json['includeExternalLink'],
        includeImage: json['includeImage'],
        includeText: json['includeText'],
        includeTitle: json['includeTitle'],
        includeCommnity: json['includeCommnity'],
      );
}

bool _hasImage(PostViewMedia postViewMedia) => postViewMedia.media.isNotEmpty && postViewMedia.media.first.thumbnailUrl != null;

bool _hasText(PostViewMedia postViewMedia) => postViewMedia.postView.post.body?.isNotEmpty == true;

bool _hasExternalLink(PostViewMedia postViewMedia) => postViewMedia.media.first.mediaType != MediaType.text;

bool _canShare(AdvancedShareSheetOptions options, PostViewMedia postViewMedia) {
  return options.includePostLink || (options.includeExternalLink && _hasExternalLink(postViewMedia)) || _canShareImage(options, postViewMedia);
}

bool _canShareImage(AdvancedShareSheetOptions options, PostViewMedia postViewMedia) {
  return (options.includeImage && _hasImage(postViewMedia)) || _isImageCustomized(options, postViewMedia);
}

bool _isImageCustomized(AdvancedShareSheetOptions options, PostViewMedia postViewMedia) {
  return options.includeTitle ||
      options.includeCommnity ||
      (options.includeText && _hasText(postViewMedia)) ||
      (options.includeImage && _hasImage(postViewMedia) && (options.includeTitle || options.includeCommnity));
}

Future<Uint8List> generateShareImage(BuildContext context, AdvancedShareSheetOptions options, PostViewMedia postViewMedia) async {
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
                  postViewMedia.postView.post.name,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (options.includeImage && _hasImage(postViewMedia))
              Image.network(
                postViewMedia.media.first.thumbnailUrl!,
              ),
            if (options.includeText && postViewMedia.postView.post.body?.isNotEmpty == true) ...[
              if (_hasImage(postViewMedia)) const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    postViewMedia.postView.post.body!,
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
                  postViewMedia.postView.community.actorId,
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

void showAdvancedShareSheet(BuildContext context, PostViewMedia postViewMedia) async {
  final ThemeData theme = Theme.of(context);
  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

  String? optionsJson = prefs.getString(LocalSettings.advancedShareOptions.name);
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
              future: generateShareImage(context, options, postViewMedia),
              builder: (context, snapshot) {
                if (!_isImageCustomized(options, postViewMedia) || snapshot.connectionState == ConnectionState.done) {
                  isGeneratingImage = false;
                }

                return AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14, bottom: 30),
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
                        if (!_canShare(options, postViewMedia))
                          Text(
                            AppLocalizations.of(context)!.nothingToShare,
                            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        if (!_isImageCustomized(options, postViewMedia) && options.includeImage && _hasImage(postViewMedia))
                          ImagePreview(
                            url: postViewMedia.media.first.thumbnailUrl.toString(),
                            isExpandable: true,
                            isComment: true,
                            showFullHeightImages: true,
                            altText: postViewMedia.media.first.altText,
                          ),
                        if (_isImageCustomized(options, postViewMedia))
                          snapshot.hasData && !isGeneratingImage
                              ? ImagePreview(
                                  bytes: snapshot.data!,
                                  isExpandable: true,
                                  isComment: true,
                                  showFullHeightImages: true,
                                )
                              : const CircularProgressIndicator(),
                        if (options.includePostLink)
                          Text(
                            postViewMedia.postView.post.apId,
                            style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline),
                          ),
                        if (options.includeExternalLink && _hasExternalLink(postViewMedia))
                          Text(
                            postViewMedia.media.first.originalUrl!,
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
                        ToggleOption(
                          description: AppLocalizations.of(context)!.includeTitle,
                          iconEnabled: Icons.title_rounded,
                          iconDisabled: Icons.title_rounded,
                          value: options.includeTitle,
                          onToggle: (_) => setState(() {
                            isGeneratingImage = true;
                            options.includeTitle = !options.includeTitle;
                          }),
                          highlightKey: null,
                          setting: null,
                          highlightedSetting: null,
                        ),
                        if (_hasImage(postViewMedia))
                          ToggleOption(
                            description: AppLocalizations.of(context)!.includeImage,
                            iconEnabled: Icons.image_rounded,
                            iconDisabled: Icons.image_rounded,
                            value: options.includeImage,
                            onToggle: (_) => setState(() {
                              isGeneratingImage = true;
                              options.includeImage = !options.includeImage;
                            }),
                            highlightKey: null,
                            setting: null,
                            highlightedSetting: null,
                          ),
                        if (_hasText(postViewMedia))
                          ToggleOption(
                            description: AppLocalizations.of(context)!.includeText,
                            iconEnabled: Icons.comment_rounded,
                            iconDisabled: Icons.comment_rounded,
                            value: options.includeText,
                            onToggle: (_) => setState(() {
                              isGeneratingImage = true;
                              options.includeText = !options.includeText;
                            }),
                            highlightKey: null,
                            setting: null,
                            highlightedSetting: null,
                          ),
                        ToggleOption(
                          description: AppLocalizations.of(context)!.includeCommunity,
                          iconEnabled: Icons.people_rounded,
                          iconDisabled: Icons.people_rounded,
                          value: options.includeCommnity,
                          onToggle: (_) => setState(() {
                            isGeneratingImage = true;
                            options.includeCommnity = !options.includeCommnity;
                          }),
                          highlightKey: null,
                          setting: null,
                          highlightedSetting: null,
                        ),
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
                        ToggleOption(
                          description: AppLocalizations.of(context)!.includePostLink,
                          iconEnabled: Icons.link_rounded,
                          iconDisabled: Icons.link_rounded,
                          value: options.includePostLink,
                          onToggle: (_) => setState(() => options.includePostLink = !options.includePostLink),
                          highlightKey: null,
                          setting: null,
                          highlightedSetting: null,
                        ),
                        if (_hasExternalLink(postViewMedia))
                          ToggleOption(
                            description: AppLocalizations.of(context)!.includeExternalLink,
                            iconEnabled: Icons.link_rounded,
                            iconDisabled: Icons.link_rounded,
                            value: options.includeExternalLink,
                            onToggle: (_) => setState(() => options.includeExternalLink = !options.includeExternalLink),
                            highlightKey: null,
                            setting: null,
                            highlightedSetting: null,
                          ),
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
                              onPressed: _canShare(options, postViewMedia) && !isGeneratingImage
                                  ? () async {
                                      // Save the share settings
                                      prefs.setString(LocalSettings.advancedShareOptions.name, jsonEncode(options.toJson()));

                                      // Generate the text to share
                                      String? text;
                                      if (options.includePostLink) {
                                        text = postViewMedia.postView.post.apId;
                                      }
                                      if (options.includeExternalLink && _hasExternalLink(postViewMedia)) {
                                        text == null ? text = postViewMedia.media.first.originalUrl! : text = '$text\n${postViewMedia.media.first.originalUrl!}';
                                      }

                                      // Do the actual sharing
                                      if (_canShareImage(options, postViewMedia)) {
                                        if (_isImageCustomized(options, postViewMedia)) {
                                          Share.shareXFiles([XFile.fromData(snapshot.data!, mimeType: 'image/jpeg')], text: text);
                                        } else {
                                          setState(() => isDownloading = true);
                                          final File file = await DefaultCacheManager().getSingleFile(postViewMedia.media.first.thumbnailUrl!);
                                          setState(() => isDownloading = false);
                                          Share.shareXFiles([XFile(file.path)], text: text);
                                        }
                                      } else if (text != null) {
                                        Share.share(text);
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
                );
              },
            );
          },
        );
      },
    );
  }
}
